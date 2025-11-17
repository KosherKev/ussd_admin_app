import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/models/org_summary.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';
import '../../app/router/routes.dart';

class OrgSummaryPage extends StatefulWidget {
  final String orgId;
  const OrgSummaryPage({super.key, required this.orgId});

  @override
  State<OrgSummaryPage> createState() => _OrgSummaryPageState();
}

class _OrgSummaryPageState extends State<OrgSummaryPage> {
  final _reports = ReportsService();

  bool _loading = true;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;
  List<OrgSummaryStats> _stats = [];
  String _role = 'org_admin';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _role = await RoleHelpers.getRole();
      final stats = await _reports.getOrgSummary(widget.orgId, startDate: _startDate, endDate: _endDate);
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateFormatters.startOfMonth,
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
      initialDate: _endDate ?? DateFormatters.endOfMonth,
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
    final totalCount = _stats.fold<int>(0, (sum, s) => sum + s.count);
    final totalAmount = _stats.fold<double>(0.0, (sum, s) => sum + s.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Org Summary'),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickStartDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null ? 'Start Date' : DateFormatters.formatDate(_startDate)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickEndDate,
                        icon: const Icon(Icons.event),
                        label: Text(_endDate == null ? 'End Date' : DateFormatters.formatDate(_endDate)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters'),
                  ),
                ),
              ],
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
                            ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          StatsCard(
                            label: 'Total Transactions',
                            value: CurrencyFormatters.formatNumber(totalCount),
                            icon: Icons.receipt_long,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          StatsCard(
                            label: 'Total Amount',
                            value: CurrencyFormatters.formatCompactGHS(totalAmount),
                            icon: Icons.account_balance_wallet,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Payment Type Breakdown',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: _stats.isEmpty
                                  ? [
                                      Row(
                                        children: [
                                          const Icon(Icons.inbox_outlined, color: AppColors.textTertiary),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'No data for selected range',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      )
                                    ]
                                  : _stats.map((s) {
                                      return Padding(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                s.paymentTypeName,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatters.formatNumber(s.count),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Text(
                                              CurrencyFormatters.formatCompactGHS(s.totalAmount),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                            ),
                          ),
                        ],
                      ),
          ),
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
}