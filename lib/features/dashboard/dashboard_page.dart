import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/ussd_session_stats.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  final String orgId;
  const DashboardPage({super.key, required this.orgId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reportsService = ReportsService();

  bool             _loading = true;
  String?          _error;
  String?          _orgName;
  List<Transaction> _recent = [];
  int              _totalTxns    = 0;
  double           _totalAmount  = 0;
  double           _totalComm    = 0;
  Map<DateTime,int> _dailyCounts = {};
  Map<String, int>  _typeCounts  = {};
  Map<String,double>_typeAmounts = {};

  // USSD session stats (Phase 2C)
  List<UssdSessionStats> _ussdStats = [];
  int    _ussdTotal      = 0;
  double _ussdCompletion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      _orgName = prefs.getString('org_name');

      // 3B fallback: if org_name was never persisted (user logged in before
      // Phase 3B), fetch it now and cache it for subsequent loads.
      if ((_orgName == null || _orgName!.isEmpty) && widget.orgId.isNotEmpty) {
        try {
          final org = await OrgService().get(widget.orgId);
          _orgName = org.name;
          await prefs.setString('org_name', org.name);
        } catch (_) {
          // Non-fatal — greeting falls back to 'Dashboard'
        }
      }

      // Fetch transactions and USSD sessions concurrently
      final results = await Future.wait([
        _reportsService.getTransactions(
          organizationId: widget.orgId.isNotEmpty ? widget.orgId : null,
          startDate: DateFormatters.sevenDaysAgo,
          endDate:   DateTime.now(),
          page: 1, limit: 10,
        ),
        _reportsService.getUssdSessions(
          startDate: DateFormatters.sevenDaysAgo,
          endDate:   DateTime.now(),
        ),
      ]);

      final result    = results[0] as dynamic;
      final ussdStats = results[1] as List<UssdSessionStats>;

      _recent        = result.items as List<Transaction>;
      _totalTxns     = result.total as int;
      _totalAmount   = _recent.fold(0.0, (s, t) => s + t.amount);
      _totalComm     = _recent.fold(0.0, (s, t) => s + t.commission);
      _dailyCounts   = _buildDailyCounts(_recent);

      final bCounts  = <String, int>{};
      final bAmounts = <String, double>{};
      for (final t in _recent) {
        bCounts[t.paymentType]  = (bCounts[t.paymentType]  ?? 0) + 1;
        bAmounts[t.paymentType] = (bAmounts[t.paymentType] ?? 0) + t.amount;
      }
      _typeCounts  = bCounts;
      _typeAmounts = bAmounts;

      // USSD stats
      _ussdStats = ussdStats;
      _ussdTotal = ussdStats.fold(0, (s, e) => s + e.count);
      final completed = ussdStats
          .where((e) => e.status.toLowerCase() == 'completed')
          .fold(0, (s, e) => s + e.count);
      _ussdCompletion = _ussdTotal == 0 ? 0.0 : (completed / _ussdTotal) * 100;

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  Map<DateTime, int> _buildDailyCounts(List<Transaction> txs) {
    final now  = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final map  = {for (final d in days) d: 0};
    for (final t in txs) {
      final d = DateTime(t.initiatedAt.year, t.initiatedAt.month, t.initiatedAt.day);
      if (map.containsKey(d)) map[d] = (map[d] ?? 0) + 1;
    }
    return map;
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
              title: _orgName != null && _orgName!.isNotEmpty
                  ? _orgName!
                  : 'Dashboard',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  else
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, Routes.settingsProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? _buildError(c)
                      : RefreshIndicator(onRefresh: _load, child: _buildContent(c)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppColors c) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 56, color: c.error),
      const SizedBox(height: AppSpacing.md),
      Text('Failed to load dashboard', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary)),
      const SizedBox(height: AppSpacing.xs),
      Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.lg),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ]),
  );

  Widget _buildContent(AppColors c) => ListView(
    children: [
      // Stats row
      Text('Last 7 Days', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
      const SizedBox(height: AppSpacing.sm),
      StatsCard(label: 'Transactions',    value: CurrencyFormatters.formatNumber(_totalTxns),   icon: Icons.receipt_long_rounded),
      const SizedBox(height: AppSpacing.sm),
      StatsCard(label: 'Total Amount',    value: CurrencyFormatters.formatCompactGHS(_totalAmount), icon: Icons.account_balance_wallet_rounded),
      const SizedBox(height: AppSpacing.sm),
      StatsCard(label: 'Total Commission',value: CurrencyFormatters.formatGHS(_totalComm),      icon: Icons.payments_rounded),

      // USSD Sessions card (Phase 2C)
      if (_ussdStats.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: c.secondaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.dialpad_rounded, color: c.secondaryBlue, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('USSD Sessions', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
              Text(
                CurrencyFormatters.formatNumber(_ussdTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
              ),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Completion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
              Text(
                '${_ussdCompletion.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _ussdCompletion >= 70 ? c.success : c.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ]),
        ),
      ],

      const SizedBox(height: AppSpacing.md),

      // Quick actions row — Org Summary (2B) + Payouts (2A)
      Row(children: [
        Expanded(
          child: _quickActionCard(
            icon: Icons.bar_chart_rounded,
            label: 'Org Summary',
            color: c.info,
            onTap: widget.orgId.isNotEmpty
                ? () => Navigator.pushNamed(context, Routes.reportsOrgSummary, arguments: widget.orgId)
                : null,
            c: c,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _quickActionCard(
            icon: Icons.account_balance_rounded,
            label: 'Payouts',
            color: c.success,
            onTap: () => Navigator.pushNamed(context, Routes.payouts),
            c: c,
          ),
        ),
      ]),

      const SizedBox(height: AppSpacing.lg),

      // Weekly chart
      Text('Weekly Activity', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
      const SizedBox(height: AppSpacing.sm),
      GlassCard(child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: _buildWeeklyChart(c))),

      const SizedBox(height: AppSpacing.lg),

      // Payment type breakdown
      if (_typeCounts.isNotEmpty) ...[
        Text('Payment Types', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: _buildTypeBreakdown(c))),
        const SizedBox(height: AppSpacing.lg),
      ],

      // Recent transactions
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Recent Transactions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, Routes.reportsTransactions),
            child: const Text('View All'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),

      if (_recent.isEmpty)
        GlassCard(
          child: Column(children: [
            Icon(Icons.inbox_outlined, size: 40, color: c.textTertiary),
            const SizedBox(height: AppSpacing.sm),
            Text('No transactions yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
          ]),
        )
      else
        ..._recent.take(5).map((t) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildTxnCard(t, c),
        )),

      const SizedBox(height: AppSpacing.xxl),
    ],
  );

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    required AppColors c,
  }) =>
      GlassCard(
        onTap: onTap,
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onTap != null ? c.textPrimary : c.textDisabled,
              fontWeight: FontWeight.w600,
            ),
          )),
          Icon(Icons.chevron_right_rounded, color: onTap != null ? c.textTertiary : c.textDisabled, size: 18),
        ]),
      );

  Widget _buildWeeklyChart(AppColors c) {
    final entries = _dailyCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxVal  = entries.isEmpty ? 0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map((e) {
        final ratio  = maxVal == 0 ? 0.0 : (e.value / maxVal);
        final height = 80 * ratio + 6.0;
        // Show abbreviated weekday + short date (e.g. "Wed\n05 Mar")
        // so the user can identify which specific day each bar represents.
        final dayLabel  = DateFormatters.formatShortWeekday(e.key);   // "Wed"
        final dateLabel = DateFormatters.formatShortDate(e.key);      // "05 Mar"
        return Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              height: height,
              decoration: BoxDecoration(
                gradient: AppGradients.amber(colors: c),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$dayLabel\n$dateLabel',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: c.textTertiary,
                fontSize: 9,
                height: 1.3,
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildTypeBreakdown(AppColors c) {
    final keys = _typeCounts.keys.toList()..sort((a, b) => (_typeCounts[b] ?? 0).compareTo(_typeCounts[a] ?? 0));
    return Column(
      children: keys.map((k) {
        final count  = _typeCounts[k]  ?? 0;
        final amount = _typeAmounts[k] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(children: [
            Expanded(child: Text(k, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
            Text('${CurrencyFormatters.formatNumber(count)} txns',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
            const SizedBox(width: AppSpacing.md),
            Text(CurrencyFormatters.formatCompactGHS(amount),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildTxnCard(Transaction t, AppColors c) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.paymentType, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
            Text(DateFormatters.formatRelative(t.initiatedAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
          ])),
          StatusHelpers.buildStatusBadge(t.status),
        ],
      ),
      const SizedBox(height: AppSpacing.xs),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(CurrencyFormatters.formatGHS(t.amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
        Text(t.transactionRef, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary)),
      ]),
    ]),
  );
}
