import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class RoutineCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const RoutineCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String habitName = data['habit_name'] ?? 'Routine';
    final int streak = (data['streak'] as num?)?.toInt() ?? 0;
    final List<bool> history =
        (data['history'] as List<dynamic>?)?.cast<bool>() ??
            List.filled(7, false);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFFFFF7ED), // Orange-50 tint
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'CURRENT STREAK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DAYS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Circular progress or icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.orange[100]!, width: 4),
                ),
                child: Center(
                  child: Icon(Icons.replay, color: Colors.orange[400]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // History Dots (Last 7 days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: history.map((completed) {
              return Container(
                width: 8,
                height: 32, // mini bar chart style or dot
                decoration: BoxDecoration(
                  color: completed ? Colors.orange : Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              habitName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
