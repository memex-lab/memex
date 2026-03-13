import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class MoodCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const MoodCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String moodName = data['mood_name'] ?? data['mood'] ?? 'Neutral';
    final int intensity = (data['intensity'] as num?)?.toInt() ?? 5;
    final String? colorHex = data['color_hex'];

    Color moodColor = _getMoodColor(moodName, colorHex);
    IconData moodIcon = _getMoodIcon(moodName);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      backgroundColor: moodColor.withValues(alpha:0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: moodColor.withValues(alpha:0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(moodIcon, color: moodColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moodName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (data.containsKey('trigger'))
                  Text(
                    data['trigger'],
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$intensity',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  height: 1.0,
                ),
              ),
              const Text(
                '/10',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood, String? hex) {
    if (hex != null) {
      // Basic hex parsing
      try {
        return Color(int.parse(hex.replaceAll('#', '0xFF')));
      } catch (_) {}
    }

    final lower = mood.toLowerCase();
    if (['happy', 'excited', 'energetic'].contains(lower)) return Colors.amber;
    if (['sad', 'tired'].contains(lower)) return Colors.indigo;
    if (['angry', 'stressed'].contains(lower)) return Colors.red;
    if (['creative', 'curious'].contains(lower)) return Colors.purple;
    if (['relaxed', 'calm'].contains(lower)) return Colors.teal;
    return const Color(0xFF64748B);
  }

  IconData _getMoodIcon(String mood) {
    final lower = mood.toLowerCase();
    if (['happy', 'excited', 'energetic'].contains(lower))
      return Icons.sentiment_very_satisfied;
    if (['sad', 'tired'].contains(lower)) return Icons.sentiment_dissatisfied;
    if (['angry', 'stressed'].contains(lower)) return Icons.mood_bad;
    if (['creative', 'curious'].contains(lower)) return Icons.auto_awesome;
    if (['relaxed', 'calm'].contains(lower)) return Icons.spa;
    return Icons.sentiment_neutral;
  }
}
