import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/ui/core/cards/card_action_notification.dart';
import 'package:memex/utils/user_storage.dart';

/// Insight Summary Card Template
///
/// Used for displaying updates to insight generation, e.g. "Produced 1 new insight".
class InsightSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const InsightSummaryCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> added = data['added_insight_cards'] ?? [];
    final List<dynamic> updated = data['updated_insight_cards'] ?? [];

    final l10n = UserStorage.l10n;
    String title = l10n.knowledgeNewDiscovery; //data['title'] ?? l10n.knowledgeNewDiscovery;

    String content = data['content'] ?? '';
    final List<String> parts = [];
    if (added.isNotEmpty) parts.add(l10n.discoveredNewInsightsCount(added.length));
    if (updated.isNotEmpty) parts.add(l10n.updatedExistingInsightsCount(updated.length));
    if (parts.isNotEmpty) {
      content = parts.join('，');
    }

    return GlassCard(
      onTap:
          () {}, // Consume tap to prevent it from navigating to TimelineCard details
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              const CardActionNotification(
                  {'action': 'filter_tag', 'tag': 'insight'}).dispatch(context);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (content.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (added.isNotEmpty || updated.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
          ],
          if (added.isNotEmpty)
            _buildListSection(context, l10n.sectionNewInsights, added, const Color(0xFF10B981)),
          if (updated.isNotEmpty)
            _buildListSection(
                context, l10n.sectionUpdatedInsights, updated, const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title,
      List<dynamic> items, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            final String itemTitle = item['title'] ?? UserStorage.l10n.unnamedInsight;
            final String? itemId = item['id'];
            return InkWell(
              onTap: itemId != null
                  ? () {
                      CardActionNotification(
                              {'action': 'navigate_to_card', 'card_id': itemId})
                          .dispatch(context);
                    }
                  : null,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8, top: 4, left: 4, right: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        itemTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
