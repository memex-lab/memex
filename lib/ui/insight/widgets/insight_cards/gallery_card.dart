import 'package:flutter/material.dart';

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
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEA580C), // Orange-600
              ),
            ),
            if (insight != null && insight!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                insight!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B), // Slate-500
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Main Headline
            Text(
              headline,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A), // Slate-900
                height: 1.3,
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
                  color: Color(0xFF64748B), // Slate-500
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
          Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF1F5F9),
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
                      style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8)),
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
                color: Colors.black.withValues(alpha:0.6),
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
