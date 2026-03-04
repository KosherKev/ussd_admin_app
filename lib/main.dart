import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart' as app_router;
import 'app/router/routes.dart';

/// Global navigator key — used by the Dio 401 interceptor to redirect to
/// login without a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');
  final themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${details.exceptionAsString()}\n\n${details.stack?.toString() ?? ''}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  };
  runApp(App(initialThemeMode: themeMode));
}

class App extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const App({super.key, required this.initialThemeMode});

  static AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
    if (mounted) {
      setState(() => _themeMode = mode);
    }
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'PayHub Admin',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      initialRoute: Routes.splash,
      onGenerateRoute: app_router.onGenerateRoute,
    );
  }
}