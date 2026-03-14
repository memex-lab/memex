import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class CanvasCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const CanvasCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Canvas';
    final String? imageUrl = data['image_url'];

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Background Grid Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar simulation
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  color: Color(0xFFF8FAFC),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gesture,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155))),
                      ],
                    ),
                    Row(
                      // Fake tools
                      children: [
                        _buildTool(const Color(0xFF0F172A)),
                        _buildTool(const Color(0xFFEF4444)),
                        _buildTool(const Color(0xFF6366F1)),
                      ],
                    )
                  ],
                ),
              ),
              // Canvas Area
              Container(
                height: 180,
                width: double.infinity,
                color:
                    Colors.white.withValues(alpha: 0.5), // Translucent to show grid
                child: imageUrl != null
                    ? LocalImage(url: imageUrl, fit: BoxFit.contain)
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                  width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text("Sketch Content",
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12)),
                        ),
                      ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTool(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.2);
    const spacing = 20.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
