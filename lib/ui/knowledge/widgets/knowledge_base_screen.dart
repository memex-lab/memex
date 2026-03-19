import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/knowledge/widgets/knowledge/knowledge_file_card.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_search_delegate.dart';
import 'package:memex/utils/user_storage.dart';
import 'knowledge_directory_page.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

/// Knowledge base page. Receives [viewModel] from parent (Compass-style).
class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key, required this.viewModel});

  final KnowledgeBaseViewModel viewModel;

  @override
  State<KnowledgeBaseScreen> createState() => KnowledgeBaseScreenState();
}

class KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to top and refresh (e.g. pull-to-refresh or double-tap nav)
  void scrollToTopAndRefresh() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    if (mounted) widget.viewModel.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: const Color(
              0xFFF1F5F9), // Match Timeline, Insights and bottom nav background
          appBar: AppBar(
            title: Text(
              'Memex',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: const Color(0xFF0F172A),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 28),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: KnowledgeSearchDelegate(),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.fetchData(),
            child: vm.isLoading
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: AgentLogoLoading()),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildParaGrid(context, vm),
                        const SizedBox(height: 32),
                        _buildRecentChangesHeader(),
                        const SizedBox(height: 16),
                        _buildRecentChangesList(vm),
                        const SizedBox(
                            height: 80), // Bottom padding for nav bar
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildParaGrid(BuildContext context, KnowledgeBaseViewModel vm) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildParaCard(
          title: UserStorage.l10n.pkmCategoryProject,
          engTitle: 'PROJECTS',
          desc: UserStorage.l10n.pkmCategoryProjectSubtitle,
          count: vm.countItems('Projects'),
          color: const Color(0xFF6366F1), // Indigo
          icon: Icons.track_changes_outlined,
          onTap: () => _navigateToFolder(context, path: 'Projects'),
        ),
        _buildParaCard(
          title: UserStorage.l10n.pkmCategoryArea,
          engTitle: 'AREAS',
          desc: UserStorage.l10n.pkmCategoryAreaSubtitle,
          count: vm.countItems('Areas'),
          color: const Color(0xFF10B981), // Emerald
          icon: Icons.grid_view,
          onTap: () => _navigateToFolder(context, path: 'Areas'),
        ),
        _buildParaCard(
          title: UserStorage.l10n.pkmCategoryResource,
          engTitle: 'RESOURCES',
          desc: UserStorage.l10n.pkmCategoryResourceSubtitle,
          count: vm.countItems('Resources'),
          color: const Color(0xFFF59E0B), // Amber
          icon: Icons.layers_outlined,
          onTap: () => _navigateToFolder(context, path: 'Resources'),
        ),
        _buildParaCard(
          title: UserStorage.l10n.pkmCategoryArchive,
          engTitle: 'ARCHIVES',
          desc: UserStorage.l10n.pkmCategoryArchiveSubtitle,
          count: vm.countItems('Archives'),
          color: const Color(0xFF64748B), // Slate
          icon: Icons.inbox_outlined,
          onTap: () => _navigateToFolder(context, path: 'Archives'),
        ),
      ],
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
                color: color.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(engTitle,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(desc,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.9)),
                                overflow: TextOverflow.ellipsis)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
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

  Widget _buildRecentChangesHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0), // Slate 200
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(UserStorage.l10n.recentChanges,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0), // Slate 200
          ),
        ),
      ],
    );
  }

  Widget _buildRecentChangesList(KnowledgeBaseViewModel vm) {
    if (vm.recentFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(UserStorage.l10n.noRecentChangesInThreeDays,
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
      );
    }

    return Column(
      children:
          vm.recentFiles.map((file) => KnowledgeFileCard(item: file)).toList(),
    );
  }

  void _navigateToFolder(BuildContext context, {required String path}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KnowledgeDirectoryPage(path: path),
      ),
    );
  }
}
