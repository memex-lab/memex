import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_config.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/llm_config.dart';

void main() {
  group('AppConfig.availableProviders', () {
    test('includes DeepSeek in global flavor', () {
      AppFlavor.init('global');

      expect(AppConfig.availableProviders, contains(LLMConfig.typeDeepSeek));
    });

    test('includes Requesty in global flavor', () {
      AppFlavor.init('global');

      expect(AppConfig.availableProviders, contains(LLMConfig.typeRequesty));
    });

    test('excludes Memex proxy service from manual providers', () {
      AppFlavor.init('global');

      expect(
          AppConfig.availableProviders, isNot(contains(LLMConfig.typeMemex)));
      expect(AppConfig.enableMemexModelService, isTrue);
    });

    test('includes DeepSeek in CN flavor', () {
      AppFlavor.init('cn');

      expect(AppConfig.availableProviders, contains(LLMConfig.typeDeepSeek));
    });

    test('excludes Requesty from CN flavor like OpenRouter', () {
      AppFlavor.init('cn');

      expect(
        AppConfig.availableProviders,
        isNot(contains(LLMConfig.typeRequesty)),
      );
    });
  });
}
