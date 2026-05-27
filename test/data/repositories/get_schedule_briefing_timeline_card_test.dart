import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_schedule_briefing_timeline_card.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'test_user';
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(userId);
    tempDir = await Directory.systemTemp.createTemp('memex_schedule_card_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns null when there is no aggregation and schedule is clean',
      () async {
    final card = await getScheduleBriefingTimelineCard();

    expect(card, isNull);
  });

  test('builds a system schedule briefing card from schedule_state', () async {
    await ScheduleStateService.instance.write(
      userId,
      ScheduleState(
        generatedAt: DateTime.parse('2026-04-28T10:00:00'),
        pending: [
          SchedulePendingItem(
            id: 'pi_2026/04/28.md#ts_1',
            kind: SchedulePendingItem.kindTodo,
            title: '收拾家里',
            description: '明天早上十点前完成',
            dueAt: DateTime.parse('2026-04-29T10:00:00'),
            sourceFactIds: const ['2026/04/28.md#ts_1'],
          ),
        ],
        completed: [
          ScheduleCompletedItem(
            id: 'pi_2026/04/27.md#ts_1',
            kind: SchedulePendingItem.kindTodo,
            title: '倒垃圾',
            closedAt: DateTime.parse('2026-04-27T10:00:00'),
            sourceFactIds: const ['2026/04/27.md#ts_1'],
          ),
        ],
        presentation: const SchedulePresentation(
          hero: SchedulePresentationHero(
            itemId: 'pi_2026/04/28.md#ts_1',
            title: '收拾家里',
            description: '明天早上十点前完成',
          ),
          editorialIntro: '今天的重点是把家里恢复到舒服的状态。',
          timeline: [
            ScheduleTimelineDay(
              dayLabel: 'Tomorrow',
              dayDate: '2026-04-29',
              itemIds: ['pi_2026/04/28.md#ts_1'],
            ),
          ],
        ),
      ),
    );

    final card = await getScheduleBriefingTimelineCard();

    expect(card, isNotNull);
    expect(card!.id, scheduleBriefingCardId);
    expect(card.uiConfigs.single.templateId, scheduleBriefingTemplateId);
    final data = card.uiConfigs.single.data;
    expect(data['hero_title'], '收拾家里');
    expect(data['summary'], contains('家里'));
    expect(data['completed_count'], 1);
    expect(data['items'], hasLength(1));
  });
}
