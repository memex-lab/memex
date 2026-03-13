import 'package:flutter/material.dart';
import 'package:memex/ui/core/widgets/adaptive_icon.dart';
import 'package:memex/domain/models/tag_model.dart';

/// Compact Card Template
///
/// Minimalist design for lightweight logs (horizontal layout).
/// - Layout: Row(Icon, Title, Details)
/// - Good for: Habits, Water, Quick logs
class CompactCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? '';
    final String? icon = data['icon'];
    // Support 'details' as List or String (if joined previously)
    final List<String> details = _getDetails();

    // Parse color
    Color themeColor = Colors.blue;
    if (data['color'] != null) {
      try {
        if (data['color'] is String) {
          themeColor = Color(
              int.parse((data['color'] as String).replaceAll('#', '0xFF')));
        }
      } catch (_) {}
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Compact
          children: [
            // Icon Container
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? AdaptiveIcon(
                      icon: icon,
                      iconType: TagIconType.flutter_icon,
                      size: 14,
                      color: themeColor,
                    )
                  : Icon(
                      Icons.notifications_none_rounded,
                      color: themeColor,
                      size: 14,
                    ),
            ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B), // Slate-800
                        height: 1.2,
                      ),
                    ),
                    if (details.isNotEmpty) ...[
                      const TextSpan(
                        text: '  ', // Slightly more space
                      ),
                      TextSpan(
                        text: details.join(' · '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B), // Slate-500
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getDetails() {
    final rawParams = data['details'];
    if (rawParams == null) return [];
    if (rawParams is List) {
      return rawParams.map((e) => e.toString()).toList();
    }
    return [];
  }
}
