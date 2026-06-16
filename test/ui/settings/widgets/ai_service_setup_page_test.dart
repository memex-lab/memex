import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/settings_registry.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/ui/settings/view_models/ai_service_setup_viewmodel.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/model_config_edit_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    AppFlavor.init('global');
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    await UserStorage.initL10n();
  });

  testWidgets('hub renders connection choices without custom model controls', (
    tester,
  ) async {
    await _pumpPage(tester, const AiServiceSetupPage());

    expect(find.text(UserStorage.l10n.aiModelHubTitle), findsWidgets);
    expect(
        find.text(UserStorage.l10n.aiSetupCurrentStatusTitle), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.aiSetupStatusNotConfiguredTitle),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.aiSetupChooseConnectionTitle),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ai-service-official-route-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ai-service-custom-route-card')),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.modelRolesTitle), findsNothing);
    expect(find.text(UserStorage.l10n.textModelRoleTitle), findsNothing);
    expect(find.text(UserStorage.l10n.visionModelRoleTitle), findsNothing);
    expect(
      find.byKey(const ValueKey('ai-service-speech-local-switch')),
      findsNothing,
    );
    expect(find.text(UserStorage.l10n.memexUsername), findsNothing);
  });

  testWidgets('settings registry model config entry opens AI model hub', (
    tester,
  ) async {
    final item = SettingsRegistry.allItems.firstWhere(
      (item) => item.id == 'model_config',
    );
    late Widget targetPage;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            targetPage = item.navigationTarget.pageBuilder(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(item.title, UserStorage.l10n.aiModelHubTitle);
    expect(item.description, UserStorage.l10n.aiModelHubSubtitle);
    expect(targetPage, isA<AiServiceSetupPage>());
  });

  testWidgets('official route opens the existing Memex auth flow', (
    tester,
  ) async {
    await _pumpPage(tester, const AiServiceSetupPage());

    await _tapByKey(tester, const ValueKey('ai-service-official-route-card'));

    expect(find.byType(MemexOfficialServicePage), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiServiceMemexRouteTitle), findsWidgets);
    expect(find.text(UserStorage.l10n.modelRolesTitle), findsNothing);

    await tester.tap(find.text(UserStorage.l10n.enableAiService));
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.memexUsername), findsOneWidget);
    expect(find.text(UserStorage.l10n.memexPassword), findsOneWidget);
  });

  testWidgets('official service page still saves Memex credentials', (
    tester,
  ) async {
    var completed = false;
    final viewModel = AiServiceSetupViewModel(
      router: MemexRouter(),
      appConfigFetcher: ({required String locale}) async => null,
    );
    addTearDown(viewModel.dispose);
    await viewModel.showMemexServiceSetup();
    viewModel.setMemexCredentials(
      'https://memex.example/v1',
      'memex-key',
      const ['memex-fast'],
    );

    await _pumpPage(
      tester,
      MemexOfficialServicePage(
        viewModel: viewModel,
        onComplete: () => completed = true,
      ),
    );

    await tester.tap(find.text(UserStorage.l10n.setupModelConfigComplete));
    await tester.pumpAndSettle();

    final configs = await UserStorage.getLLMConfigs();
    final memexConfig = configs.firstWhere(
      (config) => config.key == LLMConfig.defaultClientKey,
    );
    expect(completed, isTrue);
    expect(memexConfig.type, LLMConfig.typeMemex);
    expect(memexConfig.modelId, 'memex-fast');
    expect(memexConfig.apiKey, 'memex-key');
    expect(memexConfig.baseUrl, 'https://memex.example/v1');
  });

  testWidgets('custom route groups provider roles capabilities and advanced', (
    tester,
  ) async {
    await _pumpCustomPage(tester);

    expect(find.byType(CustomAiServiceSetupPage), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiSetupProviderCredentialsTitle),
        findsOneWidget);
    expect(find.text(UserStorage.l10n.modelRolesTitle), findsOneWidget);
    expect(find.text(UserStorage.l10n.textModelRoleTitle), findsOneWidget);
    expect(find.text(UserStorage.l10n.visionModelRoleTitle), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiSetupServiceCapabilitiesTitle),
        findsOneWidget);
    expect(
        find.text(UserStorage.l10n.locationProviderSettings), findsOneWidget);
    expect(find.text(UserStorage.l10n.speechProviderSettings), findsOneWidget);
    await _scrollUntilVisible(
      tester,
      find.text(UserStorage.l10n.aiSetupAdvancedCustomizationTitle),
    );
    expect(
      find.text(UserStorage.l10n.aiSetupAdvancedCustomizationTitle),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.advancedAgentModelAssignments),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.aiServiceMemexRouteTitle), findsNothing);
  });

  testWidgets('model role selectors update default and media agent model', (
    tester,
  ) async {
    const textConfig = LLMConfig(
      key: 'text-fast',
      type: LLMConfig.typeDeepSeek,
      modelId: 'deepseek-v4-flash',
      apiKey: 'sk-text',
      baseUrl: 'https://api.deepseek.com',
    );
    const visionConfig = LLMConfig(
      key: 'vision-main',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-5.4',
      apiKey: 'sk-vision',
      baseUrl: 'https://api.openai.com/v1',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      textConfig,
      visionConfig,
    ]);

    await _pumpCustomPage(tester);

    final textDropdown = find.byKey(
      const ValueKey('ai-model-text-slot-dropdown'),
    );
    await tester.ensureVisible(textDropdown);
    await tester.tap(textDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(textConfig.key).last);
    await tester.pumpAndSettle();

    expect(await UserStorage.getDefaultLLMConfigKey(), textConfig.key);

    final visionDropdown = find.byKey(
      const ValueKey('ai-model-vision-slot-dropdown'),
    );
    await tester.ensureVisible(visionDropdown);
    await tester.tap(visionDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(visionConfig.key).last);
    await tester.pumpAndSettle();

    final mediaConfig = await UserStorage.getAgentConfig(
      AgentDefinitions.analyzeAssets,
    );
    expect(mediaConfig.llmConfigKey, visionConfig.key);

    await tester.ensureVisible(visionDropdown);
    await tester.tap(visionDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.followTextModel).last);
    await tester.pumpAndSettle();

    final resetMediaConfig = await UserStorage.getAgentConfig(
      AgentDefinitions.analyzeAssets,
    );
    expect(resetMediaConfig.llmConfigKey, isNull);
  });

  testWidgets('vision selector warns when selected model is not multimodal', (
    tester,
  ) async {
    const multimodalConfig = LLMConfig(
      key: 'vision-ready',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-4o',
      apiKey: 'sk-vision',
      baseUrl: 'https://api.openai.com/v1',
    );
    const textOnlyConfig = LLMConfig(
      key: 'text-only',
      type: LLMConfig.typeDeepSeek,
      modelId: 'deepseek-v4-flash',
      apiKey: 'sk-text',
      baseUrl: 'https://api.deepseek.com',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      multimodalConfig,
      textOnlyConfig,
    ]);
    await UserStorage.setDefaultLLMConfigKey(multimodalConfig.key);

    await _pumpCustomPage(tester);

    expect(
      find.text(UserStorage.l10n.visionModelNonMultimodalWarning),
      findsNothing,
    );

    final visionDropdown = find.byKey(
      const ValueKey('ai-model-vision-slot-dropdown'),
    );
    await tester.ensureVisible(visionDropdown);
    await tester.tap(visionDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(textOnlyConfig.key).last);
    await tester.pumpAndSettle();

    expect(
      find.text(UserStorage.l10n.visionModelNonMultimodalWarning),
      findsOneWidget,
    );
  });

  testWidgets('speech recognition provider and Tencent Cloud config persist', (
    tester,
  ) async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(),
    );
    await _pumpCustomPage(tester);

    final speechSection = find.byKey(
      const ValueKey('ai-service-speech-recognition-section'),
    );
    await _centerFinder(tester, speechSection);
    await tester.pumpAndSettle();
    expect(speechSection, findsOneWidget);

    expect(find.text(UserStorage.l10n.speechProviderSettings), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.speechRecognitionPreviewNote),
      findsOneWidget,
    );

    await tester.tap(
      find.text(UserStorage.l10n.speechRecognitionProviderTencentCloud),
    );
    await tester.pumpAndSettle();

    var config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.provider, SpeechRecognitionProvider.tencentCloud);
    expect(await UserStorage.getUseLocalSpeechToText(), isFalse);

    final appIdField = find.byKey(
      const ValueKey('ai-service-speech-tencent-app-id-field'),
    );
    final secretIdField = find.byKey(
      const ValueKey('ai-service-speech-tencent-secret-id-field'),
    );
    final secretKeyField = find.byKey(
      const ValueKey('ai-service-speech-tencent-secret-key-field'),
    );
    expect(appIdField, findsOneWidget);
    expect(secretIdField, findsOneWidget);
    expect(secretKeyField, findsOneWidget);
    final secretKeyEditableText = find.descendant(
      of: secretKeyField,
      matching: find.byType(EditableText),
    );
    expect(
      tester.widget<EditableText>(secretKeyEditableText).obscureText,
      isTrue,
    );

    await tester.enterText(appIdField, '1250000000');
    await tester.pumpAndSettle();
    await tester.enterText(secretIdField, 'AKID-example');
    await tester.pumpAndSettle();
    await tester.enterText(secretKeyField, 'secret-key');
    await tester.pumpAndSettle();

    final engineDropdown = find.byKey(
      const ValueKey('ai-service-speech-tencent-engine-dropdown'),
    );
    await tester.ensureVisible(engineDropdown);
    await tester.pumpAndSettle();
    await tester.tap(engineDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.tencentAsrEngine16kZh).last);
    await tester.pumpAndSettle();

    config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.tencentAppId, '1250000000');
    expect(config.tencentSecretId, 'AKID-example');
    expect(config.tencentSecretKey, 'secret-key');
    expect(config.tencentEngineModel, '16k_zh');
  });

  testWidgets(
      'Xiaomi MiMo speech config supports linked and manual credentials',
      (tester) async {
    const mimoConfig = LLMConfig(
      key: 'mimo-main',
      type: LLMConfig.typeMimo,
      modelId: 'mimo-v2.5',
      apiKey: 'mimo-key',
      baseUrl: 'https://api.xiaomimimo.com/anthropic',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      mimoConfig,
    ]);
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(),
    );
    await _pumpCustomPage(tester);

    final speechSection = find.byKey(
      const ValueKey('ai-service-speech-recognition-section'),
    );
    await _centerFinder(tester, speechSection);
    await tester.pumpAndSettle();

    expect(
      find.text(UserStorage.l10n.speechRecognitionProviderLocal),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.speechRecognitionProviderTencentCloud),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.speechRecognitionProviderXiaomiMimo),
      findsOneWidget,
    );

    await tester.tap(
      find.text(UserStorage.l10n.speechRecognitionProviderXiaomiMimo),
    );
    await tester.pumpAndSettle();

    var config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.provider, SpeechRecognitionProvider.xiaomiMimo);
    expect(await UserStorage.getUseLocalSpeechToText(), isFalse);
    expect(find.text(UserStorage.l10n.mimoAsrConfigTitle), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.speechRecognitionRealtimeUnavailable),
      findsOneWidget,
    );

    final sourceDropdown = find.byKey(
      const ValueKey('ai-service-speech-mimo-source-dropdown'),
    );
    await _centerFinder(tester, sourceDropdown);
    await tester.tap(sourceDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('mimo-main').last);
    await tester.pumpAndSettle();

    config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.xiaomiMimo.llmConfigKey, 'mimo-main');
    expect(
      find.byKey(const ValueKey('ai-service-speech-mimo-api-key-field')),
      findsNothing,
    );

    await _centerFinder(tester, sourceDropdown);
    await tester.tap(sourceDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.mimoAsrManualConfig).last);
    await tester.pumpAndSettle();

    final apiKeyField = find.byKey(
      const ValueKey('ai-service-speech-mimo-api-key-field'),
    );
    final baseUrlField = find.byKey(
      const ValueKey('ai-service-speech-mimo-base-url-field'),
    );
    expect(apiKeyField, findsOneWidget);
    expect(baseUrlField, findsOneWidget);
    final apiKeyEditableText = find.descendant(
      of: apiKeyField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(apiKeyEditableText).obscureText, isTrue);

    await tester.enterText(apiKeyField, 'manual-mimo-key');
    await tester.pumpAndSettle();
    await tester.enterText(baseUrlField, 'https://mimo.example/v1');
    await tester.pumpAndSettle();

    final languageDropdown = find.byKey(
      const ValueKey('ai-service-speech-mimo-language-dropdown'),
    );
    await tester.ensureVisible(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.mimoAsrLanguageEn).last);
    await tester.pumpAndSettle();

    config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.xiaomiMimo.llmConfigKey, isEmpty);
    expect(config.xiaomiMimo.apiKey, 'manual-mimo-key');
    expect(config.xiaomiMimo.baseUrl, 'https://mimo.example/v1');
    expect(config.xiaomiMimo.language, 'en');
  });

  testWidgets('Xiaomi MiMo manual form is stable without linked configs',
      (tester) async {
    await UserStorage.saveLLMConfigs([LLMConfig.createDefaultClientConfig()]);
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(
          apiKey: 'existing-key',
          baseUrl: 'https://token-plan-sgp.xiaomimimo.com/anthropic',
          language: 'zh',
        ),
      ),
    );

    await _pumpCustomPage(tester);
    final speechSection = find.byKey(
      const ValueKey('ai-service-speech-recognition-section'),
    );
    await _centerFinder(tester, speechSection);
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.mimoAsrConfigTitle), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.speechRecognitionXiaomiMimoPreviewNote),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.speechRecognitionRealtimeUnavailable),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ai-service-speech-mimo-api-key-field')),
      findsOneWidget,
    );
    final baseUrlField = find.byKey(
      const ValueKey('ai-service-speech-mimo-base-url-field'),
    );
    expect(baseUrlField, findsOneWidget);
    final baseUrlEditableText = find.descendant(
      of: baseUrlField,
      matching: find.byType(EditableText),
    );
    expect(
      tester.widget<EditableText>(baseUrlEditableText).controller.text,
      'https://token-plan-sgp.xiaomimimo.com/anthropic',
    );

    final languageDropdown = find.byKey(
      const ValueKey('ai-service-speech-mimo-language-dropdown'),
    );
    await _centerFinder(tester, languageDropdown);
    await tester.tap(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.mimoAsrLanguageAuto).last);
    await tester.pumpAndSettle();

    var config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.provider, SpeechRecognitionProvider.xiaomiMimo);
    expect(config.xiaomiMimo.language, 'auto');

    await tester
        .tap(find.text(UserStorage.l10n.speechRecognitionProviderLocal));
    await tester.pumpAndSettle();

    config = await UserStorage.getSpeechRecognitionConfig();
    expect(config.provider, SpeechRecognitionProvider.local);
    expect(await UserStorage.getUseLocalSpeechToText(), isTrue);
    expect(
      find.byKey(const ValueKey('ai-service-speech-mimo-api-key-field')),
      findsNothing,
    );
    expect(
      find.text(UserStorage.l10n.speechRecognitionRealtimeAvailable),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.speechRecognitionLocalOnly),
      findsOneWidget,
    );
  });

  testWidgets('custom provider action opens model configuration', (
    tester,
  ) async {
    await _pumpCustomPage(tester);

    final customModelAction = find.byKey(
      const ValueKey('ai-model-custom-config-button'),
    );
    await _centerFinder(tester, customModelAction);
    await tester.tap(customModelAction);
    await tester.pumpAndSettle();

    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    expect(find.byType(ModelConfigListPage), findsNothing);
    expect(find.text(UserStorage.l10n.keyIdLabel), findsNothing);
  });

  testWidgets('advanced model routing opens agent assignments', (
    tester,
  ) async {
    await _pumpCustomPage(tester);

    final agentAssignments =
        find.text(UserStorage.l10n.advancedAgentModelAssignments);
    await _scrollUntilVisible(tester, agentAssignments);
    await tester.tap(agentAssignments);
    await tester.pumpAndSettle();

    expect(find.byType(AgentConfigListPage), findsOneWidget);
  });

  testWidgets('onboarding skip completes without saving credentials', (
    tester,
  ) async {
    var completed = false;

    await _pumpPage(
      tester,
      AiServiceSetupPage(
        onboardingMode: true,
        onComplete: () => completed = true,
      ),
    );

    await tester.tap(find.text(UserStorage.l10n.skipForNow));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('onboarding custom model save completes setup flow', (
    tester,
  ) async {
    var completed = false;
    const customConfig = LLMConfig(
      key: 'custom-openai',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-4o',
      apiKey: 'sk-test',
      baseUrl: 'https://api.openai.com/v1',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      customConfig,
    ]);
    await UserStorage.saveLLMConsent(
      true,
      providerType: LLMConfig.typeChatCompletion,
    );

    await _pumpPage(
      tester,
      AiServiceSetupPage(
        onboardingMode: true,
        onComplete: () => completed = true,
      ),
    );

    await _tapByKey(tester, const ValueKey('ai-service-custom-route-card'));

    final customModelAction = find.byKey(
      const ValueKey('ai-model-custom-config-button'),
    );
    await _centerFinder(tester, customModelAction);
    await tester.tap(customModelAction);
    await tester.pumpAndSettle();

    await tester.tap(find.text(customConfig.key));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.byType(ModelConfigListPage), findsNothing);
  });
}

Future<void> _pumpCustomPage(WidgetTester tester) async {
  await _pumpPage(tester, const AiServiceSetupPage());
  await _tapByKey(tester, const ValueKey('ai-service-custom-route-card'));
  expect(find.byType(CustomAiServiceSetupPage), findsOneWidget);
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pumpAndSettle();
}

Future<void> _tapByKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await _centerFinder(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
}

Future<void> _centerFinder(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();
}
