import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/paged.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/services/org_service.dart';
import '../../shared/models/organization.dart';
import '../../app/router/routes.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _reports = ReportsService();
  final _orgService = OrgService();

  bool _loading = true;
  String? _error;
  String _role = 'org_admin';

  List<Organization> _orgs = [];
  Organization? _selectedOrg;
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;

  Paged<Transaction>? _paged;

  final _statuses = const [
    'completed',
    'pending',
    'failed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _role = await RoleHelpers.getRole();
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_org_id');
      final lastName = prefs.getString('last_org_name');
      Organization? last;
      if (lastId != null && lastName != null) {
        last = Organization(id: lastId, name: lastName);
      }
      final orgsResult = await _orgService.list(page: 1, limit: 100);
      _orgs = orgsResult.items;
      if (_orgs.isNotEmpty) {
        _selectedOrg = _orgs.firstWhere(
          (o) => o.id == last?.id,
          orElse: () => _orgs.first,
        );
      }
      await _fetch(page: 1);
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _fetch({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _reports.getTransactions(
        organizationId: _selectedOrg?.id,
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        page: page,
        limit: 10,
      );
      setState(() {
        _paged = res;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _onSelectOrg(Organization? org) async {
    setState(() => _selectedOrg = org);
    if (org != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_org_id', org.id);
      await prefs.setString('last_org_name', org.name);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAmber,
              onPrimary: Colors.black,
              surface: AppColors.surfaceLow,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAmber,
              onPrimary: Colors.black,
              surface: AppColors.surfaceLow,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _paged == null || _paged!.limit <= 0
        ? 1
        : ((_paged!.total + _paged!.limit - 1) ~/ _paged!.limit);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(
            title: 'Transactions',
            warm: true,
            trailing: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => _fetch(page: _paged?.page ?? 1),
                  ),
          ),

          const SizedBox(height: AppSpacing.md),

          GlassCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 560;
                final orgDropdown = DropdownButtonFormField<String>(
                  initialValue: _selectedOrg?.id,
                  items: _orgs
                      .map((o) => DropdownMenuItem<String>(
                            value: o.id,
                            child: Text(o.name, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    _onSelectOrg(_orgs.firstWhere((o) => o.id == id));
                  },
                  decoration: const InputDecoration(
                    labelText: 'Organization',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                );
                final statusDropdown = DropdownButtonFormField<String?>(
                  initialValue: _status,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Statuses')),
                    ..._statuses.map((s) => DropdownMenuItem<String?>(value: s, child: Text(StatusHelpers.formatStatus(s)))),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                );
                final startBtn = OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_startDate == null ? 'Start Date' : DateFormatters.formatDate(_startDate)),
                );
                final endBtn = OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: const Icon(Icons.event),
                  label: Text(_endDate == null ? 'End Date' : DateFormatters.formatDate(_endDate)),
                );

                return Column(
                  children: [
                    if (twoCol)
                      Row(children: [Expanded(child: orgDropdown), const SizedBox(width: AppSpacing.sm), Expanded(child: statusDropdown)])
                    else
                      Column(children: [orgDropdown, const SizedBox(height: AppSpacing.sm), statusDropdown]),
                    const SizedBox(height: AppSpacing.sm),
                    if (twoCol)
                      Row(children: [Expanded(child: startBtn), const SizedBox(width: AppSpacing.sm), Expanded(child: endBtn)])
                    else
                      Column(children: [startBtn, const SizedBox(height: AppSpacing.sm), endBtn]),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _fetch(page: 1),
                        icon: const Icon(Icons.search),
                        label: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(onPressed: () => _fetch(page: 1), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _fetch(page: _paged?.page ?? 1),
                        child: (_paged?.items.isEmpty ?? true)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textTertiary),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'No Transactions',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: _paged!.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) => _buildTransactionCard(_paged!.items[i]),
                              ),
                      ),
          ),

          if ((_paged?.items.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${_paged!.page} of $pages (${_paged!.total} total)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loading || (_paged!.page <= 1) ? null : () => _fetch(page: _paged!.page - 1),
                        icon: const Icon(Icons.chevron_left),
                        color: AppColors.primaryAmber,
                      ),
                      IconButton(
                        onPressed: _loading || (_paged!.page >= pages) ? null : () => _fetch(page: _paged!.page + 1),
                        icon: const Icon(Icons.chevron_right),
                        color: AppColors.primaryAmber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) => Navigator.pushReplacementNamed(context, Routes.home, arguments: i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceLow,
        selectedItemColor: AppColors.primaryAmber,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Organizations',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          if (_role == 'super_admin')
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.organizationName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        transaction.paymentType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusHelpers.buildStatusBadge(transaction.status),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatters.formatGHS(transaction.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatters.formatDateTime(transaction.initiatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      transaction.transactionRef,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}