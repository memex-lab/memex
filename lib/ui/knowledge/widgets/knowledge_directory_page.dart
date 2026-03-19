import 'package:flutter/material.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/knowledge/widgets/knowledge/knowledge_file_card.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class KnowledgeDirectoryPage extends StatefulWidget {
  final String path;

  const KnowledgeDirectoryPage({
    super.key,
    required this.path,
  });

  @override
  State<KnowledgeDirectoryPage> createState() => _KnowledgeDirectoryPageState();
}

class _KnowledgeDirectoryPageState extends State<KnowledgeDirectoryPage> {
  final MemexRouter _memexRouter = MemexRouter();
  bool _isLoading = true;
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    setState(() => _isLoading = true);
    final dataResult = await _memexRouter.listPkmDirectory(path: widget.path);
    final data = dataResult.when(
        onOk: (d) => d, onError: (_, __) => <String, dynamic>{});
    if (data.isEmpty && dataResult.isError) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    {
      // Data expected structure: {'files': [{'name':..., 'path':...}], 'folders': [{'name':..., 'path':...}]}
      // OR a map where key is filename.
      // Checking listPkmDirectory signature: Future<Map<String, dynamic>>
      // The implementation details of listPkmDirectory:
      // It usually returns a tree or a flat list?
      // If it returns a tree, we need to parse.
      // Let's assume for now it returns a map of entries.
      // If the backend isn't perfect, we might need to adjust.
      // Based on pkm_endpoint.dart logic (not visible but assumed standard),
      // standard directory listing usually separates files and folders.

      // Let's parse whatever comes back.
      // Inspecting prior assumptions in KnowledgeBasePage: it got a Map.

      final items = data['items'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> files = [];
      final List<Map<String, dynamic>> folders = [];

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final isDirectory = item['is_directory'] == true;
          if (isDirectory) {
            folders.add(item);
          } else {
            files.add(item);
          }
        }
      }

      // Fetch counts for folders
      if (folders.isNotEmpty) {
        final folderPaths = folders.map((f) => f['path'] as String).toList();
        final countResult = await _memexRouter.countPkmItems(folderPaths);
        final counts = countResult.when(
            onOk: (c) => c, onError: (_, __) => <String, int>{});
        for (var f in folders) {
          f['item_count'] = counts[f['path']] ?? 0;
        }
      }

      if (mounted) {
        setState(() {
          _files = files;
          _folders = folders;
          _isLoading = false;
        });
      }
    }
    if (dataResult.isError && mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.path,
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF64748B), size: 20),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: AgentLogoLoading())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_folders.isNotEmpty) ...[
                  ..._folders.map((f) => _buildFolderCard(f)),
                ],
                if (_files.isNotEmpty) ...[
                  ..._files.map((f) => KnowledgeFileCard(item: f)),
                ],
                if (_folders.isEmpty && _files.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text('Empty folder',
                        style: TextStyle(color: Color(0xFFCBD5E1))),
                  ),
              ],
            ),
    );
  }

  Widget _buildFolderCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KnowledgeDirectoryPage(path: item['path']),
          ),
        );
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
                color: const Color(0xFFEFF6FF), // Blue 50
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_rounded,
                  color: Color(0xFF3B82F6), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('${item['item_count'] ?? 0} items',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
