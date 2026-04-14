import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:memex/data/services/demo_service.dart';

/// Full-screen spotlight overlay for the onboarding demo.
///
/// Draws a semi-transparent scrim with a rounded-rect cutout around the
/// target widget. Only the cutout area passes taps through; everything
/// else blocks interaction. A tooltip bubble with arrow points to the target.
class DemoOverlay extends StatelessWidget {
  const DemoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DemoService.instance,
      builder: (context, _) {
        final demo = DemoService.instance;
        if (!demo.isActive && demo.currentStep != DemoStep.done) {
          return const SizedBox.shrink();
        }

        final step = demo.currentStep;

        // Welcome and Done steps: centered overlay card
        if (step == DemoStep.welcome || step == DemoStep.done) {
          return _buildCenteredOverlay(context, demo);
        }

        // Spotlight steps: find target and draw cutout
        final targetKey = demo.currentTargetKey;
        if (targetKey == null) return const SizedBox.shrink();

        // For tapCard: wait until the card has finished updating before
        // showing the spotlight. Show a blocking scrim in the meantime.
        if (step == DemoStep.tapCard && !demo.cardReady) {
          return Material(
            color: Colors.black54,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: GestureDetector(
                    onTap: demo.skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        demo.skipText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return _SpotlightOverlay(
          targetKey: targetKey,
          tooltipText: demo.tooltipText,
          skipText: demo.skipText,
          onSkip: demo.skip,
        );
      },
    );
  }

  Widget _buildCenteredOverlay(BuildContext context, DemoService demo) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        demo.tooltipText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: demo.advance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            demo.actionButtonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (demo.currentStep == DemoStep.welcome) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: demo.skip,
                          child: Text(
                            demo.skipText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Spotlight overlay that finds the target widget via GlobalKey,
/// draws a scrim with cutout, and shows a tooltip.
class _SpotlightOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String tooltipText;
  final String skipText;
  final VoidCallback onSkip;

  const _SpotlightOverlay({
    required this.targetKey,
    required this.tooltipText,
    required this.skipText,
    required this.onSkip,
  });

  @override
  State<_SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<_SpotlightOverlay> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _findTarget();
  }

  @override
  void didUpdateWidget(_SpotlightOverlay old) {
    super.didUpdateWidget(old);
    if (old.targetKey != widget.targetKey) {
      // Clear the cutout immediately — the scrim stays, only the hole disappears.
      // Once the new target is measured, the cutout + tooltip will reappear.
      _targetRect = null;
      _findTarget();
    }
  }

  void _findTarget() {
    // Delay for animated widgets (InputSheet slide-up, page transitions, card rebuild).
    final delay = widget.targetKey == DemoService.instance.sendButtonKey
        ? const Duration(milliseconds: 400)
        : widget.targetKey == DemoService.instance.firstCardKey
            ? const Duration(milliseconds: 500)
            : const Duration(milliseconds: 350); // page transition settle
    Future.delayed(delay, () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureAndVerify();
      });
    });
  }

  /// Measure the target, then re-measure after a short delay to confirm
  /// the position is stable (guards against mid-animation measurements).
  void _measureAndVerify() {
    if (!mounted) return;
    final first = _readRect();
    if (first == null) {
      // Widget not laid out yet — retry
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _findTarget();
      });
      return;
    }

    // Wait a beat, then re-measure to confirm stability
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final second = _readRect();
        if (second != null &&
            (second.left - first.left).abs() < 2 &&
            (second.top - first.top).abs() < 2) {
          // Stable — commit
          setState(() => _targetRect = second);
        } else {
          // Still moving — retry from scratch
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _measureAndVerify();
          });
        }
      });
    });
  }

  Rect? _readRect() {
    final renderBox =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final bottomRight = renderBox.localToGlobal(
      Offset(renderBox.size.width, renderBox.size.height),
    );
    return Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      // Measuring in progress — keep the scrim up (no cutout, no tooltip)
      // so the overlay never disappears between steps.
      return Material(
        color: Colors.black54,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 16),
              child: GestureDetector(
                onTap: widget.onSkip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.skipText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final cutout = RRect.fromRectAndRadius(
      _targetRect!.inflate(8), // padding around target
      const Radius.circular(16),
    );

    // Determine tooltip position: above or below the cutout
    final bool showAbove = _targetRect!.center.dy > size.height / 2;

    return Stack(
      children: [
        // Scrim with cutout — blocks taps outside cutout, passes through inside
        Positioned.fill(
          child: _ScrimWithHole(
            holeRect: _targetRect!.inflate(8),
            child: CustomPaint(
              painter: _SpotlightPainter(cutout: cutout),
            ),
          ),
        ),

        // Tooltip bubble
        _buildTooltip(size, cutout, showAbove),

        // Skip button — top right
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: GestureDetector(
            onTap: widget.onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.skipText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTooltip(Size screenSize, RRect cutout, bool showAbove) {
    const double tooltipWidth = 280;
    const double arrowSize = 10;
    const double gap = 12;

    final cutoutRect = cutout.outerRect;
    final double tooltipX = (cutoutRect.center.dx - tooltipWidth / 2)
        .clamp(16, screenSize.width - tooltipWidth - 16);

    final double tooltipY = showAbove
        ? cutoutRect.top - gap - arrowSize
        : cutoutRect.bottom + gap + arrowSize;

    return Positioned(
      left: tooltipX,
      top: showAbove ? null : tooltipY,
      bottom: showAbove
          ? screenSize.height - cutoutRect.top + gap + arrowSize
          : null,
      width: tooltipWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showAbove)
            _buildArrow(cutoutRect.center.dx - tooltipX, pointUp: true),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.tooltipText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showAbove)
            _buildArrow(cutoutRect.center.dx - tooltipX, pointUp: false),
        ],
      ),
    );
  }

  Widget _buildArrow(double offsetX, {required bool pointUp}) {
    return SizedBox(
      height: 10,
      child: Align(
        alignment: Alignment(-1 + 2 * (offsetX / 280).clamp(0.1, 0.9), 0),
        child: CustomPaint(
          size: const Size(20, 10),
          painter: _ArrowPainter(pointUp: pointUp),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final RRect cutout;
  _SpotlightPainter({required this.cutout});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Glow border around cutout
    final glowPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(cutout, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) => old.cutout != cutout;
}

class _ArrowPainter extends CustomPainter {
  final bool pointUp;
  _ArrowPainter({required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => old.pointUp != pointUp;
}

/// A widget that absorbs taps everywhere except inside [holeRect].
/// Taps inside the hole pass through to widgets below in the Stack.
class _ScrimWithHole extends SingleChildRenderObjectWidget {
  final Rect holeRect;

  const _ScrimWithHole({required this.holeRect, required Widget child})
      : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScrimWithHole(holeRect: holeRect);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderScrimWithHole renderObject) {
    renderObject.holeRect = holeRect;
  }
}

class _RenderScrimWithHole extends RenderProxyBox {
  Rect _holeRect;

  _RenderScrimWithHole({required Rect holeRect}) : _holeRect = holeRect;

  set holeRect(Rect value) {
    if (_holeRect != value) {
      _holeRect = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // If tap is inside the hole, don't claim it — let it pass through
    if (_holeRect.contains(position)) {
      return false;
    }
    // Outside the hole: absorb the tap
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}
