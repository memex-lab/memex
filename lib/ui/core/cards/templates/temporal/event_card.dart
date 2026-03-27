import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Parse times. Assuming ISO8601 strings or DateTime objects if passed directly
    DateTime? startTime;
    if (data['start_time'] is String) {
      startTime = DateTime.tryParse(data['start_time']);
    } else if (data['start_time'] is DateTime) {
      startTime = data['start_time'];
    }

    DateTime? endTime;
    if (data['end_time'] is String) {
      endTime = DateTime.tryParse(data['end_time']);
    } else if (data['end_time'] is DateTime) {
      endTime = data['end_time'];
    }

    final String title = data['title'] ?? 'Event';
    final String? location = data['location'];

    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat monthFormat = DateFormat('MMM');
    final DateFormat dayFormat = DateFormat('dd');

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Date Block
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF5B6CFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  startTime != null
                      ? monthFormat.format(startTime).toUpperCase()
                      : '---',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B6CFF),
                  ),
                ),
                Text(
                  startTime != null ? dayFormat.format(startTime) : '--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B6CFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: const Color(0xFF4A5565)),
                    const SizedBox(width: 4),
                    Text(
                      startTime != null
                          ? '${timeFormat.format(startTime)} - ${endTime != null ? timeFormat.format(endTime) : '?'}'
                          : 'TBD',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5565)),
                    ),
                  ],
                ),
                if (location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: const Color(0xFF4A5565)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent
                                  ],
                                  stops: [0.0, 0.8, 0.9, 1.0],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    Text(
                                      location,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4A5565)),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }
}
