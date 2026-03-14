import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Article';
    final String body = data['body'] ?? '';
    final String? imageUrl = data['image_url'];

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Image (if available) - Full width
          if (imageUrl != null && imageUrl.isNotEmpty)
            SizedBox(
              height: 160,
              width: double.infinity,
              child: LocalImage(
                url: imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: const Color(0xFFE2E8F0)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Title - Headline style
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Body - Long-form text style
                // 3. Body - Markdown content
                MarkdownBody(
                  data: body,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF475569), // Slate-600
                    ),
                    // Add other styles as needed to match the app's theme
                    h1: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                    h2: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                    h3: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                    blockquote: const TextStyle(
                        color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                    code: const TextStyle(
                      backgroundColor: Color(0xFFF1F5F9),
                      color: Color(0xFF0F172A),
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
