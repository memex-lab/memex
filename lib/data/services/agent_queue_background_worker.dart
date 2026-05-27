import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/file_logger_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

class AgentQueueBackgroundWorker {
  static const Duration _maxRunDuration = Duration(seconds: 25);
  static const Duration _defaultRetryDelay = Duration(minutes: 15);

  static bool isAgentQueueDrainTask(String taskName) {
    return taskName == WorkmanagerAgentQueueDrainScheduler.taskName ||
        taskName == WorkmanagerAgentQueueDrainScheduler.uniqueName;
  }

  static Future<bool> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupLogger();
    final logger = getLogger('AgentQueueBackgroundWorker');

    try {
      await UserStorage.initL10n();
      final userId = await UserStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        logger.info('Skipping agent queue drain: no active user.');
        return true;
      }

      await MemexRouter.ensureInitializedForBackgroundTask();
      final result = await LocalTaskExecutor.instance.drainAvailableTasks(
        userId: userId,
        maxDuration: _maxRunDuration,
      );

      if (result.snapshot.hasActiveTasks) {
        await WorkmanagerAgentQueueDrainScheduler().schedule(
          initialDelay: result.nextRunnableDelay ?? _defaultRetryDelay,
          expedited: false,
        );
      }

      logger.info(
        'Agent queue drain finished. '
        'active=${result.snapshot.total}, timedOut=${result.timedOut}',
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
}
