import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/subscription.dart';
import '../../shared/services/subscription_service.dart';
import '../../widgets/app_card.dart';

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.borderMid, width: 1),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 17, color: c.textSecondary),
                    ),
                  ),
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
                              padding: const EdgeInsets.all(11),
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
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Section label ────────────────────────────────────────────────
        Text('SUBSCRIPTION DETAILS',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12)),
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
        ),

        const SizedBox(height: AppSpacing.md),

        // ── USSD section label ────────────────────────────────────────────
        Text('FEATURES',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12)),
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
        ),
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
