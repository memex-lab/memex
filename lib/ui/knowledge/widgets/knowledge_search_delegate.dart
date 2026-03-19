import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_file_page.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:path/path.dart' as p;

/// Search delegate for knowledge base files.
/// Greps file names and content in the PKM directory.
class KnowledgeSearchDelegate extends SearchDelegate<String?> {
  KnowledgeSearchDelegate()
      : super(
          searchFieldLabel: UserStorage.l10n.searchKnowledgeBase,
          searchFieldStyle: const TextStyle(fontSize: 16),
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) =>
      _SearchResultsWidget(query: query);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(UserStorage.l10n.searchKnowledgeHint,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      );
    }
    return _SearchResultsWidget(query: query);
  }
}

/// Stateful widget that performs the actual search with debounce.
class _SearchResultsWidget extends StatefulWidget {
  const _SearchResultsWidget({required this.query});
  final String query;

  @override
  State<_SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<_SearchResultsWidget> {
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _triggerSearch();
  }

  @override
  void didUpdateWidget(_SearchResultsWidget old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) {
      _triggerSearch();
    }
  }

  void _triggerSearch() {
    _debounce?.cancel();
    final q = widget.query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _doSearch(q));
  }

  Future<void> _doSearch(String q) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    final result = await MemexRouter().searchPkmFiles(q);
    if (!mounted) return;
    setState(() {
      _lastQuery = q;
      _results = result.when(
        onOk: (data) => data,
        onError: (_, __) => <Map<String, dynamic>>[],
      );
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching && _results.isEmpty) {
      return Center(child: AgentLogoLoading());
    }

    if (!_isSearching && _results.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(UserStorage.l10n.noSearchResults(_lastQuery),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) => _buildResultItem(_results[index]),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final name = item['name'] as String? ?? '';
    final filePath = item['path'] as String? ?? '';
    final snippet = item['snippet'] as String?;
    final isMd = p.extension(name).toLowerCase() == '.md';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description_outlined,
              color: Color(0xFF64748B), size: 20),
        ),
        title: Text(name,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(filePath,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            if (snippet != null) ...[
              const SizedBox(height: 4),
              Text(snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ],
        ),
        onTap: () {
          if (isMd) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KnowledgeFilePage(filePath: filePath),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(UserStorage.l10n.onlyMarkdownPreview)));
          }
        },
      ),
    );
  }
}
