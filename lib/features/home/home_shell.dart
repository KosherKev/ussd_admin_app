import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/org_service.dart';
import '../../shared/models/organization.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../dashboard/dashboard_page.dart';
import '../orgs/org_list_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  String _role = 'org_admin';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleHelpers.getRole();
    if (mounted) {
      setState(() {
        _role = role;
        _loading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final tabs = [
      const DashboardPage(),
      const OrgListPage(),
      _PaymentsPage(role: _role),
      _ReportsPage(role: _role),
      if (_role == 'super_admin') _AdminPage(role: _role),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: tabs[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
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

class _PaymentsPage extends StatefulWidget {
  final String role;
  const _PaymentsPage({required this.role});

  @override
  State<_PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<_PaymentsPage> {
  final _orgService = OrgService();
  bool _loading = true;
  String? _error;
  List<Organization> _orgs = [];
  Organization? _selectedOrg;
  Organization? _lastUsedOrg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_org_id');
      final lastName = prefs.getString('last_org_name');
      if (lastId != null && lastName != null) {
        _lastUsedOrg = Organization(id: lastId, name: lastName);
      }

      final result = await _orgService.list(page: 1, limit: 100);
      _orgs = result.items;

      if (_orgs.isNotEmpty && _selectedOrg == null) {
        // Default select last used if exists, else first
        _selectedOrg = _orgs.firstWhere(
          (o) => o.id == _lastUsedOrg?.id,
          orElse: () => _orgs.first,
        );
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandlers.getErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _onSelectOrg(Organization? org) async {
    setState(() => _selectedOrg = org);
    if (org != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_org_id', org.id);
      await prefs.setString('last_org_name', org.name);
      _lastUsedOrg = org;
    }
  }

  void _openPaymentTypes() {
    if (_selectedOrg == null) {
      DialogHelpers.showInfo(context, 'Please select an organization');
      return;
    }
    Navigator.pushNamed(context, Routes.paymentTypes, arguments: _selectedOrg!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: 'Payments',
            warm: true,
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showSignOutDialog(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
                            ElevatedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Organization',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedOrg?.id,
                                  items: _orgs
                                      .map((o) => DropdownMenuItem<String>(
                                            value: o.id,
                                            child: Text(o.name),
                                          ))
                                      .toList(),
                                  onChanged: (id) {
                                    if (id == null) return;
                                    _onSelectOrg(_orgs.firstWhere((o) => o.id == id));
                                  },
                                  decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined), labelText: 'Organization'),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openPaymentTypes,
                                    icon: const Icon(Icons.payment),
                                    label: const Text('Manage Payment Types'),
                                  ),
                                ),
                                if (_lastUsedOrg != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Last used: ${_lastUsedOrg!.name}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ActionCard(
                            icon: Icons.receipt_long,
                            title: 'Transactions',
                            description: 'View recent payments and details',
                            onTap: () => Navigator.pushNamed(context, Routes.reportsTransactions),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReportsPage extends StatefulWidget {
  final String role;
  const _ReportsPage({required this.role});

  @override
  State<_ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<_ReportsPage> {
  final _orgService = OrgService();
  bool _loading = true;
  String? _error;
  List<Organization> _orgs = [];
  Organization? _selectedOrg;
  Organization? _lastUsedOrg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_org_id');
      final lastName = prefs.getString('last_org_name');
      if (lastId != null && lastName != null) {
        _lastUsedOrg = Organization(id: lastId, name: lastName);
      }

      final result = await _orgService.list(page: 1, limit: 100);
      _orgs = result.items;

      if (_orgs.isNotEmpty && _selectedOrg == null) {
        _selectedOrg = _orgs.firstWhere(
          (o) => o.id == _lastUsedOrg?.id,
          orElse: () => _orgs.first,
        );
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandlers.getErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _onSelectOrg(Organization? org) async {
    setState(() => _selectedOrg = org);
    if (org != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_org_id', org.id);
      await prefs.setString('last_org_name', org.name);
      _lastUsedOrg = org;
    }
  }

  void _openOrgSummary() {
    if (_selectedOrg == null) {
      DialogHelpers.showInfo(context, 'Please select an organization');
      return;
    }
    Navigator.pushNamed(context, Routes.reportsOrgSummary, arguments: _selectedOrg!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: 'Reports',
            warm: true,
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showSignOutDialog(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
                            ElevatedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organization Summary',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedOrg?.id,
                                  items: _orgs
                                      .map((o) => DropdownMenuItem<String>(
                                            value: o.id,
                                            child: Text(o.name),
                                          ))
                                      .toList(),
                                  onChanged: (id) {
                                    if (id == null) return;
                                    _onSelectOrg(_orgs.firstWhere((o) => o.id == id));
                                  },
                                  decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined), labelText: 'Organization'),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openOrgSummary,
                                    icon: const Icon(Icons.bar_chart),
                                    label: const Text('View Org Summary'),
                                  ),
                                ),
                                if (_lastUsedOrg != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Last used: ${_lastUsedOrg!.name}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ActionCard(
                            icon: Icons.receipt_long,
                            title: 'Transactions',
                            description: 'Filter and browse transactions',
                            onTap: () => Navigator.pushNamed(context, Routes.reportsTransactions),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (widget.role == 'super_admin')
                            _ActionCard(
                              icon: Icons.timeline,
                              title: 'USSD Sessions',
                              description: 'Super admin analytics',
                              onTap: () => Navigator.pushNamed(context, Routes.reportsUssdSessions),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _AdminPage extends StatelessWidget {
  final String role;
  const _AdminPage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: 'Admin',
            warm: true,
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showSignOutDialog(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView(
              children: [
                _ActionCard(
                  icon: Icons.payments,
                  title: 'Pending Payouts',
                  description: 'Process outstanding payouts',
                  onTap: () => Navigator.pushNamed(context, Routes.payoutsPending),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ActionCard(
                  icon: Icons.schedule,
                  title: 'Schedule Payouts',
                  description: 'Create payout schedules',
                  onTap: () => Navigator.pushNamed(context, Routes.payoutsSchedule),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.warm(),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showSignOutDialog(BuildContext context) async {
  final confirmed = await DialogHelpers.showConfirmDialog(
    context,
    title: 'Sign Out',
    message: 'Are you sure you want to sign out?',
    confirmText: 'Sign Out',
    isDanger: true,
  );

  if (confirmed && context.mounted) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }
}
