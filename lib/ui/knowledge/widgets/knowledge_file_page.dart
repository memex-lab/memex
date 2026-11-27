import 'package:memex/ui/chat/widgets/open_super_agent_dialog.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:memex/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/ui/core/cards/templates/classic_card.dart';
import 'package:path/path.dart' as path;
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/share_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

final _logger = getLogger('KnowledgeFilePage');

class KnowledgeFilePage extends StatefulWidget {
  final String filePath;

  const KnowledgeFilePage({super.key, required this.filePath});

  @override
  State<KnowledgeFilePage> createState() => _KnowledgeFilePageState();
}

class _KnowledgeFilePageState extends State<KnowledgeFilePage> {
  final MemexRouter _memexRouter = MemexRouter();
  late String _documentPath = widget.filePath;
  String _content = '';
  List<String> _factIds = [];
  List<TimelineCardModel> _sourceCards = [];
  bool _isLoading = true;
  bool _isLoadingCards = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);
    try {
      // 1. Read file content
      final response = await _memexRouter.readPkmFile(_documentPath);
      final content = response['content'] as String? ?? '';

      // 2. Parse fact_ids
      final ids = _extractFactIds(content);

      if (mounted) {
        context.read<KnowledgeBaseViewModel?>()?.opened(_documentPath);
        setState(() {
          _content = content;
          _factIds = ids;
          _isLoading = false;
        });
      }

      // 3. Fetch cards if any
      if (ids.isNotEmpty) {
        _fetchSourceCards(ids);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ToastHelper.showError(context, e);
      }
    }
  }

  List<String> _extractFactIds(String content) {
    final regex = RegExp(r'<!--\s*fact_id:\s*(.*?)\s*-->');
    return regex
        .allMatches(content)
        .map((m) => m.group(1)!.trim())
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<void> _fetchSourceCards(List<String> ids) async {
    if (mounted) setState(() => _isLoadingCards = true);
    try {
      final cards = await _memexRouter.fetchCardByIds(ids);
      if (mounted) {
        setState(() {
          _sourceCards = _dedupeSourceCards(cards);
          _isLoadingCards = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCards = false);
      _logger.warning('Error fetching source cards: $e');
    }
  }

  List<TimelineCardModel> _dedupeSourceCards(List<TimelineCardModel> cards) {
    final seen = <String>{};
    return cards.where((card) => seen.add(card.id)).toList();
  }

  int get _uniqueFactIdCount => _factIds.toSet().length;

  Future<void> _downloadFile() async {
    if (_isLoading || _isDownloading) return;

    setState(() => _isDownloading = true);
    try {
      await ShareService.shareTextAsFile(
        context,
        fileName: path.basename(_documentPath),
        content: _content,
        mimeType: 'text/markdown',
        text: UserStorage.l10n.sharedFromMemex,
      );
    } catch (e, stackTrace) {
      _logger.severe('Failed to download knowledge file: $e', e, stackTrace);
      if (mounted) {
        ToastHelper.showError(
          context,
          UserStorage.l10n.downloadFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  String _preprocessMarkdown(String content) {
    // Replace <!-- fact_id: ... --> with a visible link/badge format that we can intercept
    // We use a custom scheme 'fact:' to identify these links
    return content.replaceAllMapped(RegExp(r'<!--\s*fact_id:\s*(.*?)\s*-->'),
        (match) {
      final id = match.group(1);
      return '[source 🔗](fact:$id)';
    });
  }

  Future<void> _move() async {
    var proposed = _documentPath;
    final target = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(UserStorage.l10n.libraryMove),
                content: TextFormField(
                    initialValue: proposed,
                    autofocus: true,
                    decoration: const InputDecoration(prefixText: 'PKM/'),
                    onChanged: (value) => proposed = value,
                    onFieldSubmitted: (value) =>
                        Navigator.pop(ctx, value.trim())),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(UserStorage.l10n.cancel)),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, proposed.trim()),
                      child: Text(UserStorage.l10n.save))
                ]));
    if (target == null || target == _documentPath || !mounted) return;
    final result =
        await _memexRouter.moveLibraryDocument(_documentPath, target);
    if (!mounted) return;
    result.when(
        onOk: (_) {
          setState(() => _documentPath = target);
        },
        onError: (e, _) => ToastHelper.showError(
            context, UserStorage.l10n.operationFailed(e.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(path.basename(_documentPath),
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        actions: [
          if (context.watch<KnowledgeBaseViewModel?>() case final vm?)
            PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == "move") {
                    await _move();
                    return;
                  }
                  if (!await vm.toggle(_documentPath, pin: action == 'pin') &&
                      context.mounted) {
                    ToastHelper.showError(
                        context, UserStorage.l10n.dataLoadFailedRetry);
                  }
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                          value: "move",
                          child: Text(UserStorage.l10n.libraryMove)),
                      PopupMenuItem(
                          value: 'pin',
                          child: Text(vm.pinned.contains(_documentPath)
                              ? UserStorage.l10n.libraryUnpin
                              : UserStorage.l10n.libraryPin)),
                      PopupMenuItem(
                          value: 'hide',
                          child: Text(vm.hidden.contains(_documentPath)
                              ? UserStorage.l10n.libraryShow
                              : UserStorage.l10n.libraryHide))
                    ]),
          IconButton(
              icon: const Icon(Icons.auto_fix_high_outlined),
              tooltip: UserStorage.l10n.libraryOrganize,
              onPressed: () => openSuperAgentDialog(context,
                  initialDraftText:
                      '${UserStorage.l10n.libraryOrganizeDraft}\n/PKM/$_documentPath')),
          IconButton(
            key: const ValueKey('knowledge_file_download_button'),
            tooltip: UserStorage.l10n.downloadFile,
            onPressed: (_isLoading || _isDownloading) ? null : _downloadFile,
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AgentLogoLoading())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: MarkdownBody(
                      data: _preprocessMarkdown(_content),
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        h1: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.5,
                            letterSpacing: -0.5),
                        h2: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.5),
                        p: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: Color(0xFF334155)),
                        blockquote: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontStyle: FontStyle.italic),
                        blockquoteDecoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                              left: BorderSide(
                                  color: Color(0xFF6366F1), width: 4)),
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null && href.startsWith('fact:')) {
                          final id = href.substring(5);
                          _scrollToCardOrOpen(id);
                        }
                      },
                    ),
                  ),

                  // Source Trace Section (only if exists)
                  if (_factIds.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE2E8F0), // Slate 200
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.link,
                                          size: 12, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                          UserStorage.l10n.sourceTraceWithCount(
                                              _uniqueFactIdCount),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF94A3B8),
                                              letterSpacing: 1.2)),
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
                            ),
                          ),
                          _isLoadingCards
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ))
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _sourceCards.length,
                                  separatorBuilder: (c, i) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final card = _sourceCards[index];
                                    return _buildSourceCard(card);
                                  },
                                ),
                          const SizedBox(height: 30), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSourceCard(TimelineCardModel card) {
    // Map TimelineCardModel to ClassicCard data structure
    // Logic adapted from TimelinePage long-press Classic Mode
    final audioAssets = card.assets?.where((a) => a.isAudio).toList() ?? [];

    final classicData = <String, dynamic>{
      'content': card.rawText ?? '',
      'images':
          card.assets?.where((a) => a.isImage).map((a) => a.url).toList() ?? [],
      'audioUrl': audioAssets.isNotEmpty ? audioAssets.first.url : null,
      'tags': [], // Force text-only/clean look without tags for Source Trace
      'status': card.status,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Original Input • Time
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                UserStorage.l10n.originalInput,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1), // Slate 300
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.circle,
                  size: 4,
                  color: Color(
                      0xFFE2E8F0)), // Slate 200, slightly lighter separator
              const SizedBox(width: 8),
              Text(
                card.displayTime(UserStorage.l10n),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1), // Slate 300
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Card Content
        ClassicCard(
          data: classicData,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TimelineCardDetailScreen(cardId: card.id),
              ),
            );
          },
        ),
      ],
    );
  }

  void _scrollToCardOrOpen(String id) {
    // If card is already in the list at bottom, maybe highlight it?
    // Or just open detail page directly.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimelineCardDetailScreen(cardId: id),
      ),
    );
  }
}
