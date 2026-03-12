import 'package:flutter/material.dart';

/// A coach mark overlay that highlights a target widget and shows a tooltip.
///
/// Uses a [GlobalKey] to locate the target widget, draws a semi-transparent
/// backdrop with a cutout around the target, and displays a message bubble.
class CoachMarkOverlay extends StatelessWidget {
  final GlobalKey targetKey;
  final String message;
  final VoidCallback onDismiss;
  final EdgeInsets targetPadding;

  const CoachMarkOverlay({
    super.key,
    required this.targetKey,
    required this.message,
    required this.onDismiss,
    this.targetPadding = const EdgeInsets.all(8),
  });

  Rect? _getTargetRect() {
    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      offset.dx - targetPadding.left,
      offset.dy - targetPadding.top,
      renderBox.size.width + targetPadding.horizontal,
      renderBox.size.height + targetPadding.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetRect = _getTargetRect();
    if (targetRect == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final showAbove = targetRect.center.dy > screenSize.height * 0.5;

    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop with cutout
            CustomPaint(
              size: screenSize,
              painter: _CoachMarkPainter(targetRect: targetRect),
            ),
            // Tooltip bubble
            Positioned(
              left: 24,
              right: 24,
              top: showAbove ? null : targetRect.bottom + 16,
              bottom:
                  showAbove ? screenSize.height - targetRect.top + 16 : null,
              child: _buildTooltip(context, showAbove),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, bool showAbove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF334155),
              height: 1.5,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap anywhere to continue',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachMarkPainter extends CustomPainter {
  final Rect targetRect;

  _CoachMarkPainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    // Draw full screen overlay
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cut out the target area with rounded rect
    final cutoutPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(targetRect, const Radius.circular(16)));

    // Combine paths (full screen minus cutout)
    final combinedPath =
        Path.combine(PathOperation.difference, fullPath, cutoutPath);

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CoachMarkPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
