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

typedef EventSyncHandler<T> = Future<void> Function(
  String userId,
  SystemEvent<T> event,
);

typedef EventSyncDependencyBuilder<T> = Future<List<String>> Function(
  String userId,
  SystemEvent<T> event,
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

/// 同步订阅：publish 时直接 await 执行 handler，而非入队任务。
class EventSyncSubscription<T> {
  EventSyncSubscription({
    required this.subscriptionId,
    required this.handler,
    this.dependsOn = const [],
    this.dependenciesBuilder,
  });

  final String subscriptionId;
  final EventSyncHandler<T> handler;

  /// 静态依赖：依赖的其他同步订阅 ID，会在这些订阅执行完毕后再执行。
  final List<String> dependsOn;

  /// 动态依赖：运行时根据事件内容决定额外依赖哪些同步订阅 ID。
  final EventSyncDependencyBuilder<T>? dependenciesBuilder;

  /// 内部调用：类型擦除后通过 dynamic cast 执行 handler。
  Future<void> _invokeHandler(String userId, SystemEvent event) async {
    await handler(userId, event as SystemEvent<T>);
  }

  /// 内部调用：类型擦除后通过 dynamic cast 执行 dependenciesBuilder。
  Future<List<String>> _invokeDependenciesBuilder(
      String userId, SystemEvent event) async {
    if (dependenciesBuilder == null) return const [];
    return dependenciesBuilder!(userId, event as SystemEvent<T>);
  }
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
  final Map<String, List<EventSyncSubscription>> _syncSubscriptions = {};

  // ---- 异步任务订阅 ----

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

  // ---- 同步订阅 ----

  void subscribeSync<T>({
    required String eventType,
    required EventSyncSubscription<T> subscription,
  }) {
    final list = _syncSubscriptions.putIfAbsent(eventType, () => []);
    list.removeWhere((s) => s.subscriptionId == subscription.subscriptionId);
    list.add(subscription);
    _logger.info(
        'Registered sync subscription: $eventType -> ${subscription.subscriptionId}');
  }

  void unsubscribeSync({
    required String eventType,
    required String subscriptionId,
  }) {
    final list = _syncSubscriptions[eventType];
    if (list == null) return;
    list.removeWhere((s) => s.subscriptionId == subscriptionId);
  }

  Future<List<String>> publish<T>({
    required String userId,
    required SystemEvent<T> event,
    List<String>? baseDependencies,
  }) async {
    // 先执行同步订阅者（拓扑排序，支持依赖关系）
    final syncSubs = List<EventSyncSubscription>.from(
      _syncSubscriptions[event.type] ?? const [],
    );

    if (syncSubs.isNotEmpty) {
      final orderedSyncSubs =
          await _resolveSyncExecutionOrder(syncSubs, userId, event);
      for (final sub in orderedSyncSubs) {
        try {
          await sub._invokeHandler(userId, event);
        } catch (e, st) {
          _logger.severe(
              'Sync subscriber ${sub.subscriptionId} failed for event ${event.type}',
              e,
              st);
        }
      }
    }

    // 再处理异步任务订阅者
    final subscriptions = List<EventTaskSubscription>.from(
      _subscriptions[event.type] ?? const [],
    );

    if (subscriptions.isEmpty) {
      _logger.fine('No task subscribers for event ${event.type}');
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
        payload: payload,
        priority: subscription.priority,
        maxRetries: subscription.maxRetries,
        // Use a shared bizId for all tasks spawned by the same event.
        // Downstream handlers (e.g. card_agent / pkm_agent) read upstream task
        // results by bizId, so bizId must be stable across subscriptions.
        bizId: 'event:${event.type}:${event.eventId}',
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
      throw StateError('Circular dependencies detected in event subscriptions');
    }

    return orderedIds.map((id) => byId[id]!).toList();
  }

  Future<List<EventSyncSubscription>> _resolveSyncExecutionOrder(
      List<EventSyncSubscription> subscriptions,
      String userId,
      SystemEvent event) async {
    final byId = <String, EventSyncSubscription>{};
    for (final sub in subscriptions) {
      byId[sub.subscriptionId] = sub;
    }

    // 合并静态依赖和动态依赖
    final allDependencies = <String, List<String>>{};
    for (final sub in subscriptions) {
      final deps = <String>[...sub.dependsOn];
      deps.addAll(await sub._invokeDependenciesBuilder(userId, event));
      allDependencies[sub.subscriptionId] = deps;
    }

    final indegree = <String, int>{};
    final dependents = <String, Set<String>>{};
    for (final sub in subscriptions) {
      indegree.putIfAbsent(sub.subscriptionId, () => 0);
      for (final depId in allDependencies[sub.subscriptionId]!) {
        if (!byId.containsKey(depId)) {
          throw StateError(
            'Sync subscription ${sub.subscriptionId} depends on unknown subscription $depId',
          );
        }
        dependents.putIfAbsent(depId, () => <String>{});
        if (dependents[depId]!.add(sub.subscriptionId)) {
          indegree[sub.subscriptionId] =
              (indegree[sub.subscriptionId] ?? 0) + 1;
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
          'Circular dependencies detected in sync event subscriptions');
    }

    return orderedIds.map((id) => byId[id]!).toList();
  }
}
