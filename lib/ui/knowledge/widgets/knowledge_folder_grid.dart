import 'package:flutter/material.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/utils/user_storage.dart';

import 'knowledge_directory_page.dart';

class KnowledgeFolderGrid extends StatelessWidget {
  const KnowledgeFolderGrid({
    super.key,
    required this.folders,
    required this.rootCounts,
  });

  final List<LibraryFolder> folders;
  final Map<String, int> rootCounts;

  @override
  Widget build(BuildContext context) {
    final l = UserStorage.l10n;
    final defaults = [
      (
        'Projects',
        l.pkmCategoryProject,
        l.pkmCategoryProjectSubtitle,
        const Color(0xFF6366F1),
        Icons.track_changes_outlined
      ),
      (
        'Areas',
        l.pkmCategoryArea,
        l.pkmCategoryAreaSubtitle,
        const Color(0xFF10B981),
        Icons.grid_view
      ),
      (
        'Resources',
        l.pkmCategoryResource,
        l.pkmCategoryResourceSubtitle,
        const Color(0xFFF59E0B),
        Icons.layers_outlined
      ),
      (
        'Archives',
        l.pkmCategoryArchive,
        l.pkmCategoryArchiveSubtitle,
        const Color(0xFF64748B),
        Icons.inbox_outlined
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: List.generate(defaults.length, (index) {
        final (root, title, desc, color, icon) = defaults[index];
        final folder = index < folders.length ? folders[index] : null;
        return _buildParaCard(
          title: folder?.name ?? title,
          engTitle: folder == null ? root.toUpperCase() : 'MARKDOWN',
          desc: folder?.latest.title ?? desc,
          count: folder?.documentCount ?? rootCounts[root] ?? 0,
          color: color,
          icon: icon,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    KnowledgeDirectoryPage(path: folder?.path ?? root),
              )),
        );
      }),
    );
  }

  Widget _buildParaCard({
    required String title,
    required String engTitle,
    required String desc,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      engTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          desc,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9)),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('$count',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
