import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class SummaryMetric {
  final String label;
  final String value;
  final String? color;
  final String? icon;

  SummaryMetric(
      {required this.label, required this.value, this.color, this.icon});

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

  SummaryHighlight({required this.url, this.label});

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
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag + Badge row
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tag.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 16 / 14,
                      letterSpacing: 0.6,
                      color: const Color(0xFF99A1AF),
                    ),
                  ),
                  if (badge != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badge!['icon'] != null)
                          SvgPicture.asset(
                            'assets/icons/icon_rocket.svg',
                            width: 16,
                            height: 16,
                          ),
                        if (badge!['icon'] != null) const SizedBox(width: 4),
                        Text(
                          badge!['text'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 16 / 14,
                            color: const Color(0xFF5B6CFF),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 32 / 24,
                letterSpacing: 0.07,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                letterSpacing: -0.15,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),

            // Insight section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon_agent_insight.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      insightTitle,
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics row
            if (metrics.isNotEmpty) ...[
              Row(
                children: metrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final metric = entry.value;
                  final isLast = index == metrics.length - 1;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            metric.label,
                            style: const TextStyle(
                              fontFamily: 'PingFang SC',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.value,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              height: 32 / 24,
                              letterSpacing: 0.07,
                              color: metric.color != null
                                  ? _parseColor(metric.color!)
                                  : const Color(0xFF0A0A0A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Highlights
            if (highlights.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: highlightsTitle.split('(').first.trim(),
                            style: const TextStyle(
                              fontFamily: 'PingFang SC',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          if (highlightsTitle.contains('('))
                            TextSpan(
                              text: '  (${highlightsTitle.split('(').last}',
                              style: const TextStyle(
                                fontFamily: 'PingFang SC',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF3F4F6),
                    ),
                    child: Center(
                      child: Text(
                        '${highlights.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                          color: const Color(0xFF6A7282),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: highlights.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = highlights[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LocalImage(
                        url: item.url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFFF7F8FA),
                          child: const Icon(Icons.broken_image,
                              color: Color(0xFF9CA3AF)),
                        ),
                      ),
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
    return const Color(0xFF5B6CFF);
  }
}
