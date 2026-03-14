import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
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
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Decorative background element (subtle gradient/blur)
          Positioned(
            top: -20,
            right: -20,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: _getTextStyle(style),
                    // Map other styles if needed or use defaults
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
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9), // Slate-100
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B), // Slate-500
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ]
              ],
            ),
          ),
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
          color: Color(0xFF334155), // Slate-700
        );
      case 'handwritten':
        return const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 18,
          height: 1.4,
          color: Color(0xFF1E293B), // Slate-800
        );
      default:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: Color(0xFF1E293B), // Slate-800
        );
    }
  }
}
