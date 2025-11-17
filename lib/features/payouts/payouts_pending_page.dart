import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/payout_service.dart';
import '../../shared/models/payout.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PayoutsPendingPage extends StatefulWidget {
  const PayoutsPendingPage({super.key});
  @override
  State<PayoutsPendingPage> createState() => _PayoutsPendingPageState();
}

class _PayoutsPendingPageState extends State<PayoutsPendingPage> {
  final _payoutService = PayoutService();

  bool _loading = true;
  String? _error;
  String _role = 'org_admin';
  List<Payout> _items = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _role = await RoleHelpers.getRole();
      if (_role != 'super_admin') {
        if (!mounted) return;
        DialogHelpers.showError(context, 'Access denied. Super admin only.');
        Navigator.pop(context);
        return;
      }
      await _load();
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    try {
      final items = await _payoutService.listPending();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _process(Payout payout) async {
    final ok = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Process Payout',
      message: 'Process payout for ${payout.organizationName}?',
      confirmText: 'Process',
    );
    if (!ok) return;
    try {
      if (!mounted) return;
      DialogHelpers.showLoading(context, message: 'Processing...');
      final ref = await _payoutService.process(payout.id);
      if (!mounted) return;
      DialogHelpers.hideLoading(context);
      DialogHelpers.showSuccess(context, 'Payout processed: $ref');
      await _load();
    } catch (e) {
      if (mounted) {
        DialogHelpers.hideLoading(context);
        ErrorHandlers.handleError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Pending Payouts'),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(onPressed: _init, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _items.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textTertiary),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('No pending payouts', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) => _buildItem(_items[i]),
                              ),
                      ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) => Navigator.pushReplacementNamed(context, Routes.home, arguments: i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceLow,
        selectedItemColor: AppColors.primaryAmber,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), activeIcon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildItem(Payout p) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.organizationName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(CurrencyFormatters.formatGHS(p.netAmount), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusHelpers.buildStatusBadge(p.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.scheduledDate == null ? 'Not Scheduled' : DateFormatters.formatDateTime(p.scheduledDate), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ElevatedButton.icon(onPressed: () => _process(p), icon: const Icon(Icons.playlist_add_check), label: const Text('Process')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}