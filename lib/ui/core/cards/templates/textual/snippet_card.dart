import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class SnippetCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const SnippetCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String text = data['text'] ?? '';
    final String style = data['style'] ?? 'default';
    final List<String> tags =
        (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: text,
            styleSheet: MarkdownStyleSheet(
              p: _getTextStyle(style),
              code: const TextStyle(
                backgroundColor: Color(0xFFF7F8FA),
                color: Color(0xFF0A0A0A),
                fontFamily: 'monospace',
              ),
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags
                  .map((tag) => Text(
                        '#$tag',
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5B6CFF),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _getTextStyle(String style) {
    switch (style) {
      case 'mono':
        return const TextStyle(
          fontFamily: 'monospace',
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF4A5565),
        );
      case 'handwritten':
        return const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 18,
          height: 1.4,
          color: Color(0xFF0A0A0A),
        );
      default:
        return const TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: Color(0xFF4A5565),
        );
    }
  }
}
