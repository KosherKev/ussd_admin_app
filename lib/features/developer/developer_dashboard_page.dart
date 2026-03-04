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
import '../../../widgets/status_chip.dart';

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

  void _selectPeriod(String period) {
    final days = int.tryParse(period.replaceAll('d', '')) ?? 30;
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
            // ── Page header with period chips inline ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title group
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
                          'Analytics',
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
                  // Period chips — right side of header row (matches mockup strip-actions)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _periodOptions.map((opt) {
                      final active = opt == _selectedPeriod;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: GestureDetector(
                          onTap: () => _selectPeriod(opt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: active ? c.primaryAmber : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: active ? c.primaryAmber : c.borderMid,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: AppTypography.labelMono(
                                active ? c.background : c.textSecondary,
                              ).copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_loading) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: c.primaryAmber),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Body ───────────────────────────────────────────────────────
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
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
      children: [

        // ── 2×2 MetricCard grid ────────────────────────────────────────
        // Matches mockup .dev-metric-grid: no icons, Instrument Serif values,
        // success metrics get green value colour.
        Row(children: [
          Expanded(child: MetricCard(
            label:    'TRANSACTIONS',
            value:    CurrencyFormatters.formatNumber(t.total),
            subLabel: t.total > 0 ? '↑ vs prior period' : null,
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: MetricCard(
            label:      'SUCCESS RATE',
            value:      t.successRate != null
                ? '${t.successRate!.toStringAsFixed(1)}%'
                : '--',
            valueColor: c.success,
            subLabel:   '↑ 1.1pp',
          )),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: MetricCard(
            label:    'NET VOLUME',
            value:    CurrencyFormatters.formatCompactGHS(t.totalNetVolume),
            subLabel: '↑ 14.7%',
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: MetricCard(
            label:      'WEBHOOK OK',
            value:      w.successRate != null
                ? '${w.successRate!.toStringAsFixed(1)}%'
                : '--',
            valueColor: w.successRate != null && w.successRate! >= 90
                ? c.success
                : c.warning,
            subLabel:   '↓ 0.3pp',
          )),
        ]),

        // ── Daily fl_chart BarChart ────────────────────────────────────
        if (u.daily.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSectionLabel('DAILY TRANSACTIONS', c),
          const SizedBox(height: AppSpacing.sm),
          _buildFlDailyChart(u.daily, c),
        ],

        // ── Channel breakdown ──────────────────────────────────────────
        const SizedBox(height: AppSpacing.lg),
        _buildSectionLabel('PAYMENT CHANNELS', c),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(children: [
            _channelRow('Mobile Money', ch.mobileMoney, t.total, c.chart1, c),
            const SizedBox(height: AppSpacing.sm),
            _channelRow('Card', ch.card, t.total, c.chart2, c),
            const SizedBox(height: AppSpacing.sm),
            _channelRow('USSD Bridge', ch.ussdBridge, t.total, c.chart3, c),
          ]),
        ),

        // ── Webhook health — individual cards per item ─────────────────
        // Matches mockup .webhook-list / .webhook-item (each item is its own card).
        const SizedBox(height: AppSpacing.lg),
        _buildSectionLabel('WEBHOOK HEALTH', c),
        const SizedBox(height: AppSpacing.sm),
        _webhookItem(
          event:   'Delivered',
          count:   w.delivered,
          total:   w.total,
          dotColor: c.success,
          status:   'delivered',
          c: c,
        ),
        const SizedBox(height: AppSpacing.xs),
        _webhookItem(
          event:    'Retrying',
          count:    w.retrying,
          total:    w.total,
          dotColor: c.warning,
          status:   'pending',
          c: c,
        ),
        const SizedBox(height: AppSpacing.xs),
        _webhookItem(
          event:    'Failed',
          count:    w.failed,
          total:    w.total,
          dotColor: c.error,
          status:   'failed',
          c: c,
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ── fl_chart BarChart — daily ──────────────────────────────────────────
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
                    if (i % 2 != 0) return const SizedBox.shrink();
                    final label = slice[i].date.length >= 5
                        ? slice[i].date.substring(5)
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

  // ── Channel row — no icon, DM Mono channel name (matches mockup .channel-row)
  Widget _channelRow(String label, int count, int total,
      Color color, AppColors c) {
    final pct    = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    final countStr = '$count';

    return Row(children: [
      // Channel name — DM Mono 11px secondary
      SizedBox(
        width: 88,
        child: Text(
          label,
          style: AppTypography.labelMono(c.textSecondary)
              .copyWith(fontSize: 11),
        ),
      ),
      // Progress track
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            color: color,
            backgroundColor: c.bgHigh,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      // Count — DM Mono 11px tertiary, right-aligned in 28px box
      SizedBox(
        width: 28,
        child: Text(
          countStr,
          textAlign: TextAlign.right,
          style: AppTypography.labelMono(c.textTertiary)
              .copyWith(fontSize: 11),
        ),
      ),
    ]);
  }

  // ── Webhook health item — individual bordered card (matches mockup .webhook-item)
  Widget _webhookItem({
    required String    event,
    required int       count,
    required int       total,
    required Color     dotColor,
    required String    status,
    required AppColors c,
  }) {
    final ref = '$count of $total';

    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(children: [
        // Status dot
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Event + ref
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ref,
                style: AppTypography.labelMono(c.textTertiary)
                    .copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        // Status badge — string-based auto-resolve
        StatusChip(status: status, compact: true),
      ]),
    );
  }

  Widget _buildSectionLabel(String label, AppColors c) => Text(
    label,
    style: AppTypography.labelMono(c.textTertiary)
        .copyWith(fontSize: 10, letterSpacing: 0.12),
  );
}
