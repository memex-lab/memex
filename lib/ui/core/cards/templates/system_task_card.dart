import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:memex/utils/user_storage.dart';

class SystemTaskCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const SystemTaskCard({super.key, required this.data});

  String get status => data['status'] ?? 'processing';
  String get title =>
      data['title'] ??
      (status == 'failed'
          ? UserStorage.l10n.aiMaterialProcessFailed
          : status == 'completed'
              ? UserStorage.l10n.aiMaterialProcessDone
              : UserStorage.l10n.aiOrganizingMaterial);
  String get message =>
      data['message'] ??
      (status == 'completed'
          ? UserStorage.l10n.taskCompletedAddedToTimeline
          : status == 'failed'
              ? UserStorage.l10n.processErrorRetryLater
              : '');

  @override
  State<SystemTaskCard> createState() => _SystemTaskCardState();
}

class _SystemTaskCardState extends State<SystemTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.6),
                  const Color(0xFFF5F3FF).withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Row(
              children: [
                // Animated AI Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _spinController,
                      builder: (context, child) {
                        final isProcessing = widget.status == 'processing';
                        return Transform.rotate(
                          angle: isProcessing
                              ? _spinController.value * 2 * 3.14159
                              : 0,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  isProcessing
                                      ? const Color(0x00A855F7)
                                      : Colors.transparent,
                                  widget.status == 'failed'
                                      ? Colors.red
                                      : const Color(0xFFA855F7),
                                  isProcessing
                                      ? const Color(0x00A855F7)
                                      : Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          widget.status == 'failed'
                              ? Icons.error_outline
                              : widget.status == 'completed'
                                  ? Icons.check_circle_outline
                                  : Icons.auto_awesome,
                          color: widget.status == 'failed'
                              ? Colors.red
                              : const Color(0xFFA855F7),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Text content with shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.status == 'processing')
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _pulseController.value,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFA855F7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (widget.status == 'processing')
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildShimmerLine(widthRatio: 0.9),
                                const SizedBox(height: 6),
                                _buildShimmerLine(widthRatio: 0.6),
                              ],
                            );
                          },
                        ),
                      if (widget.status == 'completed' ||
                          widget.status == 'failed' ||
                          widget.message.isNotEmpty)
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double widthRatio}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * widthRatio,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
              ],
              stops: [
                0.0,
                0.5 + 0.5 * (_shimmerController.value * 2 - 1),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
