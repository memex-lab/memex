import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

class SpecSheetCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const SpecSheetCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? data['name'] ?? 'Item Details';
    final String? imageUrl = data['image_url'];
    final Map<String, dynamic> specs = data['specs'] ?? {};

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    ? LocalImage(url: imageUrl, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.inventory_2_outlined,
                            color: Color(0xFF99A1AF), size: 32)),
              ),
              const SizedBox(width: 16),

              // Title & Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0A0A),
                        height: 1.2,
                      ),
                    ),
                    // Check if there's a primary subtitle or description
                    if (data['subtitle'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          data['subtitle'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (specs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Spec Grid using Wrap for flexibility or GridView
            // Using Wrap with width constrained children to simulate a grid is often safer in ListViews
            LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth =
                    (constraints.maxWidth - 16) / 2; // 2 columns
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: specs.entries.map((entry) {
                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.toString().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF99A1AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}
