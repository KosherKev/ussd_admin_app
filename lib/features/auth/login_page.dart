import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/app_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  final _passController   = TextEditingController();
  bool _loading         = false;
  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeIn;
  late final Animation<Offset>   _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final dio = buildDio();
      final res = await dio.post('/auth/login', data: {
        'email': _emailController.text.trim(),
        'password': _passController.text.trim(),
      });

      final data  = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) throw Exception('Invalid login response');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      final me   = await buildDio(token: token).get('/auth/me');
      final user = me.data['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String? ?? 'org_admin';
      await prefs.setString('role', role);

      final orgId = user?['organizationId']?.toString();
      if (orgId != null && orgId.isNotEmpty) {
        await prefs.setString('org_id', orgId);
        try {
          final org = await OrgService().get(orgId);
          await prefs.setString('org_name', org.name);
        } catch (_) {
          // Non-fatal: org name is cosmetic
        }
      }

      // Persist API key ID for Developer Dashboard
      final keyId = user?['apiKeyId']?.toString()
                 ?? user?['keyId']?.toString()
                 ?? user?['api_key_id']?.toString();
      if (keyId != null && keyId.isNotEmpty) {
        await prefs.setString('key_id', keyId);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (!mounted) return;
      String msg = ErrorHandlers.getErrorMessage(e);
      if (e is DioException) {
        final code = e.response?.statusCode ?? 0;
        final body = e.response?.data;
        final srv  = (body is Map && body['message'] is String)
            ? body['message'] as String
            : null;
        if (code == 401) {
          msg = srv ?? 'Invalid email or password.';
        } else if (code == 400) {
          msg = srv ?? 'Invalid request.';
        } else if (code == 403) {
          msg = srv ?? 'Access denied for this account.';
        } else if (srv != null) {
          msg = srv;
        }
      }
      DialogHelpers.showError(context, msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c      = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // Ambient glow — amber bottom-right (mockup Screen 6)
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
          // Ambient glow — blue top-left (mockup Screen 6)
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo — sharp amber square, P monogram, no BoxShadow
                          Center(
                            child: Hero(
                              tag: 'payhub-logo',
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: c.primaryAmber,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Center(
                                  child: Text(
                                    'P',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Heading
                          Text(
                            'Welcome back',
                            style: text.displayMedium?.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sign in to your PayHub account',
                            style: text.bodyMedium?.copyWith(color: c.textSecondary),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Form card — elevated variant
                          AppCard(
                            variant: AppCardVariant.elevated,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    validator: Validators.email,
                                  ),

                                  const SizedBox(height: AppSpacing.md),

                                  // Password field
                                  TextFormField(
                                    controller: _passController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (v) =>
                                        Validators.required(v, fieldName: 'Password'),
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  // Sign In button — sharp r=6, amber fill, dark label
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: c.primaryAmber,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.sm),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: _loading ? null : _submit,
                                      child: _loading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                  isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Sign In →',
                                              style: text.labelLarge?.copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),

                                  // Forgot password link
                                  const SizedBox(height: AppSpacing.sm),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: c.textSecondary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.xs,
                                      ),
                                    ),
                                    // No route defined yet — spec says navigation
                                    // target is null for now.
                                    onPressed: () {},
                                    child: Text(
                                      'Forgot password?',
                                      style: text.bodySmall?.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Footer
                          Text(
                            'PayHub © 2025 — Secure Payment Platform',
                            style: text.bodySmall?.copyWith(
                              color: c.textTertiary,
                              letterSpacing: 0.04,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
