import 'package:flutter/material.dart';
import 'package:memex/data/services/agent_state_debug_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/utils/user_storage.dart';

typedef AgentStateViewerEntry = AgentStateDebugEntry;

class AgentStateViewerPage extends StatefulWidget {
  const AgentStateViewerPage({
    super.key,
    this.enableTextSelection = true,
    this.stateEntriesForTesting,
    this.stateRootPathForTesting,
    this.userIdForTesting,
    this.debugService,
  });

  final bool enableTextSelection;
  final List<AgentStateViewerEntry>? stateEntriesForTesting;
  final String? stateRootPathForTesting;
  final String? userIdForTesting;
  final AgentStateDebugService? debugService;

  @override
  State<AgentStateViewerPage> createState() => _AgentStateViewerPageState();
}

class _AgentStateViewerPageState extends State<AgentStateViewerPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AgentStateViewerEntry> _states = const [];
  AgentStateViewerEntry? _selectedState;
  String _content = '';
  String _query = '';
  bool _isLoading = true;
  bool _isReading = false;
  String? _error;

  AgentStateDebugService get _debugService =>
      widget.debugService ?? AgentStateDebugService.instance;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final testEntries = widget.stateEntriesForTesting;
      final states = testEntries == null
          ? await _loadStateEntriesFromDisk()
          : ([...testEntries]
            ..sort((a, b) => b.modified.compareTo(a.modified)));

      setState(() {
        _states = states;
        _selectedState = states.isEmpty ? null : states.first;
        _isLoading = false;
      });

      if (states.isNotEmpty) {
        await _selectState(states.first);
      } else {
        _content = '';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<AgentStateViewerEntry>> _loadStateEntriesFromDisk() async {
    final userId = widget.userIdForTesting ?? await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('No active user.');
    }
    return _debugService.listStates(
      userId: userId,
      rootPath: widget.stateRootPathForTesting,
    );
  }

  Future<void> _selectState(AgentStateViewerEntry state) async {
    setState(() {
      _selectedState = state;
      _isReading = true;
      _error = null;
    });

    try {
      final raw = await state.readContent();
      final content = _debugService.renderStateContent(raw, state, _states);
      if (!mounted) return;
      setState(() {
        _content = content;
        _isReading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _content = '';
        _error = e.toString();
        _isReading = false;
      });
    }
  }

  void _scrollContentToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollContentToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String get _visibleContent {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _content;
    final lines = _content.split('\n');
    return lines.where((line) => line.toLowerCase().contains(query)).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(UserStorage.l10n.agentStates),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadStates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AgentLogoLoading())
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null && _states.isEmpty) {
      return Center(child: Text(_error!));
    }
    if (_states.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No agent state files yet. Run an agent once, then refresh.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 760;
    if (wide) {
      return Row(
        children: [
          SizedBox(width: 340, child: _buildStateList()),
          const VerticalDivider(width: 1),
          Expanded(child: _buildStateContent()),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(height: 190, child: _buildStateList()),
        const Divider(height: 1),
        Expanded(child: _buildStateContent()),
      ],
    );
  }

  Widget _buildStateList() {
    return Material(
      color: Colors.white,
      child: ListView.separated(
        itemCount: _states.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final state = _states[index];
          final selected = state.sessionId == _selectedState?.sessionId;
          final childCount = state.isChild
              ? 0
              : _states
                  .where((entry) => entry.parentSessionId == state.sessionId)
                  .length;
          final subtitle = childCount == 0
              ? state.subtitle
              : '${state.subtitle} | children: $childCount';
          return ListTile(
            selected: selected,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
            leading: Icon(
              state.isChild
                  ? Icons.account_tree_outlined
                  : Icons.psychology_alt_outlined,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            title: Text(
              state.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => _selectState(state),
          );
        },
      ),
    );
  }

  Widget _buildStateContent() {
    final selected = _selectedState;
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selected?.path ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Top',
                    onPressed: _scrollContentToTop,
                    icon: const Icon(Icons.vertical_align_top, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Bottom',
                    onPressed: _scrollContentToBottom,
                    icon: const Icon(Icons.vertical_align_bottom, size: 20),
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Filter inside this state...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isReading
              ? const Center(child: AgentLogoLoading())
              : _buildReadableStateContent(),
        ),
      ],
    );
  }

  Widget _buildReadableStateContent() {
    final content = Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        key: const ValueKey('agent_state_content_scroll'),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Text(
          _visibleContent.isEmpty ? 'No matching lines.' : _visibleContent,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
            height: 1.45,
            color: Color(0xFF222222),
          ),
        ),
      ),
    );

    if (!widget.enableTextSelection) {
      return content;
    }
    return SelectionArea(child: content);
  }
}
