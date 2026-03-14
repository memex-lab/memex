import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: padding,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6), // Keep white border
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:
                          0.08), // Increased shadow opacity for separation
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    // Add inner white glow for glass effect
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                      blurStyle: BlurStyle
                          .inner, // Use standard outer shadow but simulated inner highlight
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ));
  }
}
