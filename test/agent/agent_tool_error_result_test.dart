import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/skills/comment_agent/tools/comment_tools.dart';
import 'package:memex/agent/skills/comment_agent/tools/memory_tools.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('agent tool error results', () {
    late Directory tempRoot;
    late String userId;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'tool_error_${DateTime.now().microsecondsSinceEpoch}';
      await UserStorage.saveUser(userId);

      tempRoot = await Directory.systemTemp.createTemp('memex_tool_error_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('save_timeline_card missing fact is marked as a tool error', () async {
      final tool = TimelineCardSkill(
        forceActivate: true,
        stopAfterSuccessSaveCard: true,
      ).tools!.singleWhere((tool) => tool.name == 'save_timeline_card');

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'fact_id': '2026/05/18.md#ts_999',
          'title': 'Missing source fact',
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': 'A card without a persisted source fact.'},
            },
          ],
        },
        metadata: {'userId': userId},
      );

      expect(result.isError, isTrue);
      expect(_text(result), contains('Error executing save_timeline_card'));
      expect(_text(result), contains('fact id: 2026/05/18.md#ts_999'));
    });

    test('save_timeline_card accepts JSON-encoded list arguments', () async {
      final tool = TimelineCardSkill(
        forceActivate: true,
        stopAfterSuccessSaveCard: true,
      ).tools!.singleWhere((tool) => tool.name == 'save_timeline_card');
      final date = DateTime(2026, 5, 18);
      const factId = '2026/05/18.md#ts_3';
      await FileSystemService.instance.appendToDailyFactFile(
        userId,
        date,
        '## <id:ts_3> 11:35:17 "{}"\n\nMorning Memex project notes.',
      );

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'fact_id': factId,
          'title': 'Memex project notes',
          'ui_configs': jsonEncode([
            {
              'template_id': 'article',
              'data': {
                'title': 'Memex project notes',
                'body': 'Morning Memex project notes.',
              },
            },
          ]),
          'tags': jsonEncode([
            {'name': 'Project'},
            {'name': 'Emotion'},
          ]),
        },
        metadata: {'userId': userId},
      );

      final card = await FileSystemService.instance.readCardFile(
        userId,
        factId,
      );

      expect(result.isError, isFalse);
      expect(card?.title, 'Memex project notes');
      expect(card?.uiConfigs.single.templateId, 'article');
      expect(card?.tags, ['Project', 'Emotion']);
    });

    test('save_timeline_card still accepts native list arguments', () async {
      final tool = TimelineCardSkill(
        forceActivate: true,
        stopAfterSuccessSaveCard: true,
      ).tools!.singleWhere((tool) => tool.name == 'save_timeline_card');
      final date = DateTime(2026, 5, 18);
      const factId = '2026/05/18.md#ts_4';
      await FileSystemService.instance.appendToDailyFactFile(
        userId,
        date,
        '## <id:ts_4> 11:42:00 "{}"\n\nNative list tool args.',
      );

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'fact_id': factId,
          'title': 'Native list args',
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': 'Native list tool args.'},
            },
          ],
          'tags': [
            {'name': 'Knowledge'},
          ],
        },
        metadata: {'userId': userId},
      );

      final card = await FileSystemService.instance.readCardFile(
        userId,
        factId,
      );

      expect(result.isError, isFalse);
      expect(card?.uiConfigs.single.templateId, 'article');
      expect(card?.tags, ['Knowledge']);
    });

    test('save_timeline_card rejects malformed JSON list strings', () async {
      final tool = TimelineCardSkill(
        forceActivate: true,
        stopAfterSuccessSaveCard: true,
      ).tools!.singleWhere((tool) => tool.name == 'save_timeline_card');

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'fact_id': '2026/05/18.md#ts_5',
          'title': 'Malformed list args',
          'ui_configs': '[{"template_id":"article"',
        },
        metadata: {'userId': userId},
      );

      expect(result.isError, isTrue);
      expect(_text(result), contains('ui_configs must be valid JSON'));
    });

    test('save_timeline_card rejects JSON strings that are not arrays',
        () async {
      final tool = TimelineCardSkill(
        forceActivate: true,
        stopAfterSuccessSaveCard: true,
      ).tools!.singleWhere((tool) => tool.name == 'save_timeline_card');

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'fact_id': '2026/05/18.md#ts_6',
          'title': 'Wrong list shape',
          'ui_configs': jsonEncode({
            'template_id': 'article',
            'data': {'body': 'This should have been wrapped in a list.'},
          }),
        },
        metadata: {'userId': userId},
      );

      expect(result.isError, isTrue);
      expect(_text(result), contains('ui_configs must be an array'));
    });

    test('SaveComment invalid input is marked as a tool error', () async {
      final tool = CommentToolFactory(
        userId: userId,
        cardId: '2026/05/18.md#ts_missing',
      ).buildSaveCommentTool();

      final result = await _runToolCall(
        tool: tool,
        arguments: {
          'content': '',
          'reply_to_id': null,
        },
        metadata: {'userId': userId},
      );

      expect(result.isError, isTrue);
      expect(_text(result), contains('Error executing SaveComment'));
      expect(_text(result), contains('Comment content cannot be empty'));
    });

    test('MemoryRead without a default character is marked as a tool error',
        () async {
      final tool = MemoryToolFactory(userId: userId).buildMemoryReadTool();

      final result = await _runToolCall(
        tool: tool,
        arguments: {'labels': null},
        metadata: {'userId': userId},
      );

      expect(result.isError, isTrue);
      expect(_text(result), contains('Error executing MemoryRead'));
      expect(_text(result), contains('No default character set'));
    });

    test('search_workspace_event_logs failures are marked as tool errors',
        () async {
      final result = await _runToolCall(
        tool: buildSearchEventLogsTool(),
        arguments: {
          'from_time': '2026-05-18T00:00:00+08:00',
          'limit': 10,
          'offset': 0,
          'to_time': null,
        },
      );

      expect(result.isError, isTrue);
      expect(_text(result),
          contains('Error executing search_workspace_event_logs'));
    });
  });
}

Future<FunctionExecutionResult> _runToolCall({
  required Tool tool,
  required Map<String, dynamic> arguments,
  Map<String, dynamic> metadata = const {},
}) async {
  final client = _SingleToolCallClient(
    toolName: tool.name,
    arguments: arguments,
  );
  final state = AgentState(
    sessionId: 'tool_error_test_${DateTime.now().microsecondsSinceEpoch}',
    metadata: Map<String, dynamic>.from(metadata),
  );
  final agent = StatefulAgent(
    name: 'tool_error_test_agent',
    client: client,
    modelConfig: ModelConfig(model: 'test-model'),
    state: state,
    tools: [tool],
    withGeneralPrinciples: false,
    maxTurns: 3,
  );

  await agent.run([UserMessage.text('run the tool')], useStream: false);

  final resultMessage =
      state.history.messages.whereType<FunctionExecutionResultMessage>().single;
  return resultMessage.results.single;
}

String _text(FunctionExecutionResult result) {
  return result.content
      .whereType<TextPart>()
      .map((part) => part.text)
      .join('\n');
}

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient({
    required this.toolName,
    required this.arguments,
  });

  final String toolName;
  final Map<String, dynamic> arguments;
  var _callCount = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    _callCount += 1;
    if (_callCount == 1) {
      return ModelMessage(
        model: modelConfig.model,
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(
            id: 'call_1',
            name: toolName,
            arguments: jsonEncode(arguments),
          ),
        ],
      );
    }
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'stop',
      textOutput: 'done',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}
