import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';

class ContrastCard extends StatelessWidget {
  final String title;
  final String emotion;
  final Map<String, dynamic> oldPerspective;
  final Map<String, dynamic> newPerspective;
  final String? insight;
  final VoidCallback? onTap;

  const ContrastCard({
    super.key,
    required this.title,
    required this.emotion,
    required this.oldPerspective,
    required this.newPerspective,
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE4E6), // Rose-100/200 mix
              Color(0xFFDBEAFE), // Blue-100/200 mix
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3), // For gradient border effect
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    _buildEmotionIcon(),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48), // Rose-600
                      ),
                    ),
                  ],
                ),
                if (insight != null && insight!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    insight!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B), // Slate-500
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Old Perspective
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFFE2E8F0), // Slate-200
                        width: 4,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${oldPerspective['content'] ?? ''}"',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B), // Slate-500
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      if (oldPerspective['source'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '—— ${oldPerspective['source']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8), // Slate-400
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // New Perspective (Reframing Box)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF), // Very light indigo/blue
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined, // Or auto_fix_high
                            size: 16,
                            color: Color(0xFF6366F1), // Indigo-500
                          ),
                          const SizedBox(width: 8),
                          Text(
                            newPerspective['title'] ?? UserStorage.l10n.newPerspective,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4338CA), // Indigo-700
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 17,
                            color: Color(0xFF1E293B), // Slate-800
                            height: 1.6,
                          ),
                          children: [
                            TextSpan(
                              text: newPerspective['content'] ?? '',
                            ),
                            if (newPerspective['content'] != null &&
                                newPerspective['highlight'] != null)
                              const TextSpan(text: '\n'),
                            if (newPerspective['highlight'] != null)
                              TextSpan(
                                text: newPerspective['highlight'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF6366F1), // Indigo-500
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionIcon() {
    IconData icon;
    Color color;

    switch (emotion) {
      case 'positive':
        icon = Icons.favorite_rounded;
        color = const Color(0xFFF43F5E);
        break;
      case 'neutral':
        icon = Icons.sentiment_neutral_rounded;
        color = const Color(0xFF64748B);
        break;
      case 'negative':
      default:
        icon = Icons.heart_broken_rounded;
        color = const Color(0xFFF43F5E); // Rose-500
        break;
    }

    return Icon(icon, color: color, size: 20);
  }
}
