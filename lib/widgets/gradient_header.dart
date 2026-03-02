import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

/// Gradient header bar used at the top of each tab page.
class GradientHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? leading;
  final bool warm;

  const GradientHeader({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
    this.warm = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.warm(colors: c),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}