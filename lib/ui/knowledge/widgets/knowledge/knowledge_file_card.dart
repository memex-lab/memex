import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_file_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as path;

class KnowledgeFileCard extends StatelessWidget {
  final Map<String, dynamic> item;

  final VoidCallback? onReturn;
  const KnowledgeFileCard({
    this.onReturn,
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? '';
    final isMd = path.extension(name).toLowerCase() == '.md';
    final bool isAiGenerated = item['is_ai_generated'] ?? true;

    return GestureDetector(
      onTap: () async {
        if (isMd) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KnowledgeFilePage(filePath: item['path']),
            ),
          );
          onReturn?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(UserStorage.l10n.onlyMarkdownPreview)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A5565).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // File icon with background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/file_doc.svg',
                  width: 26,
                  height: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                      letterSpacing: -0.15,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  if (isAiGenerated) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ai_sparkle.svg',
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          UserStorage.l10n.aiGeneratedLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 20 / 10,
                            letterSpacing: -0.15,
                            color: Color(0xFF5B6CFF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
