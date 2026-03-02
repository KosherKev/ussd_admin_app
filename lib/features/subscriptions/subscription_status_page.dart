import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/subscription.dart';
import '../../shared/services/subscription_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

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
      appBar: AppBar(
        title: const Text('Subscription Status'),
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
          : _error != null
              ? _buildError(c)
              : _buildContent(c),
    );
  }

  Widget _buildError(AppColors c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 64, color: c.error),
        const SizedBox(height: AppSpacing.md),
        Text('Error Loading Subscription', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _buildContent(AppColors c) {
    if (_subscription == null) return const SizedBox();
    final sub = _subscription!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(title: 'Subscription Details'),
          const SizedBox(height: AppSpacing.lg),

          // Status card
          GlassCard(
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: sub.isActive
                      ? AppGradients.amber(colors: c)
                      : LinearGradient(colors: [c.surfaceHigh, c.surfaceMid]),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  sub.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 40, color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              StatusHelpers.buildStatusBadge(sub.status),
              const SizedBox(height: AppSpacing.md),
              Text(
                sub.isActive ? 'Subscription Active' : sub.isCancelled ? 'Subscription Cancelled' : 'Subscription Inactive',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary),
              ),
            ]),
          ),

          const SizedBox(height: AppSpacing.md),

          // Details card
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Subscription Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              _infoRow(Icons.calendar_today_rounded, 'Billing Period', sub.billingPeriod.toUpperCase(), c),
              if (sub.startDate != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.play_arrow_rounded, 'Start Date', DateFormatters.formatDate(sub.startDate), c),
              ],
              if (sub.endDate != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.event_rounded, 'End Date', DateFormatters.formatDate(sub.endDate), c),
              ],
              if (sub.gracePeriodEndDate != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.timer_rounded, 'Grace Period End', DateFormatters.formatDate(sub.gracePeriodEndDate), c),
              ],
            ]),
          ),

          const SizedBox(height: AppSpacing.md),

          // USSD status card
          GlassCard(
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (sub.ussdEnabled ? c.success : c.textTertiary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  sub.ussdEnabled ? Icons.phone_android_rounded : Icons.phonelink_off_rounded,
                  color: sub.ussdEnabled ? c.success : c.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('USSD Service', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textPrimary)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  sub.ussdEnabled ? 'Enabled' : 'Disabled',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: sub.ussdEnabled ? c.success : c.textSecondary),
                ),
              ])),
            ]),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, AppColors c) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: c.primaryAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, size: 20, color: c.primaryAmber),
    ),
    const SizedBox(width: AppSpacing.md),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
      const SizedBox(height: AppSpacing.xxs),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary)),
    ])),
  ]);
}
