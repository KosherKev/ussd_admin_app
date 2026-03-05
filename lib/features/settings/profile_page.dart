import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';
import '../../app/router/routes.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/app_card.dart';
import '../../main.dart';
import '../home/home_shell.dart';

// ---------------------------------------------------------------------------
// ProfilePage (Settings) — Phase 14
//
// Mockup: Screen 5 — "Settings"
// Layout:
//   • page-strip: eyebrow "ACCOUNT" / title "Settings"
//   • Avatar block: initials circle (amber bg) | name bold | ROLE: mono
//   • "ACCOUNT DETAILS" panel: email + org info-rows
//   • "SUBSCRIPTION" card: star icon + plan | expires detail | chevron
//   • "PREFERENCES" panel: Dark Mode toggle | SMS Receipts toggle | Dev Mode toggle
//   • Full-width danger "Sign Out" button
// ---------------------------------------------------------------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool    _loading      = true;
  String? _error;
  String? _email;
  String? _role;
  String? _orgName;
  String? _orgId;
  bool    _sendReceiptSms = false;
  bool    _devMode        = false;
  bool    _savingOrg      = false;

  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final dio   = buildDio(token: token);
      final res   = await dio.get('/auth/me');
      final user  = res.data['user'] as Map<String, dynamic>?
          ?? res.data as Map<String, dynamic>?;

      final email = user?['email']?.toString();
      final role  = user?['role']?.toString() ?? 'org_admin';
      final orgId = user?['organizationId']?.toString()
          ?? prefs.getString('org_id');

      String? orgName;
      String? orgPhone;
      bool    smsEnabled = false;

      if (orgId != null && orgId.isNotEmpty) {
        try {
          final org = await OrgService().get(orgId);
          orgName    = org.name;
          orgPhone   = org.phone;
          smsEnabled = org.sendReceiptSms ?? false;
        } catch (_) {
          orgName = user?['organization']?['name']?.toString();
        }
      }

      await prefs.setString('email', email ?? '');

      if (mounted) {
        setState(() {
          _email           = email;
          _role            = role;
          _orgName         = orgName;
          _orgId           = orgId;
          _sendReceiptSms  = smsEnabled;
          _devMode         = prefs.getBool('dev_mode') ?? false;
          _phoneController.text = orgPhone ?? '';
          _loading         = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandlers.getErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveOrgSettings() async {
    final orgId = _orgId;
    if (orgId == null || orgId.isEmpty) return;
    setState(() => _savingOrg = true);
    try {
      await OrgService().updateOrg(orgId, {
        'phone':          _phoneController.text.trim(),
        'sendReceiptSMS': _sendReceiptSms,
      });
      if (mounted) {
        DialogHelpers.showSuccess(context, 'Organisation settings saved');
        setState(() => _savingOrg = false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
        setState(() => _savingOrg = false);
      }
    }
  }

  /// First letter of the display name / email.
  String get _initials {
    if (_email != null && _email!.isNotEmpty) {
      return _email![0].toUpperCase();
    }
    return '?';
  }

  String get _displayName {
    if (_email != null && _email!.isNotEmpty) {
      final parts = _email!.split('@');
      return parts.first
          .replaceAll(RegExp(r'[._-]'), ' ')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ')
          .trim();
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final c        = context.appColors;
    final appState = App.of(context);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Page strip header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(letterSpacing: 0.12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Settings',
                          style: GoogleFonts.instrumentSerif(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: c.textPrimary,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh
                  GestureDetector(
                    onTap: _loading ? null : _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.borderMid, width: 1),
                      ),
                      child: _loading
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: c.primaryAmber))
                          : Icon(Icons.refresh_rounded,
                              size: 17, color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 56, color: c.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: c.textSecondary),
                              textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                                onPressed: _load, child: const Text('Retry')),
                          ]))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md, AppSpacing.md,
                              AppSpacing.md, AppSpacing.xxl),
                          children: [

                            // ── Avatar / identity block ──────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Initials circle
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: c.amberBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: c.amberBorder, width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _initials,
                                      style: GoogleFonts.instrumentSerif(
                                        fontSize: 24,
                                        color: c.primaryAmber,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: c.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ROLE: ${(_role ?? 'org_admin').toUpperCase()}',
                                        style: AppTypography.labelMono(
                                                c.textTertiary)
                                            .copyWith(
                                                fontSize: 10,
                                                letterSpacing: 0.04),
                                      ),
                                    ],
                                  ),
                                ),
                                // Ghost "Edit" button (navigates to edit if ever added)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: c.bgSurface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(
                                        color: c.borderMid, width: 1),
                                  ),
                                  child: Text('Edit',
                                    style: AppTypography.labelMono(
                                            c.textSecondary)
                                        .copyWith(fontSize: 11)),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),
                            Divider(height: 1, color: c.borderSubtle),
                            const SizedBox(height: AppSpacing.md),

                            // ── Account Details ──────────────────────────
                            _SectionLabel('ACCOUNT DETAILS', c),
                            const SizedBox(height: AppSpacing.xs),
                            AppCard(
                              child: Column(children: [
                                _InfoRow(
                                  icon: '✉',
                                  label: 'Email',
                                  value: _email ?? '—',
                                  c: c,
                                  context: context,
                                ),
                                if (_orgName != null) ...[
                                  Divider(height: 1, color: c.borderSubtle),
                                  _InfoRow(
                                    icon: '🏢',
                                    label: 'Organisation',
                                    value: _orgName!,
                                    c: c,
                                    context: context,
                                  ),
                                ],
                              ]),
                            ),

                            // ── Subscription ─────────────────────────────
                            const SizedBox(height: AppSpacing.md),
                            _SectionLabel('SUBSCRIPTION', c),
                            const SizedBox(height: AppSpacing.xs),
                            AppCard(
                              onTap: () {
                                final orgId = _orgId;
                                if (orgId == null || orgId.isEmpty) {
                                  DialogHelpers.showError(context,
                                      'No organisation linked to this account.');
                                  return;
                                }
                                Navigator.pushNamed(
                                    context, Routes.subscriptionStatus,
                                    arguments: orgId);
                              },
                              child: Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: c.amberBg,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(
                                        color: c.amberBorder, width: 1),
                                  ),
                                  child: Center(
                                    child: Text('★',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: c.primaryAmber)),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Subscription Status',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: c.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            )),
                                      Text('View plan and limits',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: c.textSecondary)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18, color: c.textTertiary),
                              ]),
                            ),

                            // ── Organisation settings (org_admin only) ───
                            if (_orgId != null &&
                                _orgId!.isNotEmpty &&
                                _role == 'org_admin') ...[
                              const SizedBox(height: AppSpacing.md),
                              _SectionLabel('ORGANISATION', c),
                              const SizedBox(height: AppSpacing.xs),
                              AppCard(
                                child: Column(children: [
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Contact Phone',
                                      prefixIcon:
                                          Icon(Icons.phone_outlined),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Divider(
                                      height: 1, color: c.borderSubtle),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(children: [
                                    Icon(Icons.sms_outlined,
                                        size: 18, color: c.textSecondary),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('SMS Receipts',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: c.textPrimary)),
                                        Text(
                                          'Send receipt SMS to customers',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: c.textSecondary)),
                                      ],
                                    )),
                                    Switch(
                                      value: _sendReceiptSms,
                                      onChanged: (v) =>
                                          setState(() => _sendReceiptSms = v),
                                    ),
                                  ]),
                                  const SizedBox(height: AppSpacing.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _savingOrg
                                          ? null
                                          : _saveOrgSettings,
                                      child: _savingOrg
                                          ? const SizedBox(
                                              width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.black),
                                              ))
                                          : const Text(
                                              'Save Organisation Settings'),
                                    ),
                                  ),
                                ]),
                              ),
                            ],

                            // ── Preferences panel ─────────────────────────
                            const SizedBox(height: AppSpacing.md),
                            _SectionLabel('PREFERENCES', c),
                            const SizedBox(height: AppSpacing.xs),
                            AppCard(
                              child: Column(children: [
                                // Dark Mode
                                Row(children: [
                                  Text(
                                    isDark ? '🌙' : '☀️',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Dark Mode',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: c.textPrimary)),
                                      Text(isDark ? 'Enabled' : 'Disabled',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: c.textSecondary)),
                                    ],
                                  )),
                                  Switch(
                                    value: isDark,
                                    onChanged: (v) =>
                                        appState?.setThemeMode(
                                            v ? ThemeMode.dark : ThemeMode.light),
                                  ),
                                ]),

                                Divider(height: 1, color: c.borderSubtle),

                                // Developer Mode
                                Row(children: [
                                  const Text('⚙', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Developer Mode',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: c.textPrimary)),
                                      Text(_devMode ? 'On' : 'Off',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: c.textSecondary)),
                                    ],
                                  )),
                                  Switch(
                                    value: _devMode,
                                    onChanged: (v) async {
                                      final rootContext = context;
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool('dev_mode', v);
                                      if (rootContext.mounted) {
                                        Navigator.pushNamedAndRemoveUntil(
                                            rootContext, Routes.home,
                                            (r) => false);
                                      }
                                    },
                                  ),
                                ]),
                              ]),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Sign Out ──────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => showSignOutDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c.errorBg,
                                  foregroundColor: c.error,
                                  side: BorderSide(color: c.errorBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.c);
  final String    text;
  final AppColors c;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.labelMono(c.textTertiary)
        .copyWith(fontSize: 10, letterSpacing: 0.12),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.c,
    required this.context,
  });
  final String     icon;
  final String     label;
  final String     value;
  final AppColors  c;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: AppTypography.labelMono(c.textTertiary)
                .copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: c.textPrimary)),
        ],
      )),
    ]),
  );
}