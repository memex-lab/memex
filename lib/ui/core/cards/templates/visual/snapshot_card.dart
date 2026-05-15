import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class SnapshotCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const SnapshotCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = data['image_url'] ?? '';
    final String caption = data['title'] ?? data['caption'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D111827),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with SNAPSHOT badge
            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LocalImage(
                        url: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF7F8FA),
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Color(0xFF99A1AF)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SNAPSHOT badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/camera.svg',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SNAPSHOT',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0,
                              height: 18 / 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Title
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  caption,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 23 / 20,
                    letterSpacing: -0.45,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
