import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradientHeader(title: 'Transactions'),
          SizedBox(height: 16),
          GlassCard(child: Text('Filters + table coming soon')),
        ]),
      ),
    );
  }
}