import 'package:flutter/material.dart';
import 'package:ussd_admin/widgets/app_card.dart';

/// Legacy GlassCard — now delegates to AppCard.
/// Kept for backward compatibility during migration.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.base,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}
