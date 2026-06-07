import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/logger.dart';

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
  Timer? _backgroundCompletionPoller;
  bool _bridgeInitialized = false;
  bool _executorReady = false;
  bool _pendingNativeRun = false;
  bool _nativeBackgroundRunOpen = false;

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
    _taskSubscription =
        LocalTaskExecutor.instance.taskActivitySnapshotStream.listen(
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

    final snapshot = await LocalTaskExecutor.instance.getTaskActivitySnapshot();
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
    _backgroundCompletionPoller?.cancel();
    _backgroundCompletionPoller = null;
    await _taskSubscription?.cancel();
    _taskSubscription = null;

    try {
      await _channel.invokeMethod<void>('setTaskActivity', {
        'pending': 0,
        'processing': 0,
        'retrying': 0,
        'total': 0,
        'hasActiveTasks': false,
        'reason': reason,
      });
      await _completeNativeBackgroundRun(success: false, reason: reason);
    } catch (e, stack) {
      _logger.warning('Failed to stop iOS background monitoring', e, stack);
    }
  }

  Future<void> onAppPaused() async {
    if (!Platform.isIOS || !_executorReady) return;

    final snapshot = await LocalTaskExecutor.instance.getTaskActivitySnapshot();
    await _syncSnapshot(snapshot, reason: 'app_lifecycle_paused');
  }

  Future<void> onAppResumed() async {
    if (!Platform.isIOS || !_executorReady) return;

    final snapshot = await LocalTaskExecutor.instance.getTaskActivitySnapshot();
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
        await LocalTaskExecutor.instance
            .recordGracefulShutdown(reason: 'ios_$reason');
        await _completeNativeBackgroundRun(success: false, reason: reason);
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

    final snapshot = await LocalTaskExecutor.instance.getTaskActivitySnapshot();
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
          await LocalTaskExecutor.instance.getTaskActivitySnapshot();
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

    try {
      await _channel.invokeMethod<void>('setTaskActivity', {
        'pending': snapshot.pending,
        'processing': snapshot.processing,
        'retrying': snapshot.retrying,
        'total': snapshot.total,
        'hasActiveTasks': snapshot.hasActiveTasks,
        'reason': reason,
      });

      if (!snapshot.hasActiveTasks) {
        await _completeNativeBackgroundRun(
          success: true,
          reason: 'snapshot_empty',
        );
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
    } catch (e, stack) {
      _logger.warning('Failed to complete native iOS background run', e, stack);
    }
  }
}
