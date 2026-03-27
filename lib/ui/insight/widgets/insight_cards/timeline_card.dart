import 'package:flutter/material.dart';

class TimelineItem {
  final String time;
  final String? title;
  final String? content;
  final String? icon;
  final String? color;
  final bool isFilledDot;

  TimelineItem({
    required this.time,
    this.title,
    this.content,
    this.icon,
    this.color,
    this.isFilledDot = false,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      time: json['time'] as String? ?? '--:--',
      title: json['title'] as String?,
      content: json['content'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isFilledDot: json['is_filled_dot'] as bool? ?? false,
    );
  }
}

class TimelineCard extends StatelessWidget {
  final String title;
  final List<TimelineItem> items;
  final String? insight;
  final VoidCallback? onTap;

  const TimelineCard({
    super.key,
    required this.title,
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
            const SizedBox(height: 24),

            // Insight
            if (insight != null && insight!.isNotEmpty) ...[
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
              const SizedBox(height: 24),
            ],

            // Timeline Items
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              final color = _parseColor(item.color ?? '#6366F1');

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timeline Line Column
                    SizedBox(
                      width: 24,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Vertical Line
                          if (!isLast)
                            Positioned(
                              top: 24,
                              bottom: 0,
                              left: 11,
                              child: Container(
                                width: 2,
                                color: const Color(0xFFF7F8FA),
                              ),
                            ),
                          // Dot
                          Container(
                            margin: const EdgeInsets.only(
                                top: 2), // Align with text
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: item.isFilledDot
                                  ? const Color(0xFFCBD5E1)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: item.isFilledDot
                                    ? Colors.transparent
                                    : color,
                                width: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item.isFilledDot
                                ? Colors.transparent
                                : color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Time + Icon
                              Row(
                                children: [
                                  Text(
                                    item.time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF99A1AF),
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (item.icon != null)
                                    Text(item.icon!,
                                        style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Title
                              if (item.title != null) ...[
                                Text(
                                  item.title!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: item.isFilledDot
                                        ? const Color(0xFF99A1AF)
                                        : const Color(0xFF0A0A0A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Content
                              if (item.content != null)
                                Text(
                                  item.content!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: item.isFilledDot
                                        ? const Color(0xFF99A1AF)
                                        : const Color(0xFF4A5565),
                                    fontStyle: item.isFilledDot
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
