import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/webhook_delivery.dart';
import '../../shared/services/developer_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// WebhookDeliveryDetailPage — Phase 13
//
// Design changes:
// - AppBar → Instrument Serif page-strip with back button
// - GlassCard sections → AppCard
// - Payload code block uses bgHigh fill + DM Mono text
// - Attempt history rows use AppCard accent coloured by HTTP success/fail
// ---------------------------------------------------------------------------
class WebhookDeliveryDetailPage extends StatefulWidget {
  final String deliveryId;
  const WebhookDeliveryDetailPage({super.key, required this.deliveryId});

  @override
  State<WebhookDeliveryDetailPage> createState() =>
      _WebhookDeliveryDetailPageState();
}

class _WebhookDeliveryDetailPageState
    extends State<WebhookDeliveryDetailPage> {
  final _service = DeveloperService();
  WebhookDeliveryDetail? _detail;
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
      final d = await _service.getWebhookDelivery(widget.deliveryId);
      if (mounted) setState(() { _detail = d; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
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
          children: [

            // ── Page strip header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
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
                          'DEVELOPER PORTAL',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(letterSpacing: 0.12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Delivery Detail',
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
                  ? Center(
                      child: CircularProgressIndicator(color: c.primaryAmber))
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
                            ElevatedButton(onPressed: _load,
                                child: const Text('Retry')),
                          ]))
                      : _buildContent(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors c) {
    final d = _detail!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
      children: [

        // ── Overview card ────────────────────────────────────────────
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.event,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: c.textPrimary)),
                    if (d.projectName != null)
                      Text(d.projectName!,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: c.textSecondary)),
                  ],
                )),
                StatusChip(status: d.status, compact: true),
              ]),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: c.borderSubtle),
              const SizedBox(height: AppSpacing.md),
              _detailRow('Transaction', d.transactionRef, c, copyable: true),
              _detailRow('Endpoint',   d.targetUrl,       c, copyable: true),
              _detailRow('Attempts',   '${d.attemptCount}', c),
              if (d.deliveredAt != null)
                _detailRow('Delivered',
                  DateFormatters.formatDateTime(
                      DateTime.tryParse(d.deliveredAt!)),
                  c),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Payload ──────────────────────────────────────────────────
        if (d.payload != null) ...[
          Text(
            'PAYLOAD',
            style: AppTypography.labelMono(c.textTertiary)
                .copyWith(fontSize: 10, letterSpacing: 0.12),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('JSON',
                      style: AppTypography.labelMono(c.textTertiary)
                          .copyWith(fontSize: 9)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: _prettyJson(d.payload!)));
                        DialogHelpers.showSuccess(context, 'Payload copied');
                      },
                      child: Row(children: [
                        Icon(Icons.copy_rounded,
                            size: 12, color: c.textSecondary),
                        const SizedBox(width: 4),
                        Text('Copy',
                          style: AppTypography.labelMono(c.textSecondary)
                              .copyWith(fontSize: 10)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.bgHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _prettyJson(d.payload!),
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        color: c.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Attempt history ──────────────────────────────────────────
        Text(
          'DELIVERY ATTEMPTS',
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 10, letterSpacing: 0.12),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...d.attempts.asMap().entries.map((e) {
          final attempt = e.value;
          final ok = (attempt.responseStatus ?? 0) >= 200 &&
              (attempt.responseStatus ?? 0) < 300;
          final barColor = ok ? c.success : c.error;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppCard(
              variant:     AppCardVariant.accent,
              accentColor: barColor,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: barColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Attempt #${attempt.attemptNumber ?? e.key + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (attempt.responseStatus != null)
                      Text(
                        'HTTP ${attempt.responseStatus}',
                        style: AppTypography.labelMono(barColor)
                            .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                  ]),
                  if (attempt.attemptedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormatters.formatDateTime(
                          DateTime.tryParse(attempt.attemptedAt!)),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  if (attempt.durationMs != null)
                    Text('${attempt.durationMs}ms',
                      style: AppTypography.labelMono(c.textTertiary)
                          .copyWith(fontSize: 10)),
                  if (attempt.error != null && attempt.error!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text('${attempt.error}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: c.error)),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Detail row (label + value) ────────────────────────────────────────────
  Widget _detailRow(String label, String? value, AppColors c,
      {bool copyable = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 90,
          child: Text(label,
            style: AppTypography.labelMono(c.textTertiary)
                .copyWith(fontSize: 10)),
        ),
        Expanded(
          child: Text(value ?? '—',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textPrimary)),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value ?? ''));
              DialogHelpers.showSuccess(context, 'Copied');
            },
            child: Icon(Icons.copy_outlined, size: 13, color: c.textTertiary),
          ),
      ]),
    );

  // ── Pretty JSON ───────────────────────────────────────────────────────────
  String _prettyJson(Map<String, dynamic> json) {
    final sb = StringBuffer('{');
    var first = true;
    json.forEach((k, v) {
      if (!first) sb.write(',');
      sb.write('\n  "$k": ${_jsonValue(v)}');
      first = false;
    });
    sb.write('\n}');
    return sb.toString();
  }

  String _jsonValue(dynamic v) {
    if (v == null) return 'null';
    if (v is String) return '"$v"';
    if (v is Map)  return _prettyJson(v as Map<String, dynamic>);
    if (v is List) return '[${v.map(_jsonValue).join(', ')}]';
    return '$v';
  }
}
