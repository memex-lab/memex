import 'package:flutter/material.dart';

class AICoreButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate;
  final Function(LongPressEndDetails)? onLongPressEnd;

  const AICoreButton({
    super.key,
    required this.onTap,
    required this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
  });

  @override
  State<AICoreButton> createState() => _AICoreButtonState();
}

class _AICoreButtonState extends State<AICoreButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  bool _isPressing = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    try {
      setState(fn);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _safeSetState(() => _isPressing = true);
    _scaleController.animateTo(0.9).then((_) {
      if (mounted) {
        _safeSetState(() => _isPressing = false);
        _scaleController.animateTo(1.0);
        widget.onTap();
      }
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
      onLongPressEnd: widget.onLongPressEnd,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black,
            boxShadow: _isPressing
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.30),
                      blurRadius: 18,
                      spreadRadius: 0,
                      offset: Offset.zero,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.black,
            ),
            alignment: Alignment.center,
            child: const _AnimatedStarIcon(
              isPulse: false,
              hasGlow: false,
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Helper Widgets / Animations ----

class _AnimatedStarIcon extends StatefulWidget {
  final bool isPulse;
  final bool hasGlow;

  const _AnimatedStarIcon({
    required this.isPulse,
    required this.hasGlow,
  });

  @override
  State<_AnimatedStarIcon> createState() => _AnimatedStarIconState();
}

class _AnimatedStarIconState extends State<_AnimatedStarIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulse != oldWidget.isPulse) {
      if (widget.isPulse) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity =
            widget.isPulse ? 0.4 + 0.6 * _pulseController.value : 1.0;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF818CF8), Color(0xFFC084FC), Color(0xFFF472B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Container(
            decoration: const BoxDecoration(),
            child: Opacity(
              opacity: opacity,
              child: const Icon(
                Icons.auto_awesome, // fallback standard star equivalent
                size: 32,
                color: Colors.white, // Color is defined by ShaderMask
              ),
            ),
          ),
        );
      },
    );
  }
}

