import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

abstract class AgentQueueDrainScheduler {
  Future<void> schedule({Duration? initialDelay, bool expedited});

  Future<void> cancel();
}

class WorkmanagerAgentQueueDrainScheduler implements AgentQueueDrainScheduler {
  static const String uniqueName = 'agent_queue_drain';
  static const String taskName = 'agentQueueDrainTask';
  static const String tag = 'agent_queue';

  @override
  Future<void> schedule({
    Duration? initialDelay,
    bool expedited = false,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Workmanager().registerProcessingTask(
        uniqueName,
        taskName,
        inputData: const {'source': 'agent_background_coordinator'},
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresCharging: false,
        ),
      );
      debugPrint(
        'Agent queue drain scheduled via iOS BGProcessingTask '
        '(delay: ${initialDelay?.inSeconds ?? 0}s)',
      );
      return;
    }

    await Workmanager().registerOneOffTask(
      uniqueName,
      taskName,
      inputData: const {'source': 'agent_background_coordinator'},
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      tag: tag,
      outOfQuotaPolicy:
          expedited ? OutOfQuotaPolicy.runAsNonExpeditedWorkRequest : null,
    );
    debugPrint(
      'Agent queue drain scheduled '
      '(delay: ${initialDelay?.inSeconds ?? 0}s, expedited: $expedited)',
    );
  }

  @override
  Future<void> cancel() => Workmanager().cancelByUniqueName(uniqueName);
}
