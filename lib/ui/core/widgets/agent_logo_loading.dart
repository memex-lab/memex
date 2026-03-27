import 'package:flutter/material.dart';

/// A loading indicator with pulse animation.
class AgentLogoLoading extends StatelessWidget {
  final double size;

  const AgentLogoLoading({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size > 32 ? 3.0 : 2.0,
        color: const Color(0xFF6366F1),
      ),
    );
  }
}
