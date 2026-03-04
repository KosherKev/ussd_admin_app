import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/payout.dart';
import '../../shared/services/payout_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PayoutsPage extends StatefulWidget {
  const PayoutsPage({super.key});

  @override
  State<PayoutsPage> createState() => _PayoutsPageState();
}

class _PayoutsPageState extends State<PayoutsPage> {
  final _service = PayoutService();

  List<Payout> _payouts = [];
  bool    _loading = true;
  String? _error;
  String? _orgId;

  // Per-item processing guard: maps payout id -> processing bool
  final Map<String, bool> _processing = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _orgId = prefs.getString('org_id');
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.listPending();
      if (mounted) setState(() { _payouts = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  Future<void> _schedulePayout() async {
    final orgId = _orgId;
    if (orgId == null || orgId.isEmpty) {
      DialogHelpers.showError(context, 'No organisation linked to this account.');
      return;
    }

    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Schedule Payout',
      message: 'Schedule a new payout for your organisation? This will queue all settled transactions for disbursement.',
      confirmText: 'Schedule',
    );
    if (!confirmed || !mounted) return;

    setState(() => _loading = true);
    try {
      final count = await _service.schedule(orgId);
      if (mounted) {
        DialogHelpers.showSuccess(context, 'Payout scheduled — $count transaction(s) queued.');
        _load();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _processPayout(Payout payout) async {
    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Process Payout',
      message: 'Process payout of ${CurrencyFormatters.formatGHS(payout.netAmount)} for ${payout.organizationName}?',
      confirmText: 'Process',
    );
    if (!confirmed || !mounted) return;

    setState(() => _processing[payout.id] = true);
    try {
      final ref = await _service.process(payout.id);
      if (mounted) {
        DialogHelpers.showSuccess(context, 'Payout processed — Ref: $ref');
        _load();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
        setState(() => _processing[payout.id] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              title: 'Payouts',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _load,
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Schedule button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _schedulePayout,
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Schedule New Payout'),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Summary label
            Row(
              children: [
                Text(
                  'Pending Payouts',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
                ),
                const Spacer(),
                if (!_loading && _payouts.isNotEmpty)
                  Text(
                    '${_payouts.length} item${_payouts.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? _buildError(c)
                      : _payouts.isEmpty
                          ? _buildEmpty(c)
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                itemCount: _payouts.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (ctx, i) => _buildPayoutCard(_payouts[i], c),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppColors c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 56, color: c.error),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Failed to load payouts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _error!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _buildEmpty(AppColors c) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.account_balance_wallet_outlined, size: 64, color: c.textTertiary),
      const SizedBox(height: AppSpacing.md),
      Text(
        'No Pending Payouts',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'All payouts have been processed, or none have been scheduled yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        textAlign: TextAlign.center,
      ),
    ]),
  );

  Widget _buildPayoutCard(Payout payout, AppColors c) {
    final isProcessing = _processing[payout.id] == true;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.primaryAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.account_balance_rounded, color: c.primaryAmber, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout.organizationName.isNotEmpty
                          ? payout.organizationName
                          : 'Organisation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (payout.payoutRef != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        payout.payoutRef!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: c.textTertiary,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(payout.status, c),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Amount + scheduled date row
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  label: 'Net Amount',
                  value: CurrencyFormatters.formatGHS(payout.netAmount),
                  icon: Icons.payments_rounded,
                  c: c,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _infoTile(
                  label: 'Scheduled',
                  value: payout.scheduledDate != null
                      ? DateFormatters.formatDate(payout.scheduledDate)
                      : 'Immediate',
                  icon: Icons.calendar_today_rounded,
                  c: c,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Process button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isProcessing || payout.status == 'processed')
                  ? null
                  : () => _processPayout(payout),
              icon: isProcessing
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(isProcessing ? 'Processing...' : 'Process Payout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
    required AppColors c,
  }) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.surfaceMid,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: c.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildStatusBadge(String status, AppColors c) {
    Color color;
    switch (status.toLowerCase()) {
      case 'processed':
        color = c.success;
        break;
      case 'pending':
        color = c.warning;
        break;
      case 'failed':
        color = c.error;
        break;
      default:
        color = c.textTertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color),
      ),
      child: Text(
        StatusHelpers.formatStatus(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
