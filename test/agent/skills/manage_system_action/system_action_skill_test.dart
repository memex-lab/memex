import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
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
    expect(calendarProperties, isNot(contains('fact_id')));
    expect(reminderProperties, isNot(contains('fact_id')));
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
}) async {
  final skill = SystemActionSkill();
  final state = AgentState(
    sessionId: 'system_action_skill_test',
    metadata: {'userId': 'system_action_user'},
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
