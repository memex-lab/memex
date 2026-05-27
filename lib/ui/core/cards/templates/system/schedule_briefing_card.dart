import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/user_storage.dart';

class ScheduleBriefingCard extends StatelessWidget {
  const ScheduleBriefingCard({
    super.key,
    required this.data,
    this.onTap,
  });

  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final summary = (data['summary'] as String? ?? '').trim();
    final heroTitle = (data['hero_title'] as String? ?? '').trim();
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserStorage.l10n.scheduleBriefingTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildGeneratedText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (heroTitle.isNotEmpty) ...[
            Text(
              heroTitle,
              style: const TextStyle(
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            _summaryText(summary),
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4B5563),
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...items.map(_buildItemRow),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildCountChip(
                Icons.check_circle_outline_rounded,
                UserStorage.l10n.scheduleBriefingDoneCount(
                  data['completed_count'] ?? 0,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    UserStorage.l10n.scheduleBriefingOpen,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final title = item['title'] as String? ?? '';
    final startTime = parseLocalDateTime(item['start_time']);
    final timeLabel = startTime == null
        ? null
        : DateFormat.Md(UserStorage.l10n.localeName).add_Hm().format(startTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_unchecked_rounded,
            size: 15,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (timeLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              timeLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _buildGeneratedText() {
    final generatedAt = parseLocalDateTime(data['generated_at']);
    if (generatedAt == null) return UserStorage.l10n.scheduleBriefingNoData;
    return UserStorage.l10n.scheduleBriefingUpdated(
      DateFormat.Md(UserStorage.l10n.localeName).add_Hm().format(generatedAt),
    );
  }

  String _summaryText(String summary) {
    if (summary.isNotEmpty) return summary;
    return UserStorage.l10n.scheduleBriefingNoData;
  }
}
