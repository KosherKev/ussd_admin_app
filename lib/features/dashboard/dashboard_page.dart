import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientHeader(title: 'Statistics', warm: true),
          const SizedBox(height: 16),
          GlassCard(
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total balance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('37,484', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                ])),
                const Icon(Icons.auto_graph, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Service ${i + 1}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                      Text('People ${(i + 1) * 100}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ])),
                    Text('${(i + 1) * 1000}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}