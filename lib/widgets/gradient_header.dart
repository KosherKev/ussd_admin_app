import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final bool warm;
  final Widget? trailing;
  const GradientHeader({super.key, required this.title, this.warm = true, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = warm
        ? [const Color(0xFFC89B5E), const Color(0xFF8A5A2B)]
        : [const Color(0xFF3A5F78), const Color(0xFF1F2E3A)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}