import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/http/client.dart';
import '../home/home_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: '');
  final _password = TextEditingController(text: '');
  bool _loading = false;
  String? _error;

  bool _isValidEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    final re = RegExp(r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$', caseSensitive: false);
    return re.hasMatch(s);
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      final password = _password.text.trim();
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email');
      }
      if (password.isEmpty) {
        throw Exception('Please enter your password');
      }
      final dio = buildDio();
      final res = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Invalid login');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      final me = await buildDio(token: token).get('/auth/me');
      final user = me.data['user'] as Map?;
      final role = user?['role'] as String? ?? 'org_admin';
      await prefs.setString('role', role);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _error = e.message;
        } else {
          _error = e.toString();
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign In', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), autocorrect: false, enableSuggestions: false, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, autocorrect: false, enableSuggestions: false),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login')),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}