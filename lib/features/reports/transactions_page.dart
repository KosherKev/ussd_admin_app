import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/paged.dart';
import '../../shared/services/reports_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _reports = ReportsService();

  bool _loading = true;
  String? _error;
  String? _orgId;

  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;

  Paged<Transaction>? _paged;

  static const _statuses = ['completed', 'pending', 'failed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _orgId = prefs.getString('org_id');
    _fetch(page: 1);
  }

  Future<void> _fetch({int page = 1}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _reports.getTransactions(
        organizationId: _orgId?.isNotEmpty == true ? _orgId : null,
        status:    _status,
        startDate: _startDate,
        endDate:   _endDate,
        page:      page,
        limit:     15,
      );
      if (mounted) setState(() { _paged = res; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final c = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now().subtract(const Duration(days: 7)),
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
    final pages = _paged == null || _paged!.limit <= 0 ? 1 : ((_paged!.total + _paged!.limit - 1) ~/ _paged!.limit);

    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(
            title: 'Transactions',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loading)
                  const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                else
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _fetch(page: _paged?.page ?? 1)),
                IconButton(
                    icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                    tooltip: 'Export current page as CSV',
                    onPressed: _exportCsv,
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Filters
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chips
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [null, ..._statuses].map((s) {
                      final sel = _status == s;
                      final label = s == null ? 'All' : StatusHelpers.formatStatus(s);
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _status = s);
                            // Auto-apply on status chip tap — consistent with
                            // DeveloperTransactionsPage and WebhooksListPage.
                            _fetch(page: 1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: sel ? c.primaryAmber : c.surfaceMid,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(label,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: sel ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white) : c.textSecondary,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Date range row
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(_startDate == null ? 'Start Date' : DateFormatters.formatDate(_startDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.event_rounded, size: 16),
                      label: Text(_endDate == null ? 'End Date' : DateFormatters.formatDate(_endDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textPrimary)),
                    ),
                  ),
                ]),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _fetch(page: 1),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                : _error != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.error_outline, size: 56, color: c.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(onPressed: () => _fetch(page: 1), child: const Text('Retry')),
                      ]))
                    : RefreshIndicator(
                        onRefresh: () => _fetch(page: _paged?.page ?? 1),
                        child: (_paged?.items.isEmpty ?? true)
                            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.inbox_outlined, size: 56, color: c.textTertiary),
                                const SizedBox(height: AppSpacing.md),
                                Text('No transactions found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
                              ]))
                            : ListView.separated(
                                itemCount: _paged!.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (ctx, i) => _buildCard(_paged!.items[i], c),
                              ),
                      ),
          ),

          // Pagination bar
          if (_paged?.items.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Page ${_paged!.page} / $pages  (${_paged!.total})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: c.primaryAmber,
                      onPressed: _loading || _paged!.page <= 1 ? null : () => _fetch(page: _paged!.page - 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: c.primaryAmber,
                      onPressed: _loading || _paged!.page >= pages ? null : () => _fetch(page: _paged!.page + 1),
                    ),
                  ]),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  Widget _buildCard(Transaction t, AppColors c) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.paymentType, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
          Text(t.organizationName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
        ])),
        StatusHelpers.buildStatusBadge(t.status),
      ]),
      const SizedBox(height: AppSpacing.xs),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(CurrencyFormatters.formatGHS(t.amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(DateFormatters.formatRelative(t.initiatedAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
          Text(t.transactionRef, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis),
        ]),
      ]),
    ]),
  );

  Future<void> _exportCsv() async {
    final items = _paged?.items ?? [];
    if (items.isEmpty) { DialogHelpers.showInfo(context, 'No transactions to export'); return; }
    final header = ['Payment Type', 'Status', 'Amount', 'Date', 'Reference'];
    final rows   = items.map((t) => [t.paymentType, t.status, CurrencyFormatters.formatGHS(t.amount), DateFormatters.formatDateTime(t.initiatedAt), t.transactionRef]);
    final buffer = StringBuffer();
    buffer.writeln(header.join(','));
    for (final r in rows) {
      buffer.writeln(r.map((v) => '"${v.toString().replaceAll('"', '""')}"').join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    // Clearly state page scope so user knows this is not the full dataset.
    final page  = _paged!.page;
    final total = _paged!.total;
    DialogHelpers.showSuccess(
      context,
      'Page $page copied — ${items.length} rows (${items.length} of $total total)',
    );
  }
}