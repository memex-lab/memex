import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_handlers/schedule_state_on_card_change_handler.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('handleScheduleStateOnCardChanged', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('memex_schedule_state_');
      await FileSystemService.init(tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('does not create schedule item from inserted temporal card', () async {
      const userId = 'test_user';
      final card = _taskCard(
        factId: '2026/05/26.md#ts_1',
        isCompleted: false,
      );

      await handleScheduleStateOnCardChanged(
        userId,
        SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'test',
          createdAt: DateTime.parse('2026-05-26T10:00:00'),
          payload: DataChangeRecord(
            op: DataChangeOp.insert,
            ns: DataChangeNs.card,
            documentKey: card.factId,
            after: card.toJson(),
          ),
        ),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.pending, isEmpty);
      expect(state.completed, isEmpty);
    });

    test('syncs task card completion to existing schedule todo', () async {
      const userId = 'test_user';
      const factId = '2026/05/26.md#ts_1';
      final before = _taskCard(factId: factId, isCompleted: false);
      final after = _taskCard(factId: factId, isCompleted: true);
      await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: 'Buy skincare',
        sourceFactId: factId,
        now: DateTime.parse('2026-05-26T10:00:00'),
      );

      await handleScheduleStateOnCardChanged(
        userId,
        SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'test',
          createdAt: DateTime.parse('2026-05-26T11:00:00'),
          payload: DataChangeRecord(
            op: DataChangeOp.update,
            ns: DataChangeNs.card,
            documentKey: factId,
            before: before.toJson(),
            after: after.toJson(),
          ),
        ),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.pending, isEmpty);
      expect(state.completed, hasLength(1));
      expect(state.completed.single.closedByFactId, factId);
      expect(state.completed.single.title, 'Buy skincare');
    });

    test('ignores non-card data changes', () async {
      const userId = 'test_user';

      await handleScheduleStateOnCardChanged(
        userId,
        SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'test',
          payload: DataChangeRecord(
            op: DataChangeOp.update,
            ns: DataChangeNs.pkmFile,
            documentKey: 'PKM/note.md',
            after: const {'title': 'note'},
          ),
        ),
      );

      final raw = await FileSystemService.instance.readScheduleStateRaw(userId);
      expect(raw, isNull);
    });
  });

  group('handleScheduleStateOnCardUiConfigUpdated', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('memex_schedule_state_');
      await FileSystemService.init(tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('reprojects the latest card data for relevant UI config changes',
        () async {
      const userId = 'test_user';
      const factId = '2026/05/26.md#ts_1';
      final pending = _taskCard(factId: factId, isCompleted: false);
      await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: SchedulePendingItem.kindTodo,
        title: 'Buy skincare',
        sourceFactId: factId,
        now: DateTime.parse('2026-05-26T10:00:00'),
      );

      final completed = _taskCard(factId: factId, isCompleted: true);
      await FileSystemService.instance.safeWriteCardFile(
        userId,
        factId,
        completed,
      );

      await handleScheduleStateOnCardUiConfigUpdated(
        userId,
        SystemEvent<CardUiConfigUpdatedPayload>(
          type: SystemEventTypes.cardUiConfigUpdated,
          source: 'test',
          createdAt: DateTime.parse('2026-05-26T11:00:00'),
          payload: CardUiConfigUpdatedPayload(
            cardId: factId,
            configIndex: 0,
            templateId: 'task',
            updates: const {'is_completed': true},
            previousData: pending.uiConfigs.single.data,
            updatedData: completed.uiConfigs.single.data,
          ),
        ),
      );

      final state = await ScheduleStateService.instance.read(userId);
      expect(state.pending, isEmpty);
      expect(state.completed, hasLength(1));
      expect(state.completed.single.title, 'Buy skincare');
      expect(state.completed.single.closedByFactId, factId);
    });
  });
}

CardData _taskCard({
  required String factId,
  required bool isCompleted,
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
        },
      ),
    ],
  );
}
