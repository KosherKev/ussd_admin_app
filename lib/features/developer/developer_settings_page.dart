import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../main.dart';
import '../../widgets/glass_card.dart';
import '../../shared/utils/helpers.dart';
import '../home/home_shell.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  String? _keyPrefix;
  String? _environment;
  String? _projectName;
  List<String> _scopes = [];
  String? _webhookUrl;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _keyPrefix   = prefs.getString('key_prefix');
        _environment = prefs.getString('key_environment');
        _projectName = prefs.getString('project_name');
        _scopes      = prefs.getStringList('key_scopes') ?? [];
        _webhookUrl  = prefs.getString('webhook_url');
        _userEmail   = prefs.getString('email');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c          = context.appColors;
    final appState   = App.of(context);
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: ListView(
          children: [
            // API Key card
            Text('API Key', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(children: [
                _infoRow(Icons.key_rounded,          'Key Prefix',   _keyPrefix   ?? '--', c, copyable: true),
                _divider(c),
                _infoRow(Icons.cloud_outlined,       'Environment',  _environment ?? '--', c),
                _divider(c),
                _infoRow(Icons.folder_open_outlined, 'Project',      _projectName ?? '--', c),
                if (_webhookUrl != null && _webhookUrl!.isNotEmpty) ...[
                  _divider(c),
                  _infoRow(Icons.webhook_rounded,    'Webhook URL',  _webhookUrl!, c, copyable: true),
                ],
              ]),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Scopes
            if (_scopes.isNotEmpty) ...[
              Text('Granted Scopes', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _scopes.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: c.primaryAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: c.primaryAmber.withValues(alpha: 0.4)),
                    ),
                    child: Text(s, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.primaryAmber)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Account
            Text('Account', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(children: [
                if (_userEmail != null) ...[
                  _infoRow(Icons.email_outlined, 'Email', _userEmail!, c),
                  _divider(c),
                ],
                // Theme toggle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(children: [
                    Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: c.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('Dark Mode', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
                    Switch(
                      value: isDark,
                      onChanged: (v) => appState?.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ]),
                ),
              ]),
            ),

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
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, AppColors c, {bool copyable = false}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(children: [
        Icon(icon, size: 18, color: c.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1),
        ])),
        if (copyable)
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 16, color: c.textTertiary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              DialogHelpers.showSuccess(context, 'Copied!');
            },
          ),
      ]),
    );

  Widget _divider(AppColors c) => Divider(color: c.borderSubtle, thickness: 1, height: 1);
}
