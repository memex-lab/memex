import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_platform.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/logger.dart';

class AgentBackgroundCoordinator {
  AgentBackgroundCoordinator({
    AgentBackgroundPlatform? platform,
    AgentQueueDrainScheduler? scheduler,
  })  : _platform = platform ?? MethodChannelAgentBackgroundPlatform(),
        _scheduler = scheduler ?? WorkmanagerAgentQueueDrainScheduler();

  static AgentBackgroundCoordinator? _instance;
  static AgentBackgroundCoordinator get instance {
    _instance ??= AgentBackgroundCoordinator();
    return _instance!;
  }

  final AgentBackgroundPlatform _platform;
  final AgentQueueDrainScheduler _scheduler;
  final _logger = getLogger('AgentBackgroundCoordinator');

  StreamSubscription<TaskActivitySnapshot>? _taskSubscription;
  StreamSubscription<AgentActivityMessageModel>? _messageSubscription;
  StreamSubscription<String>? _actionSubscription;
  final _openActivityController = StreamController<void>.broadcast();

  TaskActivitySnapshot _taskSnapshot = const TaskActivitySnapshot.empty();
  AgentActivityMessageModel? _latestMessage;
  AgentBackgroundStatus? _lastPublishedStatus;
  Timer? _terminalStopTimer;
  bool _started = false;
  bool _drainWorkScheduledForCurrentRun = false;

  Stream<void> get openActivityRequests => _openActivityController.stream;

  void start({
    required LocalTaskExecutor executor,
    required AgentActivityService activityService,
  }) {
    if (_started) return;
    _started = true;

    _taskSubscription = executor.taskActivitySnapshotStream.listen(
      _handleTaskSnapshot,
    );
    _messageSubscription = activityService.messageStream.listen(
      _handleActivityMessage,
    );
    _actionSubscription = _platform.actionStream.listen(_handleAction);

    unawaited(_consumeInitialAction());
    unawaited(_publishStatus());
  }

  Future<void> stop() async {
    _started = false;
    _terminalStopTimer?.cancel();
    _terminalStopTimer = null;
    await _taskSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _actionSubscription?.cancel();
    _taskSubscription = null;
    _messageSubscription = null;
    _actionSubscription = null;
    _taskSnapshot = const TaskActivitySnapshot.empty();
    _latestMessage = null;
    _lastPublishedStatus = null;
    _drainWorkScheduledForCurrentRun = false;
    await _safeStopPlatform();
  }

  void _handleTaskSnapshot(TaskActivitySnapshot snapshot) {
    _taskSnapshot = snapshot;
    if (!snapshot.hasActiveTasks) {
      _drainWorkScheduledForCurrentRun = false;
    }
    unawaited(_publishStatus());
  }

  void _handleActivityMessage(AgentActivityMessageModel message) {
    _latestMessage = message;
    unawaited(_publishStatus());
  }

  void _handleAction(String action) {
    if (action == 'agent_activity') {
      _openActivityController.add(null);
    }
  }

  Future<void> _consumeInitialAction() async {
    try {
      final action = await _platform.consumeInitialAction();
      if (action != null) _handleAction(action);
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to consume initial background action',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _publishStatus() async {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: _taskSnapshot,
      latestMessage: _latestMessage,
    );

    if (status == _lastPublishedStatus) return;
    final previousPublishedStatus = _lastPublishedStatus;
    _lastPublishedStatus = status;

    _terminalStopTimer?.cancel();
    _terminalStopTimer = null;

    try {
      if (status.state == AgentBackgroundRunState.idle) {
        await _safeStopPlatform();
        await _scheduler.cancel();
        return;
      }

      if (status.state == AgentBackgroundRunState.active) {
        await _platform.updateStatus(status);
        if (!_drainWorkScheduledForCurrentRun) {
          _drainWorkScheduledForCurrentRun = true;
          await _scheduler.schedule(expedited: true);
        }
        return;
      }

      await _platform.finishStatus(status);
      await _scheduler.cancel();
      _terminalStopTimer = Timer(const Duration(seconds: 5), () {
        unawaited(_safeStopPlatform());
      });
    } catch (e, stackTrace) {
      _lastPublishedStatus = previousPublishedStatus;
      if (status.state == AgentBackgroundRunState.active) {
        _drainWorkScheduledForCurrentRun = false;
      }
      _logger.warning(
        'Failed to publish agent background status',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _safeStopPlatform() async {
    try {
      await _platform.stopStatus();
    } catch (e, stackTrace) {
      _logger.fine('Failed to stop agent background surface', e, stackTrace);
    }
  }
}

@visibleForTesting
void resetAgentBackgroundCoordinatorForTesting() {
  AgentBackgroundCoordinator._instance = null;
}
