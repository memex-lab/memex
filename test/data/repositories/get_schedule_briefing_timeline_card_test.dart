import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_schedule_briefing_timeline_card.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
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

  test('builds a system schedule briefing card from latest aggregation',
      () async {
    await FileSystemService.instance.writeScheduleAggregation(
      userId,
      'schedule_agg_test',
      {
        'id': 'schedule_agg_test',
        'generated_at': '2026-04-28T10:00:00',
        'version': 1,
        'time_range': {
          'from': '2026-04-28',
          'to': '2026-05-05',
        },
        'hero_item': {
          'card_id': '2026/04/28.md#ts_1',
          'title': '收拾家里',
          'description': '明天早上十点前完成',
          'start_time': '2026-04-29T10:00:00',
        },
        'editorial_intro': '今天的重点是把家里恢复到舒服的状态。',
        'timeline': [
          {
            'day_label': 'Tomorrow',
            'day_date': '2026-04-29',
            'items': [
              {
                'card_id': '2026/04/28.md#ts_1',
                'title': '收拾家里',
                'type': 'task',
                'status': 'pending',
                'start_time': '2026-04-29T10:00:00',
              },
            ],
          },
        ],
        'completed': [
          {'card_id': '2026/04/27.md#ts_1', 'title': '倒垃圾'},
        ],
        'conflicts': [],
      },
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

  test('builds dirty briefing card even before first aggregation', () async {
    await ScheduleRefreshStateService.instance.markDirty(
      userId: userId,
      reason: '有新的日程相关内容',
      cardIds: const ['2026/04/28.md#ts_2'],
    );

    final card = await getScheduleBriefingTimelineCard();

    expect(card, isNotNull);
    final data = card!.uiConfigs.single.data;
    expect(data['is_dirty'], isTrue);
    expect(data['dirty_reason'], '有新的日程相关内容');
  });
}
