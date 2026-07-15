import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/companion_agent/companion_agent.dart';
import 'package:memex/db/app_database.dart';
import 'package:test/test.dart';

void main() {
  test('canonical persona history includes proactive messages before reply',
      () {
    final state = AgentState(
      sessionId: 'companion_history',
      metadata: {'userId': 'user-1'},
    );
    state.history.messages.add(
      UserMessage([TextPart('stale state that must be replaced')]),
    );
    final now = DateTime.parse('2026-07-14T10:00:00+08:00');
    final newestFirst = [
      PersonaChatMessage(
        id: 3,
        characterId: 'yaoyao',
        isFromCharacter: true,
        content: '刚才突然又想起你那句话。',
        isRead: false,
        timestamp: now.add(const Duration(minutes: 2)),
        messageType: 'chat',
        origin: 'initiative',
        contactEpisodeId: 'episode-1',
      ),
      PersonaChatMessage(
        id: 2,
        characterId: 'yaoyao',
        isFromCharacter: true,
        content: '今天是不是又玩不够。',
        isRead: false,
        timestamp: now.add(const Duration(minutes: 1)),
        messageType: 'chat',
        origin: 'initiative',
        contactEpisodeId: 'episode-1',
      ),
      PersonaChatMessage(
        id: 1,
        characterId: 'yaoyao',
        isFromCharacter: false,
        content: '每天都玩不够了。',
        isRead: true,
        timestamp: now,
        messageType: 'chat',
        origin: 'conversation',
      ),
    ];

    CompanionAgent.replaceHistoryWithPersonaChat(
      state,
      newestFirst,
      model: 'test-model',
    );

    expect(state.history.messages, hasLength(3));
    expect(state.history.messages.first, isA<UserMessage>());
    expect(state.history.messages[1], isA<ModelMessage>());
    expect(
      (state.history.messages[1] as ModelMessage).textOutput,
      contains('今天是不是又玩不够'),
    );
    expect(
      (state.history.messages[2] as ModelMessage).textOutput,
      contains('刚才突然又想起你'),
    );
    expect(state.metadata['persona_chat_history_source'], 'database');
  });
}
