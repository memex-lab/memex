import 'package:flutter/material.dart';

class CompositionItem {
  final String label;
  final double percentage;
  final Color color;

  CompositionItem({
    required this.label,
    required this.percentage,
    required this.color,
  });

  factory CompositionItem.fromJson(Map<String, dynamic> json) {
    return CompositionItem(
      label: json['label'] as String? ?? 'Unknown',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      color: _parseColor(json['color']),
    );
  }

  static Color _parseColor(dynamic colorStr) {
    if (colorStr is String) {
      // Basic hex parsing - assuming user provides #RRGGBB
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }
      // Simple named color fallback (extend as needed if agent uses names)
      switch (colorStr.toLowerCase()) {
        case 'purple':
          return const Color(0xFF6366F1);
        case 'blue':
          return const Color(0xFF3B82F6);
        case 'green':
          return const Color(0xFF10B981);
        case 'orange':
          return const Color(0xFFF97316);
        case 'red':
          return const Color(0xFFEF4444);
        case 'grey':
        case 'gray':
          return const Color(0xFF94A3B8);
        case 'black':
          return Colors.black;
      }
    }
    return const Color(0xFF94A3B8); // Default slate-400
  }
}

class HeadlineItem {
  final String text;
  final Color? color;

  HeadlineItem({required this.text, this.color});

  factory HeadlineItem.fromJson(Map<String, dynamic> json) {
    return HeadlineItem(
      text: json['text'] as String? ?? '',
      color: json['color'] != null
          ? CompositionItem._parseColor(json['color'])
          : null,
    );
  }
}

class CompositionCard extends StatelessWidget {
  final String title;
  final String? badge;
  final List<HeadlineItem> headlineItems;
  final List<CompositionItem> items;
  final String? footer;
  final String? insight;
  final VoidCallback? onTap;

  const CompositionCard({
    super.key,
    required this.title,
    this.badge,
    this.headlineItems = const [],
    this.items = const [],
    this.footer,
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32), // Extra rounded per design
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04), // subtle shadow
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8), // Muted header
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate-100
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

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
              ),
              const SizedBox(height: 24),
            ],

            // Headline
            if (headlineItems.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B), // Slate-800
                    height: 1.4,
                  ),
                  children: headlineItems.map((item) {
                    return TextSpan(
                      text: item.text,
                      style: TextStyle(
                        color: item.color ?? const Color(0xFF1E293B),
                        fontWeight:
                            item.color != null && item.color != Colors.black
                                ? FontWeight.bold
                                : FontWeight.w600,
                        // Add underlining or other styles if needed
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Progress Bar
            _buildProgressBar(),

            const SizedBox(height: 24),

            // Items Legend
            _buildLegendGrid(),

            // Footer
            if (footer != null) ...[
              const SizedBox(height: 24),
              Container(
                height: 1,
                color: const Color(0xFFF1F5F9), // Divider
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF64748B),
                    ),
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.info_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      footer!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (items.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 24, // Thicker bar
        color: const Color(0xFFF1F5F9), // Background track
        child: Row(
          children: items.map((item) {
            final flex = (item.percentage * 10).round();
            if (flex <= 0) return const SizedBox.shrink();
            return Flexible(
              flex: flex,
              child: Container(
                color: item.color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLegendGrid() {
    if (items.isEmpty) return const SizedBox.shrink();

    // Responsive 2-column layout usually works best for mobile
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: items.map((item) {
        // approx 45% width for 2 columns with spacing
        return FractionallySizedBox(
          widthFactor: 0.45,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.label} (${item.percentage.toInt()}%)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
