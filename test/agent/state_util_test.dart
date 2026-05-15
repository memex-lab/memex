import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:test/test.dart';

void main() {
  group('loadOrCreateAgentState', () {
    late Directory tempRoot;
    const userId = 'state_util_user';

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('memex_state_util_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('repairs legacy assistant thinking into content blocks', () async {
      final state = AgentState(
        sessionId: 'legacy_thinking_state',
        metadata: {'userId': userId},
      );
      state.history.messages.add(
        ModelMessage(
          model: 'claude-test',
          thought: 'Need to inspect a file first.',
          textOutput: 'I will read it.',
          functionCalls: [
            FunctionCall(
              id: 'toolu_1',
              name: 'Read',
              arguments: '{"path":"a.md"}',
            ),
          ],
          stopReason: 'tool_use',
          timestamp: 123,
        ),
      );
      await saveAgentState(state);

      final loaded = await loadOrCreateAgentState('legacy_thinking_state', {
        'userId': userId,
      });

      final message = loaded.history.messages.single as ModelMessage;
      expect(message.contentBlocks, [
        {'type': 'thinking', 'thinking': 'Need to inspect a file first.'},
        {'type': 'text', 'text': 'I will read it.'},
        {
          'type': 'tool_use',
          'id': 'toolu_1',
          'name': 'Read',
          'input': {'path': 'a.md'},
        },
      ]);
    });

    test('preserves provider-native content blocks', () async {
      final state = AgentState(
        sessionId: 'native_blocks_state',
        metadata: {'userId': userId},
      );
      const blocks = [
        {'type': 'redacted_thinking', 'data': 'opaque-data'},
      ];
      state.history.messages.add(
        ModelMessage(
          model: 'claude-test',
          thought: 'Hidden provider-native block exists.',
          contentBlocks: blocks,
          timestamp: 123,
        ),
      );
      await saveAgentState(state);

      final loaded = await loadOrCreateAgentState('native_blocks_state', {
        'userId': userId,
      });

      final message = loaded.history.messages.single as ModelMessage;
      expect(message.contentBlocks, blocks);
    });

    test('repairs legacy DeepSeek V4 tool-call turns', () async {
      final state = AgentState(
        sessionId: 'legacy_deepseek_reasoning_state',
        metadata: {'userId': userId},
      );
      state.history.messages.add(
        ModelMessage(
          model: 'deepseek-v4-pro',
          functionCalls: [
            FunctionCall(
              id: 'call_1',
              name: 'lookup',
              arguments: '{}',
            ),
          ],
          stopReason: 'tool_calls',
          timestamp: 123,
        ),
      );
      await saveAgentState(state);

      final loaded = await loadOrCreateAgentState(
        'legacy_deepseek_reasoning_state',
        {'userId': userId},
      );

      final message = loaded.history.messages.single as ModelMessage;
      expect(message.thought, ' ');
    });
  });
}
