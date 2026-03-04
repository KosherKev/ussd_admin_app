import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/paged.dart';
import '../../shared/services/reports_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/filter_chips_row.dart';
import '../../widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// TransactionsPage — Phase 11
//
// Design changes vs previous implementation:
// - GradientHeader → plain page-strip header (Instrument Serif title)
// - GlassCard filter panel → collapsible AnimatedContainer (tap filter icon)
// - Status chips → FilterChipsRow widget
// - Date row → two ghost-style buttons (always visible below chips)
// - Transaction cards → AppCard accent variant with 3px left status bar
// - Pagination → borderless row (borderSubtle divider top), no GlassCard
// ---------------------------------------------------------------------------
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _reports = ReportsService();

  bool     _loading      = true;
  String?  _error;
  String?  _orgId;
  bool     _filtersOpen  = false;

  // Filters
  String?   _status;
  DateTime? _startDate;
  DateTime? _endDate;

  Paged<Transaction>? _paged;

  // Status options — labels match StatusChip auto-resolve patterns
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
    final c      = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context:     context,
      initialDate: (isStart ? _startDate : _endDate)
          ?? DateTime.now().subtract(const Duration(days: 7)),
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
      _fetch(page: 1);
    }
  }

  void _clearFilters() {
    setState(() { _status = null; _startDate = null; _endDate = null; });
    _fetch(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final c     = context.appColors;
    final pages = _paged == null || _paged!.limit <= 0
        ? 1
        : ((_paged!.total + _paged!.limit - 1) ~/ _paged!.limit);
    final hasFilters = _status != null || _startDate != null || _endDate != null;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Page strip header ────────────────────────────────────────
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
                          'REPORTS',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(letterSpacing: 0.12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Transactions',
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
                  // Action buttons
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _HeaderBtn(
                      icon: Icons.file_download_outlined,
                      onTap: _exportCsv,
                      c: c,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _HeaderBtn(
                      icon: _loading
                          ? Icons.hourglass_empty_rounded
                          : Icons.refresh_rounded,
                      onTap: _loading
                          ? null
                          : () => _fetch(page: _paged?.page ?? 1),
                      c: c,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Filter toggle — highlights when filters active
                    _HeaderBtn(
                      icon: Icons.tune_rounded,
                      onTap: () => setState(() => _filtersOpen = !_filtersOpen),
                      c: c,
                      active: _filtersOpen || hasFilters,
                    ),
                  ]),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Status filter chips (always visible) ─────────────────────
            const SizedBox(height: AppSpacing.sm),
            FilterChipsRow(
              items:    _statuses,
              selected: _status,
              onSelect: (val) {
                setState(() => _status = val);
                _fetch(page: 1);
              },
            ),

            // ── Collapsible filter panel (date range) ────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: _filtersOpen ? 80 : 0,
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: Column(
                    children: [
                      Row(children: [
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
                        if (hasFilters) ...[
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm, vertical: 9),
                              decoration: BoxDecoration(
                                color: c.errorBg,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: c.errorBorder, width: 1),
                              ),
                              child: Text('Clear',
                                style: AppTypography.labelMono(c.error)
                                    .copyWith(fontSize: 10)),
                            ),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            // ── Count label ──────────────────────────────────────────────
            if (_paged != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: Text(
                  '${_paged!.total} TRANSACTIONS FOUND',
                  style: AppTypography.labelMono(c.textTertiary)
                      .copyWith(fontSize: 10, letterSpacing: 0.06),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // ── Transaction list ─────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 56, color: c.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: c.textSecondary),
                              textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                                onPressed: () => _fetch(page: 1),
                                child: const Text('Retry')),
                          ]))
                      : RefreshIndicator(
                          onRefresh: () => _fetch(page: _paged?.page ?? 1),
                          color: c.primaryAmber,
                          child: (_paged?.items.isEmpty ?? true)
                              ? Center(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_outlined,
                                        size: 56, color: c.textTertiary),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('No transactions found',
                                      style: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(color: c.textSecondary)),
                                  ]))
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  itemCount: _paged!.items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.xs),
                                  itemBuilder: (_, i) =>
                                      _buildCard(_paged!.items[i], c),
                                ),
                        ),
            ),

            // ── Pagination bar ───────────────────────────────────────────
            if (_paged?.items.isNotEmpty ?? false) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: c.borderSubtle, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_paged!.page} / $pages  ·  ${_paged!.total}',
                      style: AppTypography.labelMono(c.textTertiary)
                          .copyWith(fontSize: 10),
                    ),
                    Row(children: [
                      _PageBtn(
                        icon: Icons.chevron_left_rounded,
                        enabled: !_loading && _paged!.page > 1,
                        onTap: () => _fetch(page: _paged!.page - 1),
                        c: c,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _PageBtn(
                        icon: Icons.chevron_right_rounded,
                        enabled: !_loading && _paged!.page < pages,
                        onTap: () => _fetch(page: _paged!.page + 1),
                        c: c,
                      ),
                    ]),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  // ── Transaction card — AppCard accent variant ─────────────────────────────
  Widget _buildCard(Transaction t, AppColors c) {
    final s        = t.status.toLowerCase();
    final barColor = s.contains('complet') || s.contains('success')
        ? c.success
        : s.contains('fail') || s.contains('error') || s.contains('reject')
            ? c.error
            : c.warning;

    return AppCard(
      variant:     AppCardVariant.accent,
      accentColor: barColor,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(children: [
        // Left: payment type + ref
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.paymentType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.transactionRef,
                style: AppTypography.labelMono(c.textTertiary)
                    .copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Right: amount (Instrument Serif) + status badge
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            CurrencyFormatters.formatNumber(t.amount.round()),
            style: GoogleFonts.instrumentSerif(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: c.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          StatusChip(status: t.status, compact: true),
        ]),
      ]),
    );
  }

  // ── CSV export ────────────────────────────────────────────────────────────
  Future<void> _exportCsv() async {
    final items = _paged?.items ?? [];
    if (items.isEmpty) {
      DialogHelpers.showInfo(context, 'No transactions to export');
      return;
    }
    final header = ['Payment Type', 'Status', 'Amount', 'Date', 'Reference'];
    final rows   = items.map((t) => [
      t.paymentType, t.status,
      CurrencyFormatters.formatGHS(t.amount),
      DateFormatters.formatDateTime(t.initiatedAt),
      t.transactionRef,
    ]);
    final buffer = StringBuffer()..writeln(header.join(','));
    for (final r in rows) {
      buffer.writeln(r.map((v) => '"${v.toString().replaceAll('"', '""')}"').join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    DialogHelpers.showSuccess(
      context,
      'Page ${_paged!.page} copied — ${items.length} of ${_paged!.total} total',
    );
  }
}

// ── Small private widgets ─────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.icon,
    required this.c,
    this.onTap,
    this.active = false,
  });
  final IconData  icon;
  final AppColors c;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: active ? c.amberBg : c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active ? c.amberBorder : c.borderMid,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 17,
            color: active ? c.primaryAmber : c.textSecondary),
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  const _DateBtn({required this.label, required this.onTap, required this.c});
  final String     label;
  final VoidCallback onTap;
  final AppColors  c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            style: AppTypography.labelMono(c.textSecondary)
                .copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          )),
        ]),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.c,
  });
  final IconData  icon;
  final bool      enabled;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: enabled ? c.borderMid : c.borderSubtle,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 18,
            color: enabled ? c.textSecondary : c.textDisabled),
      ),
    );
  }
}