import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/models/api_key.dart';
import '../../../shared/services/developer_service.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/metric_card.dart';
import '../../../widgets/filter_chips_row.dart';

class DeveloperDashboardPage extends StatefulWidget {
  const DeveloperDashboardPage({super.key});

  @override
  State<DeveloperDashboardPage> createState() => _DeveloperDashboardPageState();
}

class _DeveloperDashboardPageState extends State<DeveloperDashboardPage> {
  final _service = DeveloperService();

  KeyUsage? _usage;
  bool      _loading    = true;
  String?   _error;
  int       _periodDays = 30;
  String?   _keyId;

  static const _periodOptions = ['7d', '30d', '90d'];

  String get _selectedPeriod => '${_periodDays}d';

  @override
  void initState() {
    super.initState();
    _loadKeyId();
  }

  Future<void> _loadKeyId() async {
    final prefs = await SharedPreferences.getInstance();
    _keyId = prefs.getString('key_id');
    _load();
  }

  Future<void> _load() async {
    if (_keyId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final from = DateTime.now().subtract(Duration(days: _periodDays)).toIso8601String();
      final to   = DateTime.now().toIso8601String();
      final usage = await _service.getKeyUsage(_keyId!, from: from, to: to);
      if (mounted) setState(() { _usage = usage; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  void _selectPeriod(String? label) {
    if (label == null) return;
    final days = int.tryParse(label.replaceAll('d', '')) ?? 30;
    if (days == _periodDays) return;
    setState(() => _periodDays = days);
    _load();
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
            // ── Page header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEVELOPER',
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
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: c.primaryAmber),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _load,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: c.bgSurface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: c.borderMid, width: 1),
                        ),
                        child: Icon(Icons.refresh_rounded,
                            size: 18, color: c.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Period FilterChipsRow ──────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            FilterChipsRow(
              items:      _periodOptions,
              selected:   _selectedPeriod,
              includeAll: false,
              onSelect:   _selectPeriod,
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _keyId == null
                      ? _buildNoKeyPrompt(c)
                      : _error != null
                          ? _buildError(c)
                          : _usage == null
                              ? Center(child: Text(
                                  'No data available',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: c.textSecondary)))
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

  Widget _buildNoKeyPrompt(AppColors c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.key_off_outlined, size: 56, color: c.textTertiary),
        const SizedBox(height: AppSpacing.md),
        Text('No API Key linked',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your API key ID will be assigned when you log in.\n'
          'Contact your organisation admin if you need access.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
      ]),
    ),
  );

  Widget _buildError(AppColors c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 56, color: c.error),
        const SizedBox(height: AppSpacing.md),
        Text('Failed to load dashboard',
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
    final u  = _usage!;
    final t  = u.transactions;
    final w  = u.webhooks;
    final ch = t.byChannel;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
      children: [

        // ── 2×2 MetricCard grid ──────────────────────────────────────
        Row(children: [
          Expanded(child: MetricCard(
            label:     'TRANSACTIONS',
            value:     CurrencyFormatters.formatNumber(t.total),
            icon:      Icons.receipt_long_rounded,
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: MetricCard(
            label:     'SUCCESS RATE',
            value:     t.successRate != null
                ? '${t.successRate!.toStringAsFixed(1)}%'
                : '--',
            icon:      Icons.check_circle_outline_rounded,
            iconColor: c.success,
          )),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: MetricCard(
            label:     'NET VOLUME',
            value:     CurrencyFormatters.formatCompactGHS(t.totalNetVolume),
            icon:      Icons.account_balance_wallet_rounded,
            iconColor: c.info,
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: MetricCard(
            label:     'WEBHOOK OK',
            value:     w.successRate != null
                ? '${w.successRate!.toStringAsFixed(1)}%'
                : '--',
            icon:      Icons.webhook_rounded,
            iconColor: w.successRate != null && w.successRate! >= 90
                ? c.success
                : c.warning,
          )),
        ]),

        // ── Daily fl_chart BarChart ──────────────────────────────────
        if (u.daily.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSectionLabel('DAILY TRANSACTIONS', c),
          const SizedBox(height: AppSpacing.sm),
          _buildFlDailyChart(u.daily, c),
        ],

        // ── Channel breakdown ────────────────────────────────────────
        const SizedBox(height: AppSpacing.lg),
        _buildSectionLabel('PAYMENT CHANNELS', c),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(children: [
            _channelRow('Mobile Money', ch.mobileMoney, t.total,
                Icons.phone_android_rounded, c.chart1, c),
            const SizedBox(height: AppSpacing.sm),
            _channelRow('Card', ch.card, t.total,
                Icons.credit_card_rounded, c.chart2, c),
            const SizedBox(height: AppSpacing.sm),
            _channelRow('USSD Bridge', ch.ussdBridge, t.total,
                Icons.dialpad_rounded, c.chart3, c),
          ]),
        ),

        // ── Webhook health ───────────────────────────────────────────
        const SizedBox(height: AppSpacing.lg),
        _buildSectionLabel('WEBHOOK HEALTH', c),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(children: [
            _webhookRow('Delivered',          w.delivered, w.total, c.success, c),
            const SizedBox(height: AppSpacing.sm),
            _webhookRow('Retrying',           w.retrying,  w.total, c.warning, c),
            const SizedBox(height: AppSpacing.sm),
            _webhookRow('Permanently Failed', w.failed,    w.total, c.error,   c),
          ]),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ── fl_chart BarChart — daily ────────────────────────────────────────────
  Widget _buildFlDailyChart(List<DailyStat> daily, AppColors c) {
    final slice  = daily.take(14).toList();
    final maxVal = slice.isEmpty ? 1.0
        : slice.map((d) => d.total.toDouble()).reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal == 0 ? 1.0 : maxVal;

    final bars = slice.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY:          d.total.toDouble(),
            color:        c.primaryAmber.withValues(alpha: 0.85),
            width:        14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
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
        height: 120,
        child: BarChart(
          BarChartData(
            maxY: safeMax * 1.2,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: c.borderSubtle, strokeWidth: 1, dashArray: [4, 4]),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= slice.length) return const SizedBox.shrink();
                    // Show every other label to avoid crowding with 14 bars
                    if (i % 2 != 0) return const SizedBox.shrink();
                    final label = slice[i].date.length >= 5
                        ? slice[i].date.substring(5)   // MM-dd
                        : slice[i].date;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(label,
                        style: AppTypography.labelMono(c.textTertiary)
                            .copyWith(fontSize: 8)),
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
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${rod.toY.toInt()}',
                  AppTypography.labelMono(c.textPrimary).copyWith(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Channel row with LinearProgressIndicator + value label ──────────────
  Widget _channelRow(String label, int count, int total,
      IconData icon, Color color, AppColors c) {
    final pct = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    final pctStr = '${(pct * 100).toStringAsFixed(0)}%';

    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary)),
              Row(children: [
                Text(pctStr,
                  style: AppTypography.labelMono(c.textTertiary)
                      .copyWith(fontSize: 10)),
                const SizedBox(width: AppSpacing.xs),
                Text('$count',
                  style: AppTypography.labelMono(c.textSecondary)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              color: color,
              backgroundColor: c.bgHigh,
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── Webhook health row ───────────────────────────────────────────────────
  Widget _webhookRow(String label, int count, int total,
      Color color, AppColors c) {
    return Row(children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.textPrimary))),
      Text(
        '$count / $total',
        style: AppTypography.labelMono(c.textSecondary).copyWith(fontSize: 11),
      ),
    ]);
  }

  Widget _buildSectionLabel(String label, AppColors c) => Text(
    label,
    style: AppTypography.labelMono(c.textTertiary)
        .copyWith(fontSize: 10, letterSpacing: 0.12),
  );
}
