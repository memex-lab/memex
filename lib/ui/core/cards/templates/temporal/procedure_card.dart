import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class ProcedureCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const ProcedureCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Procedure';
    final List<String> steps =
        (data['steps'] as List<dynamic>?)?.cast<String>() ?? [];

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final isLast = index == steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3730A3),
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: const Color(0xFFEEF2FF), // vertical line
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16), // space between items
                        child: Text(
                          steps[index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
