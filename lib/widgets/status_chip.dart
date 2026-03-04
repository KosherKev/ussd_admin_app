import 'package:flutter/material.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// StatusChip — Reusable status badge
//
// Uses AppColors semantic tokens, not hardcoded hex.
// status strings are case-insensitive matched.
// ---------------------------------------------------------------------------
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;

  /// If true, uses smaller font + padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final (fg, bg, border) = _resolve(status.toLowerCase(), c);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        _label(status),
        style: AppTypography.labelMono(fg).copyWith(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static (Color, Color, Color) _resolve(String s, AppColors c) {
    if (s.contains('complet') || s.contains('success') || s.contains('active') || s == 'enabled') {
      return (c.success, c.successBg, c.successBorder);
    }
    if (s.contains('pending') || s.contains('process') || s.contains('processing') || s.contains('scheduled')) {
      return (c.warning, c.warningBg, c.warningBorder);
    }
    if (s.contains('fail') || s.contains('error') || s.contains('reject') || s == 'disabled') {
      return (c.error, c.errorBg, c.errorBorder);
    }
    if (s.contains('info') || s.contains('sent')) {
      return (c.info, c.infoBg, c.borderMid);
    }
    // Default — neutral amber
    return (c.primaryAmber, c.amberBg, c.amberBorder);
  }

  static String _label(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }
}
