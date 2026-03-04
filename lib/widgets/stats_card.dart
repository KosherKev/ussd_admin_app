import 'package:flutter/material.dart';
import 'package:ussd_admin/widgets/metric_card.dart';

/// Legacy StatsCard — now delegates to MetricCard.
/// Kept for backward compatibility during migration.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return MetricCard(
      label: label,
      value: value,
      icon: icon,
      iconColor: iconColor,
      trend: subtitle,
    );
  }
}
