import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/model_config_edit_page.dart';
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

  testWidgets('model config page exposes a prominent add action', (
    tester,
  ) async {
    await pumpSettingsPage(tester, const ModelConfigListPage());

    final addAction = find.byKey(
      const ValueKey('add-model-config-button'),
    );
    expect(addAction, findsOneWidget);
    expect(find.text(UserStorage.l10n.addConfiguration), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.getSize(addAction).width, greaterThan(500));

    await tester.tap(addAction);
    await tester.pumpAndSettle();

    expect(find.byType(ModelConfigEditPage), findsOneWidget);
    await stopLocalAssetServer(tester);
  });

  testWidgets('agent model assignments stay collapsed but remain reachable', (
    tester,
  ) async {
    await pumpSettingsPage(tester, const ModelConfigListPage());

    final advancedSettings = find.byKey(
      const ValueKey('advanced-agent-model-settings'),
    );
    expect(advancedSettings, findsOneWidget);
    expect(find.text(UserStorage.l10n.advancedSettings), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.aiSetupAdvancedCustomizationDescription),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('agent-model-assignments-action')),
      findsNothing,
    );

    await tester.tap(advancedSettings);
    await tester.pumpAndSettle();

    final assignmentsAction = find.byKey(
      const ValueKey('agent-model-assignments-action'),
    );
    expect(assignmentsAction, findsOneWidget);
    expect(
      find.text(UserStorage.l10n.aiSetupAdvancedCustomizationDescription),
      findsOneWidget,
    );
    final advancedTheme = tester.widget<Theme>(
      find.byKey(const ValueKey('advanced-agent-model-settings-theme')),
    );
    expect(advancedTheme.data.dividerColor, Colors.transparent);
    final expandedTile = tester.widget<ExpansionTile>(advancedSettings);
    expect(
      (expandedTile.shape! as RoundedRectangleBorder).side,
      BorderSide.none,
    );
    await tester.tap(assignmentsAction);
    await tester.pumpAndSettle();

    expect(find.byType(AgentConfigListPage), findsOneWidget);
    await stopLocalAssetServer(tester);
  });

  testWidgets(
      'agent config page discovers registered agents and shows default choice',
      (tester) async {
    await UserStorage.setDefaultLLMConfigKey(customDefault.key);

    tester.view.physicalSize = const Size(1200, 4000);
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
        AgentDefinitions.displayNames[AgentDefinitions.profileAgent]!,
      ),
      findsOneWidget,
    );
    expect(find.text('Default: custom / custom-model'), findsWidgets);
    await stopLocalAssetServer(tester);
  });
}
