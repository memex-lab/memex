import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';
import 'map_card.dart'; // For MapLocation

class RouteMapCard extends StatelessWidget {
  final String title;
  final List<MapLocation> locations;
  final bool isDetail;
  final String? insight;

  const RouteMapCard({
    super.key,
    required this.title,
    required this.locations,
    this.isDetail = false,
    this.insight,
  });

  @override
  Widget build(BuildContext context) {
    if (isDetail) {
      return _buildDetailCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildDetailCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Insight Section
        if (insight != null && insight!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF166534),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Detailed Route View
        _buildContent(context, height: 300), // Taller for detail view
      ],
    );
  }

  Widget _buildListCard(BuildContext context) {
    return _buildContent(context, height: 240);
  }

  Widget _buildContent(BuildContext context, {required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), // Light purple bg
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.near_me, // Or footprint icon
                  color: Color(0xFF9333EA), // Purple
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Route Visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(
                    0xFFFAFAFA), // Light grey inner bg like dotted paper
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: CustomPaint(
                painter: _RoutePainter(locations),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<MapLocation> locations;

  _RoutePainter(this.locations);

  @override
  void paint(Canvas canvas, Size size) {
    if (locations.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF8B5CF6) // Purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Define generic layout points
    // Start: Bottom Left (15%, 85%)
    // End: Top Right (85%, 30%)
    // Control points to make an S curve

    final startOffset = Offset(size.width * 0.15, size.height * 0.8);
    final endOffset = Offset(size.width * 0.85, size.height * 0.35);

    // Draw Dashed Path
    final path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);

    // Simple cubic bezier from start to end
    // Using literal control points for a smooth S-curve
    path.cubicTo(
      size.width * 0.4, size.height * 0.2, // CP1: High up
      size.width * 0.6, size.height * 0.6, // CP2: Lower
      endOffset.dx, endOffset.dy,
    );

    // Draw dashed line
    _drawDashedPath(canvas, path, paint);

    // Draw Start Point
    canvas.drawCircle(startOffset, 6, dotPaint);
    canvas.drawCircle(startOffset, 3, whitePaint); // Hollow effect look

    // Draw labels
    _drawLabel(canvas, locations.first.name ?? UserStorage.l10n.startPoint, startOffset,
        isStart: true);

    // Draw End Point
    canvas.drawCircle(endOffset, 8, dotPaint);

    // Draw End Label (Bubble style)
    if (locations.length > 1) {
      _drawBubbleLabel(canvas, locations.last.name ?? UserStorage.l10n.endPoint, endOffset);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    double distance = 0.0;

    final pathMetrics = path.computeMetrics();
    for (var metric in pathMetrics) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset offset,
      {bool isStart = false}) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final x = offset.dx - (textPainter.width / 2);
    final y = offset.dy + 12; // Below the dot

    // Draw background pill
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          x - 8, y - 4, textPainter.width + 16, textPainter.height + 8),
      const Radius.circular(12),
    );

    final bgPaint = Paint()..color = Colors.white;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha:0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(bgRect.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawBubbleLabel(Canvas canvas, String text, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position: Top Left relative to the point?
    // Image shows it to the left of the point

    final x = offset.dx - textPainter.width - 24;
    final y = offset.dy - 12;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y - 6, textPainter.width + 24, textPainter.height + 12),
      const Radius.circular(8),
    );

    final bgPaint = Paint()..color = const Color(0xFF6366F1); // Indigo bubble

    canvas.drawRRect(bgRect, bgPaint);

    // Draw little arrow
    final path = Path();
    path.moveTo(bgRect.right - 4,
        bgRect.bottom - 4); // Start near bottom right of bubble
    path.lineTo(
        bgRect.right + 4, bgRect.bottom + 4); // Point towards the connect node
    path.lineTo(bgRect.right - 8, bgRect.bottom + 4);
    path.close();
    // Simplified arrow just separate triangle?

    textPainter.paint(canvas, Offset(x + 12, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
