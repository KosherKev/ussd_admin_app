import 'package:flutter/material.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// MetricCard — Hero number metric card
//
// Layout:
//   ┌─────────────────────┐
//   │ label          icon │
//   │ 36px number         │
//   │ [trend badge]       │
//   └─────────────────────┘
// ---------------------------------------------------------------------------
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  /// Small label above the number.
  final String label;

  /// Hero number string (e.g. "GHS 12,450").
  final String value;

  /// Optional icon pinned top-right.
  final IconData? icon;

  /// Icon colour; falls back to primaryAmber.
  final Color? iconColor;

  /// Optional trend string (e.g. "+12%" or "-3.4%").
  final String? trend;

  /// If null, trend badge is grey. If true → green, false → red.
  final bool? trendPositive;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    final text = Theme.of(context).textTheme;
    final ic   = iconColor ?? c.primaryAmber;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.borderStrong, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: label + icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: text.bodySmall?.copyWith(color: c.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ic.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Icon(icon, size: 16, color: ic),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Hero number
            Text(
              value,
              style: text.headlineMedium?.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 26,
                height: 1.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // Trend badge
            if (trend != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _TrendBadge(trend: trend!, positive: trendPositive),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend, this.positive});
  final String trend;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final Color fg;
    final Color bg;

    if (positive == true) {
      fg = c.success;
      bg = c.successBg;
    } else if (positive == false) {
      fg = c.error;
      bg = c.errorBg;
    } else {
      fg = c.textTertiary;
      bg = c.bgHigh;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        trend,
        style: AppTypography.labelMono(fg).copyWith(fontSize: 11),
      ),
    );
  }
}
