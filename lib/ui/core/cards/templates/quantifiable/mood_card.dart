import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class MoodCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const MoodCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String moodName = data['mood_name'] ?? data['mood'] ?? 'Neutral';
    final int intensity = (data['intensity'] as num?)?.toInt() ?? 5;
    final IconData moodIcon = _getMoodIcon(moodName);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FA),
              shape: BoxShape.circle,
            ),
            child: Icon(moodIcon, color: const Color(0xFF5B6CFF), size: 22),
          ),
          const SizedBox(width: 14),

          // Name + trigger
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moodName,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                if (data.containsKey('trigger')) ...[
                  const SizedBox(height: 4),
                  Text(
                    data['trigger'],
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Score (mood intensity 1-10)
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                '$intensity',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                  height: 1.0,
                ),
              ),
              Text(
                '/10',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(String mood) {
    final lower = mood.toLowerCase();
    if (['happy', 'excited', 'energetic'].contains(lower)) {
      return Icons.sentiment_very_satisfied;
    }
    if (['sad', 'tired'].contains(lower)) {
      return Icons.sentiment_dissatisfied;
    }
    if (['angry', 'stressed'].contains(lower)) {
      return Icons.mood_bad;
    }
    if (['creative', 'curious'].contains(lower)) {
      return Icons.auto_awesome;
    }
    if (['relaxed', 'calm'].contains(lower)) {
      return Icons.spa;
    }
    return Icons.sentiment_neutral;
  }
}
