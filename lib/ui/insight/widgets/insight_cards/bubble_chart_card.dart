import 'package:flutter/material.dart';

class InsightBubble {
  final String label;
  final num value;
  final String color;
  final String? subLabel;
  final bool isHighlight;

  InsightBubble({
    required this.label,
    required this.value,
    this.color = '#6366F1',
    this.subLabel,
    this.isHighlight = false,
  });

  factory InsightBubble.fromJson(Map<String, dynamic> json) {
    return InsightBubble(
      label: json['label'] as String? ?? '',
      value: json['value'] as num? ?? 1,
      color: json['color'] as String? ?? '#6366F1',
      subLabel: json['sub_label'] as String?,
      isHighlight: json['is_highlight'] as bool? ?? false,
    );
  }
}

class BubbleChartCard extends StatelessWidget {
  final String title;
  final List<InsightBubble> bubbles;
  final String? footer;
  final String? insight;
  final VoidCallback? onTap;

  const BubbleChartCard({
    super.key,
    required this.title,
    this.bubbles = const [],
    this.footer,
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort bubbles so highlight is first (or handle in layout)
    // Actually, for Wrap, having the big one in the middle is hard.
    // We will use a custom Flow or just Wrap for now.
    // If there is a highlight bubble, we might want to place it prominently.
    // Simple approach: Just Wrap centered.

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Slate-50
          borderRadius: BorderRadius.circular(32),
          // Gradient border or shadow if needed, but design looks clean flat/soft
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8), // Slate-400
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            // Bubbles Area
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: bubbles.map((b) => _buildBubble(b)).toList(),
              ),
            ),

            const SizedBox(height: 32),

            const SizedBox(height: 24),

            // Insight
            if (insight != null && insight!.isNotEmpty) ...[
              Text(
                insight!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B), // Slate-500
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Footer
            if (footer != null)
              Text(
                footer!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF94A3B8), // Slate-400
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(InsightBubble bubble) {
    // Scale size based on value (roughly).
    // Assume value is 1-100.
    // Base size 80, Max size 160.

    double size = 80;
    if (bubble.isHighlight) {
      size = 140;
    } else {
      // Simple dynamic sizing
      size = 70 + (bubble.value.clamp(0, 100) * 0.6).toDouble();
      if (size > 110) size = 110;
    }

    final color = _parseColor(bubble.color);
    // Lighter background for the bubble
    final bgColor = color.withValues(alpha:0.15);
    final textColor = color;

    // Highlight bubble style might be different (Solid bg?)
    // Converting design: "AI Agent" bubble is solid blue, text white. Others are light bg, colored text.
    final bool isSolid = bubble.isHighlight;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSolid ? color : bgColor,
        shape: BoxShape.circle,
        boxShadow: isSolid
            ? [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (bubble.isHighlight &&
              bubble.subLabel != null) // "Top Topic" logic if needed
            const Text(
              "Top Topic",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          Text(
            bubble.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSolid ? Colors.white : textColor,
              fontWeight: FontWeight.bold,
              fontSize: isSolid ? 18 : 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (bubble.subLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                bubble.subLabel!,
                style: TextStyle(
                  color: isSolid
                      ? Colors.white.withValues(alpha:0.8)
                      : textColor.withValues(alpha:0.8),
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
    }
    // Fallback simple names
    switch (colorStr.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return const Color(0xFF6366F1);
    }
  }
}
