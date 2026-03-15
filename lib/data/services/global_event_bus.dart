import 'package:logging/logging.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';

typedef EventTaskPayloadBuilder = Future<Map<String, dynamic>> Function(
  String userId,
  SystemEvent event,
);

typedef EventTaskDependencyBuilder = Future<List<String>> Function(
  String userId,
  SystemEvent event,
);

class EventTaskSubscription {
  EventTaskSubscription({
    required this.subscriptionId,
    required this.taskType,
    required this.payloadBuilder,
    this.dependsOn = const [],
    this.priority = 0,
    this.maxRetries = 10,
    this.dependenciesBuilder,
  });

  final String subscriptionId;
  final String taskType;
  final List<String> dependsOn;
  final int priority;
  final int maxRetries;
  final EventTaskPayloadBuilder payloadBuilder;
  final EventTaskDependencyBuilder? dependenciesBuilder;
}

class GlobalEventBus {
  GlobalEventBus._();

  static GlobalEventBus? _instance;
  static GlobalEventBus get instance {
    _instance ??= GlobalEventBus._();
    return _instance!;
  }

  final Logger _logger = getLogger('GlobalEventBus');
  final LocalTaskExecutor _taskExecutor = LocalTaskExecutor.instance;
  final Map<String, List<EventTaskSubscription>> _subscriptions = {};

  void subscribe({
    required String eventType,
    required EventTaskSubscription subscription,
  }) {
    final list = _subscriptions.putIfAbsent(eventType, () => []);
    list.removeWhere((s) => s.subscriptionId == subscription.subscriptionId);
    list.add(subscription);
    _logger.info(
        'Registered event subscription: $eventType -> ${subscription.taskType} (${subscription.subscriptionId})');
  }

  void unsubscribe({
    required String eventType,
    required String subscriptionId,
  }) {
    final list = _subscriptions[eventType];
    if (list == null) return;
    list.removeWhere((s) => s.subscriptionId == subscriptionId);
  }

  Future<List<String>> publish({
    required String userId,
    required SystemEvent event,
    List<String>? baseDependencies,
  }) async {
    final subscriptions = List<EventTaskSubscription>.from(
      _subscriptions[event.type] ?? const [],
    );

    if (subscriptions.isEmpty) {
      _logger.fine('No subscribers for event ${event.type}');
      return const [];
    }

    final orderedSubscriptions = _resolveExecutionOrder(subscriptions);
    final enqueuedTaskIds = <String>[];
    final enqueuedTaskIdsBySubscription = <String, String>{};

    for (final subscription in orderedSubscriptions) {
      final payload = await subscription.payloadBuilder(userId, event);
      final dependencies = <String>[
        ...(baseDependencies ?? const []),
        ...subscription.dependsOn
            .map((id) => enqueuedTaskIdsBySubscription[id])
            .whereType<String>(),
      ];

      if (subscription.dependenciesBuilder != null) {
        dependencies
            .addAll(await subscription.dependenciesBuilder!(userId, event));
      }

      final taskId = await _taskExecutor.enqueueTask(
        userId: userId,
        taskType: subscription.taskType,
        payload: {
          ...payload,
          ...event.toMap(),
        },
        priority: subscription.priority,
        maxRetries: subscription.maxRetries,
        bizId: 'event:${event.type}:${event.eventId}:${subscription.subscriptionId}',
        dependencies: dependencies.isEmpty ? null : dependencies,
      );

      enqueuedTaskIds.add(taskId);
      enqueuedTaskIdsBySubscription[subscription.subscriptionId] = taskId;
    }

    _logger.info(
        'Published event ${event.type}, enqueued ${enqueuedTaskIds.length} tasks');
    return enqueuedTaskIds;
  }

  List<EventTaskSubscription> _resolveExecutionOrder(
      List<EventTaskSubscription> subscriptions) {
    final byId = <String, EventTaskSubscription>{};
    for (final subscription in subscriptions) {
      byId[subscription.subscriptionId] = subscription;
    }

    final indegree = <String, int>{};
    final dependents = <String, Set<String>>{};
    for (final subscription in subscriptions) {
      indegree.putIfAbsent(subscription.subscriptionId, () => 0);
      for (final depId in subscription.dependsOn) {
        if (!byId.containsKey(depId)) {
          throw StateError(
            'Subscription ${subscription.subscriptionId} depends on unknown subscription $depId',
          );
        }
        dependents.putIfAbsent(depId, () => <String>{});
        if (dependents[depId]!.add(subscription.subscriptionId)) {
          indegree[subscription.subscriptionId] =
              (indegree[subscription.subscriptionId] ?? 0) + 1;
        }
      }
    }

    final queue = indegree.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();

    final orderedIds = <String>[];
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      orderedIds.add(id);
      final nextIds = (dependents[id] ?? const <String>{}).toList()..sort();
      for (final nextId in nextIds) {
        indegree[nextId] = (indegree[nextId] ?? 0) - 1;
        if (indegree[nextId] == 0) {
          queue.add(nextId);
          queue.sort();
        }
      }
    }

    if (orderedIds.length != subscriptions.length) {
      throw StateError(
          'Circular dependencies detected in event subscriptions');
    }

    return orderedIds.map((id) => byId[id]!).toList();
  }
}
