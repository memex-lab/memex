import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/llm_config.dart';

void main() {
  group('LLMConfig.duplicate', () {
    const baseConfig = LLMConfig(
      key: 'my-config',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-5.4',
      apiKey: 'sk-test',
      baseUrl: 'https://api.openai.com/v1',
      proxyUrl: 'http://127.0.0.1:7890',
      extra: {'reasoning_effort': 'medium'},
      temperature: 0.7,
      maxTokens: 4096,
      topP: 0.9,
    );

    test('creates copy with "_copy" suffix when no conflict', () {
      final duplicated = baseConfig.duplicate(existingKeys: ['other-config']);

      expect(duplicated.key, 'my-config_copy');
      expect(duplicated.type, baseConfig.type);
      expect(duplicated.modelId, baseConfig.modelId);
      expect(duplicated.apiKey, baseConfig.apiKey);
      expect(duplicated.baseUrl, baseConfig.baseUrl);
      expect(duplicated.proxyUrl, baseConfig.proxyUrl);
      expect(duplicated.extra, baseConfig.extra);
      expect(duplicated.temperature, baseConfig.temperature);
      expect(duplicated.maxTokens, baseConfig.maxTokens);
      expect(duplicated.topP, baseConfig.topP);
    });

    test('appends _copy_2 when "_copy" already exists', () {
      final duplicated = baseConfig.duplicate(
        existingKeys: ['my-config_copy'],
      );
      expect(duplicated.key, 'my-config_copy_2');
    });

    test('increments counter until unique key is found', () {
      final duplicated = baseConfig.duplicate(
        existingKeys: [
          'my-config_copy',
          'my-config_copy_2',
          'my-config_copy_3',
        ],
      );
      expect(duplicated.key, 'my-config_copy_4');
    });

    test('does not modify the original config', () {
      final duplicated = baseConfig.duplicate(existingKeys: []);
      expect(baseConfig.key, 'my-config');
      expect(duplicated.key, isNot(baseConfig.key));
    });

    test('handles keys with special characters gracefully', () {
      const config = LLMConfig(
        key: 'config-v1.2_test',
        type: LLMConfig.typeKimi,
        modelId: 'kimi-k2.5',
        apiKey: 'key',
        baseUrl: 'https://api.moonshot.cn/v1',
      );
      final duplicated = config.duplicate(existingKeys: []);
      expect(duplicated.key, 'config-v1.2_test_copy');
    });
  });

  group('DeepSeek provider', () {
    test('uses official OpenAI-compatible API defaults', () {
      expect(LLMConfig.typeDeepSeek, 'deepseek');
      expect(LLMConfig.providerDisplayName(LLMConfig.typeDeepSeek), 'DeepSeek');
      expect(LLMConfig.displayName(LLMConfig.typeDeepSeek), 'DeepSeek');
      expect(
        LLMConfig.underlyingClientType(LLMConfig.typeDeepSeek),
        LLMConfig.typeChatCompletion,
      );
      expect(
        LLMConfig.defaultBaseUrl(LLMConfig.typeDeepSeek),
        'https://api.deepseek.com',
      );
      expect(LLMConfig.supportsModelListing(LLMConfig.typeDeepSeek), isTrue);
      expect(
        LLMConfig.modelsEndpoint(
          LLMConfig.typeDeepSeek,
          'https://api.deepseek.com',
        ),
        'https://api.deepseek.com/models',
      );
    });

    test('recommends current official model IDs', () {
      expect(LLMConfig.recommendedModels(LLMConfig.typeDeepSeek), [
        'deepseek-v4-flash',
        'deepseek-v4-pro',
      ]);
      expect(LLMConfig.featuredModels(LLMConfig.typeDeepSeek), {
        'deepseek-v4-flash',
        'deepseek-v4-pro',
      });
    });

    test('requires an API key and base URL', () {
      const validConfig = LLMConfig(
        key: 'deepseek',
        type: LLMConfig.typeDeepSeek,
        modelId: 'deepseek-v4-flash',
        apiKey: 'sk-test',
        baseUrl: 'https://api.deepseek.com',
      );

      expect(validConfig.isValid, isTrue);
      expect(validConfig.copyWith(apiKey: '').isValid, isFalse);
      expect(validConfig.copyWith(baseUrl: '').isValid, isFalse);
    });
  });
}
