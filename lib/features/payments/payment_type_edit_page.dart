import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/payment_type.dart';
import '../../shared/services/payment_type_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PaymentTypeEditPage extends StatefulWidget {
  final String orgId;
  final String typeId;

  const PaymentTypeEditPage({
    super.key,
    required this.orgId,
    required this.typeId,
  });

  @override
  State<PaymentTypeEditPage> createState() => _PaymentTypeEditPageState();
}

class _PaymentTypeEditPageState extends State<PaymentTypeEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PaymentTypeService();

  // Controllers
  final _typeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  bool _enabled = true;
  bool _loading = true;
  bool _saving = false;

  bool get _isNewType => widget.typeId == 'new';

  @override
  void initState() {
    super.initState();
    if (!_isNewType) {
      _loadPaymentType();
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _typeIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentType() async {
    try {
      final types = await _service.list(widget.orgId);
      final type = types.firstWhere(
        (t) => t.typeId == widget.typeId,
        orElse: () => throw Exception('Payment type not found'),
      );

      if (mounted) {
        setState(() {
          _typeIdController.text = type.typeId;
          _nameController.text = type.name;
          _descriptionController.text = type.description ?? '';
          _minAmountController.text = type.minAmount.toString();
          _maxAmountController.text = type.maxAmount.toString();
          _enabled = type.enabled;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final minAmount = double.parse(_minAmountController.text);
      final maxAmount = double.parse(_maxAmountController.text);

      if (minAmount > maxAmount) {
        throw Exception('Min amount cannot be greater than max amount');
      }

      if (_isNewType) {
        // Create new payment type
        final newType = PaymentType(
          id: '',
          typeId: _typeIdController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          enabled: _enabled,
          minAmount: minAmount,
          maxAmount: maxAmount,
        );

        await _service.create(widget.orgId, newType);

        if (mounted) {
          DialogHelpers.showSuccess(context, 'Payment type created successfully');
          Navigator.pop(context);
        }
      } else {
        // Update existing payment type
        await _service.update(
          widget.orgId,
          widget.typeId,
          {
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            'enabled': _enabled,
            'minAmount': minAmount,
            'maxAmount': maxAmount,
          },
        );

        if (mounted) {
          DialogHelpers.showSuccess(context, 'Payment type updated successfully');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isNewType ? 'Add Payment Type' : 'Edit Payment Type'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientHeader(
                      title: _isNewType ? 'New Payment Type' : 'Edit Details',
                      warm: true,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Type ID (only for new types)
                    if (_isNewType) ...[
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type ID',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Unique identifier for this payment type (e.g., "tithe", "offering")',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _typeIdController,
                              decoration: const InputDecoration(
                                labelText: 'Type ID *',
                                hintText: 'e.g., tithe',
                                prefixIcon: Icon(Icons.tag),
                              ),
                              validator: (value) => Validators.required(
                                value,
                                fieldName: 'Type ID',
                              ),
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-z0-9_-]'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Basic Information
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name *',
                              hintText: 'e.g., Tithe',
                              prefixIcon: Icon(Icons.label),
                            ),
                            validator: (value) => Validators.required(
                              value,
                              fieldName: 'Name',
                            ),
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              hintText: 'Brief description of this payment type',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Enabled Toggle
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: (_enabled ? AppColors.success : AppColors.gray600)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(
                                    _enabled ? Icons.check_circle : Icons.cancel,
                                    color: _enabled ? AppColors.success : AppColors.gray600,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enable Payment Type',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: AppColors.white,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        _enabled
                                            ? 'Users can make payments using this type'
                                            : 'This payment type is disabled',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _enabled,
                                  onChanged: (value) {
                                    setState(() => _enabled = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Amount Limits
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Limits',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Set minimum and maximum payment amounts in GHS',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Min Amount
                          TextFormField(
                            controller: _minAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Amount (GHS) *',
                              hintText: '1.00',
                              prefixIcon: Icon(Icons.arrow_downward),
                              prefixText: 'GHS ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Minimum amount is required';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Max Amount
                          TextFormField(
                            controller: _maxAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Maximum Amount (GHS) *',
                              hintText: '10000.00',
                              prefixIcon: Icon(Icons.arrow_upward),
                              prefixText: 'GHS ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Maximum amount is required';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_saving ? 'Saving...' : 'Save Payment Type'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }
}
