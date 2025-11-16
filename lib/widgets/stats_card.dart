import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';
import 'glass_card.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? trend;
  final Color? valueColor;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.trend,
    this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.warm(),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: valueColor ?? AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (trend != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        trend!.startsWith('+')
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: trend!.startsWith('+')
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        trend!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: trend!.startsWith('+')
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
