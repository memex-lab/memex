import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('chat send errors use existing l10n strings', () {
    expect(chatErrorUserNotLoggedIn(), UserStorage.l10n.userIdNotFound);
    expect(chatErrorEmptyMessage(), UserStorage.l10n.unknownError);
    expect(
      chatErrorOperationFailed('timeout'),
      UserStorage.l10n.operationFailed('timeout'),
    );
    final missingModel = chatErrorOperationFailed(
      InvalidModelConfigException(
        'The LLM configuration for chat_agent is invalid.',
      ),
    );
    expect(missingModel, UserStorage.l10n.invalidModelConfigPlain);
    expect(missingModel, isNot(contains('chat_agent')));
    expect(missingModel, isNot(contains('InvalidModelConfigException')));

    final oauth = chatErrorOperationFailed(
      InvalidModelConfigException(
        'Gemini OAuth not authorized.',
        InvalidModelConfigReason.oauth,
      ),
    );
    expect(oauth, isNot(UserStorage.l10n.invalidModelConfigPlain));
    expect(oauth, contains('OAuth'));

    final emptyKey = chatErrorOperationFailed(
      InvalidModelConfigException(
        'LLM API Key is empty',
        InvalidModelConfigReason.emptyApiKey,
      ),
    );
    expect(emptyKey, isNot(UserStorage.l10n.invalidModelConfigPlain));
    expect(emptyKey, contains('API Key'));
  });

  test('an empty saved API key is not reported as AI turned off', () async {
    await EventBusService.instance.connect();
    InvalidModelConfigMessage? shown;
    void handler(EventBusMessage message) {
      if (message is InvalidModelConfigMessage) shown = message;
    }

    EventBusService.instance.addHandler(
      EventBusMessageType.invalidModelConfig,
      handler,
    );
    addTearDown(
      () => EventBusService.instance.removeHandler(
        EventBusMessageType.invalidModelConfig,
        handler,
      ),
    );

    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeChatCompletion,
        modelId: 'gpt-4o',
        apiKey: '',
        baseUrl: 'https://api.openai.com/v1',
      ),
    ]);
    await UserStorage.setDefaultLLMConfigKey(LLMConfig.defaultClientKey);

    final resolved = await UserStorage.getAgentLLMConfig(
      'chat_agent',
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    expect(resolved.apiKey, isEmpty);
    expect(resolved.isValid, isFalse);
    expect(
      resolved.configurationProblem,
      InvalidModelConfigReason.emptyApiKey,
    );
    InvalidModelConfigException? error;
    try {
      await UserStorage.getAgentLLMResources(
        'chat_agent',
        defaultClientKey: LLMConfig.defaultClientKey,
      );
    } on InvalidModelConfigException catch (caught) {
      error = caught;
    }
    await Future<void>.delayed(Duration.zero);

    expect(error?.reason, InvalidModelConfigReason.emptyApiKey);
    final chat = chatErrorOperationFailed(error!);
    expect(chat, isNot(UserStorage.l10n.invalidModelConfigPlain));
    expect(chat, UserStorage.l10n.operationFailed('LLM API Key is empty'));
    expect(chat, isNot(contains('chat_agent')));
    expect(shown?.reason, InvalidModelConfigReason.emptyApiKey);
    expect(shown?.detail, 'LLM API Key is empty');
    expect(
      chat,
      UserStorage.l10n.operationFailed(shown!.detail),
    );
  });

  test('a saved config with no model still says AI is off', () async {
    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeChatCompletion,
        modelId: '',
        apiKey: 'sk-test',
        baseUrl: 'https://api.openai.com/v1',
      ),
    ]);
    await UserStorage.setDefaultLLMConfigKey(LLMConfig.defaultClientKey);

    InvalidModelConfigException? error;
    try {
      await UserStorage.getAgentLLMResources(
        'chat_agent',
        defaultClientKey: LLMConfig.defaultClientKey,
      );
    } on InvalidModelConfigException catch (caught) {
      error = caught;
    }

    expect(error?.reason, InvalidModelConfigReason.notConfigured);
    expect(
      chatErrorOperationFailed(error!),
      UserStorage.l10n.invalidModelConfigPlain,
    );
  });
}
