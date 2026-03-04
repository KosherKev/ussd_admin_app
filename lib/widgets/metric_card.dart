import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// MetricCard — Hero number metric card (Refined Financial Brutalism)
//
// Layout:
//   ┌─────────────────────────┐
//   │ LABEL            [icon] │  ← optional icon (amber-tinted square)
//   │ 30px Instrument Serif   │  ← hero value, italic
//   │ ↑ 8.2% sub-label        │  ← optional sub-label (DM Mono, tertiary)
//   └─────────────────────────┘
//
// The hero value uses Instrument Serif italic to match the mockup
// (.dev-metric-value / .stat-cell-value) which specify font-family: var(--font-display).
// ---------------------------------------------------------------------------
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.subLabel,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  /// Small mono label above the number (e.g. "TRANSACTIONS").
  final String label;

  /// Hero number string (e.g. "GHS 12,450").
  final String value;

  /// Optional icon pinned top-right.
  final IconData? icon;

  /// Icon colour; falls back to primaryAmber.
  final Color? iconColor;

  /// Override value colour (e.g. c.success for success metrics).
  /// Falls back to textPrimary.
  final Color? valueColor;

  /// Optional sub-label below the hero value (DM Mono 10px tertiary).
  /// E.g. "↑ 8.2% vs prior period".
  final String? subLabel;

  /// Optional trend string (e.g. "+12%").
  final String? trend;

  /// If null → grey badge. true → green, false → red.
  final bool? trendPositive;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c  = context.appColors;
    final ic = iconColor ?? c.primaryAmber;
    final vc = valueColor ?? c.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: mono label + optional icon ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.labelMono(c.textTertiary)
                        .copyWith(fontSize: 10, letterSpacing: 0.10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: ic.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Icon(icon, size: 14, color: ic),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // ── Hero number — Instrument Serif italic 30px ────────────────
            Text(
              value,
              style: GoogleFonts.instrumentSerif(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: vc,
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // ── Optional sub-label ────────────────────────────────────────
            if (subLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                subLabel!,
                style: AppTypography.labelMono(c.textTertiary)
                    .copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // ── Optional trend badge ──────────────────────────────────────
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
