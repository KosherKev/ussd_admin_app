import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/reports_service.dart';
import '../../shared/models/ussd_session_stats.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stats_card.dart';

class UssdSessionsPage extends StatefulWidget {
  const UssdSessionsPage({super.key});
  @override
  State<UssdSessionsPage> createState() => _UssdSessionsPageState();
}

class _UssdSessionsPageState extends State<UssdSessionsPage> {
  final _reports = ReportsService();
  bool _loading = true;
  String? _error;
  String _role = 'org_admin';
  DateTime? _startDate;
  DateTime? _endDate;
  List<UssdSessionStats> _stats = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _role = await RoleHelpers.getRole();
    if (_role != 'super_admin') {
      if (mounted) {
        DialogHelpers.showError(context, 'Access denied. Super admin only.');
        Navigator.pop(context);
      }
      return;
    }
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _reports.getUssdSessions(startDate: _startDate, endDate: _endDate);
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateFormatters.sevenDaysAgo,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAmber,
              onPrimary: Colors.black,
              surface: AppColors.surfaceLow,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAmber,
              onPrimary: Colors.black,
              surface: AppColors.surfaceLow,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final totalSessions = _stats.fold<int>(0, (sum, s) => sum + s.count);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'USSD Sessions'),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickStartDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null ? 'Start Date' : DateFormatters.formatDate(_startDate)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickEndDate,
                        icon: const Icon(Icons.event),
                        label: Text(_endDate == null ? 'End Date' : DateFormatters.formatDate(_endDate)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),

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
                            ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          StatsCard(
                            label: 'Total Sessions',
                            value: CurrencyFormatters.formatNumber(totalSessions),
                            icon: Icons.timeline,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'By Status',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: _stats.isEmpty
                                  ? [
                                      Row(
                                        children: [
                                          const Icon(Icons.inbox_outlined, color: AppColors.textTertiary),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'No data for selected range',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      )
                                    ]
                                  : _stats.map((s) {
                                      final label = StatusHelpers.formatStatus(s.status);
                                      final color = StatusHelpers.getStatusColor(s.status);
                                      return Padding(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                label,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatters.formatNumber(s.count),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: color),
                                              ),
                                              child: Text(
                                                'Avg ${s.avgDuration.toStringAsFixed(1)}s',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                            ),
                          ),
                        ],
                      ),
          ),
        ]),
      ),
    );
  }
}