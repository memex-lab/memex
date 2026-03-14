import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';

enum TimelineCardVariant {
  glass,
  immersive,
  canvas,
  receipt,
  outline,
}

class TimelineCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final TimelineCardVariant variant;
  final EdgeInsetsGeometry padding;
  final Color? customBackgroundColor;

  const TimelineCard({
    super.key,
    required this.child,
    this.onTap,
    this.variant = TimelineCardVariant.glass,
    this.padding = const EdgeInsets.all(24),
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Default visual rhythm
      decoration: _buildDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (variant) {
      case TimelineCardVariant.receipt:
        // Receipt has special shape handled by custom painter/clipper usually
        // For now, standard box but white
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: TimelineTheme.colors.textTertiary.withValues(alpha: 0.2)),
          boxShadow: [TimelineTheme.shadows.card],
        );
      case TimelineCardVariant.immersive:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B), // Slate-800
              const Color(0xFF0F172A), // Slate-900
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [TimelineTheme.shadows.float],
        );
      case TimelineCardVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: TimelineTheme.colors.textTertiary.withValues(alpha: 0.3)),
        );
      case TimelineCardVariant.canvas:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: TimelineTheme.colors.glassBorder.withValues(alpha: 0.5)),
          boxShadow: [TimelineTheme.shadows.card],
        );
      case TimelineCardVariant.glass:
      default:
        // Glassmorphism handled in content stack, but here we set outer shadow/radius
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [TimelineTheme.shadows.card],
          // actual color/blur is in _buildContent for Glass
        );
    }
  }

  Widget _buildContent() {
    Widget content = Padding(padding: padding, child: child);

    if (variant == TimelineCardVariant.glass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: customBackgroundColor ??
                  TimelineTheme.colors.background.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: TimelineTheme.colors.glassBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    if (variant == TimelineCardVariant.canvas) {
      return Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
          content,
        ],
      );
    }

    return content;
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TimelineTheme.colors.textTertiary.withValues(alpha: 0.15);
    const spacing = 20.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
