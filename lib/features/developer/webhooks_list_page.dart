import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/webhook_delivery.dart';
import '../../shared/services/developer_service.dart';
import '../../app/router/routes.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class WebhooksListPage extends StatefulWidget {
  const WebhooksListPage({super.key});

  @override
  State<WebhooksListPage> createState() => _WebhooksListPageState();
}

class _WebhooksListPageState extends State<WebhooksListPage> {
  final _service = DeveloperService();

  List<WebhookDelivery> _items = [];
  bool    _loading = true;
  bool    _loadingMore = false;
  String? _error;
  String? _statusFilter;
  int     _page  = 1;
  int     _total = 0;

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
      final result = await _service.getWebhookDeliveries(
        status: _statusFilter,
        page:   reset ? 1 : _page,
        limit:  20,
      );
      if (mounted) {
        setState(() {
          _items  = reset ? result.items : [..._items, ...result.items];
          _total  = result.total;
          _page   = (reset ? 1 : _page) + 1;
          _loading     = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; _loadingMore = false; });
    }
  }

  bool get _hasMore => _items.length < _total;

  Color _statusColor(String status, AppColors c) {
    switch (status) {
      case 'delivered':         return c.success;
      case 'retrying':          return c.warning;
      case 'permanently_failed':return c.error;
      default:                  return c.textTertiary;
    }
  }

  String _formatStatus(String s) => s.replaceAll('_', ' ').split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

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
              title: 'Webhook Deliveries',
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

            // Status filter
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [null, 'delivered', 'retrying', 'permanently_failed'].map((s) {
                  final sel = _statusFilter == s;
                  final label = s == null ? 'All' : _formatStatus(s);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: GestureDetector(
                      onTap: () { setState(() => _statusFilter = s); _load(); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: sel ? c.primaryAmber : c.surfaceMid,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                              Icon(Icons.webhook_outlined, size: 56, color: c.textTertiary),
                              const SizedBox(height: AppSpacing.md),
                              Text('No webhook deliveries yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
                            ]))
                          : RefreshIndicator(
                              onRefresh: () => _load(),
                              child: ListView.separated(
                                itemCount: _items.length + (_hasMore ? 1 : 0),
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (ctx, i) {
                                  if (i == _items.length) {
                                    // Guard: defer load to post-frame and check _loadingMore
                                    // to prevent duplicate calls on every list rebuild.
                                    if (!_loadingMore && _hasMore) {
                                      WidgetsBinding.instance.addPostFrameCallback(
                                        (_) { if (mounted) _load(reset: false); },
                                      );
                                    }
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

  Widget _buildCard(WebhookDelivery d, AppColors c) {
    final statusColor = _statusColor(d.status, c);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.webhookDetail, arguments: d.id),
      child: GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.event, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(d.transactionRef, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary), overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: statusColor),
              ),
              child: Text(_formatStatus(d.status), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor)),
            ),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Row(children: [
            Icon(Icons.link_rounded, size: 14, color: c.textTertiary),
            const SizedBox(width: 4),
            Expanded(child: Text(d.targetUrl, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.textTertiary),
          ]),
        ]),
      ),
    );
  }
}
