import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'app/router/app_router.dart' as app_router;
import 'app/router/routes.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'USSD Admin',
      theme: buildTheme(),
      initialRoute: Routes.login,
      onGenerateRoute: app_router.onGenerateRoute,
      home: const LoginPage(),
    );
  }
}