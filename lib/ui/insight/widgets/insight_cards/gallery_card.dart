import 'package:flutter/material.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class ChronicleImage {
  final String url;
  final String label;

  ChronicleImage({required this.url, required this.label});

  factory ChronicleImage.fromJson(Map<String, dynamic> json) {
    return ChronicleImage(
      url: json['url'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class GalleryCard extends StatelessWidget {
  final String title;
  final String headline;
  final List<ChronicleImage> images;
  final String? content;
  final String? insight;
  final VoidCallback? onTap;

  const GalleryCard({
    super.key,
    required this.title,
    required this.headline,
    this.images = const [],
    this.content,
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 28 / 18,
                letterSpacing: -0.15,
                color: Color(0xFF0A0A0A),
              ),
            ),
            if (insight != null && insight!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                insight!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5565),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),

            // Subtitle (headline)
            Text(
              headline,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                letterSpacing: -0.15,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),

            // Images Carousel
            if (images.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: images.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 280,
                      child: _buildImageItem(context, images[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Content
            if (content != null)
              Text(
                content!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A5565), // Slate-500
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, ChronicleImage image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          LocalImage(
            url: image.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF7F8FA),
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                          fontSize: 8, color: Color(0xFF99A1AF)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          // Gradient Overlay & Label
          Positioned(
            bottom: 12,
            left: 12,
            right: 12, // Constrain width
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                image.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
