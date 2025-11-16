import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class OrgDetailPage extends StatelessWidget {
  final String orgId;
  const OrgDetailPage({super.key, required this.orgId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GradientHeader(title: 'Organization'),
          const SizedBox(height: 16),
          GlassCard(child: Text('Org ID: $orgId')),
        ]),
      ),
    );
  }
}