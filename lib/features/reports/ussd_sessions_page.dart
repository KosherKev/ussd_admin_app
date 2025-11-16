import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class UssdSessionsPage extends StatelessWidget {
  const UssdSessionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(title: 'USSD Sessions'),
          SizedBox(height: 16),
          GlassCard(child: Text('Stats coming soon')),
        ]),
      ),
    );
  }
}