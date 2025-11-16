import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
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

  void _showSignOutDialog() async {
    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDanger: true,
    );

    if (confirmed && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final tabs = [
      const DashboardPage(),
      const OrgListPage(),
      _PlaceholderPage(
        title: 'Payments',
        icon: Icons.payments,
        description: 'Manage payment types and transactions',
        role: _role,
      ),
      _PlaceholderPage(
        title: 'Reports',
        icon: Icons.bar_chart,
        description: 'View transaction reports and analytics',
        role: _role,
      ),
      if (_role == 'super_admin')
        _PlaceholderPage(
          title: 'Admin',
          icon: Icons.admin_panel_settings,
          description: 'Manage payouts and system settings',
          role: _role,
        ),
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

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String role;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.description,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: title,
            warm: true,
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showSignOutDialog(context),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Center(
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppGradients.warm(),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Coming Soon',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.primaryAmber,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.construction,
                            size: 16,
                            color: AppColors.primaryAmber,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Under Development',
                            style: TextStyle(
                              color: AppColors.primaryAmber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) async {
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
}
