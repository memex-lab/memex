import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/settings_registry.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/settings/view_models/ai_service_setup_viewmodel.dart';
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
    expect(
      find.text(UserStorage.l10n.aiSetupCustomRouteDescription),
      findsOneWidget,
    );
    expect(find.textContaining('Super Agent'), findsNothing);
    expect(find.textContaining('单个 Agent'), findsNothing);
    expect(find.text(UserStorage.l10n.modelRolesTitle), findsNothing);
    expect(find.text(UserStorage.l10n.textModelRoleTitle), findsNothing);
    expect(
      find.byKey(const ValueKey('ai-service-speech-local-switch')),
      findsNothing,
    );
    expect(find.text(UserStorage.l10n.memexUsername), findsNothing);
  });

  testWidgets('current setup shows only the active config name', (
    tester,
  ) async {
    const activeConfig = LLMConfig(
      key: 'daily-driver',
      type: LLMConfig.typeDeepSeek,
      modelId: 'deepseek-v4-flash',
      apiKey: 'sk-test',
      baseUrl: 'https://api.deepseek.com',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      activeConfig,
    ]);
    await UserStorage.setDefaultLLMConfigKey(activeConfig.key);

    await _pumpPage(tester, const AiServiceSetupPage());

    expect(find.text(activeConfig.key), findsOneWidget);
    expect(find.textContaining(activeConfig.modelId), findsNothing);
    expect(
      find.text(UserStorage.l10n.aiSetupStatusCustomTitle),
      findsNothing,
    );
    expect(
      find.text(UserStorage.l10n.aiSetupStatusCustomDescription),
      findsNothing,
    );
  });

  testWidgets('current setup names the Memex official connection', (
    tester,
  ) async {
    const memexConfig = LLMConfig(
      key: LLMConfig.defaultClientKey,
      type: LLMConfig.typeMemex,
      modelId: 'memex-fast',
      apiKey: 'memex-key',
      baseUrl: 'https://memex.example/v1',
    );
    await UserStorage.saveLLMConfigs([memexConfig]);
    await UserStorage.setDefaultLLMConfigKey(memexConfig.key);

    await _pumpPage(tester, const AiServiceSetupPage());

    expect(
      find.text(UserStorage.l10n.aiSetupStatusMemexTitle),
      findsOneWidget,
    );
    expect(find.text(memexConfig.key), findsNothing);
    expect(find.textContaining(memexConfig.modelId), findsNothing);
    expect(
      find.text(UserStorage.l10n.aiSetupStatusMemexDescription),
      findsNothing,
    );
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

  test('settings registry does not expose app lock entry', () {
    expect(
      SettingsRegistry.allItems.map((item) => item.id),
      isNot(contains('app_lock')),
    );
  });

  testWidgets('official route opens the existing Memex auth flow', (
    tester,
  ) async {
    await _pumpPage(tester, const AiServiceSetupPage());

    expect(find.textContaining('MemeX'), findsNothing);

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

  testWidgets('first custom setup opens the compact model editor directly', (
    tester,
  ) async {
    await _pumpPage(tester, const AiServiceSetupPage());

    await _tapByKey(tester, const ValueKey('ai-service-custom-route-card'));

    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    expect(find.byType(ModelConfigListPage), findsNothing);
    expect(find.text(UserStorage.l10n.keyIdLabel), findsNothing);
    expect(find.text(UserStorage.l10n.baseUrlLabel), findsNothing);
    expect(find.byIcon(Icons.save), findsNothing);
    expect(
      find.byKey(const ValueKey('model_config_bottom_save_button')),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.modelRolesTitle), findsNothing);
    expect(
      find.text(UserStorage.l10n.locationProviderSettings),
      findsNothing,
    );
    expect(find.text(UserStorage.l10n.speechProviderSettings), findsNothing);
    expect(
      find.text(UserStorage.l10n.advancedAgentModelAssignments),
      findsNothing,
    );
  });

  testWidgets('one valid custom model opens that model directly', (
    tester,
  ) async {
    const customConfig = LLMConfig(
      key: 'custom-openai',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-5.4',
      apiKey: 'sk-test',
      baseUrl: 'https://api.openai.com/v1',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      customConfig,
    ]);
    await _pumpPage(tester, const AiServiceSetupPage());

    await _tapByKey(tester, const ValueKey('ai-service-custom-route-card'));

    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    expect(find.byType(ModelConfigListPage), findsNothing);
    expect(find.text(customConfig.modelId), findsOneWidget);
    expect(find.text(UserStorage.l10n.keyIdLabel), findsNothing);
  });

  testWidgets('multiple valid custom models open the model list', (
    tester,
  ) async {
    const firstConfig = LLMConfig(
      key: 'custom-openai',
      type: LLMConfig.typeChatCompletion,
      modelId: 'gpt-5.4',
      apiKey: 'sk-openai',
      baseUrl: 'https://api.openai.com/v1',
    );
    const secondConfig = LLMConfig(
      key: 'custom-deepseek',
      type: LLMConfig.typeDeepSeek,
      modelId: 'deepseek-v4-flash',
      apiKey: 'sk-deepseek',
      baseUrl: 'https://api.deepseek.com',
    );
    await UserStorage.saveLLMConfigs([
      LLMConfig.createDefaultClientConfig(),
      firstConfig,
      secondConfig,
    ]);
    await _pumpPage(tester, const AiServiceSetupPage());

    await _tapByKey(tester, const ValueKey('ai-service-custom-route-card'));

    expect(find.byType(ModelConfigListPage), findsOneWidget);
    expect(find.byType(ModelConfigEditPage), findsNothing);
    expect(find.text(firstConfig.key), findsOneWidget);
    expect(find.text(secondConfig.key), findsOneWidget);
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
    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('model_config_bottom_save_button')),
    );
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.byType(ModelConfigListPage), findsNothing);
    expect(await UserStorage.getDefaultLLMConfigKey(), customConfig.key);
  });
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

Future<void> _centerFinder(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();
}
