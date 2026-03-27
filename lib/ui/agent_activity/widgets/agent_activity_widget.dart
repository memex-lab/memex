import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/user_storage.dart';

class AgentActivityWidget extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const AgentActivityWidget({super.key, this.navigatorKey});

  @override
  State<AgentActivityWidget> createState() => _AgentActivityWidgetState();
}

class _AgentActivityWidgetState extends State<AgentActivityWidget>
    with SingleTickerProviderStateMixin {
  AgentActivityMessageModel? _latestMessage;
  AgentActivityService? _service;
  LocalTaskExecutor? _executor;
  StreamSubscription<AgentActivityMessageModel>? _subscription;
  StreamSubscription<bool>? _taskSubscription;
  bool _hasActiveTasks = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  bool get _hasRunningAgent {
    if (_latestMessage == null) return false;
    final t = _latestMessage!.type;
    return t != AgentActivityType.agent_stop && t != AgentActivityType.error;
  }

  bool get _isActive {
    return _hasRunningAgent || _hasActiveTasks;
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    try {
      _service = AgentActivityService.instance;
      _executor = LocalTaskExecutor.instance;
      if (_executor?.hasActiveTasksStream != null) {
        _subscribeToService();
      }
    } catch (_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _initService();
      });
      return;
    }
  }

  void _initService() {
    try {
      _service = AgentActivityService.instance;
      _executor = LocalTaskExecutor.instance;
      _subscribeToService();
    } catch (_) {}
  }

  void _subscribeToService() {
    _subscription = _service?.messageStream.listen((message) {
      if (mounted) setState(() => _latestMessage = message);
    });

    try {
      _taskSubscription = _executor?.hasActiveTasksStream.listen((hasTasks) {
        if (mounted) {
          setState(() {
            _hasActiveTasks = hasTasks;
          });
        }
      });
    } catch (_) {}

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _loadLatestFromDb();
    });
  }

  Future<void> _loadLatestFromDb() async {
    try {
      final history = await _service?.getHistory(limit: 1) ?? [];
      if (history.isNotEmpty && mounted) {
        setState(() => _latestMessage = history.first);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _taskSubscription?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  bool _isDetailShowing = false;

  Future<void> _showDetail(BuildContext context) async {
    if (_isDetailShowing) return;
    _isDetailShowing = true;
    final targetContext = widget.navigatorKey?.currentContext ?? context;
    try {
      await showModalBottomSheet(
        context: targetContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _DetailSheet(initialMessage: _latestMessage),
      );
    } finally {
      if (mounted) _isDetailShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _hasRunningAgent ? () => _showDetail(context) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.75),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouncing thinking emoji
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: const Text('🤔', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 8),
                // Text
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        UserStorage.l10n.agentProcessing,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        UserStorage.l10n.keepAppOpen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF64748B).withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasRunningAgent) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final AgentActivityMessageModel? initialMessage;
  const _DetailSheet({this.initialMessage});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet>
    with SingleTickerProviderStateMixin {
  AgentActivityMessageModel? _message;
  StreamSubscription? _subscription;
  AgentActivityService? _service;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _message = widget.initialMessage;
    try {
      _service = AgentActivityService.instance;
    } catch (_) {}
    _loadHistory();
    _subscription = _service?.messageStream.listen(_handleNewMessage);
  }

  Future<void> _loadHistory() async {
    final history = await _service?.getHistory(limit: 1) ?? [];
    if (mounted && history.isNotEmpty) {
      if (_message == null || history.first.id >= _message!.id) {
        setState(() => _message = history.first);
      }
    }
  }

  void _handleNewMessage(AgentActivityMessageModel newMessage) {
    if (!mounted) return;
    setState(() => _message = newMessage);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🤔', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      UserStorage.l10n.activityDetail,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _message == null
                  ? Center(
                      child: Text(UserStorage.l10n.noAgentActivityYet,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 16)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildIcon(_message!.type),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(UserStorage.l10n.processingEllipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B))),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateFormat('HH:mm:ss').format(_message!.timestamp)} • ${_message!.agentName}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_message!.content != null &&
                            _message!.content!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: SingleChildScrollView(
                              child: MarkdownBody(
                                data: _message!.content!,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF334155),
                                      height: 1.6),
                                  code: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                      backgroundColor: Color(0xFFE2E8F0),
                                      fontFamily: 'monospace'),
                                  codeblockDecoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_message!.type != AgentActivityType.agent_stop &&
                            _message!.type != AgentActivityType.error)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF6366F1)),
                                ),
                                const SizedBox(width: 8),
                                Text(UserStorage.l10n.keepAppOpen,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(AgentActivityType type) {
    IconData iconData;
    Color color;
    switch (type) {
      case AgentActivityType.agent_start:
        iconData = Icons.rocket_launch;
        color = const Color(0xFF10B981);
      case AgentActivityType.agent_stop:
        iconData = Icons.check_circle;
        color = const Color(0xFF10B981);
      case AgentActivityType.tool_call_reqeust:
        iconData = Icons.build_circle_outlined;
        color = const Color(0xFF6366F1);
      case AgentActivityType.tool_call_response:
        iconData = Icons.task_alt;
        color = const Color(0xFF10B981);
      case AgentActivityType.thought:
      case AgentActivityType.thought_chunk:
        iconData = Icons.psychology;
        color = const Color(0xFF8B5CF6);
      case AgentActivityType.info:
      case AgentActivityType.output_chunk:
        iconData = Icons.info_outline;
        color = const Color(0xFF3B82F6);
      case AgentActivityType.error:
        iconData = Icons.error_outline;
        color = const Color(0xFFEF4444);
      case AgentActivityType.warn:
        iconData = Icons.warning_amber_rounded;
        color = const Color(0xFFF59E0B);
      case AgentActivityType.plan:
        iconData = Icons.map_outlined;
        color = const Color(0xFF10B981);
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(iconData, size: 24, color: color),
    );
  }
}
