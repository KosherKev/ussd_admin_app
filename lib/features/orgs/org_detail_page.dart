import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../shared/models/organization.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class OrgDetailPage extends StatefulWidget {
  final String orgId;
  
  const OrgDetailPage({super.key, required this.orgId});
  
  @override
  State<OrgDetailPage> createState() => _OrgDetailPageState();
}

class _OrgDetailPageState extends State<OrgDetailPage> {
  final _service = OrgService();
  Organization? _org;
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
      // Load role
      _role = await RoleHelpers.getRole();

      // Fetch all orgs and find this one
      final result = await _service.list(page: 1, limit: 100);
      final org = result.items.firstWhere(
        (o) => o.id == widget.orgId,
        orElse: () => throw Exception('Organization not found'),
      );

      if (mounted) {
        setState(() {
          _org = org;
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

  void _navigateToPaymentTypes() {
    Navigator.pushNamed(context, Routes.paymentTypes, arguments: widget.orgId);
  }

  void _navigateToSubscription() {
    Navigator.pushNamed(context, Routes.subscriptionStatus, arguments: widget.orgId);
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, Routes.reportsOrgSummary, arguments: widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Organization Details'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
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
                          'Error Loading Organization',
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
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_org == null) return const SizedBox();

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization Header
          GlassCard(
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppGradients.warm(),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Name
                Text(
                  _org!.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                      ),
                  textAlign: TextAlign.center,
                ),

                if (_org!.shortName != null && _org!.shortName!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.primaryAmber),
                    ),
                    child: Text(
                      _org!.shortName!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryAmber,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Contact Information
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                SizedBox(height: AppSpacing.md),
                
                if (_org!.email != null && _org!.email!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _org!.email!,
                  ),

                if (_org!.phone != null && _org!.phone!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: _org!.phone!,
                  ),
                ],

                if (_org!.ussdNumber != null && _org!.ussdNumber!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(
                    icon: Icons.dialpad_outlined,
                    label: 'USSD Number',
                    value: _org!.ussdNumber!,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Payment Types Card
          _buildActionCard(
            icon: Icons.payment,
            title: 'Payment Types',
            description: 'Manage payment types and settings',
            onTap: _navigateToPaymentTypes,
          ),

          SizedBox(height: AppSpacing.sm),

          // Subscription Card
          _buildActionCard(
            icon: Icons.subscriptions,
            title: 'Subscription',
            description: 'View subscription status and details',
            onTap: _navigateToSubscription,
          ),

          SizedBox(height: AppSpacing.sm),

          // Reports Card
          _buildActionCard(
            icon: Icons.bar_chart,
            title: 'Reports',
            description: 'View transaction reports and analytics',
            onTap: _navigateToReports,
          ),

          SizedBox(height: AppSpacing.lg),

          // Edit Button (Super Admin Only)
          if (_role == 'super_admin')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  DialogHelpers.showInfo(
                    context,
                    'Edit organization feature coming soon',
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Organization'),
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
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryAmber,
          ),
        ),
        SizedBox(width: AppSpacing.md),
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
              SizedBox(height: AppSpacing.xxs),
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.warm(),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
