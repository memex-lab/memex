import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_perception_skill.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_workspace.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CharacterPerceptionSkill', () {
    late Directory tempRoot;
    late CharacterWorkspaceService workspaceService;
    late CharacterModel character;
    late CharacterObservation observation;

    setUp(() async {
      tempRoot =
          await Directory.systemTemp.createTemp('memex_perception_skill_');
      await FileSystemService.init(tempRoot.path);
      workspaceService = CharacterWorkspaceService();
      character = CharacterModel(
        id: 'yaoyao',
        name: '瑶瑶',
        tags: const [],
        persona: '她关注细小、平常的生活片段。',
        enabled: true,
      );
      observation = (await workspaceService.enqueueObservation(
        userId: 'wujia',
        character: character,
        sourceEventId: 'event-skill',
        source: CharacterObservationSources.userRecord,
        content: '今天还是觉得玩不够。',
        observedAt: DateTime.parse('2026-07-13T20:00:00+08:00'),
      ))!;
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('exposes private memory tools but no messaging surface', () {
      final skill = CharacterPerceptionSkill(
        character: character,
        userId: 'wujia',
        observation: observation,
        workspaceService: workspaceService,
      );
      final names = skill.tools!.map((tool) => tool.name).toSet();

      expect(names, containsAll(['Glob', 'Grep', 'Read', 'BatchRead']));
      expect(names,
          containsAll(['Remember', 'AppendJournal', 'FinishObservation']));
      expect(names, isNot(contains('Write')));
      expect(names, isNot(contains('SaveComment')));
      expect(names, isNot(contains('SendActionMessage')));
      expect(skill.systemPrompt, contains('progressively'));
      expect(skill.systemPrompt, contains('Never create intimacy scores'));
      expect(
          skill.systemPrompt, contains('not produce a message for the user'));
    });

    test('generic Read cannot access the raw inbox', () async {
      final skill = CharacterPerceptionSkill(
        character: character,
        userId: 'wujia',
        observation: observation,
        workspaceService: workspaceService,
      );
      final read = skill.tools!.singleWhere((tool) => tool.name == 'Read');
      final result = await _runToolCall(
        tool: read,
        arguments: {'file_path': '/inbox.jsonl'},
      );

      expect(result.isError, isTrue);
    });
  });
}

Future<FunctionExecutionResult> _runToolCall({
  required Tool tool,
  required Map<String, dynamic> arguments,
}) async {
  final state = AgentState(sessionId: 'character_skill_read_test');
  final agent = StatefulAgent(
    name: 'character_skill_read_test',
    client: _SingleToolCallClient(tool.name, arguments),
    modelConfig: ModelConfig(model: 'test-model'),
    state: state,
    tools: [tool],
    withGeneralPrinciples: false,
    maxTurns: 3,
  );
  await agent.run([UserMessage.text('run')], useStream: false);
  return state.history.messages
      .whereType<FunctionExecutionResultMessage>()
      .single
      .results
      .single;
}

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient(this.toolName, this.arguments);

  final String toolName;
  final Map<String, dynamic> arguments;
  var calls = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    calls += 1;
    if (calls == 1) {
      return ModelMessage(
        model: modelConfig.model,
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(
            id: 'call-1',
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
  }) {
    throw UnsupportedError('Streaming is not used.');
  }
}
