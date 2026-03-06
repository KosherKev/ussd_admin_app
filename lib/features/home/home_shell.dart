import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../dashboard/dashboard_page.dart';
import '../payments/payment_types_list_page.dart';
import '../reports/transactions_page.dart';
import '../settings/profile_page.dart';
import '../developer/developer_dashboard_page.dart';
import '../developer/developer_transactions_page.dart';
import '../developer/webhooks_list_page.dart';
import '../developer/api_keys_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    const ProfilePage(),
  ];

  static const _orgAdminNavItems = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined,   label: 'Dashboard'),
    _NavItem(icon: Icons.payment_outlined,      label: 'Payments'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Reports'),
    _NavItem(icon: Icons.settings_outlined,     label: 'Settings'),
  ];

  // ── Developer tabs ────────────────────────────────────────────────────────
  List<Widget> get _developerTabs => [
    const DeveloperDashboardPage(),
    const DeveloperTransactionsPage(),
    const WebhooksListPage(),
    const ApiKeysPage(),
    const ProfilePage(),
  ];

  static const _developerNavItems = <_NavItem>[
    _NavItem(icon: Icons.analytics_outlined,    label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Transactions'),
    _NavItem(icon: Icons.webhook_outlined,      label: 'Webhooks'),
    _NavItem(icon: Icons.key_outlined,          label: 'API Keys'),
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
      ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
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
// Matches mockup .phone-nav / .phone-nav-item pattern:
// - Height: 64px + bottom safe area padding
// - Background: bgSurface, top border: 1px borderSubtle
// - Active tab:
//     • 2px × 18px amber pill (pni-dot) above the icon square
//     • Icon square: amberBg fill + 1px amberBorder border, r=4
//     • Label: amber, Sora 9px
// - Inactive tab:
//     • Empty 2px spacer (pni-dot transparent)
//     • Icon square: bgHigh fill, opacity 0.5
//     • Label: textTertiary, Sora 9px
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
    final c      = context.appColors;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        border: Border(top: BorderSide(color: c.borderSubtle, width: 1)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Amber pill indicator (pni-dot) ──────────────────
                    Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        color: active ? c.primaryAmber : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ── Icon square (pni-icon) ───────────────────────────
                    Opacity(
                      opacity: active ? 1.0 : 0.5,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: active ? c.amberBg : c.bgHigh,
                          borderRadius: BorderRadius.circular(4),
                          border: active
                              ? Border.all(color: c.amberBorder, width: 1)
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          size: 14,
                          color: active ? c.primaryAmber : c.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // ── Label (pni-label) ────────────────────────────────
                    Text(
                      item.label,
                      style: AppTypography.labelMono(
                        active ? c.primaryAmber : c.textTertiary,
                      ).copyWith(fontSize: 9, letterSpacing: 0.05),
                      overflow: TextOverflow.ellipsis,
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
