import 'package:flutter/material.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class RelatedFactsList extends StatefulWidget {
  final List<String> factIds;

  const RelatedFactsList({super.key, required this.factIds});

  @override
  State<RelatedFactsList> createState() => _RelatedFactsListState();
}

class _RelatedFactsListState extends State<RelatedFactsList> {
  final List<TimelineCardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    final api = MemexRouter();
    final cards = <TimelineCardModel>[];

    for (final id in widget.factIds) {
      try {
        // Assume id is fact_id directly
        final card = await api.fetchTimelineCard(id);
        if (card != null) {
          cards.add(card);
        }
      } catch (e) {
        debugPrint('Failed to fetch related fact $id: $e');
      }
    }

    if (mounted) {
      setState(() {
        _cards.addAll(cards);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: AgentLogoLoading()),
      );
    }

    if (_cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Ensure it doesn't take infinite height
      children: [
        const SizedBox(height: 16),
        const Divider(height: 32, thickness: 1, color: Color(0xFFE2E8F0)),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Related Timelines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // Slate-800
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildCardItem(context, _cards[index]);
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCardItem(BuildContext context, TimelineCardModel card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TimelineCardDetailScreen(cardId: card.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Header
            Text(
              card.displayTime(UserStorage.l10n),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Content
            if (card.html != null)
              HtmlWebViewCard(
                html: card.html!,
                config: const HtmlWebViewConfig.relatedCard(),
              )
            else if (card.uiConfigs.isNotEmpty)
              ...card.uiConfigs.asMap().entries.map((entry) {
                final index = entry.key;
                final config = entry.value;
                final isLast = index == card.uiConfigs.length - 1;

                if (config.templateId == 'legacy_html') {
                  final html = config.data['html'] as String?;
                  if (html != null && html.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                      child: HtmlWebViewCard(
                        html: html,
                        config: const HtmlWebViewConfig.relatedCard(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                  child: NativeCardFactory.build(
                    status: card.status,
                    templateId: config.templateId,
                    data: config.data,
                    title: card.title ?? '',
                    tags: card.tags,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
