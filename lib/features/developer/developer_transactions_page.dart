import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/services/reports_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/filter_chips_row.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/header_icon_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

// ---------------------------------------------------------------------------
// DeveloperTransactionsPage — Phase 11
//
// Updated to match the Refined Financial Brutalism design system:
// - GradientHeader → Instrument Serif page-strip
// - GlassCard cards → AppCard accent variant with 3px status left bar
// - Old chip ListView → FilterChipsRow widget
// - Amounts use Instrument Serif italic
// ---------------------------------------------------------------------------
class DeveloperTransactionsPage extends StatefulWidget {
  const DeveloperTransactionsPage({super.key});

  @override
  State<DeveloperTransactionsPage> createState() =>
      _DeveloperTransactionsPageState();
}

class _DeveloperTransactionsPageState
    extends State<DeveloperTransactionsPage> {
  final _service = ReportsService();

  List<Transaction> _items   = [];
  bool    _loading    = true;
  bool    _loadingMore = false;
  String? _error;
  int     _page  = 1;
  int     _total = 0;
  String? _statusFilter;

  String? _orgId;

  @override
  void initState() {
    super.initState();
    _loadOrgAndData();
  }

  Future<void> _loadOrgAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _orgId = prefs.getString('org_id');
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() { _page = 1; _loading = true; _error = null; });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final result = await _service.getTransactions(
        organizationId: _orgId,
        page:   reset ? 1 : _page,
        limit:  20,
        status: _statusFilter,
      );
      if (mounted) {
        setState(() {
          if (reset) { _items = result.items; } else { _items.addAll(result.items); }
          _total       = result.total;
          _page        = (reset ? 1 : _page) + 1;
          _loading     = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandlers.getErrorMessage(e);
          _loading = _loadingMore = false;
        });
      }
    }
  }

  bool get _hasMore => _items.length < _total;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Page strip header ──────────────────────────────────────
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
                          'DEVELOPER PORTAL',
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
                  // Refresh button
                  HeaderIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _load,
                    loading: _loading,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Status filter chips ────────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            FilterChipsRow(
              items:    const ['completed', 'processing', 'failed'],
              selected: _statusFilter,
              onSelect: (val) {
                setState(() => _statusFilter = val);
                _load();
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Transaction list ────────────────────────────────────────
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
                                onPressed: () => _load(),
                                child: const Text('Retry')),
                          ]))
                      : _items.isEmpty
                          ? Center(child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 56, color: c.textTertiary),
                                const SizedBox(height: AppSpacing.md),
                                Text('No transactions found',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: c.textSecondary)),
                              ]))
                          : RefreshIndicator(
                              onRefresh: () => _load(),
                              color: c.primaryAmber,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                itemCount: _items.length + (_hasMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.xs),
                                itemBuilder: (ctx, i) {
                                  if (i == _items.length) {
                                    if (!_loadingMore && _hasMore) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted) _load(reset: false);
                                      });
                                    }
                                    return Center(child: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: CircularProgressIndicator(
                                          color: c.primaryAmber),
                                    ));
                                  }
                                  return _buildCard(_items[i], c).animate().fade(delay: (math.min(i, 15) * 50).ms, duration: 300.ms).slideX(begin: 0.05, end: 0, duration: 300.ms);
                                },
                              ),
                            ),
            ),

            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  // ── Transaction card — AppCard accent variant ───────────────────────────
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
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            CurrencyFormatters.formatNumber(t.amount.round()),
            style: GoogleFonts.instrumentSerif(
              fontSize: 18,
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
}
