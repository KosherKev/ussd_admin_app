import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/models/org_summary.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

// ---------------------------------------------------------------------------
// OrgSummaryPage — Phase 11
//
// Design changes:
// - GradientHeader + GlassCard → Instrument Serif page-strip + AppCard
// - StatsCard → MetricCard
// - Payment type breakdown → fl_chart HorizontalBarChart inside AppCard
// ---------------------------------------------------------------------------
class OrgSummaryPage extends StatefulWidget {
  final String orgId;
  const OrgSummaryPage({super.key, required this.orgId});

  @override
  State<OrgSummaryPage> createState() => _OrgSummaryPageState();
}

class _OrgSummaryPageState extends State<OrgSummaryPage> {
  final _reports = ReportsService();

  bool     _loading = true;
  String?  _error;
  DateTime? _startDate;
  DateTime? _endDate;
  List<OrgSummaryStats> _stats = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final stats = await _reports.getOrgSummary(
        widget.orgId,
        startDate: _startDate,
        endDate:   _endDate,
      );
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
      }
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final c      = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context:     context,
      initialDate: (isStart ? _startDate : _endDate)
          ?? (isStart ? DateFormatters.startOfMonth : DateFormatters.endOfMonth),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate:  DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(primary: c.primaryAmber, onPrimary: Colors.black,
                  surface: c.bgSurface, onSurface: c.textPrimary)
              : ColorScheme.light(primary: c.primaryAmber, onPrimary: Colors.white,
                  surface: c.bgSurface, onSurface: c.textPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final totalCount  = _stats.fold<int>(0, (s, e) => s + e.count);
    final totalAmount = _stats.fold<double>(0.0, (s, e) => s + e.totalAmount);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Page strip header ──────────────────────────────────────────
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
                          'REPORTS',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(letterSpacing: 0.12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Org Summary',
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
                  // Export + refresh
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _IconBtn(icon: Icons.file_download_outlined, onTap: _exportCsv, c: c),
                    const SizedBox(width: AppSpacing.xs),
                    _IconBtn(
                      icon: _loading
                          ? Icons.hourglass_empty_rounded
                          : Icons.refresh_rounded,
                      onTap: _loading ? null : _fetch,
                      c: c,
                    ),
                  ]),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: c.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: c.textSecondary),
                              textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                          ]))
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          color: c.primaryAmber,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md, AppSpacing.md,
                                AppSpacing.md, AppSpacing.xxl),
                            children: [

                              // ── Date range filter ──────────────────────
                              AppCard(
                                child: Row(children: [
                                  Expanded(child: _DateBtn(
                                    label: _startDate == null
                                        ? 'Start date'
                                        : DateFormatters.formatDate(_startDate),
                                    onTap: () => _pickDate(isStart: true),
                                    c: c,
                                  )),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(child: _DateBtn(
                                    label: _endDate == null
                                        ? 'End date'
                                        : DateFormatters.formatDate(_endDate),
                                    onTap: () => _pickDate(isStart: false),
                                    c: c,
                                  )),
                                ]),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // ── Summary metric cards ───────────────────
                              Row(children: [
                                Expanded(child: MetricCard(
                                  label: 'TRANSACTIONS',
                                  value: CurrencyFormatters.formatNumber(totalCount),
                                )),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: MetricCard(
                                  label: 'TOTAL AMOUNT',
                                  value: CurrencyFormatters.formatCompactGHS(totalAmount),
                                )),
                              ]),

                              const SizedBox(height: AppSpacing.lg),

                              // ── Section label ──────────────────────────
                              Text(
                                'PAYMENT TYPE BREAKDOWN',
                                style: AppTypography.labelMono(c.textTertiary)
                                    .copyWith(fontSize: 10, letterSpacing: 0.12),
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // ── Breakdown ──────────────────────────────
                              _stats.isEmpty
                                  ? AppCard(
                                      child: Row(children: [
                                        Icon(Icons.inbox_outlined,
                                            color: c.textTertiary),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text('No data for selected range',
                                          style: Theme.of(context).textTheme.bodyMedium
                                              ?.copyWith(color: c.textSecondary)),
                                      ]),
                                    )
                                  : Column(children: [
                                      // Bar chart
                                      if (_stats.length > 1) ...[
                                        _buildBarChart(c),
                                        const SizedBox(height: AppSpacing.sm),
                                      ],
                                      // List rows
                                      AppCard(
                                        child: Column(
                                          children: _stats
                                              .asMap()
                                              .entries
                                              .map((entry) => Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: entry.key < _stats.length - 1
                                                        ? AppSpacing.sm
                                                        : 0),
                                                child: _buildTypeRow(entry.value, c),
                                              ))
                                              .toList(),
                                        ),
                                      ),
                                    ]),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Horizontal bar chart for payment type breakdown ──────────────────────
  Widget _buildBarChart(AppColors c) {
    final sorted = List<OrgSummaryStats>.from(_stats)
      ..sort((a, b) => b.count.compareTo(a.count));
    final maxCount = sorted.first.count.toDouble();

    final colours = [c.chart1, c.chart2, c.chart3, c.chart4];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.borderSubtle, width: 1),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final pct = maxCount == 0
              ? 0.0
              : (s.count / maxCount).clamp(0.0, 1.0);
          final color = colours[i % colours.length];

          return Padding(
            padding: EdgeInsets.only(bottom: i < sorted.length - 1
                ? AppSpacing.sm : 0),
            child: Row(children: [
              // Name
              SizedBox(
                width: 96,
                child: Text(
                  s.paymentTypeName,
                  style: AppTypography.labelMono(c.textSecondary)
                      .copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Bar track
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
              // Count
              SizedBox(
                width: 36,
                child: Text(
                  '${s.count}',
                  textAlign: TextAlign.right,
                  style: AppTypography.labelMono(c.textTertiary)
                      .copyWith(fontSize: 10),
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Payment type row ─────────────────────────────────────────────────────
  Widget _buildTypeRow(OrgSummaryStats s, AppColors c) {
    return Row(children: [
      Expanded(
        child: Text(
          s.paymentTypeName,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.textPrimary),
        ),
      ),
      Text(
        '${CurrencyFormatters.formatNumber(s.count)} txns',
        style: AppTypography.labelMono(c.textSecondary)
            .copyWith(fontSize: 11),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(
        CurrencyFormatters.formatCompactGHS(s.totalAmount),
        style: AppTypography.labelMono(c.textSecondary)
            .copyWith(fontSize: 11),
      ),
    ]);
  }

  // ── CSV export ────────────────────────────────────────────────────────────
  Future<void> _exportCsv() async {
    if (_stats.isEmpty) {
      DialogHelpers.showInfo(context, 'No data to export');
      return;
    }
    final header = ['Payment Type', 'Count', 'Total Amount'];
    final buffer = StringBuffer()..writeln(header.join(','));
    for (final s in _stats) {
      final row = [
        s.paymentTypeName,
        '${s.count}',
        CurrencyFormatters.formatGHS(s.totalAmount),
      ];
      buffer.writeln(row.map((v) => '"${v.replaceAll('"', '""')}"').join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    DialogHelpers.showSuccess(context, 'CSV copied to clipboard');
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.c, this.onTap});
  final IconData  icon;
  final AppColors c;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.borderMid, width: 1),
      ),
      child: Icon(icon, size: 17, color: c.textSecondary),
    ),
  );
}

class _DateBtn extends StatelessWidget {
  const _DateBtn({required this.label, required this.onTap, required this.c});
  final String     label;
  final VoidCallback onTap;
  final AppColors  c;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.borderMid, width: 1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_today_rounded, size: 13, color: c.textSecondary),
        const SizedBox(width: 6),
        Flexible(child: Text(
          label,
          style: AppTypography.labelMono(c.textSecondary).copyWith(fontSize: 10),
          overflow: TextOverflow.ellipsis,
        )),
      ]),
    ),
  );
}