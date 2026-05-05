import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class DigestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const DigestCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] as String?)?.trim() ?? '';
    final summary = (data['summary'] as String?)?.trim() ?? '';
    final sections = _parseSections(data['sections']);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  size: 19,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Color(0xFF0A0A0A),
                          letterSpacing: 0,
                        ),
                      ),
                    if (summary.isNotEmpty) ...[
                      if (title.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: Color(0xFF4A5565),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (sections.isNotEmpty) ...[
            const SizedBox(height: 18),
            ...sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              final isLast = index == sections.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: _DigestSectionView(section: section),
              );
            }),
          ],
        ],
      ),
    );
  }

  List<_DigestSection> _parseSections(dynamic raw) {
    if (raw is! List) return const [];
    final sections = <_DigestSection>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final type = (map['type'] as String?)?.trim().toLowerCase() ?? 'note';
      final title = (map['title'] as String?)?.trim() ?? '';
      final rawItems = map['items'];
      final items = rawItems is List
          ? rawItems
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];
      if (title.isEmpty || items.isEmpty) continue;
      sections.add(_DigestSection(type: type, title: title, items: items));
    }
    return sections;
  }
}

class _DigestSectionView extends StatelessWidget {
  final _DigestSection section;

  const _DigestSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    final style = _DigestStyle.fromType(section.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: style.background,
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, size: 16, color: style.color),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: Color(0xFF111827),
                        letterSpacing: 0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: style.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ...section.items.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: Color(0xFF4A5565),
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (section.items.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+${section.items.length - 4}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: style.color,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DigestSection {
  final String type;
  final String title;
  final List<String> items;

  const _DigestSection({
    required this.type,
    required this.title,
    required this.items,
  });
}

class _DigestStyle {
  final IconData icon;
  final Color color;
  final Color background;

  const _DigestStyle({
    required this.icon,
    required this.color,
    required this.background,
  });

  factory _DigestStyle.fromType(String type) {
    switch (type) {
      case 'project':
        return const _DigestStyle(
          icon: Icons.work_outline_rounded,
          color: Color(0xFF4F46E5),
          background: Color(0xFFEEF2FF),
        );
      case 'todo':
      case 'task':
        return const _DigestStyle(
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF059669),
          background: Color(0xFFE6F7EF),
        );
      case 'schedule':
      case 'event':
        return const _DigestStyle(
          icon: Icons.event_outlined,
          color: Color(0xFF2563EB),
          background: Color(0xFFEFF6FF),
        );
      case 'mood':
      case 'emotion':
        return const _DigestStyle(
          icon: Icons.sentiment_satisfied_alt_rounded,
          color: Color(0xFFE11D48),
          background: Color(0xFFFFEEF3),
        );
      case 'idea':
        return const _DigestStyle(
          icon: Icons.lightbulb_outline_rounded,
          color: Color(0xFFD97706),
          background: Color(0xFFFFF7E6),
        );
      case 'decision':
        return const _DigestStyle(
          icon: Icons.alt_route_rounded,
          color: Color(0xFF0891B2),
          background: Color(0xFFE6F8FB),
        );
      case 'health':
        return const _DigestStyle(
          icon: Icons.favorite_border_rounded,
          color: Color(0xFF16A34A),
          background: Color(0xFFECFDF3),
        );
      case 'finance':
        return const _DigestStyle(
          icon: Icons.payments_outlined,
          color: Color(0xFF0F766E),
          background: Color(0xFFE6FFFA),
        );
      case 'relationship':
        return const _DigestStyle(
          icon: Icons.people_outline_rounded,
          color: Color(0xFFDB2777),
          background: Color(0xFFFDF2F8),
        );
      case 'thought':
        return const _DigestStyle(
          icon: Icons.psychology_alt_outlined,
          color: Color(0xFF7C3AED),
          background: Color(0xFFF5F3FF),
        );
      case 'note':
      case 'other':
      default:
        return const _DigestStyle(
          icon: Icons.notes_rounded,
          color: Color(0xFF64748B),
          background: Color(0xFFF1F5F9),
        );
    }
  }
}
