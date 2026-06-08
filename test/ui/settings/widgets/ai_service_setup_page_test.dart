import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/model_config_edit_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    await UserStorage.initL10n();
  });

  testWidgets('renders Memex and custom model setup options', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const AiServiceSetupPage(),
    );

    expect(find.text(UserStorage.l10n.setupModelConfigTitle), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.setupModelConfigSubtitle),
      findsOneWidget,
    );
    expect(
        find.text(UserStorage.l10n.aiServiceMemexRouteTitle), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiServiceCustomApiRouteTitle),
        findsOneWidget);
    expect(
      find.text(UserStorage.l10n.aiServiceCustomModelDescription),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.aiServiceSettingsDescription),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.enableAiService), findsOneWidget);
    expect(
        find.text(UserStorage.l10n.advancedModelConfiguration), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiServiceLongDescription), findsNothing);
    expect(find.text(UserStorage.l10n.memexUsername), findsNothing);
    expect(find.text(UserStorage.l10n.memexPassword), findsNothing);
  });

  testWidgets('Memex service action expands auth form', (tester) async {
    await _pumpPage(
      tester,
      const AiServiceSetupPage(),
    );

    await tester.tap(find.text(UserStorage.l10n.enableAiService));
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.memexUsername), findsOneWidget);
    expect(find.text(UserStorage.l10n.memexPassword), findsOneWidget);
  });

  testWidgets('custom model action opens model configuration', (tester) async {
    await _pumpPage(
      tester,
      const AiServiceSetupPage(),
    );

    final customModelAction =
        find.text(UserStorage.l10n.advancedModelConfiguration);
    await tester.ensureVisible(customModelAction);
    await tester.tap(customModelAction);
    await tester.pumpAndSettle();

    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    expect(find.byType(ModelConfigListPage), findsNothing);
    expect(find.text(UserStorage.l10n.keyIdLabel), findsNothing);
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

    final customModelAction =
        find.text(UserStorage.l10n.advancedModelConfiguration);
    await tester.ensureVisible(customModelAction);
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
