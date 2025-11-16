import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/subscription.dart';
import '../../shared/services/subscription_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class SubscriptionStatusPage extends StatefulWidget {
  final String id;

  const SubscriptionStatusPage({super.key, required this.id});

  @override
  State<SubscriptionStatusPage> createState() => _SubscriptionStatusPageState();
}

class _SubscriptionStatusPageState extends State<SubscriptionStatusPage> {
  final _service = SubscriptionService();
  Subscription? _subscription;
  bool _loading = true;
  String? _error;
  String _role = 'org_admin';

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
      final subscription = await _service.getStatus(widget.id);

      if (mounted) {
        setState(() {
          _subscription = subscription;
          _loading = false;
        });
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

  void _navigateToManage() {
    Navigator.pushNamed(
      context,
      Routes.subscriptionManage,
      arguments: widget.id,
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription Status'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error Loading Subscription',
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
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_subscription == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientHeader(title: 'Subscription Details', warm: true),
          
          const SizedBox(height: AppSpacing.lg),

          // Status Card
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _subscription!.isActive
                        ? AppGradients.warm()
                        : const LinearGradient(
                            colors: [AppColors.gray600, AppColors.gray700],
                          ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    _subscription!.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                StatusHelpers.buildStatusBadge(_subscription!.status),
                
                const SizedBox(height: AppSpacing.md),
                
                Text(
                  _subscription!.isActive
                      ? 'Subscription Active'
                      : _subscription!.isCancelled
                          ? 'Subscription Cancelled'
                          : 'Subscription Inactive',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Details Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                
                const SizedBox(height: AppSpacing.md),

                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Billing Period',
                  value: _subscription!.billingPeriod.toUpperCase(),
                ),

                if (_subscription!.startDate != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(
                    icon: Icons.play_arrow,
                    label: 'Start Date',
                    value: DateFormatters.formatDate(_subscription!.startDate),
                  ),
                ],

                if (_subscription!.endDate != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(
                    icon: Icons.event,
                    label: 'End Date',
                    value: DateFormatters.formatDate(_subscription!.endDate),
                  ),
                ],

                if (_subscription!.gracePeriodEndDate != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(
                    icon: Icons.timer,
                    label: 'Grace Period End',
                    value: DateFormatters.formatDate(_subscription!.gracePeriodEndDate),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // USSD Status Card
          GlassCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (_subscription!.ussdEnabled
                            ? AppColors.success
                            : AppColors.gray600)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _subscription!.ussdEnabled
                        ? Icons.phone_android
                        : Icons.phonelink_off,
                    color: _subscription!.ussdEnabled
                        ? AppColors.success
                        : AppColors.gray600,
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USSD Service',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _subscription!.ussdEnabled ? 'Enabled' : 'Disabled',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _subscription!.ussdEnabled
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Manage Button (Super Admin Only)
          if (_role == 'super_admin')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToManage,
                icon: const Icon(Icons.settings),
                label: const Text('Manage Subscription'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryAmber),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
