import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// HeaderIconButton — Reusable icon button for page-strip headers
// 
// Use this for "Refresh", "Back", or "Filter" buttons next to the page title.
// ---------------------------------------------------------------------------
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.active = false,
    this.loading = false,
  });

  final IconData  icon;
  final VoidCallback? onTap;
  final bool active;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? c.amberBg : c.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active ? c.amberBorder : c.borderMid,
            width: 1,
          ),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: c.primaryAmber,
                  ),
                )
              : Icon(
                  icon,
                  size: 17,
                  color: active ? c.primaryAmber : c.textSecondary,
                ),
        ),
      ),
    );
  }
}
