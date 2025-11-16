import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class SubscriptionStatusPage extends StatelessWidget {
  final String id;
  const SubscriptionStatusPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Subscription Status'),
          const SizedBox(height: 16),
          GlassCard(child: Text('ID: $id')),
        ]),
      ),
    );
  }
}