import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class RatingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const RatingCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String subject = data['subject'] ?? 'Rating';
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final double maxScore = (data['max_score'] as num?)?.toDouble() ?? 5.0;
    final String? comment = data['comment'];

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score / $maxScore',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Star rating visualization
          Row(
            children: List.generate(5, (index) {
              // Normalize score to 5 stars
              final normalizedScore = (score / maxScore) * 5;
              if (index < normalizedScore.floor()) {
                return const Icon(Icons.star, color: Colors.amber, size: 20);
              } else if (index < normalizedScore &&
                  (normalizedScore - index) >= 0.5) {
                return const Icon(Icons.star_half,
                    color: Colors.amber, size: 20);
              } else {
                return const Icon(Icons.star_border,
                    color: Colors.amber, size: 20);
              }
            }),
          ),
          if (comment != null) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
