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

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
      return;
    }

    try {
      final dio = buildDio(token: token);
      final res = await dio.get('/auth/me');
      final user = res.data['user'] as Map<String, dynamic>?;
      
      if (user != null) {
        await prefs.setString('role', user['role']?.toString() ?? 'org_admin');
        
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        throw Exception('Invalid user data');
      }
    } catch (e) {
      // Token invalid or expired, clear and go to login
      await prefs.remove('token');
      await prefs.remove('role');
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surfaceLow,
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppGradients.warm(),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: AppShadows.shadowXl,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: AppSpacing.xxl),
              
              // App title
              Text(
                'USSD Admin',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              SizedBox(height: AppSpacing.xs),
              
              Text(
                'Payment Management Platform',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.xxxl),
              
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryAmber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
