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

class _HomeShellState extends State<HomeShell>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int    _index   = 0;
  String _orgId   = '';
  bool   _devMode = false;
  bool   _loading = true;

  // AnimationController for the fade transition between tabs
  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _index     = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..value = 1.0; // start fully visible
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _switchTab(int newIndex) async {
    if (newIndex == _index) return;
    // Fade out, swap, fade in
    await _fadeCtrl.reverse();
    if (mounted) {
      setState(() => _index = newIndex);
    }
    _fadeCtrl.forward();
  }

  bool get _isDeveloper => _devMode;

  // ── Org Admin tabs ────────────────────────────────────────────────────────
  List<Widget> get _orgAdminTabs => [
    DashboardPage(orgId: _orgId),
    PaymentTypesListPage(orgId: _orgId, embedded: true),
    const TransactionsPage(),
    const PayoutsPage(),
    const ProfilePage(),
  ];

  static const _orgAdminNavItems = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined,      label: 'Dashboard'),
    _NavItem(icon: Icons.payment_outlined,         label: 'Payments'),
    _NavItem(icon: Icons.receipt_long_outlined,    label: 'Reports'),
    _NavItem(icon: Icons.account_balance_outlined, label: 'Payouts'),
    _NavItem(icon: Icons.settings_outlined,        label: 'Settings'),
  ];

  // ── Developer tabs ────────────────────────────────────────────────────────
  List<Widget> get _developerTabs => [
    const DeveloperDashboardPage(),
    const DeveloperTransactionsPage(),
    const WebhooksListPage(),
    const ProfilePage(),
  ];

  static const _developerNavItems = <_NavItem>[
    _NavItem(icon: Icons.analytics_outlined,    label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Transactions'),
    _NavItem(icon: Icons.webhook_outlined,      label: 'Webhooks'),
    _NavItem(icon: Icons.settings_outlined,     label: 'Settings'),
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

    final tabs      = _isDeveloper ? _developerTabs     : _orgAdminTabs;
    final navItems  = _isDeveloper ? _developerNavItems : _orgAdminNavItems;
    final safeIndex = _index.clamp(0, tabs.length - 1);
    final c         = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: IndexedStack(
            index: safeIndex,
            children: tabs,
          ),
        ),
      ),
      bottomNavigationBar: _CustomBottomNav(
        items:       navItems,
        activeIndex: safeIndex,
        onTap:       _switchTab,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _NavItem — data class for a single bottom nav entry
// ---------------------------------------------------------------------------
class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String   label;
}

// ---------------------------------------------------------------------------
// _CustomBottomNav — Refined Financial Brutalism bottom navigation bar
//
// - Height: 64px + bottom safe area padding
// - Background: bgSurface, top border: 1px borderStrong
// - Active: amber 3px top indicator line + amber icon + amber label (labelSmall Sora)
// - Inactive: textTertiary icon + label
// - No animated NavigationIndicator pill
// ---------------------------------------------------------------------------
class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({
    required this.items,
    required this.activeIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int            activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        border: Border(top: BorderSide(color: c.borderStrong, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      height: 64 + bottom,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i      = entry.key;
          final item   = entry.value;
          final active = i == activeIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 3px top indicator line when active
                    if (active)
                      Positioned(
                        top: 0,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: c.primaryAmber,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),

                    // Icon + label column
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: active ? c.primaryAmber : c.textTertiary,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: text.labelSmall?.copyWith(
                              color: active ? c.primaryAmber : c.textTertiary,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
