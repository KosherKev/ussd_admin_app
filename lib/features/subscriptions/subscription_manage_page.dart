import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class SubscriptionManagePage extends StatelessWidget {
  final String id;
  const SubscriptionManagePage({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Manage Subscription'),
          const SizedBox(height: 16),
          GlassCard(child: Text('ID: $id')),
        ]),
      ),
    );
  }
}