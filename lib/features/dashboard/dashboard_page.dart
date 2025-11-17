import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/services/reports_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/org_service.dart';
import '../../shared/models/organization.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';
import '../../app/router/routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reportsService = ReportsService();
  final _orgService = OrgService();
  
  bool _loading = true;
  String? _error;
  String _role = 'org_admin';
  List<Transaction> _recentTransactions = [];
  int _totalTransactions = 0;
  double _totalAmount = 0.0;
  double _totalCommission = 0.0;
  Map<DateTime, int> _dailyCounts = {};
  Map<String, int> _typeCounts = {};
  Map<String, double> _typeAmounts = {};
  Organization? _selectedOrg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _role = await RoleHelpers.getRole();
      String? organizationId;
      if (_role != 'super_admin') {
        final prefs = await SharedPreferences.getInstance();
        final lastId = prefs.getString('last_org_id');
        final lastName = prefs.getString('last_org_name');
        Organization? last;
        if (lastId != null && lastName != null) {
          last = Organization(id: lastId, name: lastName);
        }
        final orgsResult = await _orgService.list(page: 1, limit: 100);
        final orgs = orgsResult.items;
        if (orgs.isEmpty) {
          throw Exception('No organization available');
        }
        _selectedOrg = orgs.firstWhere(
          (o) => o.id == last?.id,
          orElse: () => orgs.first,
        );
        organizationId = _selectedOrg?.id;
      }

      final transactionsResult = await _reportsService.getTransactions(
        organizationId: organizationId,
        startDate: DateFormatters.sevenDaysAgo,
        endDate: DateTime.now(),
        page: 1,
        limit: 10,
      );

      _recentTransactions = transactionsResult.items;
      _totalTransactions = transactionsResult.total;

      // Calculate totals
      _totalAmount = _recentTransactions.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
      _totalCommission = _recentTransactions.fold(
        0.0,
        (sum, t) => sum + t.commission,
      );

      // Build daily buckets for last 7 days
      _dailyCounts = _generateDailyCounts(_recentTransactions);
      // Build payment type breakdown
      final breakdownCounts = <String, int>{};
      final breakdownAmounts = <String, double>{};
      for (final t in _recentTransactions) {
        breakdownCounts[t.paymentType] = (breakdownCounts[t.paymentType] ?? 0) + 1;
        breakdownAmounts[t.paymentType] = (breakdownAmounts[t.paymentType] ?? 0.0) + t.amount;
      }
      _typeCounts = breakdownCounts;
      _typeAmounts = breakdownAmounts;

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandlers.getErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              title: (_role != 'super_admin' && _selectedOrg != null)
                  ? 'Dashboard — ${_selectedOrg!.name}'
                  : 'Dashboard',
              warm: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _load,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.account_circle, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, Routes.settingsProfile),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: _buildContent(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error Loading Dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _load,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      children: [
        // Stats Cards
        Text(
          'Last 7 Days',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
              ),
        ),

        const SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Transactions',
          value: CurrencyFormatters.formatNumber(_totalTransactions),
          icon: Icons.receipt_long,
        ),

        const SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Amount',
          value: CurrencyFormatters.formatCompactGHS(_totalAmount),
          icon: Icons.account_balance_wallet,
        ),

        const SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Commission',
          value: CurrencyFormatters.formatGHS(_totalCommission),
          icon: Icons.payments,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Weekly Chart
        Text(
          'Weekly Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildWeeklyChart(),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Payment Type Breakdown
        Text(
          'Payment Type Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildPaymentTypeBreakdown(),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Recent Transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.reportsTransactions),
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        if (_recentTransactions.isEmpty)
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No Transactions',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'No transactions in the last 7 days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          ...(_recentTransactions.take(5).map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildTransactionCard(transaction),
            );
          }).toList()),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Map<DateTime, int> _generateDailyCounts(List<Transaction> txs) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      return d;
    });
    final map = {for (final d in days) d: 0};
    for (final t in txs) {
      final d = DateTime(t.initiatedAt.year, t.initiatedAt.month, t.initiatedAt.day);
      if (map.containsKey(d)) {
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map;
  }

  Widget _buildWeeklyChart() {
    final entries = _dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = entries.isEmpty ? 0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map((e) {
        final ratio = maxVal == 0 ? 0.0 : (e.value / maxVal);
        final height = 100 * ratio + 8; // minimum height
        final label = _weekdayLabel(e.key.weekday);
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: height,
                decoration: BoxDecoration(
                  gradient: AppGradients.warm(),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$label\n${CurrencyFormatters.formatNumber(e.value)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildPaymentTypeBreakdown() {
    if (_typeCounts.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.inbox_outlined, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'No data for breakdown',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }
    final keys = _typeCounts.keys.toList()
      ..sort((a, b) => (_typeCounts[b] ?? 0).compareTo(_typeCounts[a] ?? 0));
    return Column(
      children: keys.map((k) {
        final count = _typeCounts[k] ?? 0;
        final amount = _typeAmounts[k] ?? 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  k,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                ),
              ),
              Text(
                CurrencyFormatters.formatNumber(count),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                CurrencyFormatters.formatCompactGHS(amount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
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
                      Text(
                        transaction.organizationName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        transaction.paymentType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                StatusHelpers.buildStatusBadge(transaction.status),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      CurrencyFormatters.formatGHS(transaction.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatters.formatRelative(transaction.initiatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      transaction.transactionRef,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
