import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class ConversationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const ConversationCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rawMessages = data['messages'] ?? [];
    // Show last 3 messages
    final messages = rawMessages
        .take(3)
        .toList(); // Actually usually we want latest at bottom, but let's just show list.
    // If we want chronological, we might need to reverse if data is new->old. Assuming data is old->new (chat log).

    final String title = data['title'] ?? 'Conversation';

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (optional, maybe just title)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF99A1AF)),
            ),
          ),

          if (messages.isEmpty)
            const Center(
                child:
                    Text("No messages", style: TextStyle(color: const Color(0xFF99A1AF)))),

          // Chat Bubbles
          ...messages.map((m) {
            final String text = m['text'] ?? '';
            final String sender = m['sender'] ?? '';
            final bool isMe = m['isMe'] == true || sender == 'me';

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 240), // Limit width
                decoration: BoxDecoration(
                  color:
                      isMe ? const Color(0xFF3B82F6) : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isMe
                        ? const Radius.circular(12)
                        : const Radius.circular(2),
                    bottomRight: isMe
                        ? const Radius.circular(2)
                        : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(sender,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5565))),
                      ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isMe ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
