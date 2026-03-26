import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class ProgressCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final String? cardId;
  final int? configIndex;
  final Function(String cardId, int configIndex, Map<String, dynamic> data)?
      onUpdate;

  const ProgressCard({
    super.key,
    required this.data,
    this.onTap,
    this.cardId,
    this.configIndex,
    this.onUpdate,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  late double _current;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _current = (widget.data['current'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  void didUpdateWidget(ProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data['current'] != oldWidget.data['current']) {
      // Update local state if external data changes
      _current = (widget.data['current'] as num?)?.toDouble() ?? 0.0;
    }
  }

  void _updateProgress(double value) {
    setState(() {
      _current = value;
    });

    if (widget.cardId != null &&
        widget.configIndex != null &&
        widget.onUpdate != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        widget.onUpdate!(
          widget.cardId!,
          widget.configIndex!,
          {'current': _current},
        );
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = (widget.data['total'] as num?)?.toDouble() ?? 100.0;
    final String unit = widget.data['unit'] ?? '%';
    final String label = widget.data['label'] ?? 'Progress';

    return GlassCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.transparent
                      ],
                      stops: [0.0, 0.8, 0.9, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.white,
                        ],
                        stops: [0.0, 0.1, 0.2, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            '${_current.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} $unit',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A5565),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Restore spacing
          // Slider with compacted layout to match previous design
          SizedBox(
            height: 16,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF5B6CFF),
                inactiveTrackColor: const Color(0xFFF7F8FA),
                thumbColor: Colors.white,
                trackHeight: 12,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: SliderComponentShape.noOverlay, // Remove ripple
                trackShape: _CustomTrackShape(),
              ),
              child: Slider(
                value: _current.clamp(0.0, total),
                min: 0.0,
                max: total,
                onChanged: (value) => _updateProgress(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
