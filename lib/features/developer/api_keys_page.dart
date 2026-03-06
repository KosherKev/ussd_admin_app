import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/models/api_key.dart';
import '../../shared/services/developer_service.dart';
import '../../shared/utils/helpers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/header_icon_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

// ---------------------------------------------------------------------------
// ApiKeysPage — Refined Financial Brutalism
//
// Lists the org's API keys from GET /api/v1/keys.
// "+ New Key" opens a bottom sheet to provision a key.
// Long-press or tap the revoke icon to revoke.
// On creation the secret key is shown in a copyable dialog (shown once).
// ---------------------------------------------------------------------------
class ApiKeysPage extends StatefulWidget {
  const ApiKeysPage({super.key});

  @override
  State<ApiKeysPage> createState() => _ApiKeysPageState();
}

class _ApiKeysPageState extends State<ApiKeysPage> {
  final _service = DeveloperService();

  List<OrgApiKey> _keys    = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final keys = await _service.listKeys();
      if (mounted) setState(() { _keys = keys; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  // ── Create Key ─────────────────────────────────────────────────────────────
  Future<void> _showCreateSheet() async {
    final result = await showModalBottomSheet<NewApiKey>(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   context.appColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CreateKeySheet(),
    );

    if (result != null && mounted) {
      // Show the secret key once — it will never be returned again.
      await _showSecretDialog(result);
      _load();
    }
  }

  Future<void> _showSecretDialog(NewApiKey key) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final c = ctx.appColors;
        return AlertDialog(
          backgroundColor: c.bgSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text('Save your secret key',
            style: GoogleFonts.instrumentSerif(
              fontSize: 20, fontStyle: FontStyle.italic,
              color: c.textPrimary),
          ),
          content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This key will only be shown once. Copy it now and store it safely.',
                style: Theme.of(ctx).textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.bgHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.amberBorder, width: 1),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      key.secretKey,
                      style: GoogleFonts.dmMono(
                        fontSize: 11, color: c.primaryAmber,
                        letterSpacing: 0.3),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 16, color: c.primaryAmber),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: key.secretKey));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Copied!')));
                    },
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                Container(width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: c.warning, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text('You will not be able to see this key again.',
                  style: AppTypography.labelMono(c.warning)
                      .copyWith(fontSize: 10))),
              ]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('I\'ve copied it',
                style: TextStyle(color: c.primaryAmber)),
            ),
          ],
        );
      },
    );
  }

  // ── Revoke ──────────────────────────────────────────────────────────────────
  Future<void> _revokeKey(OrgApiKey key) async {
    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title:       'Revoke Key',
      message:     'Revoke "${key.projectName}"? Any app using this key will immediately lose access.',
      confirmText: 'Revoke',
      isDanger:    true,
    );
    if (!confirmed || !mounted) return;

    try {
      await _service.revokeKey(key.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorHandlers.getErrorMessage(e)),
          backgroundColor: context.appColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page-strip header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEVELOPER',
                        style: AppTypography.labelMono(c.primaryAmber)
                            .copyWith(letterSpacing: 0.12)),
                      const SizedBox(height: 2),
                      Text('API Keys',
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 28, fontStyle: FontStyle.italic,
                          color: c.textPrimary, height: 1.1)),
                    ],
                  )),
                  // Refresh
                  HeaderIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _load,
                    loading: _loading,
                  ),
                  // New Key
                  GestureDetector(
                    onTap: _showCreateSheet,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: c.amberBg,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.amberBorder, width: 1)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add_rounded, size: 15, color: c.primaryAmber),
                        const SizedBox(width: 4),
                        Text('New Key',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(fontSize: 11)),
                      ]),
                    ),
                  ).animate().fade(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? _buildError(c)
                      : _buildList(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppColors c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 48, color: c.error),
        const SizedBox(height: AppSpacing.md),
        Text('Failed to load', style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(_error!, style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _buildList(AppColors c) {
    if (_keys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.key_off_rounded, size: 48, color: c.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text('No API keys yet',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Tap "New Key" to create your first API key.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: c.textSecondary),
              textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: c.primaryAmber,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
        itemCount: _keys.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (ctx, i) => _buildKeyCard(_keys[i], c)
            .animate()
            .fade(delay: (math.min(i, 15) * 50).ms, duration: 300.ms)
            .slideY(begin: 0.05, end: 0, duration: 300.ms),
      ),
    );
  }

  Widget _buildKeyCard(OrgApiKey key, AppColors c) {
    final envColor = key.environment == 'live'
        ? c.success
        : c.info;
    final envBg = key.environment == 'live'
        ? c.successBg
        : c.info.withValues(alpha: 0.10);
    final envBorder = key.environment == 'live'
        ? c.successBorder
        : c.info.withValues(alpha: 0.30);

    return AppCard(
      variant: key.isActive ? AppCardVariant.base : AppCardVariant.base,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Top row: project name + env chip + revoke -─────────────────
        Row(children: [
          // Key icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: key.isActive ? c.amberBg : c.bgHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: key.isActive ? c.amberBorder : c.borderMid, width: 1)),
            child: Icon(Icons.key_rounded, size: 16,
              color: key.isActive ? c.primaryAmber : c.textTertiary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key.projectName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.textPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(key.keyPrefix,
                style: GoogleFonts.dmMono(
                  fontSize: 10, color: c.textTertiary, letterSpacing: 0.3)),
            ],
          )),
          // Environment chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: envBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: envBorder, width: 1)),
            child: Text(key.environment.toUpperCase(),
              style: AppTypography.labelMono(envColor).copyWith(fontSize: 9)),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Active dot
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: key.isActive ? c.successBg : c.bgHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: key.isActive ? c.successBorder : c.borderMid,
                width: 1)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                decoration: BoxDecoration(
                  color: key.isActive ? c.success : c.textTertiary,
                  shape: BoxShape.circle)),
              const SizedBox(width: 3),
              Text(key.isActive ? 'ACTIVE' : 'REVOKED',
                style: AppTypography.labelMono(
                    key.isActive ? c.success : c.textTertiary)
                  .copyWith(fontSize: 9)),
            ]),
          ),
        ]),

        if (key.scopes.isNotEmpty) ...[ 
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: c.borderSubtle),
          const SizedBox(height: AppSpacing.sm),
          Wrap(spacing: 4, runSpacing: 4,
            children: key.scopes.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.bgHigh,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(color: c.borderSubtle, width: 1)),
              child: Text(s,
                style: AppTypography.labelMono(c.textTertiary)
                    .copyWith(fontSize: 9)),
            )).toList(),
          ),
        ],

        if (key.webhookUrl != null && key.webhookUrl!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Icon(Icons.webhook_rounded, size: 12, color: c.textTertiary),
            const SizedBox(width: 4),
            Expanded(child: Text(key.webhookUrl!,
              style: AppTypography.labelMono(c.textTertiary)
                  .copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis)),
          ]),
        ],

        if (key.isActive) ...[
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: c.borderSubtle),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () => _revokeKey(key),
            child: Row(children: [
              Icon(Icons.delete_outline_rounded, size: 14, color: c.error),
              const SizedBox(width: 6),
              Text('Revoke key',
                style: AppTypography.labelMono(c.error).copyWith(fontSize: 10)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// _CreateKeySheet — bottom sheet to provision a new API key
// ---------------------------------------------------------------------------
class _CreateKeySheet extends StatefulWidget {
  const _CreateKeySheet();

  @override
  State<_CreateKeySheet> createState() => _CreateKeySheetState();
}

class _CreateKeySheetState extends State<_CreateKeySheet> {
  final _service    = DeveloperService();
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _whUrlCtrl  = TextEditingController();

  String _env      = 'live';
  bool   _creating = false;
  String? _error;

  final List<String> _selectedScopes = ['payments:write', 'payments:read'];
  static const _availableScopes = [
    'payments:write',
    'payments:read',
    'webhooks:read',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _creating = true; _error = null; });
    try {
      final key = await _service.createKey(
        projectName: _nameCtrl.text.trim(),
        environment: _env,
        webhookUrl:  _whUrlCtrl.text.trim().isEmpty ? null : _whUrlCtrl.text.trim(),
        scopes:      _selectedScopes,
      );
      if (mounted) Navigator.pop(context, key);
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _creating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c      = context.appColors;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg,
          AppSpacing.md, AppSpacing.md + bottom),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(child: Container(width: 36, height: 3,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: c.borderMid,
                borderRadius: BorderRadius.circular(2)))),

            Text('New API Key',
              style: GoogleFonts.instrumentSerif(
                fontSize: 22, fontStyle: FontStyle.italic,
                color: c.textPrimary)),
            const SizedBox(height: AppSpacing.lg),

            // Project name
            _label('PROJECT NAME', c),
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: c.textPrimary),
              decoration: _inputDeco('e.g. HostelConnect Live', c),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Environment toggle
            _label('ENVIRONMENT', c),
            Row(children: ['live', 'test'].map((e) {
              final sel = e == _env;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _env = e),
                child: Container(
                  margin: EdgeInsets.only(right: e == 'live' ? 4 : 0,
                                          left:  e == 'test' ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: sel ? c.amberBg : c.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: sel ? c.amberBorder : c.borderMid, width: 1)),
                  child: Center(child: Text(e.toUpperCase(),
                    style: AppTypography.labelMono(
                      sel ? c.primaryAmber : c.textTertiary).copyWith(fontSize: 11))),
                ),
              ));
            }).toList()),
            const SizedBox(height: AppSpacing.md),

            // Webhook URL
            _label('WEBHOOK URL (optional)', c),
            TextFormField(
              controller: _whUrlCtrl,
              style: TextStyle(color: c.textPrimary, fontSize: 13),
              decoration: _inputDeco('https://your-server.com/webhooks/payhub', c),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),

            // Scopes
            _label('SCOPES', c),
            Wrap(spacing: 6, runSpacing: 6,
              children: _availableScopes.map((s) {
                final sel = _selectedScopes.contains(s);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) { _selectedScopes.remove(s); } else { _selectedScopes.add(s); }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? c.amberBg : c.bgSurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: sel ? c.amberBorder : c.borderMid, width: 1)),
                    child: Text(s,
                      style: AppTypography.labelMono(
                        sel ? c.primaryAmber : c.textTertiary)
                        .copyWith(fontSize: 10)),
                  ),
                );
              }).toList(),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: c.error, fontSize: 12)),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Create button
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: _creating ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm))),
                child: _creating
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2,
                          color: Colors.black))
                    : Text('Create Key',
                        style: AppTypography.labelMono(Colors.black)
                            .copyWith(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, AppColors c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: AppTypography.labelMono(c.textTertiary)
          .copyWith(fontSize: 10, letterSpacing: 0.10)),
  );

  InputDecoration _inputDeco(String hint, AppColors c) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: c.textTertiary, fontSize: 13),
    filled: true,
    fillColor: c.bgSurface,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: c.borderMid)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: c.borderMid)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: c.primaryAmber, width: 1.5)),
  );
}
