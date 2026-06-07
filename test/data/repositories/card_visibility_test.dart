import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/card_visibility.dart';
import 'package:memex/domain/models/card_model.dart';

void main() {
  test('hides Dynamic Surface maintenance system task cards', () {
    const card = CardData(
      factId: '2026/06/07.md#ts_1',
      timestamp: 1,
      status: 'completed',
      tags: ['surface-footprints'],
      uiConfigs: [
        UiConfig(
          templateId: 'system_task',
          data: {'agentName': 'surface-footprints'},
        ),
      ],
    );

    expect(shouldHideFromTimeline(card), isTrue);
  });

  test('does not hide normal custom agent system task cards', () {
    const card = CardData(
      factId: '2026/06/07.md#ts_2',
      timestamp: 1,
      status: 'completed',
      tags: ['research-agent'],
      uiConfigs: [
        UiConfig(
          templateId: 'system_task',
          data: {'agentName': 'research-agent'},
        ),
      ],
    );

    expect(shouldHideFromTimeline(card), isFalse);
  });
}
