import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/models/org_summary.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';

class OrgSummaryPage extends StatefulWidget {
  final String orgId;
  const OrgSummaryPage({super.key, required this.orgId});

  @override
  State<OrgSummaryPage> createState() => _OrgSummaryPageState();
}

class _OrgSummaryPageState extends State<OrgSummaryPage> {
  final _reports = ReportsService();

  bool _loading = true;
  String? _error;
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
      final stats = await _reports.getOrgSummary(widget.orgId, startDate: _startDate, endDate: _endDate);
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final c = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate)
          ?? (isStart ? DateFormatters.startOfMonth : DateFormatters.endOfMonth),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(primary: c.primaryAmber, onPrimary: Colors.black, surface: c.surfaceLow, onSurface: c.textPrimary)
              : ColorScheme.light(primary: c.primaryAmber, onPrimary: Colors.white, surface: c.surfaceLow, onSurface: c.textPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final totalCount  = _stats.fold<int>(0, (sum, s) => sum + s.count);
    final totalAmount = _stats.fold<double>(0.0, (sum, s) => sum + s.totalAmount);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Org Summary'),
        backgroundColor: c.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(
            title: 'Summary',
            trailing: IconButton(icon: const Icon(Icons.file_download_outlined, color: Colors.white), onPressed: _exportCsv),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Column(children: [
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: true),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(_startDate == null ? 'Start Date' : DateFormatters.formatDate(_startDate)),
                )),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: false),
                  icon: const Icon(Icons.event_rounded, size: 16),
                  label: Text(_endDate == null ? 'End Date' : DateFormatters.formatDate(_endDate)),
                )),
              ]),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(width: double.infinity,
                child: ElevatedButton(onPressed: _fetch, child: const Text('Apply')),
              ),
            ]),
          ),

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                : _error != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.error_outline, size: 64, color: c.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                      ]))
                    : ListView(children: [
                        StatsCard(label: 'Total Transactions', value: CurrencyFormatters.formatNumber(totalCount), icon: Icons.receipt_long_rounded),
                        const SizedBox(height: AppSpacing.sm),
                        StatsCard(label: 'Total Amount', value: CurrencyFormatters.formatCompactGHS(totalAmount), icon: Icons.account_balance_wallet_rounded),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Payment Type Breakdown', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(
                          child: _stats.isEmpty
                              ? Row(children: [
                                  Icon(Icons.inbox_outlined, color: c.textTertiary),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text('No data for selected range', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
                                ])
                              : Column(
                                  children: _stats.map((s) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                    child: Row(children: [
                                      Expanded(child: Text(s.paymentTypeName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
                                      Text(CurrencyFormatters.formatNumber(s.count), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                                      const SizedBox(width: AppSpacing.md),
                                      Text(CurrencyFormatters.formatCompactGHS(s.totalAmount), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                                    ]),
                                  )).toList(),
                                ),
                        ),
                      ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_stats.isEmpty) { DialogHelpers.showInfo(context, 'No data to export'); return; }
    final header = ['Payment Type', 'Count', 'Total Amount'];
    final buffer = StringBuffer();
    buffer.writeln(header.join(','));
    for (final s in _stats) {
      final row = [s.paymentTypeName, '${s.count}', CurrencyFormatters.formatGHS(s.totalAmount)];
      buffer.writeln(row.map((v) => '"${v.replaceAll('"', '""')}"').join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    DialogHelpers.showSuccess(context, 'CSV copied to clipboard');
  }
}