import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/payment_type.dart';
import '../../shared/services/payment_type_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PaymentTypesListPage extends StatefulWidget {
  final String orgId;
  
  const PaymentTypesListPage({super.key, required this.orgId});
  
  @override
  State<PaymentTypesListPage> createState() => _PaymentTypesListPageState();
}

class _PaymentTypesListPageState extends State<PaymentTypesListPage> {
  final _service = PaymentTypeService();
  List<PaymentType> _paymentTypes = [];
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
      final types = await _service.list(widget.orgId);

      if (mounted) {
        setState(() {
          _paymentTypes = types;
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

  Future<void> _toggleEnabled(PaymentType type) async {
    try {
      DialogHelpers.showLoading(context, message: 'Updating...');

      await _service.update(widget.orgId, type.typeId, {
        'enabled': !type.enabled,
      });

      if (mounted) {
        DialogHelpers.hideLoading(context);
        DialogHelpers.showSuccess(
          context,
          '${type.name} ${!type.enabled ? 'enabled' : 'disabled'}',
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        DialogHelpers.hideLoading(context);
        ErrorHandlers.handleError(context, e);
      }
    }
  }

  void _navigateToEdit(PaymentType? type) {
    Navigator.pushNamed(
      context,
      Routes.paymentTypeEdit,
      arguments: {
        'orgId': widget.orgId,
        'typeId': type?.typeId ?? 'new',
      },
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Types'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              title: 'Payment Types',
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
                  : null,
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
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
                                'Error Loading Payment Types',
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
                        )
                      : _paymentTypes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payment_outlined,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No Payment Types',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Add payment types to get started',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                itemCount: _paymentTypes.length,
                                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) {
                                  final type = _paymentTypes[i];
                                  return _buildPaymentTypeCard(type);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentTypeCard(PaymentType type) {
    return GlassCard(
      child: InkWell(
        onTap: () => _navigateToEdit(type),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: type.enabled
                          ? AppGradients.warm()
                          : LinearGradient(
                              colors: [
                                AppColors.gray600,
                                AppColors.gray700,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                type.name,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: (type.enabled ? AppColors.success : AppColors.gray600)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: type.enabled ? AppColors.success : AppColors.gray600,
                                ),
                              ),
                              child: Text(
                                type.enabled ? 'Active' : 'Disabled',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: type.enabled ? AppColors.success : AppColors.gray600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (type.description != null && type.description!.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            type.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Amount Range
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Min Amount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            CurrencyFormatters.formatGHS(type.minAmount),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Max Amount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            CurrencyFormatters.formatGHS(type.maxAmount),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToEdit(type),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleEnabled(type),
                      icon: Icon(
                        type.enabled ? Icons.toggle_on : Icons.toggle_off,
                        size: 18,
                      ),
                      label: Text(type.enabled ? 'Disable' : 'Enable'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.enabled ? AppColors.warning : AppColors.success,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
