import 'dart:async';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/agent/run_mode/agent_run_mode.dart';

void main() {
  test('gateMutatingToolCall denies mutating tools in confirm mode', () async {
    final state = AgentState(
      sessionId: 'session-1',
      metadata: {
        AgentRunMode.metadataKey: AgentRunMode.confirm.wireName,
        'chat_session_id': 'session-1',
      },
    );

    final denied = await runZoned(
      () => gateMutatingToolCall(
        toolName: 'mint_record_fact_id',
        summary: 'Reserve a new card id (processing placeholder)',
      ),
      zoneValues: {
        AgentCallToolContext.ZoneKey: AgentCallToolContext(
          state: state,
          agent: StatefulAgent(
            name: 'test',
            client: _NoOpClient(),
            modelConfig: ModelConfig(model: 'test'),
            state: state,
            tools: const [],
            withGeneralPrinciples: false,
          ),
          batchCallId: 'batch-1',
          cancelToken: CancelToken(),
        ),
      },
    );

    expect(denied, isNotNull);
    final textPart = denied!.content as TextPart;
    expect(textPart.text, contains('declined'));
  });
}

class _NoOpClient extends LLMClient {
  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) {
    throw UnsupportedError('not used');
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
    throw UnsupportedError('not used');
  }
}
