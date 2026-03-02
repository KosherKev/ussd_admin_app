import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart' as app_router;
import 'app/router/routes.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  static _AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (mounted) {
      setState(() {
        _themeMode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
        _themeLoaded = true;
      });
    }
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
    if (!_themeLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildDarkTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayHub Admin',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      initialRoute: Routes.splash,
      onGenerateRoute: app_router.onGenerateRoute,
    );
  }
}