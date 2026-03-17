import 'package:flutter/material.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_file_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as path;

class KnowledgeFileCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const KnowledgeFileCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? '';
    final isMd = path.extension(name).toLowerCase() == '.md';
    // Using a consistent default for "AI Generated" matching the design mockup for now
    final bool isAiGenerated = item['is_ai_generated'] ?? true;

    return GestureDetector(
      onTap: () {
        if (isMd) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KnowledgeFilePage(filePath: item['path']),
            ),
          );
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
                color: const Color(0xFF64748B).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Slate 100
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF64748B), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(isMd ? 'MD' : 'FILE',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8))),
                      ),
                      if (isAiGenerated) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome,
                            size: 12, color: Color(0xFF818CF8)),
                        const SizedBox(width: 4),
                        Text(UserStorage.l10n.aiGeneratedLabel,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF818CF8),
                                fontWeight: FontWeight.w500)),
                      ]
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
