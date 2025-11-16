import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../widgets/glass_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final dio = buildDio();
      final res = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('Invalid login response');
      }

      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Get user info
      final me = await buildDio(token: token).get('/auth/me');
      final user = me.data['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String? ?? 'org_admin';
      await prefs.setString('role', role);

      if (!mounted) return;

      // Navigate to home
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (!mounted) return;
      ErrorHandlers.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppGradients.warm(),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.shadowLg,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Title
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.white,
                          ),
                    ),

                    SizedBox(height: AppSpacing.xs),

                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    // Login Form
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: Validators.email,
                            ),

                            SizedBox(height: AppSpacing.md),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) => Validators.required(
                                value,
                                fieldName: 'Password',
                              ),
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // Login Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.black,
                                          ),
                                        ),
                                      )
                                    : const Text('Sign In'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // Footer
                    Text(
                      'USSD Admin © 2025',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
