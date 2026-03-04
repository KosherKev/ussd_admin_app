import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../dashboard/dashboard_page.dart';
import '../payments/payment_types_list_page.dart';
import '../payouts/payouts_page.dart';
import '../reports/transactions_page.dart';
import '../settings/profile_page.dart';
import '../developer/developer_dashboard_page.dart';
import '../developer/developer_transactions_page.dart';
import '../developer/webhooks_list_page.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int    _index = 0;
  String _orgId = '';
  bool   _devMode = false;
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check dev_mode whenever the app comes back to foreground.
  /// This handles the edge case where the session pref changes without
  /// a full route replacement (e.g., background/foreground cycle).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSession();
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _orgId   = prefs.getString('org_id') ?? '';
        _devMode = prefs.getBool('dev_mode') ?? false;
        _loading = false;
      });
    }
  }

  bool get _isDeveloper => _devMode;

  // ---------- Org Admin tabs ----------
  List<Widget> get _orgAdminTabs => [
    DashboardPage(orgId: _orgId),
    PaymentTypesListPage(orgId: _orgId, embedded: true),
    const TransactionsPage(),
    const PayoutsPage(),
    const ProfilePage(),
  ];

  List<NavigationDestination> get _orgAdminDests => const [
    NavigationDestination(
      icon:         Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon:         Icon(Icons.payment_outlined),
      selectedIcon: Icon(Icons.payment_rounded),
      label: 'Payments',
    ),
    NavigationDestination(
      icon:         Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Reports',
    ),
    NavigationDestination(
      icon:         Icon(Icons.account_balance_outlined),
      selectedIcon: Icon(Icons.account_balance_rounded),
      label: 'Payouts',
    ),
    NavigationDestination(
      icon:         Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  // ---------- Developer tabs ----------
  List<Widget> get _developerTabs => [
    const DeveloperDashboardPage(),
    const DeveloperTransactionsPage(),
    const WebhooksListPage(),
    const ProfilePage(),
  ];

  List<NavigationDestination> get _developerDests => const [
    NavigationDestination(
      icon:         Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon:         Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Transactions',
    ),
    NavigationDestination(
      icon:         Icon(Icons.webhook_outlined),
      selectedIcon: Icon(Icons.webhook_rounded),
      label: 'Webhooks',
    ),
    NavigationDestination(
      icon:         Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final c = context.appColors;
      return Scaffold(
        backgroundColor: c.background,
        body: Center(child: CircularProgressIndicator(color: c.primaryAmber)),
      );
    }

    final tabs  = _isDeveloper ? _developerTabs  : _orgAdminTabs;
    final dests = _isDeveloper ? _developerDests : _orgAdminDests;
    final safeIndex = _index.clamp(0, tabs.length - 1);
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: safeIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.borderSubtle, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (i) {
            // Clamp guard for role changes during session
            if (i < tabs.length) setState(() => _index = i);
          },
          destinations: dests,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-out helper — used by all settings/profile pages
// ---------------------------------------------------------------------------
Future<void> showSignOutDialog(BuildContext context) async {
  final confirmed = await DialogHelpers.showConfirmDialog(
    context,
    title:       'Sign Out',
    message:     'Are you sure you want to sign out?',
    confirmText: 'Sign Out',
    isDanger:    true,
  );

  if (confirmed && context.mounted) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }
}
