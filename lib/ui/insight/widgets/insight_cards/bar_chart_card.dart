import 'package:flutter/material.dart';

class BarItem {
  final String label;
  final double value;
  final String? icon;
  final String? color;
  final bool isHighlight;

  BarItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.isHighlight = false,
  });

  factory BarItem.fromJson(Map<String, dynamic> json) {
    return BarItem(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isHighlight: json['is_highlight'] as bool? ?? false,
    );
  }
}

class BarChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String unit;
  final List<BarItem> items;
  final String? insight;
  final VoidCallback? onTap;

  const BarChartCard({
    super.key,
    required this.title,
    this.subtitle,
    this.unit = '',
    this.items = const [],
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine max value for normalization
    double maxY = items.isNotEmpty
        ? items.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 10;
    if (maxY == 0) maxY = 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0A0A), // Slate-900
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A5565), // Slate-500
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Horizontal Bars List
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              final percent = (item.value / maxY).clamp(0.0, 1.0);
              final color = item.color != null
                  ? _parseColor(item.color!)
                  : const Color(0xFF5B6CFF);
              final isHighlight = item.isHighlight;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    if (item.icon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          item.icon!,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label & Value
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isHighlight
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isHighlight
                                        ? const Color(0xFF0A0A0A)
                                        : const Color(0xFF4A5565),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.value.toStringAsFixed(1)}$unit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isHighlight
                                      ? color
                                      : const Color(0xFF4A5565),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Bar
                          SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                // Background
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F8FA), // Slate-100
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                // Foreground
                                FractionallySizedBox(
                                  widthFactor: percent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isHighlight
                                          ? color
                                          : color.withValues(alpha:0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Insight
            if (insight != null && insight!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                insight!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5565), // Slate-500
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    if (colorStr.isEmpty) return const Color(0xFF5B6CFF);

    try {
      // 1. Clean up the string (remove hash, whitespace)
      String hex = colorStr.replaceAll('#', '').trim();

      // 2. Handle malformed strings like "EC4899,is_highlight:true"
      // Match the first sequence of 6 or 8 hex digits
      final match = RegExp(r'^[0-9a-fA-F]{6,8}').firstMatch(hex);
      if (match != null) {
        hex = match.group(0)!;
      } else {
        // If no valid hex found at start, return default
        return const Color(0xFF5B6CFF);
      }

      // 3. Parse based on length
      if (hex.length == 6) {
        return Color(int.parse(hex, radix: 16) + 0xFF000000);
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      debugPrint('Error parsing color: $colorStr - $e');
    }
    return const Color(0xFF5B6CFF);
  }
}
