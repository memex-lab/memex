import 'package:flutter/material.dart';

class SummaryMetric {
  final String label;
  final String value;
  final String? color;
  final String? icon;

  SummaryMetric({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  factory SummaryMetric.fromJson(Map<String, dynamic> json) {
    return SummaryMetric(
      label: json['label'] as String? ?? '',
      value: (json['value'] ?? '').toString(),
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class SummaryHighlight {
  final String url;
  final String? label;

  SummaryHighlight({
    required this.url,
    this.label,
  });

  factory SummaryHighlight.fromJson(Map<String, dynamic> json) {
    return SummaryHighlight(
      url: json['url'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String tag;
  final String title;
  final String date;
  final Map<String, dynamic>? badge;
  final String insightTitle;
  final String insightContent;
  final List<SummaryMetric> metrics;
  final String highlightsTitle;
  final List<SummaryHighlight> highlights;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.tag,
    required this.title,
    required this.date,
    this.badge,
    this.insightTitle = 'Agent Insight',
    required this.insightContent,
    this.metrics = const [],
    this.highlightsTitle = 'Highlights',
    this.highlights = const [],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Tag + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Slate-100
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B), // Slate-500
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Blue-50
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (badge!['icon'] != null) ...[
                          Text(
                            badge!['icon'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          badge!['text'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6), // Blue-500
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title & Date
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A), // Slate-900
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8), // Slate-400
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),

            // Insight Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate-50
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy_outlined,
                          size: 18, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text(
                        insightTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    insightContent,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF475569), // Slate-600
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Row
            if (metrics.isNotEmpty) ...[
              Row(
                children: metrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final metric = entry.value;
                  final isLast = index == metrics.length - 1;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                metric.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: metric.color != null
                                  ? _parseColor(metric.color!)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Highlights
            if (highlights.isNotEmpty) ...[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      highlightsTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${highlights.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: highlights.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = highlights[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            item.url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 120,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.broken_image,
                                  color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                        // Label Overlay
                        if (item.label != null)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              item.label!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Selection Checkmark removed
                      ],
                    );
                  },
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
    return const Color(0xFF6366F1);
  }
}
