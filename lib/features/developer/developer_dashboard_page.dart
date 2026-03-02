import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/models/api_key.dart';
import '../../../shared/services/developer_service.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gradient_header.dart';
import '../../../widgets/stats_card.dart';

class DeveloperDashboardPage extends StatefulWidget {
  const DeveloperDashboardPage({super.key});

  @override
  State<DeveloperDashboardPage> createState() => _DeveloperDashboardPageState();
}

class _DeveloperDashboardPageState extends State<DeveloperDashboardPage> {
  final _service = DeveloperService();

  KeyUsage? _usage;
  bool      _loading = true;
  String?   _error;
  int       _periodDays = 30;   // 7, 30 or 90
  String?   _keyId;

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
      // No key_id stored — show empty prompt
      setState(() { _loading = false; });
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

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              title: 'Developer Dashboard',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  else
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Period selector
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [7, 30, 90].map((d) {
                  final sel = _periodDays == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: GestureDetector(
                      onTap: () { setState(() => _periodDays = d); _load(); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: sel ? c.primaryAmber : c.surfaceMid,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('${d}d',
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
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                  : _keyId == null
                      ? _buildNoKeyPrompt(c)
                      : _error != null
                          ? _buildError(c)
                          : _usage == null
                              ? Center(child: Text('No data available', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)))
                              : RefreshIndicator(onRefresh: _load, child: _buildContent(c)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoKeyPrompt(AppColors c) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.key_off_outlined, size: 56, color: c.textTertiary),
      const SizedBox(height: AppSpacing.md),
      Text('No API Key linked', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary)),
      const SizedBox(height: AppSpacing.xs),
      Text('Your API key ID will be assigned when you log in.\nContact your organisation admin if you need access.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
    ]),
  );

  Widget _buildError(AppColors c) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 56, color: c.error),
      const SizedBox(height: AppSpacing.md),
      Text('Failed to load dashboard', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: c.textPrimary)),
      const SizedBox(height: AppSpacing.xs),
      Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.lg),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ]),
  );

  Widget _buildContent(AppColors c) {
    final u = _usage!;
    final t = u.transactions;
    final w = u.webhooks;
    final ch = t.byChannel;

    return ListView(
      children: [
        // Stats row
        StatsCard(label: 'Transactions', value: CurrencyFormatters.formatNumber(t.total), icon: Icons.receipt_long_rounded),
        const SizedBox(height: AppSpacing.sm),
        StatsCard(
          label:    'Success Rate',
          value:    t.successRate != null ? '${t.successRate!.toStringAsFixed(1)}%' : '--',
          icon:     Icons.check_circle_outline_rounded,
          iconColor: c.success,
        ),
        const SizedBox(height: AppSpacing.sm),
        StatsCard(label: 'Volume (net)', value: CurrencyFormatters.formatCompactGHS(t.totalNetVolume), icon: Icons.account_balance_wallet_rounded),
        const SizedBox(height: AppSpacing.sm),
        StatsCard(
          label:    'Webhook Success',
          value:    w.successRate != null ? '${w.successRate!.toStringAsFixed(1)}%' : '--',
          icon:     Icons.webhook_rounded,
          iconColor: w.successRate != null && w.successRate! >= 90 ? c.success : c.warning,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Channel breakdown
        Text('Payment Channels', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _channelRow('Mobile Money', ch.mobileMoney, t.total, Icons.phone_android_rounded, c.chart1, c),
                const SizedBox(height: AppSpacing.sm),
                _channelRow('Card',         ch.card,        t.total, Icons.credit_card_rounded,    c.chart2, c),
                const SizedBox(height: AppSpacing.sm),
                _channelRow('USSD Bridge',  ch.ussdBridge,  t.total, Icons.dialpad_rounded,        c.chart3, c),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Daily bar chart
        if (u.daily.isNotEmpty) ...[
          Text('Daily Transactions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: _buildDailyChart(u.daily, c))),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Webhook health
        Text('Webhook Health', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: [
              _webookHealthRow('Delivered',           w.delivered, w.total, c.success, c),
              const SizedBox(height: AppSpacing.sm),
              _webookHealthRow('Retrying',            w.retrying,  w.total, c.warning, c),
              const SizedBox(height: AppSpacing.sm),
              _webookHealthRow('Permanently Failed',  w.failed,    w.total, c.error,   c),
            ]),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _channelRow(String label, int count, int total, IconData icon, Color color, AppColors c) {
    final pct = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(value: pct, minHeight: 6, color: color, backgroundColor: c.surfaceHigh),
        ),
      ])),
      const SizedBox(width: AppSpacing.sm),
      Text('$count', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _webookHealthRow(String label, int count, int total, Color color, AppColors c) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary))),
      Text('$count / $total', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
    ]);
  }

  Widget _buildDailyChart(List<DailyStat> daily, AppColors c) {
    final maxVal = daily.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: daily.take(14).map((d) {
        final ratio = maxVal == 0 ? 0.0 : d.total / maxVal;
        final h = 70.0 * ratio + 4.0;
        final label = d.date.substring(5); // MM-dd
        return Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              height: h,
              decoration: BoxDecoration(
                gradient: AppGradients.amber(colors: c),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(label, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary, fontSize: 9)),
          ]),
        );
      }).toList(),
    );
  }
}
