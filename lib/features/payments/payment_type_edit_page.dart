import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/payment_type.dart';
import '../../shared/services/payment_type_service.dart';
import '../../widgets/app_card.dart';

// ---------------------------------------------------------------------------
// PaymentTypeEditPage — Phase 12
//
// Design: plain Scaffold + Instrument Serif page-strip AppBar style.
// - GradientHeader/GlassCard → page-strip header + AppCard sections
// - Section headings: DM Mono small-caps labels (same as dashboard)
// - Toggle row styled with bgRaised fill instead of old glassy card
// ---------------------------------------------------------------------------
class PaymentTypeEditPage extends StatefulWidget {
  final String  orgId;
  final String? typeId;  // null = create new

  const PaymentTypeEditPage({
    super.key,
    required this.orgId,
    this.typeId,
  });

  @override
  State<PaymentTypeEditPage> createState() => _PaymentTypeEditPageState();
}

class _PaymentTypeEditPageState extends State<PaymentTypeEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PaymentTypeService();

  final _typeIdController     = TextEditingController();
  final _nameController       = TextEditingController();
  final _descController       = TextEditingController();
  final _minAmountController  = TextEditingController();
  final _maxAmountController  = TextEditingController();

  bool _enabled = true;
  bool _loading = true;
  bool _saving  = false;

  bool get _isNew => widget.typeId == null;

  @override
  void initState() {
    super.initState();
    _isNew ? setState(() => _loading = false) : _loadType();
  }

  @override
  void dispose() {
    _typeIdController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadType() async {
    try {
      final type = await _service.get(widget.orgId, widget.typeId!);
      if (mounted) {
        setState(() {
          _typeIdController.text    = type.typeId;
          _nameController.text      = type.name;
          _descController.text      = type.description ?? '';
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
      final min = double.parse(_minAmountController.text);
      final max = double.parse(_maxAmountController.text);
      if (min > max) throw Exception('Min amount cannot exceed max amount');

      if (_isNew) {
        final newType = PaymentType(
          id:          '',
          typeId:      _typeIdController.text.trim(),
          name:        _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null : _descController.text.trim(),
          enabled:    _enabled,
          minAmount:  min,
          maxAmount:  max,
        );
        await _service.create(widget.orgId, newType);
        if (mounted) {
          DialogHelpers.showSuccess(context, 'Payment type created');
          Navigator.pop(context);
        }
      } else {
        await _service.update(widget.orgId, widget.typeId!, {
          'name':        _nameController.text.trim(),
          'description': _descController.text.trim().isEmpty
              ? null : _descController.text.trim(),
          'enabled':    _enabled,
          'minAmount':  min,
          'maxAmount':  max,
        });
        if (mounted) {
          DialogHelpers.showSuccess(context, 'Payment type updated');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) ErrorHandlers.handleError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── Page strip header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.borderMid, width: 1),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 17, color: c.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIGURATION',
                          style: AppTypography.labelMono(c.primaryAmber)
                              .copyWith(letterSpacing: 0.12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isNew ? 'New Type' : 'Edit Type',
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
                ],
              ),
            ),
            Divider(height: 1, color: c.borderSubtle),

            // ── Form body ──────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: c.primaryAmber))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Type ID — only for new
                            if (_isNew) ...[
                              _SectionLabel('TYPE ID', c),
                              const SizedBox(height: AppSpacing.xs),
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unique slug for this payment type (e.g. "school_fees"). Cannot be changed later.',
                                      style: Theme.of(context).textTheme.bodySmall
                                          ?.copyWith(color: c.textSecondary),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    TextFormField(
                                      controller: _typeIdController,
                                      decoration: const InputDecoration(
                                        labelText: 'Type ID *',
                                        hintText:  'e.g., school_fees',
                                        prefixIcon: Icon(Icons.tag),
                                      ),
                                      validator: (v) => Validators.required(
                                          v, fieldName: 'Type ID'),
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-z0-9_-]')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],

                            // Basic info
                            _SectionLabel('BASIC INFO', c),
                            const SizedBox(height: AppSpacing.xs),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Name *',
                                      hintText: 'e.g., School Fees',
                                      prefixIcon: Icon(Icons.label_outline),
                                    ),
                                    validator: (v) => Validators.required(
                                        v, fieldName: 'Name'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _descController,
                                    decoration: const InputDecoration(
                                      labelText: 'Description (optional)',
                                      hintText:
                                          'Brief description of this payment type',
                                      prefixIcon: Icon(Icons.notes_outlined),
                                    ),
                                    maxLines: 3,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  // Enable toggle row
                                  _ToggleRow(
                                    enabled: _enabled,
                                    onChanged: (v) =>
                                        setState(() => _enabled = v),
                                    c: c,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Amount limits
                            _SectionLabel('AMOUNT LIMITS', c),
                            const SizedBox(height: AppSpacing.xs),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set min/max payment amounts in GHS.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: c.textSecondary),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _minAmountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Minimum Amount (GHS) *',
                                      hintText:  '1.00',
                                      prefixIcon: Icon(Icons.south_rounded),
                                      prefixText: 'GHS ',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: _amountValidator,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _maxAmountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Maximum Amount (GHS) *',
                                      hintText:  '10000.00',
                                      prefixIcon: Icon(Icons.north_rounded),
                                      prefixText: 'GHS ',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: _amountValidator,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _saving ? null : _save,
                                child: _saving
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation(Colors.black),
                                        ))
                                    : Text(_isNew
                                        ? 'Create Payment Type'
                                        : 'Save Changes'),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Cancel button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final v = double.tryParse(value);
    if (v == null || v <= 0) return 'Enter a valid amount';
    return null;
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.c);
  final String    text;
  final AppColors c;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.labelMono(c.textTertiary)
        .copyWith(fontSize: 10, letterSpacing: 0.12),
  );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.enabled,
    required this.onChanged,
    required this.c,
  });
  final bool              enabled;
  final ValueChanged<bool> onChanged;
  final AppColors         c;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: c.bgRaised,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Row(children: [
      Icon(
        enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: enabled ? c.success : c.textTertiary,
        size: 22,
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment type enabled',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: c.textPrimary)),
          Text(
            enabled
                ? 'Users can make payments using this type'
                : 'This payment type is currently disabled',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ]),
      ),
      Switch(value: enabled, onChanged: onChanged),
    ]),
  );
}
