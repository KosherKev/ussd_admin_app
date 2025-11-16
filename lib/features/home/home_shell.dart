import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/gradient_header.dart';
import '../dashboard/dashboard_page.dart';
import '../orgs/org_list_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  String _role = 'org_admin';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _role = prefs.getString('role') ?? 'org_admin';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const DashboardPage(),
      const OrgListPage(),
      const _PlaceholderPage(title: 'Payments'),
      const _PlaceholderPage(title: 'Reports'),
      if (_role == 'super_admin') const _PlaceholderPage(title: 'Admin'),
    ];
    return Scaffold(
      body: SafeArea(child: tabs[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Orgs'),
          const BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Payments'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          if (_role == 'super_admin') const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(title: title),
          const SizedBox(height: 16),
          const Expanded(child: Center(child: Text('Coming soon'))),
        ],
      ),
    );
  }
}