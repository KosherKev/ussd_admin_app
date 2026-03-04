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
  /// When true, the widget is embedded inside HomeShell — no Scaffold/AppBar.
  final bool embedded;

  const PaymentTypesListPage({super.key, required this.orgId, this.embedded = false});

  @override
  State<PaymentTypesListPage> createState() => _PaymentTypesListPageState();
}

class _PaymentTypesListPageState extends State<PaymentTypesListPage> {
  final _service = PaymentTypeService();
  List<PaymentType> _paymentTypes = [];
  bool _loading = true;
  bool _toggling = false; // guards the enable/disable action
  String? _error;

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
    if (_toggling) return; // prevent double-tap
    setState(() => _toggling = true);
    try {
      await _service.update(widget.orgId, type.typeId, {
        'enabled': !type.enabled,
      });

      if (mounted) {
        DialogHelpers.showSuccess(
          context,
          '${type.name} ${!type.enabled ? 'enabled' : 'disabled'}',
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlers.handleError(context, e);
      }
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _navigateToEdit(PaymentType? type) {
    Navigator.pushNamed(
      context,
      Routes.paymentTypeEdit,
      arguments: {
        'orgId':  widget.orgId,
        'typeId': type?.typeId,   // null = create new
      },
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: 'Payment Types',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loading)
                  const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                else
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: c.error),
                            const SizedBox(height: AppSpacing.md),
                            Text('Error Loading Payment Types',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
                              textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _paymentTypes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment_outlined, size: 64, color: c.textTertiary),
                                const SizedBox(height: AppSpacing.md),
                                Text('No Payment Types',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary)),
                                const SizedBox(height: AppSpacing.xs),
                                Text('Tap + to add your first payment type',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              itemCount: _paymentTypes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) => _buildPaymentTypeCard(_paymentTypes[i], c),
                            ),
                          ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Stack(
        children: [
          body,
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md + 80, // above nav bar
            child: FloatingActionButton(
              heroTag: 'payment_types_fab',
              onPressed: () => _navigateToEdit(null),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentTypeCard(PaymentType type, AppColors c) {
    return GlassCard(
      onTap: () => _navigateToEdit(type),
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
                      ? AppGradients.amber(colors: c)
                      : LinearGradient(colors: [c.surfaceHigh, c.surfaceMid]),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

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
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: (type.enabled ? c.success : c.textTertiary).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: type.enabled ? c.success : c.textTertiary),
                          ),
                          child: Text(
                            type.enabled ? 'Active' : 'Disabled',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: type.enabled ? c.success : c.textTertiary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (type.description != null && type.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        type.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Amount Range
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.surfaceMid,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(CurrencyFormatters.formatGHS(type.minAmount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.surfaceMid,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(CurrencyFormatters.formatGHS(type.maxAmount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToEdit(type),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggling ? null : () => _toggleEnabled(type),
                  icon: _toggling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : Icon(type.enabled ? Icons.toggle_off_outlined : Icons.toggle_on_outlined, size: 18),
                  label: Text(type.enabled ? 'Disable' : 'Enable'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type.enabled ? c.warning : c.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
