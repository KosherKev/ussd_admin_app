import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/services/reports_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class DeveloperTransactionsPage extends StatefulWidget {
  const DeveloperTransactionsPage({super.key});

  @override
  State<DeveloperTransactionsPage> createState() => _DeveloperTransactionsPageState();
}

class _DeveloperTransactionsPageState extends State<DeveloperTransactionsPage> {
  final _service = ReportsService();

  List<Transaction> _items = [];
  bool    _loading = true;
  bool    _loadingMore = false;
  String? _error;
  int     _page = 1;
  int     _total = 0;
  String? _statusFilter;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
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
        page:      reset ? 1 : _page,
        limit:     20,
        status:    _statusFilter,
        startDate: _from,
        endDate:   _to,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _items = result.items;
          } else {
            _items.addAll(result.items);
          }
          _total   = result.total;
          _page    = (reset ? 1 : _page) + 1;
          _loading     = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; _loadingMore = false; });
    }
  }

  bool get _hasMore => _items.length < _total;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(
          children: [
            GradientHeader(
              title: 'Transactions',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  else
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _load()),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Status filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'completed', 'processing', 'failed'].map((s) {
                  final sel = (s == 'All' && _statusFilter == null) || _statusFilter == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _statusFilter = s == 'All' ? null : s);
                        _load();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: sel ? c.primaryAmber : c.surfaceMid,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          StatusHelpers.formatStatus(s),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: sel ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white) : c.textSecondary,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                          ElevatedButton(onPressed: () => _load(), child: const Text('Retry')),
                        ]))
                      : _items.isEmpty
                          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.receipt_long_outlined, size: 56, color: c.textTertiary),
                              const SizedBox(height: AppSpacing.md),
                              Text('No transactions found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
                            ]))
                          : RefreshIndicator(
                              onRefresh: () => _load(),
                              child: ListView.separated(
                                itemCount: _items.length + (_hasMore ? 1 : 0),
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (ctx, i) {
                                  if (i == _items.length) {
                                    if (!_loadingMore) _load(reset: false);
                                    return Center(child: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: CircularProgressIndicator(color: c.primaryAmber),
                                    ));
                                  }
                                  return _buildCard(_items[i], c);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Transaction t, AppColors c) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.paymentType, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
          Text(DateFormatters.formatRelative(t.initiatedAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
        ])),
        StatusHelpers.buildStatusBadge(t.status),
      ]),
      const SizedBox(height: AppSpacing.xs),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(CurrencyFormatters.formatGHS(t.amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
        Text(t.transactionRef, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary), overflow: TextOverflow.ellipsis),
      ]),
    ]),
  );
}
