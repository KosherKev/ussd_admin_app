import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PayoutsSchedulePage extends StatelessWidget {
  const PayoutsSchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(title: 'Schedule Payouts'),
          SizedBox(height: 16),
          GlassCard(child: Text('Form coming soon')),
        ]),
      ),
    );
  }
}