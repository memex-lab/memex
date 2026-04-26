import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class LinkCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const LinkCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String url = data['url'] ?? '';
    final String domain = data['domain'] ?? Uri.tryParse(url)?.host ?? '';
    final String? title = data['title'];

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0A0A),
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.link,
                            size: 12, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        domain.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7),
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
