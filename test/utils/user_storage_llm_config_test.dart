import 'package:flutter_test/flutter_test.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/model_role_config_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserStorage LLM defaults', () {
    test(
      'agents without explicit config use selected global default',
      () async {
        final defaultConfig = LLMConfig.createDefaultClientConfig();
        final customConfig = defaultConfig.copyWith(
          key: 'fast',
          modelId: 'gpt-fast',
        );

        await UserStorage.saveLLMConfigs([defaultConfig, customConfig]);
        expect(
          await UserStorage.getDefaultLLMConfigKey(),
          LLMConfig.defaultClientKey,
        );

        await UserStorage.setDefaultLLMConfigKey(customConfig.key);

        final resolved = await UserStorage.getAgentLLMConfig(
          AgentDefinitions.chatAgent,
          defaultClientKey: LLMConfig.defaultClientKey,
        );

        expect(await UserStorage.getDefaultLLMConfigKey(), customConfig.key);
        expect(resolved.key, customConfig.key);
        expect(resolved.modelId, customConfig.modelId);
      },
    );

    test(
      'removed selected default falls back to legacy default config',
      () async {
        final defaultConfig = LLMConfig.createDefaultClientConfig();
        final customConfig = defaultConfig.copyWith(key: 'custom');

        await UserStorage.saveLLMConfigs([defaultConfig, customConfig]);
        await UserStorage.setDefaultLLMConfigKey(customConfig.key);
        await UserStorage.saveLLMConfigs([defaultConfig]);

        expect(
          await UserStorage.getDefaultLLMConfigKey(),
          LLMConfig.defaultClientKey,
        );
      },
    );

    test('AgentConfig.copyWith can clear explicit model selection', () {
      const config = AgentConfig(llmConfigKey: 'custom');

      expect(config.copyWith(llmConfigKey: null).llmConfigKey, isNull);
    });

    test('DeepSeek builds an OpenAI-compatible chat client', () async {
      const config = LLMConfig(
        key: 'deepseek',
        type: LLMConfig.typeDeepSeek,
        modelId: 'deepseek-v4-flash',
        apiKey: 'sk-test',
        baseUrl: 'https://api.deepseek.com',
      );

      final resources = await UserStorage.buildLLMResources(config);

      expect(resources.client, isA<OpenAIClient>());
      expect(resources.modelConfig.model, 'deepseek-v4-flash');
    });

    test('Requesty builds an OpenAI-compatible chat client', () async {
      const config = LLMConfig(
        key: 'requesty',
        type: LLMConfig.typeRequesty,
        modelId: 'gpt-5.6-sol',
        apiKey: 'sk-test',
        baseUrl: 'https://router.requesty.ai/v1',
      );

      final resources = await UserStorage.buildLLMResources(config);

      expect(resources.client, isA<OpenAIClient>());
      expect(resources.modelConfig.model, 'gpt-5.6-sol');
    });

    test(
      'model role service maps text role to selected global default',
      () async {
        final defaultConfig = LLMConfig.createDefaultClientConfig();
        final textConfig = defaultConfig.copyWith(
          key: 'text-fast',
          modelId: 'text-model',
        );
        await UserStorage.saveLLMConfigs([defaultConfig, textConfig]);

        await ModelRoleConfigService.setTextModel(textConfig.key);

        final selection = await ModelRoleConfigService.loadSelection();
        expect(selection.textConfigKey, textConfig.key);
        expect(await UserStorage.getDefaultLLMConfigKey(), textConfig.key);
      },
    );
  });
}
