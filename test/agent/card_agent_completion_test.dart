import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/card_agent/card_agent.dart';
import 'package:memex/agent/card_agent/rule_based_card_matcher.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardAgent completion evidence', () {
    late Directory tempRoot;
    late String userId;
    const factId = '2026/05/18.md#ts_1';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'card_completion_${DateTime.now().microsecondsSinceEpoch}';
      await UserStorage.saveUser(userId);

      tempRoot = await Directory.systemTemp.createTemp('memex_card_done_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('successful save tool alone is not enough when card file is missing',
        () async {
      final evidence = await CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        messages: [_saveToolMessage(factId: factId)],
      );

      expect(evidence.hasMatchingSuccessfulSaveToolCall, isTrue);
      expect(evidence.cardExists, isFalse);
      expect(evidence.isComplete, isFalse);
      expect(evidence.missingRequirements, contains('card_file_exists'));
      expect(evidence.missingRequirements, contains('status_completed'));
    });

    test('completed card with matching save tool is complete', () async {
      await _writeCard(
        userId: userId,
        factId: factId,
        status: 'completed',
      );

      final evidence = await CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        messages: [_saveToolMessage(factId: factId)],
      );

      expect(evidence.isComplete, isTrue);
      expect(evidence.toJson()['is_complete'], isTrue);
      expect(evidence.missingRequirements, isEmpty);
    });

    test('processing card is incomplete even after a save tool call', () async {
      await _writeCard(
        userId: userId,
        factId: factId,
        status: 'processing',
      );

      final evidence = await CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        messages: [_saveToolMessage(factId: factId)],
      );

      expect(evidence.isComplete, isFalse);
      expect(evidence.status, 'processing');
      expect(evidence.missingRequirements, contains('status_completed'));
    });

    test('save tool call must target the same fact id', () async {
      await _writeCard(
        userId: userId,
        factId: factId,
        status: 'completed',
      );

      final evidence = await CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        messages: [_saveToolMessage(factId: '2026/05/18.md#ts_2')],
      );

      expect(evidence.cardExists, isTrue);
      expect(evidence.hasMatchingSuccessfulSaveToolCall, isFalse);
      expect(evidence.isComplete, isFalse);
      expect(
        evidence.missingRequirements,
        contains('matching_successful_save_timeline_card_tool_call'),
      );
    });

    test('rule-based fallback writes a completed card', () async {
      const initial = CardData(
        factId: factId,
        timestamp: 1000,
        status: 'processing',
        tags: [],
        uiConfigs: [],
      );
      final card = applyRuleBasedTemplate(
        card: initial,
        combinedText: 'A quiet but complete rule-based memory.',
        imageUrls: const [],
        audioUrl: null,
      );
      await FileSystemService.instance.safeWriteCardFile(userId, factId, card);

      final evidence = await CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        requireSaveToolCall: false,
      );

      expect(card.status, 'completed');
      expect(evidence.isComplete, isTrue);
      expect(evidence.requireSaveToolCall, isFalse);
    });
  });
}

FunctionExecutionResultMessage _saveToolMessage({
  required String factId,
  bool isError = false,
}) {
  return FunctionExecutionResultMessage(
    results: [
      FunctionExecutionResult(
        id: 'call_1',
        name: 'save_timeline_card',
        isError: isError,
        arguments: jsonEncode({'fact_id': factId}),
        content: [TextPart('saved')],
      ),
    ],
  );
}

Future<void> _writeCard({
  required String userId,
  required String factId,
  required String status,
}) async {
  await FileSystemService.instance.safeWriteCardFile(
    userId,
    factId,
    CardData(
      factId: factId,
      timestamp: 1000,
      status: status,
      tags: const [],
      title: 'Completion fixture',
      uiConfigs: const [
        UiConfig(
          templateId: 'snippet',
          data: {'text': 'completion fixture'},
        ),
      ],
    ),
  );
}
