import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class PersonCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const PersonCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'] ?? 'Unknown';
    final String? avatarUrl = data['image_url'];
    final String? relation = data['relation'];
    final String? status = data['status']; // Online, Busy, etc.

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(name.substring(0, 1).toUpperCase(),
                        style:
                            const TextStyle(fontSize: 24, color: Color(0xFF99A1AF)))
                    : null,
              ),
              if (status != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                if (relation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B6CFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        relation,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF5B6CFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF99A1AF)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return const Color(0xFF10B981);
      case 'busy':
        return const Color(0xFFEF4444);
      case 'away':
        return Colors.amber;
      default:
        return const Color(0xFF99A1AF);
    }
  }
}
