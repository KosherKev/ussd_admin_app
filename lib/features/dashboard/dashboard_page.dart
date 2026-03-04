import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/ussd_session_stats.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

class DashboardPage extends StatefulWidget {
  final String orgId;
  const DashboardPage({super.key, required this.orgId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reportsService = ReportsService();

  bool               _loading     = true;
  String?            _error;
  String?            _orgName;
  List<Transaction>  _recent      = [];
  int                _totalTxns   = 0;
  double             _totalAmount = 0;
  double             _totalComm   = 0;
  Map<DateTime, int> _dailyCounts = {};
  Map<String, int>   _typeCounts  = {};
  Map<String, double>_typeAmounts = {};

  List<UssdSessionStats> _ussdStats      = [];
  int                    _ussdTotal      = 0;
  double                 _ussdCompletion = 0;

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

      if ((_orgName == null || _orgName!.isEmpty) && widget.orgId.isNotEmpty) {
        try {
          final org = await OrgService().get(widget.orgId);
          _orgName = org.name;
          await prefs.setString('org_name', org.name);
        } catch (_) {}
      }

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

      _recent      = result.items as List<Transaction>;
      _totalTxns   = result.total as int;
      _totalAmount = _recent.fold(0.0, (s, t) => s + t.amount);
      _totalComm   = _recent.fold(0.0, (s, t) => s + t.commission);
      _dailyCounts = _buildDailyCounts(_recent);

      final bCounts  = <String, int>{};
      final bAmounts = <String, double>{};
      for (final t in _recent) {
        bCounts[t.paymentType]  = (bCounts[t.paymentType]  ?? 0) + 1;
        bAmounts[t.paymentType] = (bAmounts[t.paymentType] ?? 0) + t.amount;
      }
      _typeCounts  = bCounts;
      _typeAmounts = bAmounts;

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
    final days = List.generate(7, (i) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c),
            Divider(height: 1, color: c.borderSubtle),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? _buildError(c)
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: c.primaryAmber,
                          child: _buildContent(c),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_orgName != null && _orgName!.isNotEmpty)
                  Text(
                    _orgName!.toUpperCase(),
                    style: AppTypography.labelMono(c.primaryAmber)
                        .copyWith(letterSpacing: 0.12),
                  ),
                const SizedBox(height: 2),
                Text(
                  'Dashboard',
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
          Row(mainAxisSize: MainAxisSize.min, children: [
            _HeaderIconBtn(icon: Icons.refresh_rounded, onTap: _load, c: c),
            const SizedBox(width: AppSpacing.xs),
            _HeaderIconBtn(
              icon: Icons.account_circle_outlined,
              onTap: () => Navigator.pushNamed(context, Routes.settingsProfile),
              c: c,
            ),
          ]),
        ],
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

  Widget _buildContent(AppColors c) => ListView(
    padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
    children: [
      _buildHeroCard(c),
      const SizedBox(height: AppSpacing.sm),

      // 2-col metric grid (no icons — matches mockup .stat-cell)
      Row(children: [
        Expanded(child: MetricCard(
          label: 'TRANSACTIONS',
          value: CurrencyFormatters.formatNumber(_totalTxns),
        )),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: MetricCard(
          label: 'COMMISSION',
          value: 'GHS ${CurrencyFormatters.formatNumber(_totalComm.round())}',
        )),
      ]),
      if (_ussdStats.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: MetricCard(
            label: 'USSD SESSIONS',
            value: CurrencyFormatters.formatNumber(_ussdTotal),
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: MetricCard(
            label:      'COMPLETION',
            value:      '${_ussdCompletion.toStringAsFixed(1)}%',
            valueColor: _ussdCompletion >= 70 ? c.success : c.warning,
          )),
        ]),
      ],

      const SizedBox(height: AppSpacing.lg),
      _buildSectionLabel('DAILY ACTIVITY', c),
      const SizedBox(height: AppSpacing.sm),
      _buildFlBarChart(c),

      const SizedBox(height: AppSpacing.lg),
      Row(children: [
        Expanded(child: _buildQuickAction(
          icon:  Icons.bar_chart_rounded,
          label: 'Org Summary',
          color: c.info,
          onTap: widget.orgId.isNotEmpty
              ? () => Navigator.pushNamed(context, Routes.reportsOrgSummary,
                        arguments: widget.orgId)
              : null,
          c: c,
        )),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildQuickAction(
          icon:  Icons.account_balance_rounded,
          label: 'Payouts',
          color: c.success,
          onTap: () => Navigator.pushNamed(context, Routes.payouts),
          c: c,
        )),
      ]),

      if (_typeCounts.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.lg),
        _buildSectionLabel('PAYMENT TYPES', c),
        const SizedBox(height: AppSpacing.sm),
        _buildTypeBreakdown(c),
      ],

      const SizedBox(height: AppSpacing.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSectionLabel('RECENT', c),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, Routes.reportsTransactions),
            child: Text('View all →',
                style: AppTypography.labelMono(c.primaryAmber)
                    .copyWith(fontSize: 12)),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),

      if (_recent.isEmpty)
        AppCard(
          child: Column(children: [
            Icon(Icons.inbox_outlined, size: 40, color: c.textTertiary),
            const SizedBox(height: AppSpacing.sm),
            Text('No transactions yet',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: c.textSecondary)),
          ]),
        )
      else
        ..._recent.take(5).map((t) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _buildTxnItem(t, c),
        )),
    ],
  );

  // ── Hero stat card ────────────────────────────────────────────────────────
  Widget _buildHeroCard(AppColors c) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final completed = _recent
        .where((t) => t.status.toLowerCase().contains('complet')).length;
    final failed    = _recent
        .where((t) => t.status.toLowerCase().contains('fail')).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.borderMid, width: 1),
        gradient: RadialGradient(
          center: const Alignment(0.9, -0.9),
          radius: 0.9,
          colors: [
            c.primaryAmber.withValues(alpha: isDark ? 0.08 : 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
                color: c.primaryAmber, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text('TOTAL VOLUME · 7 DAYS',
              style: AppTypography.labelMono(c.textTertiary)
                  .copyWith(letterSpacing: 0.10)),
        ]),
        const SizedBox(height: AppSpacing.md),

        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'GHS ',
              style: GoogleFonts.dmMono(
                  fontSize: 18, fontWeight: FontWeight.w400,
                  color: c.textTertiary),
            ),
            TextSpan(
              text: CurrencyFormatters.formatNumber(_totalAmount.round()),
              style: GoogleFonts.instrumentSerif(
                fontSize: 52,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: c.textPrimary,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: c.successBg,
              border: Border.all(color: c.successBorder, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                    color: c.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('+12.4%',
                  style: AppTypography.labelMono(c.success)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('vs last week',
              style: AppTypography.labelMono(c.textTertiary)
                  .copyWith(fontSize: 11)),
        ]),
        const SizedBox(height: AppSpacing.sm),

        Text(
          '$completed completed · $failed failed · last updated now',
          style: AppTypography.monoBody(c.textTertiary).copyWith(fontSize: 11),
        ),
      ]),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label, AppColors c) => Text(
    label,
    style: AppTypography.labelMono(c.textTertiary)
        .copyWith(fontSize: 10, letterSpacing: 0.12),
  );

  // ── fl_chart BarChart ─────────────────────────────────────────────────────
  Widget _buildFlBarChart(AppColors c) {
    final entries = _dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final now    = DateTime.now();
    final todayD = DateTime(now.year, now.month, now.day);
    final maxVal = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final safeMax = (maxVal == 0 ? 1 : maxVal).toDouble();

    final bars = entries.asMap().entries.map((entry) {
      final i       = entry.key;
      final e       = entry.value;
      final isToday = e.key == todayD;
      final color   = e.value == 0
          ? c.bgHigh
          : isToday
              ? c.primaryAmber
              : c.primaryAmber.withValues(alpha: 0.75);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: color,
            width: 22,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(3)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: safeMax,
              color: Colors.transparent,
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.borderSubtle, width: 1),
      ),
      child: SizedBox(
        height: 130,
        child: BarChart(
          BarChartData(
            maxY: safeMax * 1.15,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                  color: c.borderSubtle,
                  strokeWidth: 1,
                  dashArray: [4, 4]),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= entries.length) {
                      return const SizedBox.shrink();
                    }
                    final isToday = entries[i].key == todayD;
                    final label = DateFormatters
                        .formatShortWeekday(entries[i].key)
                        .substring(0, 2);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        label,
                        style: AppTypography.labelMono(
                          isToday ? c.primaryAmber : c.textTertiary,
                        ).copyWith(fontSize: 9, letterSpacing: 0.05),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: bars,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => c.bgOverlay,
                tooltipRoundedRadius: AppRadius.xs,
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                  '${rod.toY.toInt()}',
                  AppTypography.labelMono(c.textPrimary)
                      .copyWith(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Quick action ──────────────────────────────────────────────────────────
  Widget _buildQuickAction({
    required IconData icon,
    required String   label,
    required Color    color,
    required VoidCallback? onTap,
    required AppColors c,
  }) =>
      AppCard(
        onTap: onTap,
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onTap != null ? c.textPrimary : c.textDisabled,
                fontWeight: FontWeight.w600,
              ))),
          Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 16),
        ]),
      );

  // ── Payment type breakdown ────────────────────────────────────────────────
  Widget _buildTypeBreakdown(AppColors c) {
    final keys = _typeCounts.keys.toList()
      ..sort((a, b) =>
          (_typeCounts[b] ?? 0).compareTo(_typeCounts[a] ?? 0));
    return AppCard(
      child: Column(
        children: keys.map((k) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(children: [
            Expanded(child: Text(k,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: c.textPrimary))),
            Text(
              '${CurrencyFormatters.formatNumber(_typeCounts[k] ?? 0)} txns',
              style: AppTypography.labelMono(c.textSecondary)
                  .copyWith(fontSize: 11),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              CurrencyFormatters.formatCompactGHS(_typeAmounts[k] ?? 0),
              style: AppTypography.labelMono(c.textSecondary)
                  .copyWith(fontSize: 11),
            ),
          ]),
        )).toList(),
      ),
    );
  }

  // ── Transaction item ──────────────────────────────────────────────────────
  Widget _buildTxnItem(Transaction t, AppColors c) {
    final s = t.status.toLowerCase();
    final barColor = s.contains('complet')
        ? c.success
        : s.contains('fail')
            ? c.error
            : c.warning;

    return AppCard(
      variant:     AppCardVariant.accent,
      accentColor: barColor,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(t.paymentType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 2),
            Text(t.transactionRef,
                style: AppTypography.labelMono(c.textTertiary)
                    .copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(CurrencyFormatters.formatGHS(t.amount),
              style: GoogleFonts.dmMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary)),
          const SizedBox(height: 2),
          Text(DateFormatters.formatRelative(t.initiatedAt),
              style: AppTypography.labelMono(c.textTertiary)
                  .copyWith(fontSize: 10)),
        ]),
      ]),
    );
  }
}

// ── Header icon button ────────────────────────────────────────────────────────
class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn(
      {required this.icon, required this.onTap, required this.c});
  final IconData     icon;
  final VoidCallback onTap;
  final AppColors    c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.borderMid, width: 1),
        ),
        child: Icon(icon, size: 18, color: c.textSecondary),
      ),
    );
  }
}
