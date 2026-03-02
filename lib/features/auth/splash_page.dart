import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/http/client.dart';
import '../../app/router/routes.dart';
import '../../app/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale  = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
      return;
    }

    try {
      final dio  = buildDio(token: token);
      final res  = await dio.get('/auth/me');
      final user = res.data['user'] as Map<String, dynamic>?;

      if (user != null) {
        await prefs.setString('role', user['role']?.toString() ?? 'org_admin');
        if (user['organizationId'] != null) {
          await prefs.setString('org_id', user['organizationId'].toString());
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        throw Exception('Invalid user data');
      }
    } catch (_) {
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('org_id');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.surfaceMid, c.background, c.background],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppGradients.amber(colors: c),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [
                        BoxShadow(
                          color: c.primaryAmber.withValues(alpha: 0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'PayHub',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Payment Management Platform',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(c.primaryAmber),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
