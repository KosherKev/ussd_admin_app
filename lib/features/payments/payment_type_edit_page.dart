import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class PaymentTypeEditPage extends StatelessWidget {
  final String orgId;
  final String typeId;
  const PaymentTypeEditPage({super.key, required this.orgId, required this.typeId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Edit Payment Type'),
          const SizedBox(height: 16),
          GlassCard(child: Text('Org ID: $orgId, Type: $typeId')),
        ]),
      ),
    );
  }
}