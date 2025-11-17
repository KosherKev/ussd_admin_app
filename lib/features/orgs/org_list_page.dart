import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/utils/helpers.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../shared/services/org_service.dart';
import 'org_store.dart';

class OrgListPage extends StatelessWidget {
  const OrgListPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrgStore(OrgService())..fetch(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _searchController = TextEditingController();
  String _role = 'org_admin';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final role = await RoleHelpers.getRole();
    if (mounted) {
      setState(() => _role = role);
    }
  }

  void _onOrgTap(String orgId) {
    Navigator.pushNamed(context, Routes.orgDetail, arguments: orgId);
  }

  Future<void> _onRefresh() async {
    final store = context.read<OrgStore>();
    await store.fetch(page: 1, q: _searchController.text.trim());
  }

  void _onSearch() {
    final store = context.read<OrgStore>();
    store.fetch(page: 1, q: _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<OrgStore>();
    final state = store.state;
    final pages = state.limit > 0 ? ((state.total + state.limit - 1) ~/ state.limit) : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GradientHeader(
              title: 'Organizations',
              warm: true,
              trailing: state.loading
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

            const SizedBox(height: AppSpacing.md),

            // Search Bar
            GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search organizations',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: state.loading ? null : _onSearch,
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Organization List
            Expanded(
              child: state.loading && state.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Error loading organizations',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.white,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                state.error!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                onPressed: _onRefresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.business_outlined,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No organizations found',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Try a different search term'
                                        : 'Get started by creating an organization',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.separated(
                                itemCount: state.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, i) {
                                  final org = state.items[i];
                                  return GlassCard(
                                    child: InkWell(
                                      onTap: () => _onOrgTap(org.id),
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                      child: Padding(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        child: Row(
                                          children: [
                                            // Icon
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: AppGradients.warm(),
                                                borderRadius: BorderRadius.circular(AppRadius.md),
                                              ),
                                              child: const Icon(
                                                Icons.business,
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
                                                  Text(
                                                    org.name,
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                          color: AppColors.white,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                  ),
                                                  if (org.email != null && org.email!.isNotEmpty) ...[
                                                    const SizedBox(height: AppSpacing.xxs),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.email_outlined,
                                                          size: 14,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                        const SizedBox(width: AppSpacing.xxs),
                                                        Expanded(
                                                          child: Text(
                                                            org.email!,
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                  color: AppColors.textSecondary,
                                                                ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  if (org.phone != null && org.phone!.isNotEmpty) ...[
                                                    const SizedBox(height: AppSpacing.xxs),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.phone_outlined,
                                                          size: 14,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                        const SizedBox(width: AppSpacing.xxs),
                                                        Expanded(
                                                          child: Text(
                                                            org.phone!,
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                  color: AppColors.textSecondary,
                                                                ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: AppSpacing.sm),

                                            // Short Name Badge & Arrow
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (org.shortName != null && org.shortName!.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: AppSpacing.sm,
                                                      vertical: AppSpacing.xxs,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryAmber.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                                      border: Border.all(
                                                        color: AppColors.primaryAmber.withValues(alpha: 0.3),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      org.shortName!,
                                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                            color: AppColors.primaryAmber,
                                                          ),
                                                    ),
                                                  ),
                                                const SizedBox(height: AppSpacing.xs),
                                                const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),

            // Pagination
            if (state.items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${state.page} of $pages (${state.total} total)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: state.loading || state.page <= 1
                              ? null
                              : () => store.fetch(page: state.page - 1, q: _searchController.text.trim()),
                          icon: const Icon(Icons.chevron_left),
                          color: AppColors.primaryAmber,
                        ),
                        IconButton(
                          onPressed: state.loading || state.page >= pages
                              ? null
                              : () => store.fetch(page: state.page + 1, q: _searchController.text.trim()),
                          icon: const Icon(Icons.chevron_right),
                          color: AppColors.primaryAmber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: _role == 'super_admin'
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement create organization dialog
                DialogHelpers.showInfo(context, 'Create organization feature coming soon');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
