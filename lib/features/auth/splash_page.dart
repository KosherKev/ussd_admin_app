import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/http/client.dart';
import '../../app/router/routes.dart';
import '../../app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
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
      body: Stack(
        children: [
          // Ambient glow — amber bottom-right (matches login screen)
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    c.primaryAmber.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Ambient glow — blue top-left
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x0F3A7FBB),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sharp amber logo square — no glow shadow
                Hero(
                  tag: 'payhub-logo',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: c.primaryAmber,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ).animate()
                 .fade(duration: 600.ms, curve: Curves.easeOut)
                 .scaleXY(begin: 0.88, end: 1.0, duration: 800.ms, curve: Curves.easeOutBack),

                const SizedBox(height: AppSpacing.xl),

                // PayHub wordmark
                Text(
                  'PayHub',
                  style: AppTypography.displayHero(c.textPrimary),
                ).animate(delay: 150.ms)
                 .fade(duration: 600.ms)
                 .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Payment Management Platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ).animate(delay: 300.ms)
                 .fade(duration: 600.ms)
                 .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

                const SizedBox(height: AppSpacing.xxxl),

                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(c.primaryAmber),
                  ),
                ).animate(delay: 600.ms).fade(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
