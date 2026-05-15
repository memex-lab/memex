import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_handlers/schedule_dirty_on_card_update_handler.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('shouldMarkScheduleDirtyForCardUiConfigUpdate', () {
    test('marks task completion changes as schedule relevant', () {
      final payload = _payload(
        templateId: 'task',
        updates: const {'is_completed': true},
        previousData: const {'is_completed': false},
        updatedData: const {'is_completed': true},
      );

      expect(shouldMarkScheduleDirtyForCardUiConfigUpdate(payload), isTrue);
    });

    test('ignores unchanged task completion updates', () {
      final payload = _payload(
        templateId: 'task',
        updates: const {'is_completed': false},
        previousData: const {'is_completed': false},
        updatedData: const {'is_completed': false},
      );

      expect(shouldMarkScheduleDirtyForCardUiConfigUpdate(payload), isFalse);
    });

    test('ignores non-schedule template updates', () {
      final payload = _payload(
        templateId: 'progress',
        updates: const {'current': 5},
        previousData: const {'current': 4},
        updatedData: const {'current': 5},
      );

      expect(shouldMarkScheduleDirtyForCardUiConfigUpdate(payload), isFalse);
    });
  });

  group('handleScheduleDirtyOnCardUiConfigUpdated', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.saveUser('test_user');
      await UserStorage.setLocale(const Locale('en'));
      tempDir = await Directory.systemTemp.createTemp('memex_schedule_dirty_');
      await FileSystemService.init(tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('marks schedule refresh state dirty for task completion', () async {
      const userId = 'test_user';
      final payload = _payload(
        templateId: 'task',
        updates: const {'is_completed': true},
        previousData: const {'is_completed': false},
        updatedData: const {'is_completed': true},
      );

      await handleScheduleDirtyOnCardUiConfigUpdated(
        userId,
        SystemEvent<CardUiConfigUpdatedPayload>(
          type: SystemEventTypes.cardUiConfigUpdated,
          source: 'test',
          payload: payload,
        ),
      );

      final state = await ScheduleRefreshStateService.instance.read(userId);
      expect(state.isDirty, isTrue);
      expect(state.cardIds, contains(payload.cardId));
    });
  });
}

CardUiConfigUpdatedPayload _payload({
  required String templateId,
  required Map<String, dynamic> updates,
  required Map<String, dynamic> previousData,
  required Map<String, dynamic> updatedData,
}) {
  return CardUiConfigUpdatedPayload(
    cardId: '2026/04/28.md#ts_1',
    configIndex: 0,
    templateId: templateId,
    updates: updates,
    previousData: previousData,
    updatedData: updatedData,
  );
}
