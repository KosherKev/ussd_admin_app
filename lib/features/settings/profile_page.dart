import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../main.dart';
import '../home/home_shell.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? _error;
  String? _email;
  String? _role;
  String? _orgName;
  String? _orgId;
  bool _sendReceiptSms = false;
  bool _savingOrg = false;

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
      final user  = res.data['user'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>?;

      final email  = user?['email']?.toString();
      final role   = user?['role']?.toString() ?? 'org_admin';
      final orgId  = user?['organizationId']?.toString() ?? prefs.getString('org_id');

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

      // Cache email for DeveloperSettingsPage
      await prefs.setString('email', email ?? '');

      if (mounted) {
        setState(() {
          _email           = email;
          _role            = role;
          _orgName         = orgName;
          _orgId           = orgId;
          _sendReceiptSms  = smsEnabled;
          _phoneController.text = orgPhone ?? '';
          _loading         = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
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

  @override
  Widget build(BuildContext context) {
    final c        = context.appColors;
    final appState = App.of(context);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(
            title: 'Settings',
            trailing: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                : _error != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.error_outline, size: 56, color: c.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ]))
                    : ListView(children: [
                        // Account card
                        Text('Account', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(child: Column(children: [
                          _infoRow(Icons.email_outlined, 'Email', _email ?? '--', c),
                          Divider(color: c.borderSubtle, thickness: 1, height: 1),
                          _infoRow(Icons.badge_outlined, 'Role', StatusHelpers.formatStatus(_role ?? 'org_admin'), c),
                          if (_orgName != null) ...[
                            Divider(color: c.borderSubtle, thickness: 1, height: 1),
                            _infoRow(Icons.business_outlined, 'Organisation', _orgName!, c),
                          ],
                        ])),

                        // Organisation settings (only for org_admin with an org)
                        if (_orgId != null && _orgId!.isNotEmpty && _role == 'org_admin') ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text('Organisation Settings', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(child: Column(children: [
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Phone',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Divider(color: c.borderSubtle, thickness: 1, height: 1),
                            Row(children: [
                              Icon(Icons.sms_outlined, size: 20, color: c.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('SMS Receipts', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary)),
                                Text('Send receipt SMS to customers after payment', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                              ])),
                              Switch(
                                value: _sendReceiptSms,
                                onChanged: (v) => setState(() => _sendReceiptSms = v),
                              ),
                            ]),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _savingOrg ? null : _saveOrgSettings,
                                child: _savingOrg
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                    : const Text('Save Organisation Settings'),
                              ),
                            ),
                          ])),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Appearance
                        Text('Appearance', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(child: Row(children: [
                          Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: c.textSecondary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text('Dark Mode', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
                          Switch(
                            value: isDark,
                            onChanged: (v) => appState?.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                          ),
                        ])),

                        const SizedBox(height: AppSpacing.lg),

                        // Sign out
                        OutlinedButton.icon(
                          onPressed: () => showSignOutDialog(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: c.error,
                            side: BorderSide(color: c.error),
                            minimumSize: const Size(double.infinity, 52),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, AppColors c) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(children: [
        Icon(icon, size: 18, color: c.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary)),
        ])),
      ]),
    );
}