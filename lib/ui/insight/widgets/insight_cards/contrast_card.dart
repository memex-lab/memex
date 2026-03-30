import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memex/utils/user_storage.dart';

class ContrastCard extends StatelessWidget {
  final String title;
  final String emotion;
  final Map<String, dynamic> oldPerspective;
  final Map<String, dynamic> newPerspective;
  final String? insight;
  final VoidCallback? onTap;

  const ContrastCard({
    super.key,
    required this.title,
    required this.emotion,
    required this.oldPerspective,
    required this.newPerspective,
    this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),

            // Old perspective (quoted)
            Text(
              '\u201C${oldPerspective['content'] ?? ''}\u201D',
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

            // New perspective box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: emoji + text
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_edit_pen.svg',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            newPerspective['title'] ??
                                UserStorage.l10n.newPerspective,
                            style: const TextStyle(
                              fontFamily: 'PingFang SC',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                              letterSpacing: -0.15,
                              color: Color(0xFF155DFC),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Text(
                    newPerspective['content'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 22.75 / 14,
                      letterSpacing: -0.15,
                      color: Color(0xFF1E2939),
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
}
