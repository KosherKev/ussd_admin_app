import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/services/org_service.dart';
import '../../shared/services/payout_service.dart';
import '../../shared/models/organization.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PayoutsSchedulePage extends StatefulWidget {
  const PayoutsSchedulePage({super.key});
  @override
  State<PayoutsSchedulePage> createState() => _PayoutsSchedulePageState();
}

class _PayoutsSchedulePageState extends State<PayoutsSchedulePage> {
  final _orgService = OrgService();
  final _payoutService = PayoutService();

  bool _loading = true;
  String? _error;
  String _role = 'org_admin';
  List<Organization> _orgs = [];
  Organization? _selectedOrg;
  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _role = await RoleHelpers.getRole();
      if (_role != 'super_admin') {
        if (!mounted) return;
        DialogHelpers.showError(context, 'Access denied. Super admin only.');
        Navigator.pop(context);
        return;
      }
      final orgs = await _orgService.list(page: 1, limit: 200);
      _orgs = orgs.items;
      if (_orgs.isNotEmpty) _selectedOrg = _orgs.first;
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
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
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedOrg == null) {
      if (!mounted) return;
      DialogHelpers.showInfo(context, 'Select an organization');
      return;
    }
    try {
      if (!mounted) return;
      DialogHelpers.showLoading(context, message: 'Scheduling payouts...');
      final count = await _payoutService.schedule(_selectedOrg!.id, scheduledDate: _scheduledDate);
      if (!mounted) return;
      DialogHelpers.hideLoading(context);
      DialogHelpers.showSuccess(context, 'Scheduled $count payouts');
    } catch (e) {
      if (mounted) {
        DialogHelpers.hideLoading(context);
        ErrorHandlers.handleError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Schedule Payouts'),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(onPressed: _init, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  GlassCard(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedOrg?.id,
                          items: _orgs
                              .map((o) => DropdownMenuItem<String>(value: o.id, child: Text(o.name)))
                              .toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            setState(() => _selectedOrg = _orgs.firstWhere((o) => o.id == id));
                          },
                          decoration: const InputDecoration(
                            labelText: 'Organization',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event),
                          label: Text(_scheduledDate == null ? 'Scheduled Date' : DateFormatters.formatDate(_scheduledDate)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.schedule_send),
                            label: const Text('Schedule'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) => Navigator.pushReplacementNamed(context, Routes.home, arguments: i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceLow,
        selectedItemColor: AppColors.primaryAmber,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), activeIcon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}