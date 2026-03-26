import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RadarDimension {
  final String label;
  final double value;
  final double max;

  RadarDimension({
    required this.label,
    required this.value,
    this.max = 100,
  });

  factory RadarDimension.fromJson(Map<String, dynamic> json) {
    return RadarDimension(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      max: (json['max'] as num? ?? 100).toDouble(),
    );
  }
}

class RadarChartCard extends StatelessWidget {
  final String title;
  final String? badge;
  final String centerValue;
  final String centerLabel;
  final List<RadarDimension> dimensions;
  final String color;
  final String? insight;
  final VoidCallback? onTap;

  const RadarChartCard({
    super.key,
    required this.title,
    this.badge,
    required this.centerValue,
    required this.centerLabel,
    this.dimensions = const [],
    this.color = '#8B5CF6',
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A), // Dark Navy/Slate-900 per design
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.2),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF99A1AF), // Slate-400
                    letterSpacing: 1.5,
                  ),
                ),
                if (badge != null)
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1), // Slate-300
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Radar Chart + Center Text
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: themeColor.withValues(alpha:0.4),
                            borderColor: themeColor.withValues(alpha:0.8),
                            entryRadius: 0, // No dots on corners
                            borderWidth: 2, // Thicker border
                            dataEntries: dimensions
                                .map((d) => RadarEntry(value: _normalize(d)))
                                .toList(),
                          ),
                        ],
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(
                          color: Color(0xFF334155), // Slate-700 lines
                          width: 1.5,
                        ),
                        titlePositionPercentageOffset: 0.1,
                        titleTextStyle: const TextStyle(
                          color: Color(0xFF99A1AF), // Slate-400
                          fontSize: 12,
                        ),
                        tickCount: 1, // Minimize grid lines
                        ticksTextStyle: const TextStyle(
                            color: Colors.transparent, fontSize: 0),
                        tickBorderData: const BorderSide(
                          color: Color(0xFF334155), // Slate-700
                          width: 1,
                        ),
                        gridBorderData: const BorderSide(
                          color: Color(0xFF334155), // Slate-700
                          width: 1.5,
                        ),
                        getTitle: (index, angle) {
                          return RadarChartTitle(
                            text: dimensions[index].label,
                            angle: 0,
                          );
                        },
                      ),
                    ),
                  ),

                  // Center Value
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerValue,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha:0.9),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          centerLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha:0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (insight != null && insight!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                insight!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      Colors.white.withValues(alpha:0.7), // Keeping dark mode style
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _normalize(RadarDimension d) {
    if (d.max == 0) return 0;
    // We normalize to a somewhat standard scale, say 100 max for logic?
    // Actually RadarChart works best if all entries are relatively scaled?
    // Let's assume input values are comparable or normalized by caller.
    // If max is provided, normalize to percentage.
    return (d.value / d.max) * 100;
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
        return const Color(0xFF8B5CF6); // Violet-500
      case 'pink':
        return Colors.pink;
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}
