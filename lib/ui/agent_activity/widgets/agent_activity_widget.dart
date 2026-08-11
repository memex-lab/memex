import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/user_storage.dart';

class AgentActivityWidget extends StatefulWidget {
  final bool forceVisible;
  final TaskActivitySnapshot initialTaskSnapshot;
  final Stream<TaskActivitySnapshot>? taskActivitySnapshotStream;

  const AgentActivityWidget({
    super.key,
    this.forceVisible = false,
    this.initialTaskSnapshot = const TaskActivitySnapshot.empty(),
    this.taskActivitySnapshotStream,
  });

  @override
  State<AgentActivityWidget> createState() => _AgentActivityWidgetState();
}

class _AgentActivityWidgetState extends State<AgentActivityWidget> {
  StreamSubscription<TaskActivitySnapshot>? _taskSubscription;
  Timer? _initRetryTimer;
  TaskActivitySnapshot _taskSnapshot = const TaskActivitySnapshot.empty();

  bool get _isActive {
    return widget.forceVisible || _taskSnapshot.hasActiveTasks;
  }

  AgentBackgroundStatus get _status => AgentBackgroundStatus.fromActivity(
        taskSnapshot: _taskSnapshot,
      );

  @override
  void initState() {
    super.initState();
    _taskSnapshot = widget.initialTaskSnapshot;
    _subscribeToTaskStream();
  }

  void _scheduleInitRetry() {
    _initRetryTimer?.cancel();
    _initRetryTimer = Timer(
      const Duration(seconds: 1),
      () {
        if (mounted) _subscribeToTaskStream();
      },
    );
  }

  void _subscribeToTaskStream() {
    _initRetryTimer?.cancel();
    _initRetryTimer = null;
    var needsRetry = false;

    try {
      final taskStream = widget.taskActivitySnapshotStream ??
          LocalTaskExecutor.instance.runnableTaskActivitySnapshotStream;
      _taskSubscription ??= taskStream.listen((snapshot) {
        if (mounted) {
          setState(() => _taskSnapshot = snapshot);
        }
      });
    } catch (_) {
      needsRetry = true;
    }

    unawaited(_loadCurrentState());
    if (needsRetry) _scheduleInitRetry();
  }

  Future<void> _loadCurrentState() async {
    try {
      if (widget.taskActivitySnapshotStream == null) {
        final snapshot =
            await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
        if (mounted) {
          setState(() => _taskSnapshot = snapshot);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _initRetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();
    final status = _status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.88),
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
          const _AgentActivityLogo(size: 36),
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
                  status.hasActiveTasks
                      ? status.taskSummary
                      : UserStorage.l10n.keepAppOpen,
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
        ],
      ),
    );
  }
}

class _AgentActivityLogo extends StatelessWidget {
  final double size;

  const _AgentActivityLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
