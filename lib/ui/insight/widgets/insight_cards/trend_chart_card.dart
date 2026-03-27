import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendPoint {
  final String label;
  final double value;
  final bool isHighlight;

  TrendPoint({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      isHighlight: json['is_highlight'] as bool? ?? false,
    );
  }
}

class TrendChartCard extends StatelessWidget {
  final String title;
  final String? topRightText;
  final List<TrendPoint> points;
  final Map<String, dynamic>? highlightInfo;
  final String color;
  final String? insight;
  final VoidCallback? onTap;

  const TrendChartCard({
    super.key,
    required this.title,
    this.topRightText,
    this.points = const [],
    this.highlightInfo,
    this.color = '#6366F1',
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(color);
    // Find highlighted point for tooltip
    final highlightIndex = points.indexWhere((p) => p.isHighlight);
    final highlightPoint = highlightIndex != -1 ? points[highlightIndex] : null;

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    // Determine min/max for y-axis
    double minY = points.isNotEmpty
        ? points.map((p) => p.value).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxY = points.isNotEmpty
        ? points.map((p) => p.value).reduce((a, b) => a > b ? a : b)
        : 10;
    if (minY > 0) minY = 0; // anchor to 0 usually
    maxY = maxY * 1.2; // some padding

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
                if (topRightText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    topRightText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF99A1AF),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // Line Chart
            AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: Color(0xFFF7F8FA), // Slate-100
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            // Dynamic interval to prevent overlap
                            interval: points.length > 8
                                ? (points.length / 7).ceilToDouble()
                                : 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < points.length) {
                                final p = points[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    p.label,
                                    style: TextStyle(
                                      color: p.isHighlight
                                          ? themeColor
                                          : const Color(0xFF99A1AF),
                                      fontWeight: p.isHighlight
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (maxY - minY) / 4,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (points.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: themeColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                // Show dots at intervals or highlight
                                final index = spot.x.toInt();
                                if (index >= 0 && index < points.length) {
                                  return points[index].isHighlight ||
                                      index % 2 == 0;
                                }
                                return false;
                              },
                              getDotPainter: (spot, percent, barData, index) {
                                final idx = spot.x.toInt();
                                final isHigh = idx >= 0 &&
                                    idx < points.length &&
                                    points[idx].isHighlight;

                                return FlDotCirclePainter(
                                  radius: isHigh ? 6 : 4,
                                  color: Colors.white,
                                  strokeWidth: isHigh ? 3 : 2,
                                  strokeColor: themeColor,
                                );
                              }),
                          belowBarData: BarAreaData(
                            show: true,
                            color: themeColor.withValues(alpha:0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                          enabled:
                              false), // Disable interaction for static card
                    ),
                  ),

                  // Tooltip overlay for highlighted point
                  if (highlightPoint != null && highlightInfo != null)
                    LayoutBuilder(builder: (context, constraints) {
                      // Simple absolute positioning estimation based on spots
                      // This is tricky without precise coordinates.
                      // For simplicity in this iteration, we place a fixed floating card
                      // near the highlighted point index.
                      final index = points.indexOf(highlightPoint);
                      final xPercent = index / (points.length - 1);
                      final yPercent =
                          (highlightPoint.value - minY) / (maxY - minY);

                      // A bit simpler: Just center the tooltip if we can't align perfectly.
                      // Or simple Align based on x.

                      return Align(
                        alignment: Alignment(
                          -1.0 + (xPercent * 2.0), // -1 to 1 range
                          -1.0 +
                              ((1.0 - yPercent) * 2.0) -
                              0.4, // Move up a bit
                        ),
                        child: FractionalTranslation(
                          translation: const Offset(0, -0.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A), // Slate-800
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  highlightInfo!['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (highlightInfo!['subtitle'] != null)
                                  Text(
                                    highlightInfo!['subtitle'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

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
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
    }
    return const Color(0xFF5B6CFF);
  }
}
