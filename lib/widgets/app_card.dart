import 'package:flutter/material.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// AppCard — Refined Financial Brutalism card widget
//
// Variants:
//   AppCardVariant.base     — bgSurface fill, 1px borderStrong border, r=md
//   AppCardVariant.elevated — bgRaised fill, 1px borderStrong border, r=md
//   AppCardVariant.accent   — bgSurface fill + 3px left accent bar in [accentColor]
// ---------------------------------------------------------------------------
enum AppCardVariant { base, elevated, accent }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.base,
    this.accentColor,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  final Widget child;
  final AppCardVariant variant;

  /// Only used when [variant] == [AppCardVariant.accent].
  /// Falls back to amber if null.
  final Color? accentColor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Override default border radius (AppRadius.md = 10).
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final c  = context.appColors;
    final r  = borderRadius ?? AppRadius.md;
    final br = BorderRadius.circular(r);

    final fillColor = switch (variant) {
      AppCardVariant.elevated => c.bgRaised,
      _                       => c.bgSurface,
    };

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: br,
        border: Border.all(color: c.borderStrong, width: 1),
      ),
      child: child,
    );

    // Accent variant: wrap in a Row with a 3px left bar.
    if (variant == AppCardVariant.accent) {
      final barColor = accentColor ?? c.primaryAmber;
      content = ClipRRect(
        borderRadius: br,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: barColor),
              Expanded(
                child: Container(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border(
                      top:    BorderSide(color: c.borderStrong, width: 1),
                      right:  BorderSide(color: c.borderStrong, width: 1),
                      bottom: BorderSide(color: c.borderStrong, width: 1),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }
    return content;
  }
}
