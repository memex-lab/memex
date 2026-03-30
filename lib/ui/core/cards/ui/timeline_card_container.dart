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
    this.padding = const EdgeInsets.all(20),
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
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
              const Color(0xFF0A0A0A), // Slate-800
              const Color(0xFF0A0A0A), // Slate-900
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
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [TimelineTheme.shadows.card],
        );
    }
  }

  Widget _buildContent() {
    Widget content = Padding(padding: padding, child: child);

    if (variant == TimelineCardVariant.glass) {
      // Simple white card — no backdrop blur
      return content;
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
