import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressItem {
  final String label;
  final double value;
  final String color;

  ProgressItem({
    required this.label,
    required this.value,
    required this.color,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      color: json['color'] as String? ?? '#E2E8F0',
    );
  }
}

class ProgressChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double current;
  final double target;
  final String? centerText;
  final List<ProgressItem> items;
  final String? insight;
  final VoidCallback? onTap;

  const ProgressChartCard({
    super.key,
    required this.title,
    this.subtitle,
    this.current = 0,
    this.target = 100,
    this.centerText,
    this.items = const [],
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
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to top
          children: [
            // Left: Chart
            Padding(
              padding: const EdgeInsets.only(top: 8.0), // Slight adjustment
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        sections: _buildSections(),
                      ),
                    ),
                    Center(
                      child: Text(
                        centerText ?? '${((current / target) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A), // Slate-900
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),

            // Right: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A), // Slate-900
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B), // Slate-500
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Legend Items
                  ...items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _parseColor(item.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B), // Slate-500
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${item.value.toInt()})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8), // Slate-400
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),

                  // Insight
                  if (insight != null && insight!.isNotEmpty) ...[
                    const SizedBox(height: 16),
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
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    // If explicit items are provided and they sum up to roughly the target, use them.
    // Otherwise fallback to simple current/remainder logic.

    if (items.isNotEmpty) {
      return items.map((item) {
        return PieChartSectionData(
          color: _parseColor(item.color),
          value: item.value,
          title: '',
          radius: 12, // Thickness
          showTitle: false,
        );
      }).toList();
    }

    // Default Fallback
    final remainder = target - current;
    return [
      PieChartSectionData(
        color: const Color(0xFFF43F5E), // Rose-500
        value: current,
        title: '',
        radius: 12,
        showTitle: false,
      ),
      if (remainder > 0)
        PieChartSectionData(
          color: const Color(0xFFF1F5F9), // Slate-100/200 like
          value: remainder,
          title: '',
          radius: 12,
          showTitle: false,
        ),
    ];
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
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFFE2E8F0);
    }
  }
}
