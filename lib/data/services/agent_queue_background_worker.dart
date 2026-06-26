import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_platform.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/file_logger_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/sqlite_busy_retry.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

class AgentQueueBackgroundWorker {
  static const Duration _maxRunDuration = Duration(seconds: 25);
  static const Duration _defaultRetryDelay = Duration(minutes: 15);
  static const int _databaseMaxAttempts = 3;

  static bool isAgentQueueDrainTask(String taskName) {
    return taskName == WorkmanagerAgentQueueDrainScheduler.taskName ||
        taskName == WorkmanagerAgentQueueDrainScheduler.uniqueName;
  }

  static Future<bool> run({
    Future<void> Function(String userId)? initializeTaskQueue,
    LocalTaskExecutor? executor,
    AgentQueueDrainScheduler? scheduler,
    AgentBackgroundPlatform? backgroundPlatform,
    AgentActivityService? activityService,
    Duration maxRunDuration = _maxRunDuration,
    Duration databaseRetryDelay = const Duration(milliseconds: 300),
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupLogger();
    final logger = getLogger('AgentQueueBackgroundWorker');

    try {
      await UserStorage.initL10n();
      final userId = await UserStorage.getUserId();
      final surfacePlatform =
          backgroundPlatform ?? MethodChannelAgentBackgroundPlatform();
      if (userId == null || userId.isEmpty) {
        logger.info('Skipping agent queue drain: no active user.');
        await _stopBackgroundSurface(logger, surfacePlatform);
        return true;
      }

      final taskExecutor = executor ?? LocalTaskExecutor.instance;
      final queueScheduler = scheduler ?? WorkmanagerAgentQueueDrainScheduler();
      final labels = _statusLabels();
      final liveSurface = _LiveBackgroundSurfacePublisher(
        logger: logger,
        platform: surfacePlatform,
        labels: labels,
      );
      final result = await SqliteBusyRetry.run(
        operation: 'agent queue drain',
        logger: logger,
        maxAttempts: _databaseMaxAttempts,
        retryDelay: databaseRetryDelay,
        action: () async {
          if (initializeTaskQueue != null) {
            await initializeTaskQueue(userId);
          } else {
            await MemexRouter.ensureTaskQueueInitializedForBackgroundTask(
              userId,
              executor: taskExecutor,
            );
          }
          final liveActivityService =
              activityService ?? _tryGetActivityService(logger);
          if (liveActivityService != null) {
            await liveSurface.start(liveActivityService);
          }
          try {
            return await taskExecutor.drainAvailableTasks(
              userId: userId,
              maxDuration: maxRunDuration,
              stopWhenDone: true,
            );
          } finally {
            await liveSurface.stop();
          }
        },
      );

      if (result.snapshot.hasActiveTasks) {
        if (result.timedOut || result.deferredToAnotherOwner) {
          await AgentForegroundTaskTracker.instance.markPaused(
            message: UserStorage.l10n.agentBackgroundPausedDetail,
          );
        } else {
          await AgentForegroundTaskTracker.instance.clearPause();
        }
        await queueScheduler.schedule(
          initialDelay: result.nextRunnableDelay ?? _defaultRetryDelay,
          expedited: false,
        );
      } else {
        await AgentForegroundTaskTracker.instance.clearPause();
      }
      await _syncBackgroundSurfaceAfterDrain(
        logger,
        surfacePlatform,
        latestMessage: liveSurface.latestMessage,
        labels: labels,
      );

      logger.info(
        'Agent queue drain finished. '
        'active=${result.snapshot.total}, timedOut=${result.timedOut}, '
        'deferred=${result.deferredToAnotherOwner}',
      );
      return true;
    } catch (e, stackTrace) {
      logger.severe('Agent queue drain failed', e, stackTrace);
      return false;
    } finally {
      await FileLoggerService.instance.dispose();
    }
  }

  static Duration clampNextDelay(int? scheduledAtSeconds) {
    if (scheduledAtSeconds == null) return _defaultRetryDelay;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final seconds = max(30, scheduledAtSeconds - now);
    return Duration(seconds: seconds);
  }

  static Future<void> _syncBackgroundSurfaceAfterDrain(
    Logger logger,
    AgentBackgroundPlatform platform, {
    AgentActivityMessageModel? latestMessage,
    AgentBackgroundStatusLabels labels = const AgentBackgroundStatusLabels(),
  }) async {
    if (!platform.isSupported) return;

    try {
      final foregroundSnapshot =
          await AgentForegroundTaskTracker.instance.getSnapshot();
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: foregroundSnapshot.taskSnapshot,
        foregroundSnapshot: foregroundSnapshot,
        latestMessage: latestMessage,
        labels: labels,
      );
      if (!status.shouldShowSystemSurface) {
        await _stopBackgroundSurface(logger, platform);
        return;
      }
      if (status.state == AgentBackgroundRunState.failed) {
        await platform.finishStatus(status, isInBackground: true);
      } else {
        await platform.updateStatus(status, isInBackground: true);
      }
    } catch (e, stackTrace) {
      logger.warning(
        'Failed to refresh Android agent background surface after drain',
        e,
        stackTrace,
      );
    }
  }

  static Future<void> _stopBackgroundSurface(
    Logger logger,
    AgentBackgroundPlatform platform,
  ) async {
    if (!platform.isSupported) return;

    try {
      await platform.stopStatus();
    } catch (e, stackTrace) {
      logger.warning(
        'Failed to stop Android agent background surface after drain',
        e,
        stackTrace,
      );
    }
  }

  static bool isDatabaseLockedForTesting(Object error) =>
      SqliteBusyRetry.isDatabaseLocked(error);

  static AgentBackgroundStatusLabels _statusLabels() {
    try {
      return AgentBackgroundStatusLabels.fromL10n(UserStorage.l10n);
    } catch (_) {
      return const AgentBackgroundStatusLabels();
    }
  }

  static AgentActivityService? _tryGetActivityService(Logger logger) {
    try {
      return AgentActivityService.instance;
    } catch (e, stackTrace) {
      logger.fine(
        'Skipping live Android agent background surface updates: '
        'agent activity service is unavailable',
        e,
        stackTrace,
      );
      return null;
    }
  }
}

class _LiveBackgroundSurfacePublisher {
  _LiveBackgroundSurfacePublisher({
    required this.logger,
    required this.platform,
    required this.labels,
  });

  final Logger logger;
  final AgentBackgroundPlatform platform;
  final AgentBackgroundStatusLabels labels;
  StreamSubscription<AgentActivityMessageModel>? _subscription;
  Future<void> _publishChain = Future<void>.value();

  AgentActivityMessageModel? latestMessage;

  Future<void> start(AgentActivityService activityService) async {
    if (!platform.isSupported) return;
    await _subscription?.cancel();
    _subscription = activityService.messageStream.listen(
      (message) {
        latestMessage = message;
        _publishChain =
            _publishChain.then((_) => _publish(message)).catchError((
          Object e,
          StackTrace stackTrace,
        ) {
          logger.warning(
            'Failed to refresh Android agent background surface from activity',
            e,
            stackTrace,
          );
        });
        unawaited(_publishChain);
      },
      onError: (Object e, StackTrace stackTrace) {
        logger.warning(
          'Agent activity stream failed in background',
          e,
          stackTrace,
        );
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _publishChain;
  }

  Future<void> _publish(AgentActivityMessageModel message) async {
    final foregroundSnapshot =
        await AgentForegroundTaskTracker.instance.getSnapshot();
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: foregroundSnapshot.taskSnapshot,
      latestMessage: message,
      foregroundSnapshot: foregroundSnapshot,
      labels: labels,
    );
    if (!status.shouldShowSystemSurface) return;

    if (status.state == AgentBackgroundRunState.failed) {
      await platform.finishStatus(status, isInBackground: true);
      return;
    }

    await platform.updateStatus(status, isInBackground: true);
  }
}
