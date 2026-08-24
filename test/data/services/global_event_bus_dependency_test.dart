import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/system_event.dart';

void main() {
  late AppDatabase db;
  late LocalTaskExecutor executor;
  late GlobalEventBus eventBus;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    executor = LocalTaskExecutor.forTesting(db: db);
    eventBus = GlobalEventBus.forTesting(executor);
  });

  tearDown(() async {
    await executor.stop();
    await db.close();
  });

  test('maps legacy EventBus dependencies to wait-for-completion barriers',
      () async {
    eventBus.subscribe(
      eventType: 'dependency-test',
      subscription: EventTaskSubscription(
        subscriptionId: 'source',
        taskType: 'source-task',
        payloadBuilder: (_, __) async => const {},
      ),
    );
    eventBus.subscribe(
      eventType: 'dependency-test',
      subscription: EventTaskSubscription(
        subscriptionId: 'legacy-waiter',
        taskType: 'legacy-waiter-task',
        dependsOn: const ['source'],
        dependenciesBuilder: (_, __) async => const ['dynamic-wait'],
        payloadBuilder: (_, __) async => const {},
      ),
    );
    eventBus.subscribe(
      eventType: 'dependency-test',
      subscription: EventTaskSubscription(
        subscriptionId: 'hard-dependent',
        taskType: 'hard-dependent-task',
        requiresSuccessOf: const ['source'],
        successDependenciesBuilder: (_, __) async => const ['dynamic-hard'],
        payloadBuilder: (_, __) async => const {},
      ),
    );

    await eventBus.publish(
      userId: 'user-a',
      event: SystemEvent<void>(
        type: 'dependency-test',
        payload: null,
        source: 'test',
        eventId: 'event-dependency-semantics',
      ),
      baseDependencies: const ['base-wait'],
    );

    final tasks = await db.select(db.tasks).get();
    final sourceTask = tasks.singleWhere((task) => task.type == 'source-task');
    final legacyWaiter =
        tasks.singleWhere((task) => task.type == 'legacy-waiter-task');
    final hardDependent =
        tasks.singleWhere((task) => task.type == 'hard-dependent-task');

    expect(
      _dependencyConditions(sourceTask.dependencies),
      {'base-wait': 'wait_for_completion'},
    );
    expect(
      _dependencyConditions(legacyWaiter.dependencies),
      {
        sourceTask.id: 'wait_for_completion',
        'dynamic-wait': 'wait_for_completion',
        'base-wait': 'wait_for_completion',
      },
    );
    expect(
      _dependencyConditions(hardDependent.dependencies),
      {
        sourceTask.id: 'requires_success',
        'dynamic-hard': 'requires_success',
        'base-wait': 'wait_for_completion',
      },
    );
  });
}

Map<String, String> _dependencyConditions(String? encoded) {
  final dependencies = jsonDecode(encoded!) as List<dynamic>;
  return {
    for (final dependency in dependencies.cast<Map<String, dynamic>>())
      dependency['task_id'] as String: dependency['condition'] as String,
  };
}
