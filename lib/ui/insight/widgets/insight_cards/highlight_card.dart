import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  final String title;
  final String quoteContent;
  final String? quoteHighlight;
  final String? footer;
  final String? theme;
  final String? date;
  final String? insight;
  final VoidCallback? onTap;

  const HighlightCard({
    super.key,
    this.title = 'INSIGHT',
    required this.quoteContent,
    this.quoteHighlight,
    this.footer,
    this.theme,
    this.date,
    this.insight,
    this.onTap,
  });

  List<Color> get _gradientColors {
    switch (theme) {
      case 'orange':
        return [const Color(0xFFF97316), const Color(0xFFFB923C)];
      case 'blue':
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
      case 'primary':
      default:
        return [const Color(0xFF6366F1), const Color(0xFFA855F7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: _gradientColors.first.withValues(alpha:0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Watermark Icon
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.format_quote_rounded,
                size: 180,
                color: Colors.white.withValues(alpha:0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withValues(alpha:0.5), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          date!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily:
                                'monospace', // Monospace for date looks nice
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quote Content with Highlight
                  _buildRichQuote(),

                  const SizedBox(height: 32),

                  // Insight
                  if (insight != null) ...[
                    Text(
                      insight!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.9),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Footer
                  if (footer != null)
                    Text(
                      footer!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.9),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichQuote() {
    if (quoteHighlight == null || quoteHighlight!.isEmpty) {
      return Text(
        quoteContent,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.4,
          letterSpacing: -0.5,
        ),
      );
    }

    final spans = <TextSpan>[];
    final lowerContent = quoteContent.toLowerCase();
    final lowerHighlight = quoteHighlight!.toLowerCase();

    int start = 0;
    while (true) {
      final index = lowerContent.indexOf(lowerHighlight, start);
      if (index == -1) {
        // No more matches
        spans.add(TextSpan(text: quoteContent.substring(start)));
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: quoteContent.substring(start, index)));
      }

      // Add matched text
      final matchedText =
          quoteContent.substring(index, index + quoteHighlight!.length);
      spans.add(TextSpan(
        text: matchedText,
        style: const TextStyle(
          color: Color(0xFFFDE047), // Yellow highlight
        ),
      ));

      start = index + quoteHighlight!.length;
    }

    // Add opening quote icon
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '"', // Explicit large opening quote for style
          style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              height: 0.5,
              fontWeight: FontWeight.bold),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.4,
              letterSpacing: -0.5,
            ),
            children: spans,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: const Text(
            '"', // Explicit large closing quote
            style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                height: 0.5,
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
