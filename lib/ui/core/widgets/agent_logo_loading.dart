import 'package:flutter/material.dart';

/// A branded loading indicator using the agent logo with pulse + rotation animation.
/// Replaces CircularProgressIndicator for page-level loading states.
class AgentLogoLoading extends StatefulWidget {
  final double size;

  const AgentLogoLoading({super.key, this.size = 48});

  @override
  State<AgentLogoLoading> createState() => _AgentLogoLoadingState();
}

class _AgentLogoLoadingState extends State<AgentLogoLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.85 + 0.3 * _controller.value;
        final glowOpacity = 0.1 + 0.25 * _controller.value;
        final rotation = 0.06 * _controller.value;
        return Container(
          width: widget.size + 16,
          height: widget.size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: glowOpacity),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size * 0.2),
        child: Image.asset(
          'assets/agent_logo.png',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
