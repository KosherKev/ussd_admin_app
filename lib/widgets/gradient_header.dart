import 'package:flutter/material.dart';
import 'package:ussd_admin/widgets/page_header.dart';

/// Legacy GradientHeader — now delegates to PageHeader.
/// Kept for backward compatibility during migration.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
    this.warm = true,
  });

  final String title;
  final Widget? trailing;
  final Widget? leading;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: title,
      accentIcon: leading,
      trailing: trailing,
      warm: warm,
    );
  }
}
