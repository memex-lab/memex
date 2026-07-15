import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_agent.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_workspace.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CharacterAgent transforms and finishes one observation', () async {
    final tempRoot = await Directory.systemTemp.createTemp('memex_char_agent_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });
    await FileSystemService.init(tempRoot.path);
    AgentActivityService.setInstance(LocalAgentActivityService.instance);

    const userId = 'character_agent_user';
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她会从平常的小事里记住关系的质感。',
      enabled: true,
    );
    final workspaceService = CharacterWorkspaceService();
    final observation = (await workspaceService.enqueueObservation(
      userId: userId,
      character: character,
      sourceEventId: 'event-agent-1',
      source: CharacterObservationSources.userRecord,
      factId: '2026/07/13.md#ts_1',
      content: '姐姐总和小朋友说长大学习很难，所以她现在不想长大。',
      observedAt: DateTime.parse('2026-07-13T20:30:00+08:00'),
    ))!;
    final client = _ScriptedCharacterClient();

    await CharacterAgent.digestObservation(
      userId: userId,
      character: character,
      observation: observation,
      workspaceService: workspaceService,
      client: client,
      modelConfig: ModelConfig(model: 'test-model'),
    );

    expect(
      await workspaceService.loadPendingObservations(userId, character.id),
      isEmpty,
    );
    expect(client.calledTools, [
      'AppendJournal',
      'Remember',
      'FinishObservation',
    ]);

    final pkmNote = File(
      p.join(
        FileSystemService.instance.getCharacterPkmPath(userId, character.id),
        'people',
        'user-and-66.md',
      ),
    );
    expect(await pkmNote.readAsString(), contains('姐姐会开玩笑地渲染长大'));

    final journalFiles = await Directory(
      FileSystemService.instance.getCharacterJournalPath(userId, character.id),
    )
        .list(recursive: true)
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    expect(journalFiles, hasLength(1));
    expect(
      await journalFiles.single.readAsString(),
      contains('这更像她们之间轻轻的玩笑'),
    );

    final stateDirectory =
        await FileSystemService.instance.getAgentStateDirectory(userId);
    final stateFile = File(
      p.join(
        stateDirectory,
        'character_perception_${character.id}_'
        '${observation.id.substring(0, 20)}.json',
      ),
    );
    expect(await stateFile.exists(), isFalse);
  });

  test('CharacterAgent selects one proactive action from its own memory',
      () async {
    final tempRoot = await Directory.systemTemp.createTemp('memex_char_agent_');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });
    await FileSystemService.init(tempRoot.path);
    AgentActivityService.setInstance(LocalAgentActivityService.instance);

    const userId = 'initiative_agent_user';
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她说话平常、轻轻的。',
      enabled: true,
    );
    final client = _ScriptedInitiativeClient();
    final decision = await CharacterAgent.considerInitiative(
      userId: userId,
      character: character,
      context: CharacterInitiativeContext(
        sourceEventId: 'event-initiative-1',
        factId: 'fact-1',
        now: DateTime.parse('2026-07-13T21:00:00+08:00'),
        recentPrivateChat: [
          CharacterConversationTurn(
            isFromCharacter: false,
            content: '你在干嘛呢',
            timestamp: DateTime.parse('2026-07-13T20:55:00+08:00'),
            isRead: true,
            origin: 'conversation',
          ),
        ],
      ),
      workspaceService: CharacterWorkspaceService(),
      client: client,
      modelConfig: ModelConfig(model: 'test-model'),
    );

    expect(decision.action, CharacterInitiativeAction.speak);
    expect(decision.messages, ['刚想起你。', '没忙什么，你呢？']);
    expect(client.toolNames, contains('Speak'));
    expect(client.lastPrompt, isNot(contains('combined_text')));
    expect(client.lastPrompt, isNot(contains('<observation>')));
    expect(client.lastPrompt, contains('is_read'));
    expect(client.lastPrompt, contains('origin'));
  });
}

class _ScriptedCharacterClient extends LLMClient {
  final calledTools = <String>[];
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
    final (name, arguments) = switch (_callCount) {
      1 => (
          'AppendJournal',
          {'content': '这更像她们之间轻轻的玩笑，不是什么沉重的事。'},
        ),
      2 => (
          'Remember',
          {
            'path': 'people/user-and-66.md',
            'content': '# 她和 66\n\n姐姐会开玩笑地渲染长大学习很难。',
          },
        ),
      _ => ('FinishObservation', <String, dynamic>{}),
    };
    calledTools.add(name);
    expect(tools?.map((tool) => tool.name), contains(name));
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'tool_calls',
      functionCalls: [
        FunctionCall(
          id: 'call-$_callCount',
          name: name,
          arguments: jsonEncode(arguments),
        ),
      ],
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

class _ScriptedInitiativeClient extends LLMClient {
  List<String> toolNames = [];
  String lastPrompt = '';

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    toolNames = tools?.map((tool) => tool.name).toList() ?? [];
    final prompt = StringBuffer();
    for (final message in messages) {
      if (message is SystemMessage) {
        prompt.writeln(message.content);
      } else if (message is UserMessage) {
        for (final part in message.contents.whereType<TextPart>()) {
          prompt.writeln(part.text);
        }
      }
    }
    lastPrompt = prompt.toString();
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'tool_calls',
      functionCalls: [
        FunctionCall(
          id: 'initiative-call-1',
          name: 'Speak',
          arguments: jsonEncode({
            'messages': ['刚想起你。', '没忙什么，你呢？'],
          }),
        ),
      ],
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
