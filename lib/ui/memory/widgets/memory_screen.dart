import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:memex/ui/memory/view_models/memory_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

/// Memory screen. Receives [viewModel] from parent (Compass-style).
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key, required this.viewModel});

  final MemoryViewModel viewModel;

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.viewModel.loadMemory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              UserStorage.l10n.memoryTitle,
              style: const TextStyle(
                  color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
          body: _buildBody(vm),
        );
      },
    );
  }

  Widget _buildBody(MemoryViewModel vm) {
    if (vm.isLoading) {
      return Center(child: AgentLogoLoading());
    }

    if (vm.error != null) {
      return Center(
        child: Text(
          UserStorage.l10n.errorLoadingMemory(vm.error!),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final archived = vm.memoryData?['archived_memory'] as String? ?? '';
    final buffer = (vm.memoryData?['recent_buffer'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF6366F1),
              tabs: [
                Tab(text: UserStorage.l10n.longTermProfile),
                Tab(text: UserStorage.l10n.recentBuffer),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildArchivedView(archived),
                _buildRecentView(buffer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedView(String content) {
    if (content.isEmpty) {
      return const Center(
        child: Text(
          'No long-term memories yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A)),
          h2: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
          h3: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155)),
          p: const TextStyle(
              fontSize: 15, color: Color(0xFF475569), height: 1.5),
          listBullet: const TextStyle(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }

  Widget _buildRecentView(List<Map<String, dynamic>> buffer) {
    if (buffer.isEmpty) {
      return const Center(
        child: Text(
          'No recent memories in buffer.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final reversedBuffer = buffer.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reversedBuffer.length,
      itemBuilder: (context, index) {
        final item = reversedBuffer[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['subject'] ?? 'General',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(item['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic isoValue) {
    if (isoValue == null) return '';
    try {
      final date = DateTime.parse(isoValue.toString());
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
