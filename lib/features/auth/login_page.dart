import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/http/client.dart';
import '../../shared/utils/helpers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/routes.dart';
import '../../shared/services/org_service.dart';
import '../../widgets/glass_card.dart';
import 'package:dio/dio.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
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

        // 3B — persist org_name so the Dashboard greeting works
        try {
          final org = await OrgService().get(orgId);
          await prefs.setString('org_name', org.name);
        } catch (_) {
          // Non-fatal: org name is cosmetic only; login still proceeds
        }
      }

      // 3C — persist key_id so the Developer Dashboard shows usage stats
      // The API returns this as 'apiKeyId' on the user object.
      // Field name is documented as best-effort; gracefully ignored if absent.
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
        final data = e.response?.data;
        final srv  = (data is Map && data['message'] is String) ? data['message'] as String : null;
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
    final c    = context.appColors;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // Decorative gradient blobs
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  c.primaryAmber.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  c.secondaryBlue.withValues(alpha: 0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppGradients.amber(colors: c),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              boxShadow: [
                                BoxShadow(
                                  color: c.primaryAmber.withValues(alpha: 0.30),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.hub_rounded, size: 40, color: Colors.white),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sign in to your PayHub account',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: c.textSecondary,
                                ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Form card
                          GlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                            () => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (v) => Validators.required(v, fieldName: 'Password'),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      child: _loading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context).brightness == Brightness.dark
                                                      ? Colors.black
                                                      : Colors.white,
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

                          const SizedBox(height: AppSpacing.xl),

                          Text(
                            'PayHub © 2025',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: c.textTertiary,
                                ),
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
