import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late LLMConfig builtInDefault;
  late LLMConfig customDefault;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('memex_widget_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
          return tempDir.path;
        default:
          return null;
      }
    });

    await UserStorage.initL10n();
    builtInDefault = LLMConfig.createDefaultClientConfig();
    customDefault = builtInDefault.copyWith(
      key: 'custom',
      modelId: 'custom-model',
      apiKey: 'test-key',
    );
    await UserStorage.saveLLMConfigs([builtInDefault, customDefault]);
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> pumpSettingsPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(MaterialApp(home: page));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> stopLocalAssetServer(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await LocalAssetServer.stopServer();
    });
  }

  testWidgets('model config page can set a custom config as default',
      (tester) async {
    await pumpSettingsPage(tester, const ModelConfigListPage());

    expect(await UserStorage.getDefaultLLMConfigKey(), builtInDefault.key);
    expect(find.text('custom'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.setAsDefault));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(await UserStorage.getDefaultLLMConfigKey(), customDefault.key);
    expect(
      find.text(UserStorage.l10n.modelSetAsDefault(customDefault.modelId)),
      findsOneWidget,
    );
    await stopLocalAssetServer(tester);
  });

  testWidgets(
      'agent config page discovers registered agents and shows default choice',
      (tester) async {
    await UserStorage.setDefaultLLMConfigKey(customDefault.key);

    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpSettingsPage(tester, const AgentConfigListPage());

    expect(
        find.text(AgentDefinitions.displayNames[AgentDefinitions.chatAgent]!),
        findsOneWidget);
    expect(
      find.text(
        AgentDefinitions
            .displayNames[AgentDefinitions.clarificationResolutionAgent]!,
      ),
      findsOneWidget,
    );
    expect(find.text('Default: custom / custom-model'), findsWidgets);
    await stopLocalAssetServer(tester);
  });
}
