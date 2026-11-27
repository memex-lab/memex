import 'package:flutter/material.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/memex_brand_title.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/settings/view_models/data_import_viewmodel.dart';
import 'package:memex/ui/settings/widgets/data_import_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'knowledge_directory_page.dart';
import 'knowledge_file_page.dart';
import 'knowledge_folder_grid.dart';
import 'knowledge_search_delegate.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key, required this.viewModel});
  final KnowledgeBaseViewModel viewModel;
  @override
  State<KnowledgeBaseScreen> createState() => KnowledgeBaseScreenState();
}

class KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void scrollToTopAndRefresh() {
    if (_scroll.hasClients)
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    widget.viewModel.fetchData(forceRefresh: true);
  }

  Future<void> _import() async {
    final vm = DataImportViewModel(router: MemexRouter());
    try {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => DataImportPage(viewModel: vm)));
    } finally {
      vm.dispose();
    }
    if (mounted) await widget.viewModel.fetchData(forceRefresh: true);
  }

  Widget _group(List<Widget> children) => Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children));
  Widget _heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 0, 10),
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)));
  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel, l = UserStorage.l10n;
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const MemexBrandTitle(),
            centerTitle: false,
            actions: [
              TextButton.icon(
                  onPressed: _import,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: Text(l.libraryImport))
            ]),
        body: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              final topics = vm.topics, featured = vm.featured;
              return RefreshIndicator(
                  onRefresh: () => vm.fetchData(forceRefresh: true),
                  child: ListView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                      children: [
                        _group([
                          ListTile(
                              leading: const Icon(Icons.search),
                              title: Text(l.searchKnowledgeBase),
                              onTap: () => showSearch(
                                  context: context,
                                  delegate: KnowledgeSearchDelegate()))
                        ]),
                        if (vm.isLoading && vm.documents.isEmpty)
                          const LinearProgressIndicator(),
                        if (vm.failed)
                          TextButton(
                              onPressed: () => vm.fetchData(forceRefresh: true),
                              child: Text(l.dataLoadFailedRetry)),
                        const SizedBox(height: 16),
                        KnowledgeFolderGrid(
                            folders: vm.frequentFolders,
                            rootCounts: vm.rootCounts),
                        if (featured.isNotEmpty) ...[
                          _heading(l.libraryImportant),
                          _group([
                            for (final doc in featured)
                              _LibraryRow(doc: doc, vm: vm),
                          ])
                        ],
                        if (topics.isNotEmpty) ...[
                          _heading(l.libraryTopics),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                for (final topic in topics.keys)
                                  Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Material(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => Scaffold(
                                                          appBar: AppBar(
                                                              title:
                                                                  Text(topic)),
                                                          body:
                                                              ListenableBuilder(
                                                                  listenable:
                                                                      vm,
                                                                  builder:
                                                                      (_, __) {
                                                                    final docs =
                                                                        vm.topics[topic] ??
                                                                            [];
                                                                    return ListView.builder(
                                                                        itemCount:
                                                                            docs
                                                                                .length,
                                                                        itemBuilder: (_, i) => _LibraryRow(
                                                                            doc:
                                                                                docs[i],
                                                                            vm: vm));
                                                                  })))),
                                              child: Container(
                                                  width: 114,
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .bookmarks_outlined,
                                                            color: AppColors
                                                                .primary,
                                                            size: 19),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(topic,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        Text(
                                                            l.libraryTopicCount(
                                                                topics[topic]!
                                                                    .length),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall)
                                                      ])))))
                              ]))
                        ],
                        const SizedBox(height: 22),
                        _group([
                          ListTile(
                              leading: const Icon(Icons.folder_open_outlined),
                              title: Text(l.libraryOriginals),
                              subtitle:
                                  Text(l.libraryDocCount(vm.documents.length)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const KnowledgeDirectoryPage(
                                              path: ''))))
                        ]),
                      ]));
            }));
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.doc, required this.vm});
  final LibraryDocument doc;
  final KnowledgeBaseViewModel vm;
  @override
  Widget build(BuildContext context) {
    final l = UserStorage.l10n;
    final pinned = vm.pinned.contains(doc.path),
        hidden = vm.hidden.contains(doc.path);
    final summary = doc.totalTasks > 0
        ? l.libraryTaskProgress(doc.totalTasks - doc.openTasks, doc.totalTasks)
        : doc.excerpt;
    void open() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => KnowledgeFilePage(filePath: doc.path)));
    return ListTile(
        leading: Icon(
            pinned
                ? Icons.push_pin_outlined
                : doc.totalTasks > 0
                    ? Icons.checklist
                    : Icons.article_outlined,
            color: AppColors.primary),
        title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: summary.isEmpty
            ? null
            : Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: open,
        trailing: PopupMenuButton<String>(
            onSelected: (action) async {
              if (action == 'open') {
                open();
                return;
              }
              if (!await vm.toggle(doc.path, pin: action == 'pin') &&
                  context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.dataLoadFailedRetry)));
              }
            },
            itemBuilder: (_) => [
                  PopupMenuItem(value: 'open', child: Text(l.libraryOpen)),
                  PopupMenuItem(
                      value: 'pin',
                      child: Text(pinned ? l.libraryUnpin : l.libraryPin)),
                  PopupMenuItem(
                      value: 'hide',
                      child: Text(hidden ? l.libraryShow : l.libraryHide))
                ]));
  }
}
