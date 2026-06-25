import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/super_agent/super_agent_harness.dart';

void main() {
  group('SuperAgentHarness idle skill tracking', () {
    test('persists idle counters in agent metadata across agent recreation',
        () async {
      final state = AgentState(
        sessionId: 'super_agent_harness_test',
        activeSkills: ['optional_skill'],
      );

      await _completeTurn(_agent(state));
      await _completeTurn(_agent(state));

      expect(
        state.metadata['super_agent_idle_skill_turns_v1'],
        {'optional_skill': 2},
      );
      expect(state.systemReminders, isNot(contains('idle_skills')));

      // Simulate closing/reopening the chat or rebuilding the agent around the
      // same persisted AgentState: metadata survives, static maps do not matter.
      await _completeTurn(_agent(state));

      expect(
        state.metadata['super_agent_idle_skill_turns_v1'],
        {'optional_skill': 3},
      );
      expect(
        state.systemReminders['idle_skills'],
        contains('optional_skill'),
      );
    });

    test('resets persisted counter when the optional skill is used', () async {
      final state = AgentState(
        sessionId: 'super_agent_harness_used_skill_test',
        activeSkills: ['optional_skill'],
        metadata: {
          'super_agent_idle_skill_turns_v1': {'optional_skill': 3},
        },
        systemReminders: {
          'idle_skills': 'stale reminder',
        },
      );
      final agent = _agent(state);

      await SuperAgentHarness.buildParentHook('test_user').afterToolCall(
        ToolResultHookContext(
          agent,
          result: FunctionExecutionResult(
            id: 'call_1',
            name: 'optional_tool',
            isError: false,
            arguments: '{}',
            content: [TextPart('ok')],
          ),
          modelMessage: ModelMessage(model: 'test-model'),
        ),
      );
      await _completeTurn(agent);

      expect(
          state.metadata, isNot(contains('super_agent_idle_skill_turns_v1')));
      expect(state.systemReminders, isNot(contains('idle_skills')));
    });
  });
}

Future<void> _completeTurn(StatefulAgent agent) async {
  await SuperAgentHarness.buildParentHook('test_user').onTurnCompletion(
    TurnCompletionHookContext(
      agent,
      finalMessage: ModelMessage(model: 'test-model', textOutput: 'done'),
      continuationCount: 0,
      maxContinuations: 3,
    ),
  );
}

StatefulAgent _agent(AgentState state) {
  return StatefulAgent(
    name: 'test_agent',
    client: _FakeClient(),
    modelConfig: ModelConfig(model: 'test-model'),
    state: state,
    skills: [_TestSkill()],
    withGeneralPrinciples: false,
  );
}

class _TestSkill extends Skill {
  _TestSkill()
      : super(
          name: 'optional_skill',
          description: 'Optional test skill',
          systemPrompt: '',
          tools: [
            Tool(
              name: 'optional_tool',
              description: 'Optional tool',
              parameters: const {'type': 'object', 'properties': {}},
            ),
          ],
        );
}

class _FakeClient extends LLMClient {
  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}
