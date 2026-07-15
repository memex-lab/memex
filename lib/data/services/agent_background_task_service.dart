import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

/// Keeps iOS informed while Memex agent tasks are active.
///
/// This service intentionally does not initialize the database by itself.
/// MemexRouter calls [startMonitoring] after the task handlers and database are
/// ready, so native background launches can be buffered until Dart can safely
/// resume the local queue.
class AgentBackgroundTaskService {
  AgentBackgroundTaskService._();

  static final AgentBackgroundTaskService instance =
      AgentBackgroundTaskService._();

  static const MethodChannel _channel =
      MethodChannel('com.memexlab.memex/agent_background_tasks');

  final _logger = getLogger('AgentBackgroundTaskService');

  StreamSubscription<TaskActivitySnapshot>? _taskSubscription;
  StreamSubscription<AgentForegroundTaskSnapshot>? _trackerSubscription;
  Timer? _backgroundCompletionPoller;
  bool _bridgeInitialized = false;
  bool _executorReady = false;
  bool _pendingNativeRun = false;
  bool _nativeBackgroundRunOpen = false;
  Set<String>? _progressActiveTaskIds;
  int _progressCompleted = 0;
  int _progressTotal = 0;
  TaskActivitySnapshot _latestTaskSnapshot = const TaskActivitySnapshot.empty();
  AgentForegroundTaskSnapshot _latestForegroundSnapshot =
      const AgentForegroundTaskSnapshot.empty();

  Future<void> initializeNativeBridge() async {
    if (!Platform.isIOS || _bridgeInitialized) return;

    _bridgeInitialized = true;
    _channel.setMethodCallHandler(_handleNativeCall);

    try {
      final capabilities =
          await _channel.invokeMapMethod<String, dynamic>('initialize');
      _logger.info('iOS agent background bridge initialized: $capabilities');
    } catch (e, stack) {
      _logger.warning(
        'Failed to initialize iOS agent background bridge',
        e,
        stack,
      );
    }
  }

  Future<void> startMonitoring() async {
    if (!Platform.isIOS) return;
    await initializeNativeBridge();

    _executorReady = true;
    await _taskSubscription?.cancel();
    await _trackerSubscription?.cancel();
    _taskSubscription =
        LocalTaskExecutor.instance.runnableTaskActivitySnapshotStream.listen(
      (snapshot) => unawaited(
        _syncSnapshot(snapshot, reason: 'task_activity_changed'),
      ),
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Task activity stream failed',
          error,
          stackTrace,
        );
      },
    );
    _trackerSubscription =
        AgentForegroundTaskTracker.instance.watchSnapshot().listen(
      (snapshot) {
        _latestForegroundSnapshot = snapshot;
        unawaited(
          _syncSnapshot(
            _latestTaskSnapshot,
            reason: 'foreground_task_tracker_changed',
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Foreground task tracker stream failed',
          error,
          stackTrace,
        );
      },
    );

    final snapshot =
        await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
    _latestForegroundSnapshot =
        await AgentForegroundTaskTracker.instance.getSnapshot();
    await _syncSnapshot(snapshot, reason: 'executor_ready');

    if (_pendingNativeRun) {
      _pendingNativeRun = false;
      await _handleNativeRun(reason: 'pending_native_run');
    }
  }

  Future<void> stopMonitoring({String reason = 'stopped'}) async {
    if (!Platform.isIOS) return;

    _executorReady = false;
    _pendingNativeRun = false;
    _resetProgressSession();
    _backgroundCompletionPoller?.cancel();
    _backgroundCompletionPoller = null;
    await _taskSubscription?.cancel();
    await _trackerSubscription?.cancel();
    _taskSubscription = null;
    _trackerSubscription = null;
    _latestTaskSnapshot = const TaskActivitySnapshot.empty();
    _latestForegroundSnapshot = const AgentForegroundTaskSnapshot.empty();

    try {
      await _channel.invokeMethod<void>('setTaskActivity', {
        'pending': 0,
        'processing': 0,
        'retrying': 0,
        'total': 0,
        'hasActiveTasks': false,
        'hasRunnableTasks': false,
        'reason': reason,
      });
      await _completeNativeBackgroundRun(success: false, reason: reason);
    } catch (e, stack) {
      _logger.warning('Failed to stop iOS background monitoring', e, stack);
    }
  }

  Future<void> onAppPaused() async {
    if (!Platform.isIOS || !_executorReady) return;

    final snapshot =
        await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
    await _syncSnapshot(snapshot, reason: 'app_lifecycle_paused');
  }

  Future<void> onAppResumed() async {
    if (!Platform.isIOS || !_executorReady) return;

    await AgentForegroundTaskTracker.instance.clearAttention();
    await AgentForegroundTaskTracker.instance.clearPause();
    final snapshot =
        await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
    await _syncSnapshot(snapshot, reason: 'app_lifecycle_resumed');
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'runPendingAgentTasks':
        final args = call.arguments as Map<Object?, Object?>?;
        await _handleNativeRun(
          reason: args?['reason']?.toString() ?? 'native_background_run',
        );
        return true;
      case 'backgroundTaskExpired':
        final args = call.arguments as Map<Object?, Object?>?;
        final reason = args?['reason']?.toString() ?? 'native_expired';
        await AgentForegroundTaskTracker.instance.markPaused(
          message: UserStorage.l10n.agentBackgroundPausedDetail,
        );
        _backgroundCompletionPoller?.cancel();
        _backgroundCompletionPoller = null;
        _nativeBackgroundRunOpen = false;
        _resetProgressSession();
        _logger.info(
          'iOS background task expired ($reason); agent queue will resume later',
        );
        return true;
      default:
        throw MissingPluginException('Unknown native method ${call.method}');
    }
  }

  Future<void> _handleNativeRun({required String reason}) async {
    _nativeBackgroundRunOpen = true;

    if (!_executorReady) {
      _pendingNativeRun = true;
      _logger
          .info('Buffered native iOS background run until executor is ready');
      return;
    }

    await LocalTaskExecutor.instance.clearGracefulShutdownMarker();

    final snapshot =
        await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
    await _syncSnapshot(snapshot, reason: reason);

    if (snapshot.hasActiveTasks) {
      _startCompletionPoller();
    } else {
      await _completeNativeBackgroundRun(success: true, reason: 'no_tasks');
    }
  }

  void _startCompletionPoller() {
    _backgroundCompletionPoller?.cancel();
    _backgroundCompletionPoller =
        Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_executorReady) return;

      final snapshot =
          await LocalTaskExecutor.instance.getRunnableTaskActivitySnapshot();
      await _syncSnapshot(snapshot, reason: 'background_completion_poll');

      if (!snapshot.hasActiveTasks) {
        _backgroundCompletionPoller?.cancel();
        _backgroundCompletionPoller = null;
        await _completeNativeBackgroundRun(
          success: true,
          reason: 'tasks_completed',
        );
      }
    });
  }

  Future<void> _syncSnapshot(
    TaskActivitySnapshot snapshot, {
    required String reason,
  }) async {
    if (!Platform.isIOS || !_bridgeInitialized) return;

    _latestTaskSnapshot = snapshot;
    final foregroundSnapshot = _latestForegroundSnapshot.hasActiveTasks ||
            _latestForegroundSnapshot.hasAttention
        ? _latestForegroundSnapshot
        : await AgentForegroundTaskTracker.instance.getSnapshot();
    final trackedTaskSnapshot = foregroundSnapshot.taskSnapshot;
    final progress = _progressFor(trackedTaskSnapshot);
    final hasVisibleWork =
        foregroundSnapshot.hasActiveTasks || foregroundSnapshot.hasAttention;
    final hasRunnableWork = snapshot.hasActiveTasks;
    final pending = trackedTaskSnapshot.pending;
    final processing = trackedTaskSnapshot.processing;
    final retrying = trackedTaskSnapshot.retrying;
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: trackedTaskSnapshot,
      foregroundSnapshot: foregroundSnapshot,
    );

    try {
      await _channel.invokeMethod<void>('setTaskActivity', {
        'pending': pending,
        'processing': processing,
        'retrying': retrying,
        'total': pending + processing + retrying,
        'taskSummary': status.taskSummary,
        'statusText': status.statusText,
        'progressCompleted': progress.completed,
        'progressTotal': progress.total,
        'state': status.state.name,
        'title': status.title,
        'stage': status.stage,
        'detail': status.detail,
        'hasActiveTasks': hasVisibleWork,
        'hasRunnableTasks': hasRunnableWork,
        'reason': reason,
      });

      if (!hasRunnableWork) {
        await _completeNativeBackgroundRun(
          success: true,
          reason: 'snapshot_empty',
        );
        _resetProgressSession();
      }
    } catch (e, stack) {
      _logger.warning('Failed to sync task activity to iOS', e, stack);
    }
  }

  Future<void> _completeNativeBackgroundRun({
    required bool success,
    required String reason,
  }) async {
    if (!Platform.isIOS || !_bridgeInitialized || !_nativeBackgroundRunOpen) {
      return;
    }

    _nativeBackgroundRunOpen = false;

    try {
      await _channel.invokeMethod<void>('completeBackgroundRun', {
        'success': success,
        'reason': reason,
      });
      _resetProgressSession();
    } catch (e, stack) {
      _logger.warning('Failed to complete native iOS background run', e, stack);
    }
  }

  _TaskProgress _progressFor(TaskActivitySnapshot snapshot) {
    final activeTaskIds = snapshot.activeTaskIds;
    final previousTaskIds = _progressActiveTaskIds;

    if (!snapshot.hasActiveTasks) {
      if (previousTaskIds != null && previousTaskIds.isNotEmpty) {
        _progressCompleted += previousTaskIds.length;
      }
      _progressTotal = _progressTotal < _progressCompleted
          ? _progressCompleted
          : _progressTotal;
      _progressActiveTaskIds = const <String>{};
      return _TaskProgress(
        completed: _progressTotal,
        total: _progressTotal,
      );
    }

    if (previousTaskIds == null) {
      _progressCompleted = 0;
      _progressTotal = activeTaskIds.length;
    } else {
      final finishedTaskCount =
          previousTaskIds.difference(activeTaskIds).length;
      final newTaskCount = activeTaskIds.difference(previousTaskIds).length;
      _progressCompleted += finishedTaskCount;
      _progressTotal += newTaskCount;
    }

    _progressActiveTaskIds = Set.unmodifiable(activeTaskIds);
    if (_progressTotal < activeTaskIds.length + _progressCompleted) {
      _progressTotal = activeTaskIds.length + _progressCompleted;
    }

    return _TaskProgress(
      completed: _progressCompleted,
      total: _progressTotal,
    );
  }

  void _resetProgressSession() {
    _progressActiveTaskIds = null;
    _progressCompleted = 0;
    _progressTotal = 0;
  }
}

class _TaskProgress {
  final int completed;
  final int total;

  const _TaskProgress({
    required this.completed,
    required this.total,
  });
}
