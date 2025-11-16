import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PayoutsPendingPage extends StatelessWidget {
  const PayoutsPendingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(title: 'Pending Payouts'),
          SizedBox(height: 16),
          GlassCard(child: Text('List coming soon')),
        ]),
      ),
    );
  }
}