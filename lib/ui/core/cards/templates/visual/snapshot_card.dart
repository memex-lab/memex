import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/ui/core/cards/ui/timeline_card_container.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class SnapshotCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const SnapshotCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = data['image_url'] ?? '';
    final String caption = data['title'] ?? data['caption'] ?? '';
    final String location = data['location'] ?? '';

    return TimelineCard(
      onTap: onTap,
      variant: TimelineCardVariant.glass,
      padding: EdgeInsets.zero, // Full bleed image
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: LocalImage(
                  url: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: TimelineTheme.colors.background,
                      child: Center(
                          child: Icon(Icons.broken_image,
                              color: TimelineTheme.colors.textTertiary))),
                ),
              ),
              // Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha:0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.camera, size: 10, color: Colors.white),
                      SizedBox(width: 4),
                      Text("SNAPSHOT",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              )
            ],
          ),

          // Content Section
          if (location.isNotEmpty || caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (location.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: TimelineTheme.colors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                location,
                                style: TimelineTheme.typography.label.copyWith(
                                  color: TimelineTheme.colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (caption.isNotEmpty)
                    Text(
                      caption,
                      style: TimelineTheme.typography.title.copyWith(
                        color: TimelineTheme.colors.textPrimary,
                        height: 1.3,
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
