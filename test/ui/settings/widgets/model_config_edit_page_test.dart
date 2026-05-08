import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/model_config_edit_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('ModelConfigEditPage duplicate mode', () {
    const sourceConfig = LLMConfig(
      key: 'source-config',
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

    testWidgets('shows "Duplicate Configuration" title when duplicateSource is provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ModelConfigEditPage(duplicateSource: sourceConfig),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Duplicate Configuration'), findsOneWidget);
    });

    testWidgets('pre-fills fields from duplicateSource', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ModelConfigEditPage(duplicateSource: sourceConfig),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Basic fields are visible on page load
      expect(find.text('source-config'), findsOneWidget);
      expect(find.text('gpt-5.4'), findsOneWidget);
      expect(find.text('sk-test'), findsOneWidget);
      expect(find.text('https://api.openai.com/v1'), findsOneWidget);
      // Advanced fields (proxy, temperature, maxTokens, topP, extra)
      // are inside a collapsed ExpansionTile and not checked here.
    });

    testWidgets('save button is present when duplicateSource is provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ModelConfigEditPage(duplicateSource: sourceConfig),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
    });

    testWidgets('saves duplicate config with unique key', (tester) async {
      // Pre-populate storage with a default config and a custom config
      final defaultConfig = LLMConfig.createDefaultClientConfig();
      const customConfig = LLMConfig(
        key: 'myconfig',
        type: LLMConfig.typeChatCompletion,
        modelId: 'gpt-4o',
        apiKey: 'sk-real-key',
        baseUrl: 'https://custom.example.com/v1',
        proxyUrl: 'http://proxy.example.com:8080',
      );
      await UserStorage.saveLLMConfigs([defaultConfig, customConfig]);
      await UserStorage.saveLLMConsent(
        true,
        providerType: LLMConfig.typeChatCompletion,
      );

      // Simulate what ModelConfigListPage._duplicateConfig does:
      // generate a unique key before passing to edit page
      final duplicatedConfig = customConfig.duplicate(
        existingKeys: [defaultConfig.key, customConfig.key],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ModelConfigEditPage(duplicateSource: duplicatedConfig),
        ),
      );
      await tester.pump();

      // Tap save — duplicate config should be added
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify storage now has 3 configs: default + myconfig + myconfig_copy
      final configs = await UserStorage.getLLMConfigs();
      expect(configs.length, 3);
      expect(configs.any((c) => c.key == 'myconfig'), isTrue);
      expect(configs.any((c) => c.key == 'myconfig_copy'), isTrue);

      // Verify duplicated config preserves original values
      final duplicated = configs.firstWhere((c) => c.key == 'myconfig_copy');
      expect(duplicated.type, customConfig.type);
      expect(duplicated.modelId, customConfig.modelId);
      expect(duplicated.apiKey, customConfig.apiKey);
      expect(duplicated.baseUrl, customConfig.baseUrl);
      expect(duplicated.proxyUrl, customConfig.proxyUrl);
    });

    testWidgets('increments counter when duplicate key already exists', (tester) async {
      final defaultConfig = LLMConfig.createDefaultClientConfig();
      const customConfig = LLMConfig(
        key: 'myconfig',
        type: LLMConfig.typeChatCompletion,
        modelId: 'gpt-4o',
        apiKey: 'sk-real-key',
        baseUrl: 'https://custom.example.com/v1',
      );
      const existingCopy = LLMConfig(
        key: 'myconfig_copy',
        type: LLMConfig.typeChatCompletion,
        modelId: 'gpt-4o-mini',
        apiKey: 'sk-other',
        baseUrl: 'https://other.example.com/v1',
      );
      await UserStorage.saveLLMConfigs([defaultConfig, customConfig, existingCopy]);
      await UserStorage.saveLLMConsent(
        true,
        providerType: LLMConfig.typeChatCompletion,
      );

      // Simulate what ModelConfigListPage._duplicateConfig does:
      // generate a unique key before passing to edit page
      final duplicatedConfig = customConfig.duplicate(
        existingKeys: [defaultConfig.key, customConfig.key, existingCopy.key],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ModelConfigEditPage(duplicateSource: duplicatedConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(const Duration(milliseconds: 500));

      final configs = await UserStorage.getLLMConfigs();
      expect(configs.length, 4);
      expect(configs.any((c) => c.key == 'myconfig_copy_2'), isTrue);
    });
  });
}
