import 'package:flutter/material.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// PageHeader — Refined Financial Brutalism section header
//
// Plain bgBase background — no gradient pill.
// Large Sora title + optional subtitle + optional accentIcon + trailing.
// ---------------------------------------------------------------------------
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentIcon,
    this.trailing,
    /// [warm] is kept for API compatibility but ignored visually.
    this.warm = false,
  });

  final String title;
  final String? subtitle;

  /// Icon widget displayed to the left of the title.
  final Widget? accentIcon;

  /// Widget placed at the far right (e.g. action buttons).
  final Widget? trailing;

  /// Legacy param — kept for backward compat, ignored visually.
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
      ),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (accentIcon != null) ...[
            accentIcon!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.titleLarge?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: text.bodySmall?.copyWith(color: c.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
