import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class GalleryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const GalleryCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls =
        (data['image_urls'] as List<dynamic>?)?.cast<String>() ?? [];
    final String? title = data['title'];

    if (imageUrls.isEmpty) {
      return GlassCard(
        onTap: onTap,
        child: const Center(child: Text('No images')),
      );
    }

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid(imageUrls),
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> imageUrls) {
    int count = imageUrls.length;
    if (count == 1) {
      return SizedBox(
        height: 180,
        width: double.infinity,
        child: _buildImage(imageUrls[0]),
      );
    }

    if (count == 2) {
      return SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(child: _buildImage(imageUrls[0])),
            const SizedBox(width: 2),
            Expanded(child: _buildImage(imageUrls[1])),
          ],
        ),
      );
    }

    if (count == 3) {
      return SizedBox(
        height: 320,
        child: Column(
          children: [
            Expanded(child: _buildImage(imageUrls[0])),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(imageUrls[1])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(imageUrls[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4+
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[0])),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[1])),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[2])),
                const SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(
                          imageUrls[count > 3 ? 3 : 0]), // Safety check index
                      if (count > 4)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              '+${count - 4}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
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

  Widget _buildImage(String url) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: LocalImage(
        url: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Color(0xFF99A1AF))),
      ),
    );
  }
}
