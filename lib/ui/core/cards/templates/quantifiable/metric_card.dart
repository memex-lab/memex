import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class MetricCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const MetricCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = [];
    final String cardTitle = data['title'] ?? '';

    if (data.containsKey('items') && data['items'] is List) {
      items = List<Map<String, dynamic>>.from(data['items']);
    } else {
      items = [data];
    }

    if (items.isEmpty) return const SizedBox.shrink();

    Widget content;
    final int count = items.length;

    if (count == 1) {
      content = _buildMetricRow(context, items[0]);
    } else {
      List<Widget> rows = [];
      for (int i = 0; i < count; i += 2) {
        if (i + 1 < count) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildGridItem(context, items[i])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGridItem(context, items[i + 1])),
                ],
              ),
            ),
          );
        } else {
          rows.add(_buildWideItem(context, items[i]));
        }
      }

      List<Widget> spacedRows = [];
      for (int j = 0; j < rows.length; j++) {
        spacedRows.add(rows[j]);
        if (j < rows.length - 1) {
          spacedRows.add(const SizedBox(height: 12));
        }
      }

      content = Column(
        children: spacedRows,
      );
    }

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cardTitle.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6CFF), // Indigo 500
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cardTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A), // Slate 900
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          content,
        ],
      ),
    );
  }

  Widget _buildWideItem(BuildContext context, Map<String, dynamic> itemData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA).withValues(alpha: 0.5), // Slate 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF7F8FA), // Slate 100
          width: 1,
        ),
      ),
      child: _buildMetricRow(context, itemData),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> itemData) {
    final String title = itemData['title'] ?? 'Metric';

    final num valueNum = itemData['value'] as num? ?? 0.0;
    String valueStr = valueNum % 1 == 0
        ? valueNum.toInt().toString()
        : valueNum.toStringAsFixed(4);
    if (valueStr.contains('.')) {
      valueStr = valueStr
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    final String unit = itemData['unit'] ?? '';
    final String label = itemData['label'] ?? '';
    final String trend = itemData['trend'] ?? 'neutral';
    final String colorTheme = itemData['color'] ?? 'indigo';

    final Map<String, dynamic> theme = _getTheme(colorTheme);
    final Color primaryColor = theme['primary'];
    final Color bgColor = theme['bg'];

    IconData trendIcon;
    Color trendColor;
    bool hasTrend = false;

    if (trend == 'up') {
      trendIcon = Icons.trending_up_rounded;
      trendColor = const Color(0xFF10B981); // Emerald 500
      hasTrend = true;
    } else if (trend == 'down') {
      trendIcon = Icons.trending_down_rounded;
      trendColor = const Color(0xFFEF4444); // Red 500
      hasTrend = true;
    } else {
      trendIcon = Icons.horizontal_rule_rounded;
      trendColor = const Color(0xFF99A1AF); // Slate 400
      hasTrend = false;
    }

    final IconData leadingIcon =
        hasTrend ? trendIcon : Icons.multiline_chart_rounded;
    final Color leadingIconColor = hasTrend ? trendColor : primaryColor;
    final Color leadingBgColor =
        hasTrend ? trendColor.withValues(alpha: 0.12) : bgColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA).withValues(alpha: 0.5), // Slate 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF7F8FA), // Slate 100
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: leadingBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: leadingIconColor.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    leadingIcon,
                    size: 16,
                    color: leadingIconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: Color(0xFF4A5565), // Slate 600
                        letterSpacing: -0.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        valueStr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A), // Slate 900
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF99A1AF), // Slate 400
                      ),
                    ),
                  ],
                ],
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A5565), // Slate 500
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, Map<String, dynamic> itemData) {
    final String title = itemData['title'] ?? 'Metric';

    // Handle value formatting gracefully
    final num valueNum = itemData['value'] as num? ?? 0.0;
    String valueStr = valueNum % 1 == 0
        ? valueNum.toInt().toString()
        : valueNum.toStringAsFixed(4);

    // Trim trailing zeros for decimals
    if (valueStr.contains('.')) {
      valueStr = valueStr
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    final String unit = itemData['unit'] ?? '';
    final String label = itemData['label'] ?? '';
    final String trend = itemData['trend'] ?? 'neutral';
    final String colorTheme = itemData['color'] ?? 'indigo';

    final Map<String, dynamic> theme = _getTheme(colorTheme);
    final Color primaryColor = theme['primary'];
    final Color bgColor = theme['bg'];

    IconData trendIcon;
    Color trendColor;
    bool hasTrend = false;

    if (trend == 'up') {
      trendIcon = Icons.trending_up_rounded;
      trendColor = const Color(0xFF10B981); // Emerald 500
      hasTrend = true;
    } else if (trend == 'down') {
      trendIcon = Icons.trending_down_rounded;
      trendColor = const Color(0xFFEF4444); // Red 500
      hasTrend = true;
    } else {
      trendIcon = Icons.horizontal_rule_rounded;
      trendColor = const Color(0xFF99A1AF); // Slate 400
      hasTrend = false;
    }

    final IconData leadingIcon =
        hasTrend ? trendIcon : Icons.multiline_chart_rounded;
    final Color leadingIconColor = hasTrend ? trendColor : primaryColor;
    final Color leadingBgColor =
        hasTrend ? trendColor.withValues(alpha: 0.12) : bgColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Premium Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: leadingBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: leadingIconColor.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              leadingIcon,
              size: 22,
              color: leadingIconColor,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Middle: Title and Label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A0A0A), // Slate 800
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A5565), // Slate 500
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Right: Value and Unit
        const SizedBox(width: 16),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: valueStr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A), // Slate 900
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF99A1AF), // Slate 400
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getTheme(String color) {
    switch (color) {
      case 'emerald':
        return {
          'bg': const Color(0xFFECFDF5),
          'primary': const Color(0xFF10B981),
        };
      case 'orange':
        return {
          'bg': const Color(0xFFFFF7ED),
          'primary': const Color(0xFFF97316),
        };
      case 'purple':
        return {
          'bg': const Color(0xFFFAF5FF),
          'primary': const Color(0xFFA855F7),
        };
      case 'blue':
        return {
          'bg': const Color(0xFFEFF6FF),
          'primary': const Color(0xFF3B82F6),
        };
      default: // Indigo as default
        return {
          'bg': const Color(0xFFEEF2FF),
          'primary': const Color(0xFF5B6CFF),
        };
    }
  }
}
