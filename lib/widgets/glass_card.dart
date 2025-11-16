import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.65), blurRadius: 30, offset: Offset(0, 10)),
        ],
        border: Border.all(color: Colors.transparent),
      ),
      child: child,
    );
  }
}