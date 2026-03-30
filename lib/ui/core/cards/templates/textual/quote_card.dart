import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class QuoteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const QuoteCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String content = data['content'] ?? '';
    final String? author = data['author'];
    final String? source = data['source'];

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Opening quote
          Text(
            '\u201C',
            style: GoogleFonts.imbue(
              fontSize: 60,
              fontWeight: FontWeight.w700,
              height: 0.3,
              color: const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 8),

          // Quote content
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 0.2,
              color: const Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 8),

          // Closing quote
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\u201D',
              style: GoogleFonts.imbue(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                height: 0.3,
                color: const Color(0xFFD1D5DB),
              ),
            ),
          ),

          // Author + source
          if (author != null || source != null) ...[
            const SizedBox(height: 20),
            if (author != null)
              Text(
                '— $author',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  letterSpacing: -0.15,
                  color: const Color(0xFF99A1AF),
                ),
              ),
            if (source != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  source,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF99A1AF),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
