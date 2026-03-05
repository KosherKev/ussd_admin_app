import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/webhook_delivery.dart';
import '../../shared/services/developer_service.dart';
import '../../app/router/routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/filter_chips_row.dart';
import '../../widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// WebhooksListPage — Phase 13
//
// Design changes:
// - GradientHeader → Instrument Serif page-strip with refresh icon button
// - Old chip ListView → FilterChipsRow
// - GlassCard cards → AppCard accent variant coloured by status
// - Event name bold body, transactionRef in DM Mono 10px
// - URL on second row with link-icon; chevron right for tap affordance
// ---------------------------------------------------------------------------
class WebhooksListPage extends StatefulWidget {
  const WebhooksListPage({super.key});

  @override
  State<WebhooksListPage> createState() => _WebhooksListPageState();
}

class _WebhooksListPageState extends State<WebhooksListPage> {
  final _service = DeveloperService();

  String? _orgId;
  List<WebhookDelivery> _items = [];
  bool    _loading     = true;
  bool    _loadingMore = false;
  String? _error;
  String? _statusFilter;
  int     _page  = 1;
  int     _total = 0;

  @override
  void initState() {
    super.initState();
    _loadOrgId();
  }

  Future<void> _loadOrgId() async {
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
      if (_orgId == null) {
        if (mounted) setState(() { _loading = _loadingMore = false; });
        return;
      }
      final result = await _service.getWebhookDeliveries(
        _orgId!,
        status: _statusFilter,
        page:   reset ? 1 : _page,
        limit:  20,
      );
      if (mounted) {
        setState(() {
          _items       = reset ? result.items : [..._items, ...result.items];
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

  Color _barColor(String status, AppColors c) {
    switch (status) {
      case 'delivered':          return c.success;
      case 'retrying':           return c.warning;
      case 'permanently_failed': return c.error;
      default:                   return c.textTertiary;
    }
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
                          'Webhook Deliveries',
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
                  GestureDetector(
                    onTap: _loading ? null : () => _load(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.borderMid, width: 1),
                      ),
                      child: _loading
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: c.primaryAmber))
                          : Icon(Icons.refresh_rounded,
                              size: 17, color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Filter chips ───────────────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            FilterChipsRow(
              items: const ['delivered', 'retrying', 'permanently_failed'],
              selected: _statusFilter,
              onSelect: (val) {
                setState(() => _statusFilter = val);
                _load();
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Delivery list ──────────────────────────────────────────
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
                            ElevatedButton(onPressed: () => _load(),
                                child: const Text('Retry')),
                          ]))
                      : _items.isEmpty
                          ? Center(child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.webhook_outlined,
                                    size: 56, color: c.textTertiary),
                                const SizedBox(height: AppSpacing.md),
                                Text('No webhook deliveries',
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
                                  return _buildCard(_items[i], c);
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

  // ── Delivery card ─────────────────────────────────────────────────────────
  Widget _buildCard(WebhookDelivery d, AppColors c) {
    final bar = _barColor(d.status, c);
    return AppCard(
      variant:     AppCardVariant.accent,
      accentColor: bar,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      onTap: () => Navigator.pushNamed(
          context, Routes.webhookDetail, arguments: d.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.event,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.transactionRef,
                  style: AppTypography.labelMono(c.textTertiary)
                      .copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )),
            StatusChip(status: d.status, compact: true),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Row(children: [
            Icon(Icons.link_rounded, size: 13, color: c.textTertiary),
            const SizedBox(width: 4),
            Expanded(child: Text(
              d.targetUrl,
              style: AppTypography.labelMono(c.textSecondary)
                  .copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            )),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, size: 16, color: c.textTertiary),
          ]),
        ],
      ),
    );
  }
}
