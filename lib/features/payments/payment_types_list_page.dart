import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/payment_type.dart';
import '../../shared/services/payment_type_service.dart';
import '../../widgets/filter_chips_row.dart';
import '../../widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// PaymentTypesListPage — Phase 12
//
// Mockup: .pt-card layout
// - page-strip header (Instrument Serif "Payment Types") + "+ Add" button
// - FilterChipsRow: All / Active / Disabled
// - pt-card: name + StatusChip badge | opt description | 3-col limits | actions
// - Disabled cards rendered at opacity 0.65
// - FAB replaced by inline "+ Add" button in header trailing
// ---------------------------------------------------------------------------
class PaymentTypesListPage extends StatefulWidget {
  final String orgId;
  /// When true, embedded inside HomeShell — no extra Scaffold/AppBar needed.
  final bool embedded;

  const PaymentTypesListPage({
    super.key,
    required this.orgId,
    this.embedded = false,
  });

  @override
  State<PaymentTypesListPage> createState() => _PaymentTypesListPageState();
}

class _PaymentTypesListPageState extends State<PaymentTypesListPage> {
  final _service = PaymentTypeService();

  List<PaymentType> _paymentTypes = [];
  bool    _loading = true;
  bool    _toggling = false;
  String? _error;
  String? _filter; // null = All, 'active', 'disabled'

  List<PaymentType> get _filtered {
    if (_filter == null) return _paymentTypes;
    if (_filter == 'active')   return _paymentTypes.where((t) =>  t.enabled).toList();
    if (_filter == 'disabled') return _paymentTypes.where((t) => !t.enabled).toList();
    return _paymentTypes;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final types = await _service.list(widget.orgId);
      if (mounted) setState(() { _paymentTypes = types; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _error = ErrorHandlers.getErrorMessage(e); _loading = false; });
      }
    }
  }

  Future<void> _toggleEnabled(PaymentType type) async {
    if (_toggling) return;
    setState(() => _toggling = true);
    try {
      await _service.update(widget.orgId, type.typeId, {'enabled': !type.enabled});
      if (mounted) {
        DialogHelpers.showSuccess(
          context,
          '${type.name} ${!type.enabled ? 'enabled' : 'disabled'}',
        );
        await _load();
      }
    } catch (e) {
      if (mounted) ErrorHandlers.handleError(context, e);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _navigateToEdit(PaymentType? type) {
    Navigator.pushNamed(
      context,
      Routes.paymentTypeEdit,
      arguments: {'orgId': widget.orgId, 'typeId': type?.typeId},
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Page strip header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        'Payment Types',
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
                // Refresh
                if (_loading)
                  SizedBox(
                    width: 38, height: 38,
                    child: Center(child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: c.primaryAmber),
                    )),
                  )
                else ...[
                  _HeaderBtn(
                      icon: Icons.refresh_rounded,
                      onTap: _load,
                      c: c),
                  const SizedBox(width: AppSpacing.xs),
                ],
                // Primary "+ Add" button
                GestureDetector(
                  onTap: () => _navigateToEdit(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 9),
                    decoration: BoxDecoration(
                      color: c.primaryAmber,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+ Add',
                      style: AppTypography.labelMono(c.background)
                          .copyWith(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.borderSubtle),

          // ── Filter chips ───────────────────────────────────────────
          const SizedBox(height: AppSpacing.sm),
          FilterChipsRow(
            items:    const ['active', 'disabled'],
            selected: _filter,
            onSelect: (val) => setState(() => _filter = val),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── List ───────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.primaryAmber))
                : _error != null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 56, color: c.error),
                          const SizedBox(height: AppSpacing.md),
                          Text(_error!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: c.textSecondary),
                            textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(onPressed: _load,
                              child: const Text('Retry')),
                        ]))
                    : _filtered.isEmpty
                        ? Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment_outlined,
                                  size: 56, color: c.textTertiary),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _paymentTypes.isEmpty
                                    ? 'No payment types yet'
                                    : 'No ${_filter ?? ''} types',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: c.textSecondary)),
                            ]))
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: c.primaryAmber,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (_, i) =>
                                  _buildCard(_filtered[i], c),
                            ),
                          ),
          ),

          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );

    return widget.embedded
        ? body
        : Scaffold(backgroundColor: c.background, body: body);
  }

  // ── .pt-card ─────────────────────────────────────────────────────────────
  Widget _buildCard(PaymentType type, AppColors c) {
    return Opacity(
      opacity: type.enabled ? 1.0 : 0.65,
      child: Container(
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header: name + slug + status badge ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: c.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${type.typeId}',
                          style: AppTypography.labelMono(c.textTertiary)
                              .copyWith(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    status: type.enabled ? 'active' : 'disabled',
                    compact: true,
                  ),
                ],
              ),
            ),

            // ── Optional description ─────────────────────────────────
            if (type.description != null && type.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  type.description!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: c.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: c.borderSubtle,
                indent: AppSpacing.md, endIndent: AppSpacing.md),
            const SizedBox(height: AppSpacing.sm),

            // ── 3-col limits row (Min / Max / Txns) ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(children: [
                _LimitCell(label: 'Min',
                    value: CurrencyFormatters.formatGHS(type.minAmount), c: c),
                _LimitDivider(c: c),
                _LimitCell(label: 'Max',
                    value: CurrencyFormatters.formatGHS(type.maxAmount), c: c),
                _LimitDivider(c: c),
                _LimitCell(label: 'Txns', value: type.transactionCount.toString(), c: c),
              ]),
            ),

            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: c.borderSubtle),

            // ── Action row: Edit | Enable/Disable ────────────────────
            IntrinsicHeight(
              child: Row(children: [
                // Edit
                Expanded(
                  child: _ActionBtn(
                    label: 'Edit',
                    onTap: () => _navigateToEdit(type),
                    c: c,
                    borderRight: true,
                  ),
                ),
                // Toggle
                Expanded(
                  child: _ActionBtn(
                    label: type.enabled ? 'Disable' : 'Enable',
                    onTap: _toggling ? null : () => _toggleEnabled(type),
                    loading: _toggling,
                    c: c,
                    danger: type.enabled,
                    success: !type.enabled,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon, required this.c, this.onTap});
  final IconData  icon;
  final AppColors c;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.borderMid, width: 1),
      ),
      child: Icon(icon, size: 17, color: c.textSecondary),
    ),
  );
}

class _LimitCell extends StatelessWidget {
  const _LimitCell({required this.label, required this.value, required this.c});
  final String    label;
  final String    value;
  final AppColors c;

  @override
  Widget build(BuildContext context) => Expanded(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
        style: AppTypography.labelMono(c.textTertiary)
            .copyWith(fontSize: 9, letterSpacing: 0.08)),
      const SizedBox(height: 2),
      Text(value,
        style: AppTypography.labelMono(c.textPrimary)
            .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis),
    ],
  ));
}

class _LimitDivider extends StatelessWidget {
  const _LimitDivider({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 30,
    color: c.borderSubtle,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.c,
    this.onTap,
    this.loading = false,
    this.danger  = false,
    this.success = false,
    this.borderRight = false,
  });

  final String     label;
  final AppColors  c;
  final VoidCallback? onTap;
  final bool loading;
  final bool danger;
  final bool success;
  final bool borderRight;

  @override
  Widget build(BuildContext context) {
    final fg = danger
        ? c.error
        : success
            ? c.success
            : c.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: borderRight
              ? Border(right: BorderSide(color: c.borderSubtle, width: 1))
              : null,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: fg))
              : Text(
                  label,
                  style: AppTypography.labelMono(fg)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
