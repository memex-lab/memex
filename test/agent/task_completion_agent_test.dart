import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/task_completion_agent/task_completion_agent.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TaskCompletionAgent.markExistingScheduleTaskCompleted', () {
    test('marks an existing task card completed', () async {
      const userId = 'task_completion_card_user';
      const cardId = '2026/05/23.md#ts_1';
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_task_completion_card_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      SharedPreferences.setMockInitialValues({});
      await UserStorage.saveUser(userId);
      await FileSystemService.init(tempDir.path);
      await FileSystemService.instance.safeWriteCardFile(
        userId,
        cardId,
        const CardData(
          factId: cardId,
          timestamp: 1779494400,
          status: 'completed',
          tags: [],
          uiConfigs: [
            UiConfig(
              templateId: 'task',
              data: {'title': 'Prepare documents', 'is_completed': false},
            ),
          ],
        ),
      );

      final updated = await markExistingScheduleTaskCompleted(
        userId: userId,
        cardId: cardId,
      );

      expect(updated, isTrue);
      final data = await _readTaskData(userId, cardId);
      expect(data['is_completed'], isTrue);
    });

    test(
      'marks one existing subtask completed without completing the parent',
      () async {
        const userId = 'task_completion_subtask_user';
        const cardId = '2026/05/23.md#ts_2';
        final tempDir = await Directory.systemTemp.createTemp(
          'memex_task_completion_subtask_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        SharedPreferences.setMockInitialValues({});
        await UserStorage.saveUser(userId);
        await FileSystemService.init(tempDir.path);
        await FileSystemService.instance.safeWriteCardFile(
          userId,
          cardId,
          const CardData(
            factId: cardId,
            timestamp: 1779494400,
            status: 'completed',
            tags: [],
            uiConfigs: [
              UiConfig(
                templateId: 'task',
                data: {
                  'title': 'Visa checklist',
                  'is_completed': false,
                  'subtasks': [
                    {'title': 'Collect documents', 'completed': false},
                    {'title': 'Submit form', 'completed': false},
                  ],
                },
              ),
            ],
          ),
        );

        final updated = await markExistingScheduleTaskCompleted(
          userId: userId,
          cardId: cardId,
          subtaskTitle: 'Collect documents',
        );

        expect(updated, isTrue);
        final data = await _readTaskData(userId, cardId);
        expect(data['is_completed'], isFalse);
        expect(
          (data['subtasks'] as List).map(
            (subtask) => (subtask as Map)['completed'],
          ),
          [true, false],
        );
      },
    );
  });
}

Future<Map<String, dynamic>> _readTaskData(String userId, String cardId) async {
  final card = await FileSystemService.instance.readCardFile(userId, cardId);
  return card!.uiConfigs
      .singleWhere((config) => config.templateId == 'task')
      .data;
}
