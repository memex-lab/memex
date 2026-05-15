import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/schedule_refresh_router_agent/schedule_refresh_router_agent.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScheduleRefreshRouterAgent helpers', () {
    test('detects temporal card templates as schedule relevant', () {
      const card = CardData(
        factId: '2026/04/26.md#ts_1',
        timestamp: 1777188000,
        status: 'completed',
        tags: [],
        uiConfigs: [
          UiConfig(
            templateId: 'task',
            data: {'due_date': '2026-04-27T10:00:00'},
          ),
        ],
      );

      expect(hasScheduleRelevantTemplates(card), isTrue);
    });

    test('ignores non temporal card templates', () {
      const card = CardData(
        factId: '2026/04/26.md#ts_2',
        timestamp: 1777188000,
        status: 'completed',
        tags: [],
        uiConfigs: [
          UiConfig(
            templateId: 'classic_card',
            data: {'content': '普通记录'},
          ),
        ],
      );

      expect(hasScheduleRelevantTemplates(card), isFalse);
    });

    test('router context contains raw input and structured card data', () {
      const card = CardData(
        factId: '2026/04/26.md#ts_3',
        timestamp: 1777188000,
        status: 'completed',
        title: '明早收拾家里',
        tags: ['home'],
        uiConfigs: [
          UiConfig(
            templateId: 'task',
            data: {
              'title': '收拾家里',
              'due_date': '2026-04-27T10:00:00',
            },
          ),
        ],
      );

      final context = buildScheduleRefreshRouterContext(
        factId: card.factId,
        combinedText: '提醒我明天早上十点收拾家里',
        cardData: card,
        recentScheduleContext: const {'count': 0, 'cards': []},
        refreshState: const {'is_dirty': false},
      );

      expect(context['new_input']['combined_text'], contains('收拾家里'));
      expect(context['new_card']['title'], '明早收拾家里');
      expect(context['new_card']['ui_configs'].single['template_id'], 'task');
      expect(context['recent_schedule_context']['count'], 0);
    });

    test('overrides skipped LLM decisions for temporal routine cards',
        () async {
      const userId = 'router_test_user';
      final tempDir =
          await Directory.systemTemp.createTemp('memex_router_guard_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      SharedPreferences.setMockInitialValues({});
      await UserStorage.saveUser(userId);
      await UserStorage.setLocale(const Locale('en'));
      await FileSystemService.init(tempDir.path);

      const card = CardData(
        factId: '2026/05/14.md#ts_4',
        timestamp: 1778753606,
        status: 'completed',
        title: 'Water plants',
        tags: ['routine'],
        uiConfigs: [
          UiConfig(
            templateId: 'routine',
            data: {
              'title': 'Water plants',
              'next_due_date': '2026-05-18T20:00:00',
            },
          ),
        ],
      );

      final decision = await ensureScheduleRelevantDecision(
        userId: userId,
        factId: card.factId,
        cardData: card,
        decision: const ScheduleRefreshRouteResult(
          action: ScheduleRefreshRouteAction.skipped,
          reason: 'LLM thought this routine had no schedule impact.',
        ),
      );

      expect(decision.action, ScheduleRefreshRouteAction.markedDirty);
      final state = await ScheduleRefreshStateService.instance.read(userId);
      expect(state.isDirty, isTrue);
      expect(state.cardIds, contains(card.factId));
    });
  });
}
