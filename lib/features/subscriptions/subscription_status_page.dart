import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/subscription.dart';
import '../../shared/services/subscription_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/header_icon_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ---------------------------------------------------------------------------
// SubscriptionStatusPage — Refined Financial Brutalism design
//
// Layout:
//   • Instrument Serif page-strip header with back + refresh buttons
//   • Hero status card: ★ amber icon square, status + billing period
//   • Details AppCard: subscription info rows (Start, End, Grace Period)
//   • USSD service row (enabled/disabled with status chip)
// ---------------------------------------------------------------------------
class SubscriptionStatusPage extends StatefulWidget {
  final String id;
  const SubscriptionStatusPage({super.key, required this.id});

  @override
  State<SubscriptionStatusPage> createState() => _SubscriptionStatusPageState();
}

class _SubscriptionStatusPageState extends State<SubscriptionStatusPage> {
  final _service = SubscriptionService();
  Subscription? _subscription;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final subscription = await _service.getStatus(widget.id);
      if (mounted) setState(() { _subscription = subscription; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  // ── Pay / Renew ─────────────────────────────────────────────────────────────
  Future<void> _showPaySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PaySheet(
        subscriptionId: widget.id,
        service: _service,
        onSuccess: () { Navigator.pop(context); _load(); },
      ),
    );
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
                  // Back button
                  HeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                          'Subscription',
                          style: GoogleFonts.instrumentSerif(
                            fontSize: 28,
                            fontStyle: FontStyle.italic,
                            color: c.textPrimary,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  HeaderIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _load,
                    loading: _loading,
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
                      ? _buildError(c)
                      : _buildContent(c),
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
        Text('Failed to load',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(_error!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _buildContent(AppColors c) {
    if (_subscription == null) return const SizedBox.shrink();
    final sub = _subscription!;

    // Determine status colour
    final statusColor = sub.isActive ? c.success
        : sub.isCancelled ? c.error
        : c.warning;
    final statusBg = sub.isActive ? c.successBg
        : sub.isCancelled ? c.errorBg
        : c.warningBg;
    final statusBorder = sub.isActive ? c.successBorder
        : sub.isCancelled ? c.errorBorder
        : c.warningBorder;

    final billingLabel = sub.billingPeriod.isEmpty
        ? 'Monthly'
        : '${sub.billingPeriod[0].toUpperCase()}${sub.billingPeriod.substring(1)}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
      children: [

        // ── Hero status card ─────────────────────────────────────────────
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ★ icon square
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: sub.isActive ? c.amberBg : c.bgHigh,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: sub.isActive ? c.amberBorder : c.borderMid,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    sub.isActive ? '★' : '○',
                    style: TextStyle(
                        fontSize: 24,
                        color: sub.isActive ? c.primaryAmber : c.textTertiary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        sub.isActive
                            ? 'Active · $billingLabel'
                            : sub.isCancelled
                                ? 'Cancelled'
                                : 'Inactive',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          border: Border.all(color: statusBorder, width: 1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          sub.status.toUpperCase(),
                          style: AppTypography.labelMono(statusColor)
                              .copyWith(fontSize: 9),
                        ),
                      ),
                    ]),
                    if (sub.endDate != null) ...[ 
                      const SizedBox(height: 3),
                      Text(
                        'Expires ${DateFormatters.formatDate(sub.endDate)}'
                        '${sub.ussdEnabled ? ' · USSD enabled' : ''}',
                        style: AppTypography.labelMono(c.textTertiary)
                            .copyWith(fontSize: 10, letterSpacing: 0.04),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // ── Section label ────────────────────────────────────────────────
        Text('SUBSCRIPTION DETAILS',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12)).animate().fade(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: AppSpacing.xs),

        // ── Details card ─────────────────────────────────────────────────
        AppCard(
          child: Column(children: [
            _detailRow('Billing Period', billingLabel, c),
            if (sub.startDate != null) ...[
              Divider(height: 1, color: c.borderSubtle),
              _detailRow('Start Date',
                  DateFormatters.formatDate(sub.startDate), c),
            ],
            if (sub.endDate != null) ...[
              Divider(height: 1, color: c.borderSubtle),
              _detailRow('End Date',
                  DateFormatters.formatDate(sub.endDate), c),
            ],
            if (sub.gracePeriodEndDate != null) ...[
              Divider(height: 1, color: c.borderSubtle),
              _detailRow('Grace Period End',
                  DateFormatters.formatDate(sub.gracePeriodEndDate), c),
            ],
          ]),
        ).animate().fade(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // ── Section label ────────────────────────────────────────────────
        Text('FEATURES',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12)).animate().fade(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: AppSpacing.xs),

        // ── USSD feature row ─────────────────────────────────────────────
        AppCard(
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: sub.ussdEnabled
                    ? c.successBg
                    : c.bgHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: sub.ussdEnabled ? c.successBorder : c.borderMid,
                  width: 1,
                ),
              ),
              child: Icon(
                sub.ussdEnabled
                    ? Icons.phone_android_rounded
                    : Icons.phonelink_off_rounded,
                color: sub.ussdEnabled ? c.success : c.textTertiary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USSD Service',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: c.textPrimary,
                          fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  sub.ussdEnabled ? 'Enabled' : 'Disabled',
                  style: AppTypography.labelMono(
                          sub.ussdEnabled ? c.success : c.textTertiary)
                      .copyWith(fontSize: 10),
                ),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: sub.ussdEnabled ? c.successBg : c.bgHigh,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: sub.ussdEnabled ? c.successBorder : c.borderMid,
                  width: 1,
                ),
              ),
              child: Text(
                sub.ussdEnabled ? 'ON' : 'OFF',
                style: AppTypography.labelMono(
                        sub.ussdEnabled ? c.success : c.textTertiary)
                    .copyWith(fontSize: 9),
              ),
            ),
          ]),
        ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
        
        // ── Pay / Renew button ────────────────────────────────────────────
        const SizedBox(height: AppSpacing.lg),
        Text('ACTIONS',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12)).animate().fade(delay: 400.ms, duration: 400.ms),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showPaySheet,
            icon: const Icon(Icons.credit_card_rounded, size: 16),
            label: Text(
              sub.isActive ? 'Renew Subscription' : 'Pay Now',
              style: AppTypography.labelMono(Colors.black).copyWith(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primaryAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          ),
        ).animate().fade(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

        // ── PIN Prompt Help (only if not active) ──────────────────────────
        if (!sub.isActive) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            variant: AppCardVariant.elevated,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline_rounded, size: 20, color: c.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PIN prompt never appeared?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        )),
                      const SizedBox(height: 4),
                      Text(
                        'If you didn\'t receive a mobile money prompt, contact the super admin. '
                        'They can force-verify the transaction or mark it as failed so you can retry.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 500.ms, duration: 400.ms),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value, AppColors c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(children: [
      Expanded(child: Text(label,
        style: AppTypography.labelMono(c.textTertiary)
            .copyWith(fontSize: 10, letterSpacing: 0.08))),
      Text(value,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ---------------------------------------------------------------------------
// _PaySheet — payment bottom sheet with OTP support
// ---------------------------------------------------------------------------
class _PaySheet extends StatefulWidget {
  final String subscriptionId;
  final SubscriptionService service;
  final VoidCallback onSuccess;

  const _PaySheet({
    required this.subscriptionId,
    required this.service,
    required this.onSuccess,
  });

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();

  String  _network      = 'MTN';
  String  _billingModel = 'monthly';
  bool    _paying       = false;
  String? _error;

  // OTP step state
  bool   _needsOtp    = false;
  String _txnRef      = '';

  static const _networks = ['MTN', 'VODAFONE', 'AIRTELTIGO'];
  static const _billingOptions = [
    ('monthly',        'Monthly',       'GHS 100 / month'),
    ('annual_prepaid', 'Annual Prepaid','GHS 1,200 upfront'),
    ('annual_monthly', 'Annual Monthly','GHS 100 / month (annual)'),
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _paying = true; _error = null; });
    try {
      final res = await widget.service.pay(
        widget.subscriptionId,
        phone:        _phoneCtrl.text.trim(),
        network:      _network,
        billingModel: _billingModel,
      );
      final requiresOtp = res['requiresOtp'] == true;
      final txnRef      = (res['transactionRef'] ?? '').toString();

      if (requiresOtp) {
        if (mounted) setState(() { _needsOtp = true; _txnRef = txnRef; _paying = false; });
      } else {
        // Push prompt sent — inform user to approve on phone
        if (mounted) {
          setState(() => _paying = false);
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              final c = ctx.appColors;
              return AlertDialog(
                backgroundColor: c.bgSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                icon: Icon(Icons.phone_android_rounded, color: c.primaryAmber, size: 40),
                title: Text('Approve on your phone',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 20, fontStyle: FontStyle.italic, color: c.textPrimary)),
                content: Text(
                  'A payment prompt has been sent to ${_phoneCtrl.text.trim()}.\n\n'
                  '1. Approve the debit on your mobile money phone.\n'
                  '2. Your subscription will activate automatically once confirmed.\n\n'
                  'If the PIN prompt never appears, please contact the Super Admin to force-verify the transaction.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () { Navigator.pop(ctx); widget.onSuccess(); },
                    child: Text('Done', style: TextStyle(color: c.primaryAmber)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _paying = false; });
    }
  }

  Future<void> _submitOtp() async {
    if (_otpCtrl.text.trim().isEmpty) return;
    setState(() { _paying = true; _error = null; });
    try {
      await widget.service.submitOtp(
        widget.subscriptionId,
        transactionRef: _txnRef,
        otp: _otpCtrl.text.trim(),
      );
      if (mounted) widget.onSuccess();
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _paying = false; });
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
      child: _needsOtp ? _buildOtpStep(c) : _buildPayStep(c),
    );
  }

  Widget _buildPayStep(AppColors c) => Form(
    key: _formKey,
    child: Column(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(child: Container(width: 36, height: 3,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(color: c.borderMid, borderRadius: BorderRadius.circular(2)))),

        Text('Pay Subscription',
          style: GoogleFonts.instrumentSerif(
            fontSize: 22, fontStyle: FontStyle.italic, color: c.textPrimary)),
        const SizedBox(height: AppSpacing.lg),

        // Phone
        _label('MOBILE MONEY NUMBER', c),
        TextFormField(
          controller: _phoneCtrl,
          style: TextStyle(color: c.textPrimary),
          decoration: _inputDeco('e.g. 0244111111', c),
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid number' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // Network
        _label('NETWORK', c),
        Row(children: _networks.map((n) {
          final sel = n == _network;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _network = n),
            child: Container(
              margin: EdgeInsets.only(
                right: n != _networks.last ? 4 : 0,
                left:  n != _networks.first ? 4 : 0),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: sel ? c.amberBg : c.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: sel ? c.amberBorder : c.borderMid, width: 1)),
              child: Center(child: Text(n,
                style: AppTypography.labelMono(
                  sel ? c.primaryAmber : c.textTertiary).copyWith(fontSize: 10))),
            ),
          ));
        }).toList()),
        const SizedBox(height: AppSpacing.md),

        // Billing model
        _label('BILLING MODEL', c),
        Column(children: _billingOptions.map((opt) {
          final (val, label, desc) = opt;
          final sel = val == _billingModel;
          return GestureDetector(
            onTap: () => setState(() => _billingModel = val),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: sel ? c.amberBg : c.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: sel ? c.amberBorder : c.borderMid, width: 1)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: sel ? c.primaryAmber : c.textPrimary,
                      fontWeight: FontWeight.w600)),
                  Text(desc,
                    style: AppTypography.labelMono(sel ? c.primaryAmber : c.textTertiary)
                      .copyWith(fontSize: 10)),
                ])),
                if (sel) Icon(Icons.check_circle_rounded, size: 16, color: c.primaryAmber),
              ]),
            ),
          );
        }).toList()),

        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: TextStyle(color: c.error, fontSize: 12)),
        ],

        const SizedBox(height: AppSpacing.lg),

        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _paying ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: c.primaryAmber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
          child: _paying
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : Text('Pay Now',
                style: AppTypography.labelMono(Colors.black).copyWith(fontSize: 12)),
        )),
      ],
    ),
  );

  Widget _buildOtpStep(AppColors c) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(child: Container(width: 36, height: 3,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(color: c.borderMid, borderRadius: BorderRadius.circular(2)))),

      Text('Enter OTP',
        style: GoogleFonts.instrumentSerif(
          fontSize: 22, fontStyle: FontStyle.italic, color: c.textPrimary)),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'An OTP was sent to ${_phoneCtrl.text.trim()}. Enter it below to complete the payment.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: AppSpacing.lg),

      _label('ONE-TIME PASSWORD', c),
      TextField(
        controller: _otpCtrl,
        style: TextStyle(color: c.textPrimary, letterSpacing: 6, fontSize: 20),
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: _inputDeco('000000', c).copyWith(counterText: ''),
      ),

      if (_error != null) ...[
        const SizedBox(height: AppSpacing.md),
        Text(_error!, style: TextStyle(color: c.error, fontSize: 12)),
      ],

      const SizedBox(height: AppSpacing.lg),

      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _paying ? null : _submitOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primaryAmber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
        child: _paying
          ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
          : Text('Confirm Payment',
              style: AppTypography.labelMono(Colors.black).copyWith(fontSize: 12)),
      )),
    ],
  );

  Widget _label(String text, AppColors c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: AppTypography.labelMono(c.textTertiary).copyWith(fontSize: 10, letterSpacing: 0.10)),
  );

  InputDecoration _inputDeco(String hint, AppColors c) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: c.textTertiary, fontSize: 13),
    filled: true,
    fillColor: c.bgSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
