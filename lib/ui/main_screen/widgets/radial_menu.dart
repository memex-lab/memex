import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memex/domain/models/shortcut_item.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/utils/user_storage.dart';

class RadialMenu extends StatefulWidget {
  final List<ShortcutItem> items;
  final Offset center;
  final Function(ShortcutItem?) onItemSelected;
  final VoidCallback onCancel;
  final bool visible;
  final String? transcriptText;
  final bool isCalibrating;

  const RadialMenu({
    super.key,
    required this.items,
    required this.center,
    required this.onItemSelected,
    required this.onCancel,
    required this.visible,
    this.transcriptText,
    this.isCalibrating = false,
  });

  @override
  State<RadialMenu> createState() => RadialMenuState();
}

class RadialMenuState extends State<RadialMenu> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  ShortcutItem? _hoveredItem;
  bool _isCancelHovered = false;

  // Layout Configuration
  // Simply one layer for the Cancel button
  final double _cancelRadius = 120.0;

  // Cache layout to avoid recalculating every frame
  List<_LayoutItem> _layoutItems = [];
  Size? _lastScreenSize;

  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    if (widget.visible) {
      _controller.forward();
      _waveformController.repeat(reverse: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;
    if (_lastScreenSize != screenSize) {
      _lastScreenSize = screenSize;
      if (widget.visible) {
        _calculateLayout();
      }
    }
  }

  @override
  void didUpdateWidget(RadialMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
        _waveformController.repeat(reverse: true);
        _calculateLayout();
      } else {
        _controller.reverse();
        _waveformController.reset();
        _hoveredItem = null;
        _isCancelHovered = false;
      }
    }
    if (widget.items != oldWidget.items) {
      _calculateLayout();
    }
  }

  void _calculateLayout() {
    if (!mounted) return;

    _layoutItems.clear();

    // Let's just place Cancel at a fixed offset
    const cancelAngle = -math.pi / 2;
    _layoutItems.add(_LayoutItem(
      index: widget.items.length, // Cancel index
      angle: cancelAngle,
      radius: _cancelRadius,
      center: widget.center +
          Offset(_cancelRadius * math.cos(cancelAngle),
              _cancelRadius * math.sin(cancelAngle)),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void handleUpdate(Offset localPosition) {
    if (!widget.visible) return;

    double minDistance = double.infinity;
    _LayoutItem? closestItem;

    for (final item in _layoutItems) {
      final dist = (localPosition - item.center).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestItem = item;
      }
    }

    if (closestItem != null && minDistance < 60) {
      _updateHover(closestItem.index);
    } else {
      _clearHover();
    }
  }

  void _updateHover(int index) {
    final total = widget.items.length;
    if (index == total) {
      if (!_isCancelHovered) {
        HapticFeedback.lightImpact();
        setState(() {
          _isCancelHovered = true;
          _hoveredItem = null;
        });
      }
    } else {
      final item = widget.items[index];
      if (_hoveredItem != item) {
        HapticFeedback.selectionClick();
        setState(() {
          _hoveredItem = item;
          _isCancelHovered = false;
        });
      }
    }
  }

  void _clearHover() {
    if (_hoveredItem != null || _isCancelHovered) {
      setState(() {
        _hoveredItem = null;
        _isCancelHovered = false;
      });
    }
  }

  void handleRelease() {
    if (!widget.visible) return;
    if (_isCancelHovered) {
      widget.onCancel();
    } else {
      widget.onItemSelected(_hoveredItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_layoutItems.isEmpty && widget.visible) {
      _calculateLayout();
    }

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          const hubSize = 60.0;

          return Stack(
            children: [
              // Background blur
              if (widget.visible)
                Container(
                  color: Colors.black.withOpacity(0.01),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: widget.visible ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: 8 * value,
                            sigmaY:
                                8 * value), // Increased blur for premium feel
                        child: Container(
                          color: Colors.white.withOpacity(
                              0.4 * value), // Light overlay instead of dark
                        ),
                      );
                    },
                  ),
                ),

              // Items (Only Cancel button now)
              ..._layoutItems.map((layoutItem) {
                final index = layoutItem.index;
                final isCancel = index == widget.items.length;
                if (!isCancel) return const SizedBox.shrink(); // Safety check

                final isHovered = _isCancelHovered;

                return Positioned(
                  left: layoutItem.center.dx - 40,
                  top: layoutItem.center.dy - 30,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.rotate(
                      angle: layoutItem.angle + math.pi / 2,
                      child: Transform.scale(
                        scale: _scaleAnimation.value * (isHovered ? 1.1 : 1.0),
                        child: _buildCancelButton(isHovered, layoutItem.radius),
                      ),
                    ),
                  ),
                );
              }),

              // Center Hub
              Positioned(
                left: widget.center.dx - hubSize / 2,
                top: widget.center.dy - hubSize / 2,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: hubSize,
                    height: hubSize,
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Hardcode to white for clarity if theme is tricky
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.mic,
                        color: TimelineTheme.colors.primary, size: 28),
                  ),
                ),
              ),

              // Feedback Bubble
              if (widget.visible)
                Align(
                  alignment: const Alignment(0, -0.2), // Adjusted higher
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      constraints:
                          const BoxConstraints(minWidth: 120, maxWidth: 260),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          TimelineTheme.shadows.float
                        ], // Premium shadow
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isCancelHovered) ...[
                            Text(
                              UserStorage.l10n.cancel,
                              textAlign: TextAlign.center,
                              style: TimelineTheme.typography.body.copyWith(
                                color: TimelineTheme.colors.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ] else ...[
                            Container(
                              height: 24,
                              margin: const EdgeInsets.only(bottom: 4),
                              alignment: Alignment.center,
                              child: _hoveredItem != null
                                  ? Text(
                                      _hoveredItem!.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TimelineTheme.typography.body
                                          .copyWith(
                                        color: TimelineTheme.colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : AnimatedBuilder(
                                      animation: _waveformController,
                                      builder: (context, child) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: List.generate(
                                            8,
                                            (i) => Container(
                                                  width: 4,
                                                  height: 8 +
                                                      (math.sin(i * 0.8 +
                                                                  _waveformController
                                                                          .value *
                                                                      math.pi *
                                                                      2) *
                                                              12)
                                                          .abs(),
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  decoration: BoxDecoration(
                                                    color: TimelineTheme
                                                        .colors.primary
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                )),
                                      ),
                                    ),
                            ),
                            Text(
                              widget.isCalibrating
                                  ? UserStorage.l10n.speechTranscribing
                                  : UserStorage.l10n.releaseToSend,
                              textAlign: TextAlign.center,
                              style: TimelineTheme.typography.small.copyWith(
                                color: TimelineTheme.colors.textSecondary,
                              ),
                            ),
                            if (widget.isCalibrating) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TimelineTheme.colors.primary,
                                ),
                              ),
                            ],
                            // Real-time transcript
                            if (widget.transcriptText != null &&
                                widget.transcriptText!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 280, maxHeight: 120),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: _TranscriptAutoScroll(
                                  text: widget.transcriptText!,
                                  style: TimelineTheme.typography.body.copyWith(
                                    fontSize: 14,
                                    color: TimelineTheme.colors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(String label, bool isHovered, double radius) {
    return CustomPaint(
      painter: _CurvedItemPainter(
        color: isHovered
            ? TimelineTheme.colors.primary // Indigo Active
            : Colors.white.withOpacity(0.9), // White Default
        isHovered: isHovered,
        curvatureRadius: radius,
        textColor: isHovered ? Colors.white : TimelineTheme.colors.textPrimary,
      ),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TimelineTheme.typography.body.copyWith(
            color: isHovered ? Colors.white : TimelineTheme.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(bool isHovered, double radius) {
    return CustomPaint(
      painter: _CurvedItemPainter(
        color: isHovered
            ? TimelineTheme.colors.danger // Red Active
            : TimelineTheme.colors.danger.withOpacity(0.1), // Soft Red Default
        isHovered: isHovered,
        curvatureRadius: radius,
        textColor: isHovered ? Colors.white : TimelineTheme.colors.danger,
      ),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          UserStorage.l10n.cancel,
          style: TimelineTheme.typography.body.copyWith(
            color: isHovered ? Colors.white : TimelineTheme.colors.danger,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LayoutItem {
  final int index;
  final double angle;
  final double radius;
  final Offset center;

  _LayoutItem(
      {required this.index,
      required this.angle,
      required this.radius,
      required this.center});
}

class _CurvedItemPainter extends CustomPainter {
  final Color color;
  final bool isHovered;
  final double curvatureRadius;
  final Color textColor; // Unused in painting but good for context

  _CurvedItemPainter(
      {required this.color,
      required this.isHovered,
      required this.curvatureRadius,
      this.textColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..strokeCap = StrokeCap.round;

    // Add subtle shadow for the white cards
    if (!isHovered && color == Colors.white.withOpacity(0.9)) {
      // Manual shadow drawing if needed, but might be complex with Stroke.
      // For now, clean flat look is better than messy shadow on stroke.
    }

    // Center of curvature
    final centerOffset =
        Offset(size.width / 2, curvatureRadius + size.height / 2);
    final rect = Rect.fromCircle(center: centerOffset, radius: curvatureRadius);

    final sweepAngle = size.width / curvatureRadius;
    final startAngle = -math.pi / 2 - sweepAngle / 2;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedItemPainter oldDelegate) {
    return color != oldDelegate.color ||
        isHovered != oldDelegate.isHovered ||
        curvatureRadius != oldDelegate.curvatureRadius;
  }
}

/// Auto-scrolling transcript text widget.
class _TranscriptAutoScroll extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TranscriptAutoScroll({required this.text, required this.style});

  @override
  State<_TranscriptAutoScroll> createState() => _TranscriptAutoScrollState();
}

class _TranscriptAutoScrollState extends State<_TranscriptAutoScroll> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _TranscriptAutoScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: widget.style,
      ),
    );
  }
}
