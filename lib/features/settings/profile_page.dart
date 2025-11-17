import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? _error;
  String? _email;
  String? _role;
  String? _orgName;

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final dio = buildDio(token: token);
      final res = await dio.get('/auth/me');
      final user = res.data['user'] as Map<String, dynamic>?
          ?? res.data as Map<String, dynamic>?;
      setState(() {
        _email = user?['email']?.toString();
        _role = user?['role']?.toString();
        _orgName = user?['organization']?['name']?.toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandlers.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Profile'),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(_email ?? '-', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.white)),
                                  const SizedBox(height: AppSpacing.md),
                                  Text('Role', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: AppSpacing.xs),
                                  StatusHelpers.buildStatusBadge(_role ?? 'org_admin'),
                                  const SizedBox(height: AppSpacing.md),
                                  Text('Organization', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(_orgName ?? '-', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
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