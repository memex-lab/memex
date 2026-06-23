import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_templates.dart';
import 'package:memex/data/services/file_system_service.dart';

void main() {
  test('native metric validator wins when custom metadata reuses template_id',
      () {
    const customFields = [
      TimelineTemplateFieldMeta(
        name: 'custom_only',
        type: 'String',
        required: true,
        description: 'Custom-only field',
      ),
    ];

    expect(
      () => validateUiConfig(
        {
          'template_id': 'metric',
          'data': {
            'items': [
              {'title': 'Sleep', 'value': 6.5},
            ],
          },
        },
        customTemplateFields: const {'metric': customFields},
      ),
      returnsNormally,
    );
  });

  test('custom validator still applies to non-native template ids', () {
    const customFields = [
      TimelineTemplateFieldMeta(
        name: 'score',
        type: 'Number',
        required: true,
        description: 'Score',
      ),
    ];

    expect(
      () => validateUiConfig(
        {
          'template_id': 'my_custom_metric',
          'data': {'score': 42},
        },
        customTemplateFields: const {'my_custom_metric': customFields},
      ),
      returnsNormally,
    );

    expect(
      () => validateUiConfig(
        {
          'template_id': 'my_custom_metric',
          'data': {},
        },
        customTemplateFields: const {'my_custom_metric': customFields},
      ),
      throwsArgumentError,
    );
  });
}
