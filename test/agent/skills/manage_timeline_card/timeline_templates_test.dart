import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/card_agent/rule_based_card_matcher.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_templates.dart';
import 'package:memex/domain/models/card_model.dart';

void main() {
  group('timeline template validation', () {
    test('accepts valid digest config', () {
      expect(
        () => validateUiConfig({
          'template_id': 'digest',
          'data': {
            'summary': 'Mixed project note with mood, schedule, and todos.',
            'sections': [
              {
                'type': 'project',
                'title': 'Project',
                'items': ['Discussed launch risk with the team'],
              },
              {
                'type': 'todo',
                'title': 'Todos',
                'items': ['Revise the PRD tonight'],
              },
            ],
          },
        }),
        returnsNormally,
      );
    });

    test('rejects digest without sections', () {
      expect(
        () => validateUiConfig({
          'template_id': 'digest',
          'data': {'summary': 'A mixed note.', 'sections': []},
        }),
        throwsArgumentError,
      );
    });
  });

  group('rule-based card matcher', () {
    test('uses digest for long mixed text when LLM is unavailable', () {
      const card = CardData(
        factId: '2026/05/05.md#ts_1',
        timestamp: 0,
        status: 'processing',
        tags: [],
        uiConfigs: [],
      );

      final result = applyRuleBasedTemplate(
        card: card,
        combinedText: '''
Project: discussed the PRD delay and launch risk with Alex.
Mood: I feel anxious because the review may be unfocused.
Schedule: set up a product review next Wednesday at 14:00.
Todo: revise the PRD tonight and add one risk slide.
Idea: maybe split the launch into a smaller first milestone.
''',
        imageUrls: const [],
        audioUrl: null,
      );

      expect(result.uiConfigs.single.templateId, 'digest');
      expect(result.uiConfigs.single.data['sections'], isNotEmpty);
    });
  });
}
