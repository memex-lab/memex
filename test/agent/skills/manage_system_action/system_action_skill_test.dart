import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/agent/run_mode/agent_run_mode.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('superagent_device_');
    await FileSystemService.init(root.path);
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  test('prepares a pending calendar event instead of writing to the device',
      () async {
    final result = await _runTool(
      toolName: 'create_calendar_event',
      arguments: {
        'title': ' Team review ',
        'start_time': '2026-08-01 15:30:00',
        'end_time': '2026-08-01 16:30:00',
        'notes': ' Bring the launch plan ',
        'location': ' Meeting room A ',
      },
    );

    expect(result.isError, isFalse);
    expect(_text(result), contains('for user confirmation'));
    expect(_text(result), contains('not been written'));

    final actions = await SystemActionService.instance.getPending();
    expect(actions, hasLength(1));
    final action = actions.single;
    final data = jsonDecode(action.actionData!) as Map<String, dynamic>;
    expect(action.actionType, 'calendar');
    expect(action.status, 'pending');
    expect(action.factId, isNull);
    expect(data['title'], 'Team review');
    expect(data['notes'], 'Bring the launch plan');
    expect(data['location'], 'Meeting room A');
    expect(DateTime.parse(data['start_time']), DateTime(2026, 8, 1, 15, 30));
    expect(DateTime.parse(data['end_time']), DateTime(2026, 8, 1, 16, 30));

    final artifact = ChatArtifact.fromToolMetadata(result.metadata);
    expect(artifact, isNotNull);
    expect(artifact!.kind, ChatArtifact.kindSystemAction);
    expect(artifact.systemActionKind, 'calendar');
    expect(artifact.systemActionId, action.id);
    expect(artifact.targetUri, contains(action.id));

    final actionCenterItems =
        await CardAttachmentService.instance.getPendingAttachments();
    expect(actionCenterItems, hasLength(1));
    expect(actionCenterItems.single.type, CardAttachmentType.systemAction);
    expect(actionCenterItems.single.id, 'system_action_${action.id}');
  });

  test('prepares a reminder with an explicit due date', () async {
    final result = await _runTool(
      toolName: 'create_reminder',
      arguments: {
        'title': 'Call the dentist',
        'due_date': '2026-08-02 09:00:00',
        'notes': 'Ask about the next checkup',
      },
    );

    expect(result.isError, isFalse);
    final actions = await SystemActionService.instance.getPending();
    expect(actions, hasLength(1));
    final action = actions.single;
    final data = jsonDecode(action.actionData!) as Map<String, dynamic>;
    expect(action.actionType, 'reminder');
    expect(action.factId, isNull);
    expect(data['title'], 'Call the dentist');
    expect(DateTime.parse(data['due_date']), DateTime(2026, 8, 2, 9));

    final artifact = ChatArtifact.fromToolMetadata(result.metadata)!;
    expect(artifact.systemActionKind, 'reminder');
    expect(artifact.systemActionId, action.id);
  });

  test('rejects reminders without a due date', () async {
    final result = await _runTool(
      toolName: 'create_reminder',
      arguments: {
        'title': 'Call the dentist',
      },
    );

    expect(result.isError, isTrue);
    expect(await SystemActionService.instance.getPending(), isEmpty);
  });

  test('rejects invalid event ranges without creating an action', () async {
    final result = await _runTool(
      toolName: 'create_calendar_event',
      arguments: {
        'title': 'Impossible meeting',
        'start_time': '2026-08-01 16:30:00',
        'end_time': '2026-08-01 15:30:00',
      },
    );

    expect(result.isError, isTrue);
    expect(await SystemActionService.instance.getPending(), isEmpty);
  });

  test('saved record proposal is attached, idempotent and respects rejection',
      () async {
    const factId = '2026/09/17.md#ts_1';
    final fs = FileSystemService.instance;
    await fs.writeYamlFile(
        fs.getCardPath('system_action_user', factId),
        const CardData(
                factId: factId,
                timestamp: 1789603200,
                status: 'completed',
                tags: [],
                uiConfigs: [],
                fact: '2099年周五下午三点带妈妈复查。')
            .toJson());
    final arguments = <String, dynamic>{
      'title': '陪妈妈复查',
      'start_time': '2099-09-18 15:00:00',
      'fact_id': factId,
    };
    final first =
        await _runTool(toolName: 'create_calendar_event', arguments: arguments);
    expect(first.isError, isFalse);
    final id = ChatArtifact.fromToolMetadata(first.metadata)!.systemActionId!;
    final attachments =
        await CardAttachmentService.instance.getAttachments(factId);
    expect(attachments.single.id, 'system_action_$id');
    expect((await SystemActionService.instance.getAction(id))!.factId, factId);
    await _runTool(toolName: 'create_calendar_event', arguments: arguments);
    expect(await SystemActionService.instance.getPending(), hasLength(1));
    await SystemActionService.instance.updateActionStatus(id, 'rejected');
    final retry =
        await _runTool(toolName: 'create_calendar_event', arguments: arguments);
    expect(_text(retry), contains('rejected'));
    expect(ChatArtifact.fromToolMetadata(retry.metadata), isNull);
    expect(await SystemActionService.instance.getPending(), isEmpty);
    expect(
        await CardAttachmentService.instance.getAttachments(factId), isEmpty);
    expect(await db.select(db.systemActions).get(), hasLength(1));
  });

  test('record proposals require a real completed source in the current user',
      () async {
    const factId = '2026/09/17.md#ts_2';
    final fs = FileSystemService.instance;
    for (final user in ['other_user', 'system_action_user']) {
      await fs.writeYamlFile(
          fs.getCardPath(user, factId),
          CardData(
                  factId: factId,
                  timestamp: 1789603200,
                  status: user == 'other_user' ? 'completed' : 'processing',
                  tags: const [],
                  uiConfigs: const [],
                  fact: '复查')
              .toJson());
    }
    final result =
        await _runTool(toolName: 'create_calendar_event', arguments: {
      'title': '复查',
      'start_time': '2099-09-18 15:00:00',
      'fact_id': factId,
    });
    expect(result.isError, isTrue);
    expect(await SystemActionService.instance.getPending(), isEmpty);
  });

  test('record reminders reject past dates and deleted sources', () async {
    const factId = '2026/09/17.md#ts_4';
    final fs = FileSystemService.instance;
    Future<void> save(bool deleted) => fs.writeYamlFile(
        fs.getCardPath('system_action_user', factId),
        CardData(
                factId: factId,
                timestamp: 1789603200,
                status: 'completed',
                tags: const [],
                uiConfigs: const [],
                fact: '复查准备',
                deleted: deleted)
            .toJson());
    await save(false);
    final past = await _runTool(toolName: 'create_reminder', arguments: {
      'title': '复查准备',
      'due_date': '2000-01-01 09:00:00',
      'fact_id': factId,
    });
    expect(past.isError, isTrue);
    await save(true);
    final deleted = await _runTool(toolName: 'create_reminder', arguments: {
      'title': '复查准备',
      'due_date': '2099-09-18 09:00:00',
      'fact_id': factId,
    });
    expect(deleted.isError, isTrue);
    expect(await SystemActionService.instance.getPending(), isEmpty);
    await save(false);
    final future = await _runTool(toolName: 'create_reminder', arguments: {
      'title': '复查准备',
      'due_date': '2099-09-18 09:00:00',
      'fact_id': factId,
    });
    expect(future.isError, isFalse);
    expect((await SystemActionService.instance.getPending()).single.factId,
        factId);
  });

  test(
      'read-only denies a leaked proposal tool; confirm mode prepares without blocking',
      () async {
    final args = {'title': '复查', 'start_time': '2099-09-18 15:00:00'};
    final denied = await _runTool(
        toolName: 'create_calendar_event',
        arguments: args,
        mode: AgentRunMode.readOnly);
    expect(denied.isError, isTrue);
    expect(await SystemActionService.instance.getPending(), isEmpty);
    final prepared = await _runTool(
        toolName: 'create_calendar_event',
        arguments: args,
        mode: AgentRunMode.confirm);
    expect(prepared.isError, isFalse);
    expect(await SystemActionService.instance.getPending(), hasLength(1));
  });

  test('skill exposes only the two pending creation tools', () {
    final skill = SystemActionSkill();
    final calendarProperties =
        skill.tools!.first.parameters['properties'] as Map;
    final reminderParameters = skill.tools!.last.parameters;
    final reminderProperties = reminderParameters['properties'] as Map;

    expect(
      skill.tools!.map((tool) => tool.name),
      ['create_calendar_event', 'create_reminder'],
    );
    expect(calendarProperties, contains('fact_id'));
    expect(skill.tools!.first.parameters['required'], ['title', 'start_time']);
    expect(reminderProperties, contains('fact_id'));
    expect(reminderParameters['required'], ['title', 'due_date']);
    expect(
      skill.tools!.every(
        (tool) => tool.description.contains('user confirmation'),
      ),
      isTrue,
    );
  });
}

Future<FunctionExecutionResult> _runTool({
  required String toolName,
  required Map<String, dynamic> arguments,
  AgentRunMode mode = AgentRunMode.auto,
}) async {
  final skill = SystemActionSkill();
  final state = AgentState(
    sessionId: 'system_action_skill_test',
    metadata: {
      'userId': 'system_action_user',
      AgentRunMode.metadataKey: mode.wireName
    },
  );
  final agent = StatefulAgent(
    name: 'system_action_skill_test_agent',
    client: _SingleToolCallClient(
      toolName: toolName,
      arguments: arguments,
    ),
    modelConfig: ModelConfig(model: 'test'),
    state: state,
    tools: skill.tools,
    withGeneralPrinciples: false,
    maxTurns: 3,
  );

  await agent.run([UserMessage.text('prepare it')], useStream: false);

  return state.history.messages
      .whereType<FunctionExecutionResultMessage>()
      .single
      .results
      .single;
}

String _text(FunctionExecutionResult result) {
  return result.content.whereType<TextPart>().map((part) => part.text).join();
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
