import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_handlers/schedule_state_on_card_change_handler.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScheduleStateService mutations', () {
    late Directory tempDir;
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('memex_schedule_state_');
      await FileSystemService.init(tempDir.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
        'completePendingItem moves item to completed and writes back task card',
        () async {
      const userId = 'test_user';
      const factId = '2026/05/26.md#ts_1';
      final card = _taskCard(factId: factId, isCompleted: false);
      await FileSystemService.instance.safeWriteCardFile(userId, factId, card);

      await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: 'Buy skincare',
        sourceFactId: factId,
        dueAt: DateTime.parse('2020-05-27T09:00:00'),
        now: DateTime.parse('2026-05-26T10:00:00'),
      );
      final pending = await ScheduleStateService.instance.read(userId);
      GlobalEventBus.instance.subscribeSync<DataChangeRecord>(
        eventType: SystemEventTypes.dataChanged,
        subscription: EventSyncSubscription<DataChangeRecord>(
          subscriptionId: 'schedule_state_service_test_completion_sync',
          handler: handleScheduleStateOnCardChanged,
        ),
      );
      addTearDown(() {
        GlobalEventBus.instance.unsubscribeSync(
          eventType: SystemEventTypes.dataChanged,
          subscriptionId: 'schedule_state_service_test_completion_sync',
        );
      });

      await ScheduleStateService.instance.completePendingItem(
        userId: userId,
        pendingId: pending.pending.single.id,
        closedByFactId: '2026/05/26.md#ts_2',
        closedAt: DateTime.parse('2026-05-26T11:00:00'),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.pending, isEmpty);
      expect(state.completed, hasLength(1));
      expect(state.completed.single.closedByFactId, '2026/05/26.md#ts_2');

      final updatedCard =
          await FileSystemService.instance.readCardFile(userId, factId);
      expect(updatedCard!.uiConfigs.single.data['is_completed'], isTrue);
    });

    test('setSubtaskCompletion persists state without touching task card',
        () async {
      const userId = 'test_user';
      const factId = '2026/05/26.md#ts_1';
      await FileSystemService.instance.safeWriteCardFile(
        userId,
        factId,
        _taskCard(
          factId: factId,
          isCompleted: false,
          subtasks: const [
            {'title': '整理今日工作进展要点', 'completed': false},
            {'title': '撰写日报内容', 'completed': false},
            {'title': '发送给主管', 'completed': false},
          ],
        ),
      );

      final initial = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: '下午 6 点提交日报给主管',
        sourceFactId: factId,
        dueAt: DateTime.parse('2026-05-27T18:00:00'),
        subtasks: const [
          ScheduleSubtask(title: '整理今日工作进展要点'),
          ScheduleSubtask(title: '撰写日报内容'),
          ScheduleSubtask(title: '发送给主管'),
        ],
        now: DateTime.parse('2026-05-27T16:00:00'),
      );

      await ScheduleStateService.instance.setSubtaskCompletion(
        userId: userId,
        pendingId: initial.pending.single.id,
        subtaskTitle: '整理今日工作进展要点',
        completed: true,
        changedAt: DateTime.parse('2026-05-27T16:10:00'),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.pending.single.subtasks.first.completed, isTrue);
      expect(state.pending.single.subtasks.first.closedByFactId, isNull);

      final updatedCard =
          await FileSystemService.instance.readCardFile(userId, factId);
      final rawSubtasks =
          updatedCard!.uiConfigs.single.data['subtasks'] as List<dynamic>;
      expect(rawSubtasks.first as Map, containsPair('completed', false));
      expect(updatedCard.uiConfigs.single.data['is_completed'], isFalse);
    });

    test('setPresentation and searchCompleted persist canonical state',
        () async {
      const userId = 'test_user';
      await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: 'Write launch plan',
        sourceFactId: '2026/05/26.md#ts_1',
        now: DateTime.parse('2026-05-26T10:00:00'),
      );
      final pending = await ScheduleStateService.instance.read(userId);
      await ScheduleStateService.instance.completePendingItem(
        userId: userId,
        pendingId: pending.pending.single.id,
        closedByFactId: '2026/05/26.md#ts_2',
        closedAt: DateTime.parse('2026-05-26T11:00:00'),
      );

      await ScheduleStateService.instance.setPresentation(
        userId: userId,
        presentation: const SchedulePresentation(
          editorialIntro: 'Clear morning, one completed planning task.',
          timeline: [
            ScheduleTimelineDay(dayLabel: 'Today', dayDate: '2026-05-26'),
          ],
        ),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.presentation!.editorialIntro, contains('Clear morning'));

      final matches = await ScheduleStateService.instance.searchCompleted(
        userId: userId,
        query: 'launch',
      );
      expect(matches, hasLength(1));
      expect(matches.single.title, 'Write launch plan');
    });

    test('ensureInitialized creates empty canonical schedule state', () async {
      const userId = 'test_user';

      final state = await ScheduleStateService.instance.ensureInitialized(
        userId,
        now: DateTime.parse('2026-05-26T09:00:00'),
      );

      expect(state.pending, isEmpty);
      expect(state.completed, isEmpty);
      expect(state.presentation, isNull);
    });

    test('addPendingItem does not create device action by default', () async {
      const userId = 'test_user';

      final state = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: 'Submit visa documents',
        sourceFactId: '2026/05/26.md#ts_1',
        dueAt: DateTime.parse('2099-05-27T09:00:00'),
        now: DateTime.parse('2026-05-26T10:00:00'),
      );

      expect(state.pending.single.syncDeviceAction, isFalse);
      expect(state.pending.single.deviceActionId, isNull);
      final actions = await db.select(db.systemActions).get();
      expect(actions, isEmpty);
    });

    test('syncDeviceAction controls device action creation and cancellation',
        () async {
      const userId = 'test_user';

      final state = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindEvent,
        title: 'Dentist appointment',
        sourceFactId: '2026/05/26.md#ts_1',
        startTime: DateTime.parse('2099-05-27T09:00:00'),
        now: DateTime.parse('2026-05-26T10:00:00'),
        syncDeviceAction: true,
      );

      expect(state.pending.single.syncDeviceAction, isTrue);
      expect(state.pending.single.deviceActionId, isNotNull);
      var actions = await db.select(db.systemActions).get();
      expect(actions, hasLength(1));
      expect(actions.single.actionType, 'calendar');

      final updated = await ScheduleStateService.instance.updatePendingItem(
        userId: userId,
        pendingId: state.pending.single.id,
        syncDeviceAction: false,
        now: DateTime.parse('2026-05-26T10:05:00'),
      );

      expect(updated.pending.single.syncDeviceAction, isFalse);
      expect(updated.pending.single.deviceActionId, isNull);
      actions = await db.select(db.systemActions).get();
      expect(actions, isEmpty);
    });

    test('disabling sync preserves completed device action history', () async {
      const userId = 'test_user';

      final state = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindEvent,
        title: 'Dentist appointment',
        sourceFactId: '2026/05/26.md#ts_1',
        startTime: DateTime.parse('2099-05-27T09:00:00'),
        now: DateTime.parse('2026-05-26T10:00:00'),
        syncDeviceAction: true,
      );
      final actionId = state.pending.single.deviceActionId!;
      await db.update(db.systemActions).write(
            const SystemActionsCompanion(status: Value('completed')),
          );

      final updated = await ScheduleStateService.instance.updatePendingItem(
        userId: userId,
        pendingId: state.pending.single.id,
        syncDeviceAction: false,
        now: DateTime.parse('2026-05-26T10:05:00'),
      );

      expect(updated.pending.single.syncDeviceAction, isFalse);
      expect(updated.pending.single.deviceActionId, isNull);
      final actions = await db.select(db.systemActions).get();
      expect(actions, hasLength(1));
      expect(actions.single.id, actionId);
      expect(actions.single.status, 'completed');
    });

    test('completed synced actions are not replaced on item update', () async {
      const userId = 'test_user';

      final state = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindEvent,
        title: 'Dentist appointment',
        sourceFactId: '2026/05/26.md#ts_1',
        startTime: DateTime.parse('2099-05-27T09:00:00'),
        now: DateTime.parse('2026-05-26T10:00:00'),
        syncDeviceAction: true,
      );
      final actionId = state.pending.single.deviceActionId!;
      await db.update(db.systemActions).write(
            const SystemActionsCompanion(status: Value('completed')),
          );

      final updated = await ScheduleStateService.instance.updatePendingItem(
        userId: userId,
        pendingId: state.pending.single.id,
        title: 'Dentist appointment updated',
        now: DateTime.parse('2026-05-26T10:05:00'),
      );

      expect(updated.pending.single.deviceActionId, actionId);
      final actions = await db.select(db.systemActions).get();
      expect(actions, hasLength(1));
      expect(actions.single.id, actionId);
      expect(actions.single.status, 'completed');
    });

    test('cards and aggregation are not imported after initialization',
        () async {
      const userId = 'test_user';
      const secondTaskId = '2026/05/27.md#ts_1';

      final first = await ScheduleStateService.instance.ensureInitialized(
        userId,
        now: DateTime.parse('2026-05-26T09:00:00'),
      );
      expect(first.pending, isEmpty);
      expect(first.presentation, isNull);

      await FileSystemService.instance.safeWriteCardFile(
        userId,
        secondTaskId,
        _taskCard(factId: secondTaskId, isCompleted: false),
      );

      final second = await ScheduleStateService.instance.ensureInitialized(
        userId,
        now: DateTime.parse('2026-05-27T09:00:00'),
      );

      expect(second.pending, isEmpty);
      expect(second.presentation, isNull);

      final rebuilt = await ScheduleStateService.instance.rebuildFromCards(
        userId,
        now: DateTime.parse('2026-05-28T09:00:00'),
      );
      expect(rebuilt.pending, isEmpty);
      expect(rebuilt.presentation, isNull);
    });
  });
}

CardData _taskCard({
  required String factId,
  required bool isCompleted,
  List<Map<String, dynamic>> subtasks = const [],
}) {
  return CardData(
    factId: factId,
    timestamp: 1779789600,
    status: 'ready',
    tags: const [],
    title: 'Buy skincare',
    uiConfigs: [
      UiConfig(
        templateId: 'task',
        data: {
          'title': 'Buy skincare',
          'due_date': '2026-05-27T09:00:00',
          'is_completed': isCompleted,
          if (subtasks.isNotEmpty) 'subtasks': subtasks,
        },
      ),
    ],
  );
}
