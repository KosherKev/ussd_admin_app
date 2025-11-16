import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/org_summary.dart';
import '../../shared/services/reports_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reportsService = ReportsService();
  
  bool _loading = true;
  String? _error;
  List<Transaction> _recentTransactions = [];
  List<OrgSummaryStats> _summaryStats = [];
  int _totalTransactions = 0;
  double _totalAmount = 0.0;
  double _totalCommission = 0.0;

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
      // Get recent transactions (last 7 days)
      final transactionsResult = await _reportsService.getTransactions(
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
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              title: 'Dashboard',
              warm: true,
              trailing: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _load,
                    ),
            ),

            SizedBox(height: AppSpacing.md),

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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Error Loading Dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
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

        SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Transactions',
          value: CurrencyFormatters.formatNumber(_totalTransactions),
          icon: Icons.receipt_long,
        ),

        SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Amount',
          value: CurrencyFormatters.formatCompactGHS(_totalAmount),
          icon: Icons.account_balance_wallet,
        ),

        SizedBox(height: AppSpacing.sm),

        StatsCard(
          label: 'Total Commission',
          value: CurrencyFormatters.formatGHS(_totalCommission),
          icon: Icons.payments,
        ),

        SizedBox(height: AppSpacing.lg),

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
              onPressed: () {
                // Navigate to full transactions report
                DialogHelpers.showInfo(
                  context,
                  'Full reports coming soon',
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.sm),

        if (_recentTransactions.isEmpty)
          GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No Transactions',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
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
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildTransactionCard(transaction),
            );
          }).toList()),

        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
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
                      SizedBox(height: AppSpacing.xxs),
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

            SizedBox(height: AppSpacing.sm),

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
