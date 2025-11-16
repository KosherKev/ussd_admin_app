import 'package:flutter/material.dart';
import 'dart:async';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/subscription.dart';
import '../../shared/services/subscription_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class SubscriptionManagePage extends StatefulWidget {
  final String id;

  const SubscriptionManagePage({super.key, required this.id});

  @override
  State<SubscriptionManagePage> createState() => _SubscriptionManagePageState();
}

class _SubscriptionManagePageState extends State<SubscriptionManagePage> {
  final _service = SubscriptionService();
  Subscription? _subscription;
  bool _loading = true;
  String? _error;
  String _role = 'org_admin';

  String _selectedPeriod = 'monthly';
  DateTime? _selectedStartDate;

  final List<Map<String, String>> _billingPeriods = [
    {'value': 'monthly', 'label': 'Monthly', 'icon': '📅'},
    {'value': 'quarterly', 'label': 'Quarterly (3 months)', 'icon': '📆'},
    {'value': 'yearly', 'label': 'Yearly (12 months)', 'icon': '🗓️'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    _role = await RoleHelpers.getRole();
    
    if (_role != 'super_admin') {
      if (mounted) {
        DialogHelpers.showError(context, 'Access denied. Super admin only.');
        Navigator.pop(context);
      }
      return;
    }

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
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

  Future<void> _activate() async {
    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Activate Subscription',
      message: 'Are you sure you want to activate this subscription with $_selectedPeriod billing?',
      confirmText: 'Activate',
    );

    if (!confirmed) return;
    if (!mounted) return;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final pageNavigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    DialogHelpers.showLoading(context, message: 'Activating...');
    _activateAsync(rootNavigator, pageNavigator, messenger);
  }

  Future<void> _activateAsync(
    NavigatorState rootNavigator,
    NavigatorState pageNavigator,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      await _service.activate(
        widget.id,
        billingPeriod: _selectedPeriod,
        startDate: _selectedStartDate,
      );

      if (!mounted) {
        rootNavigator.pop();
        return;
      }

      rootNavigator.pop();
      DialogHelpers.showSuccessWithMessenger(messenger, 'Subscription activated successfully');
      pageNavigator.pop();
    } catch (e) {
      rootNavigator.pop();
      DialogHelpers.showErrorWithMessenger(messenger, ErrorHandlers.getErrorMessage(e));
    }
  }

  Future<void> _cancel() async {
    final confirmed = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Cancel Subscription',
      message: 'Are you sure you want to cancel this subscription? This action cannot be undone.',
      confirmText: 'Cancel Subscription',
      isDanger: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final pageNavigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    DialogHelpers.showLoading(context, message: 'Cancelling...');
    _cancelAsync(rootNavigator, pageNavigator, messenger);
  }

  Future<void> _cancelAsync(
    NavigatorState rootNavigator,
    NavigatorState pageNavigator,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      await _service.cancel(widget.id);

      if (!mounted) {
        rootNavigator.pop();
        return;
      }

      rootNavigator.pop();
      DialogHelpers.showSuccessWithMessenger(messenger, 'Subscription cancelled successfully');
      pageNavigator.pop();
    } catch (e) {
      rootNavigator.pop();
      DialogHelpers.showErrorWithMessenger(messenger, ErrorHandlers.getErrorMessage(e));
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null && mounted) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Subscription'),
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
          const GradientHeader(title: 'Manage Subscription', warm: true),
          
          const SizedBox(height: AppSpacing.lg),

          // Current Status
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    StatusHelpers.buildStatusBadge(_subscription!.status),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _subscription!.isActive
                            ? 'Subscription is currently active'
                            : _subscription!.isCancelled
                                ? 'Subscription has been cancelled'
                                : 'Subscription is inactive',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Activate Section
          if (!_subscription!.isActive) ...[
            Text(
              'Activate Subscription',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
            ),
            
            const SizedBox(height: AppSpacing.sm),

            // Billing Period Selection
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Billing Period',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),

                  ..._billingPeriods.map((period) {
                    final isSelected = _selectedPeriod == period['value'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period['value']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryAmber.withValues(alpha: 0.1)
                                : AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryAmber
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                period['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  period['label']!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.white,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryAmber,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Start Date Selection
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date (Optional)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Leave blank to start immediately',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),

                  InkWell(
                    onTap: _pickStartDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: _selectedStartDate != null
                              ? AppColors.primaryAmber
                              : AppColors.gray700,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryAmber,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              _selectedStartDate != null
                                  ? DateFormatters.formatDate(_selectedStartDate)
                                  : 'Start immediately',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Activate Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _activate,
                icon: const Icon(Icons.check_circle),
                label: const Text('Activate Subscription'),
              ),
            ),
          ],

          // Cancel Section
          if (_subscription!.isActive) ...[
            Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
            
            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Cancel Subscription',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    'This will immediately cancel the subscription. This action cannot be undone.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _cancel,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
