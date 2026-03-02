import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/webhook_delivery.dart';
import '../../shared/services/developer_service.dart';
import '../../widgets/glass_card.dart';

class WebhookDeliveryDetailPage extends StatefulWidget {
  final String deliveryId;
  const WebhookDeliveryDetailPage({super.key, required this.deliveryId});

  @override
  State<WebhookDeliveryDetailPage> createState() => _WebhookDeliveryDetailPageState();
}

class _WebhookDeliveryDetailPageState extends State<WebhookDeliveryDetailPage> {
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
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  Color _statusColor(String s, AppColors c) {
    switch (s) {
      case 'delivered':          return c.success;
      case 'retrying':           return c.warning;
      case 'permanently_failed': return c.error;
      default:                   return c.textTertiary;
    }
  }

  String _fmt(String s) => s.replaceAll('_', ' ').split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Delivery Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline, size: 56, color: c.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : _buildContent(c),
    );
  }

  Widget _buildContent(AppColors c) {
    final d = _detail!;
    final statusColor = _statusColor(d.status, c);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Header card
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.event, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary)),
                if (d.projectName != null) Text(d.projectName!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: statusColor),
                ),
                child: Text(_fmt(d.status), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor)),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
            _row('Transaction', d.transactionRef, c, copyable: true),
            _row('Endpoint',    d.targetUrl,       c, copyable: true),
            _row('Attempts',    '${d.attemptCount}', c),
            if (d.deliveredAt != null) _row('Delivered at', DateFormatters.formatDateTime(DateTime.tryParse(d.deliveredAt!)), c),
          ]),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Payload
        if (d.payload != null) ...[
          Text('Payload', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('JSON', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary)),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _prettyJson(d.payload!)));
                    DialogHelpers.showSuccess(context, 'Payload copied');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy'),
                ),
              ]),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: c.surfaceMid, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _prettyJson(d.payload!),
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: c.textPrimary, height: 1.5),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Attempt history
        Text('Delivery Attempts', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        ...d.attempts.asMap().entries.map((e) {
          final attempt = e.value;
          final ok = (attempt.responseStatus ?? 0) >= 200 && (attempt.responseStatus ?? 0) < 300;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: ok ? c.success : c.error, shape: BoxShape.circle)),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Attempt #${attempt.attemptNumber ?? e.key + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (attempt.responseStatus != null)
                    Text('HTTP ${attempt.responseStatus}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ok ? c.success : c.error, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: AppSpacing.xs),
                if (attempt.attemptedAt != null)
                  Text(DateFormatters.formatDateTime(DateTime.tryParse(attempt.attemptedAt!)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                if (attempt.durationMs != null)
                  Text('${attempt.durationMs}ms',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary)),
                if (attempt.error != null && attempt.error!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('Error: ${attempt.error}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.error)),
                ],
              ]),
            ),
          );
        }),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _row(String label, String? value, AppColors c, {bool copyable = false}) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary))),
      Expanded(child: Text(value ?? '--', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textPrimary))),
      if (copyable)
        InkWell(
          onTap: () { Clipboard.setData(ClipboardData(text: value ?? '')); DialogHelpers.showSuccess(context, 'Copied'); },
          child: Icon(Icons.copy_outlined, size: 14, color: c.textTertiary),
        ),
    ]),
  );

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
    if (v is Map) return _prettyJson(v as Map<String, dynamic>);
    if (v is List) return '[${v.map(_jsonValue).join(', ')}]';
    return '$v';
  }
}
