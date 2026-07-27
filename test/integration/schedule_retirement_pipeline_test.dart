import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/super_agent/subagent/delegate_subagent_tool.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('retired schedule capability pipeline', () {
    final eventBus = EventBusService.instance;

    setUp(() async {
      eventBus.clearHandlers();
      await eventBus.connect();
    });

    tearDown(() {
      eventBus.clearHandlers();
    });

    test(
      'is unavailable to SuperAgent and blocked from every Timeline ingress',
      () async {
        final delegateTool = buildDelegateToSubagentTool();
        final properties = delegateTool.parameters['properties'] as Map;
        final agentType = properties['agent_type'] as Map;
        expect(agentType['enum'], isNot(contains('schedule')));

        final viewModel = TimelineViewModel.forTest(
          fetchTimelineCards: ({
            int page = 1,
            int limit = TimelineViewModel.pageLimit,
            List<String>? tags,
            DateTime? dateFrom,
            DateTime? dateTo,
          }) async {
            return Ok([
              _card(
                id: '_system/schedule_briefing',
                templateId: 'classic_card',
              ),
              _card(
                id: '2026/07/27.md#ts_1',
                templateId: 'classic_card',
              ),
            ]);
          },
        );
        addTearDown(viewModel.dispose);
        await viewModel.load.execute();
        viewModel.init();

        expect(
          viewModel.cards.map((card) => card.id),
          ['2026/07/27.md#ts_1'],
        );

        eventBus.emitEvent(
          CardAddedMessage(
            id: 'legacy-schedule-copy',
            html: '',
            timestamp: DateTime(2026, 7, 27).millisecondsSinceEpoch ~/ 1000,
            tags: const [],
            status: 'completed',
            uiConfigs: const [
              UiConfig(templateId: 'schedule_briefing', data: {}),
            ],
          ),
        );
        await pumpEventQueue();

        expect(
          viewModel.cards.map((card) => card.id),
          ['2026/07/27.md#ts_1'],
        );

        eventBus.emitEvent(
          CardUpdatedMessage(
            id: '2026/07/27.md#ts_1',
            html: '',
            timestamp: DateTime(2026, 7, 27).millisecondsSinceEpoch ~/ 1000,
            tags: const [],
            status: 'completed',
            uiConfigs: const [
              UiConfig(templateId: 'schedule_briefing', data: {}),
            ],
          ),
        );
        await pumpEventQueue();

        expect(viewModel.cards, isEmpty);
      },
    );
  });
}

TimelineCardModel _card({
  required String id,
  required String templateId,
}) {
  return TimelineCardModel(
    id: id,
    timestamp: DateTime(2026, 7, 27),
    tags: const [],
    status: 'completed',
    uiConfigs: [UiConfig(templateId: templateId, data: const {})],
  );
}
