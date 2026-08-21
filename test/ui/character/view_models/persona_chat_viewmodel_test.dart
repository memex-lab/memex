import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/ui/character/view_models/persona_chat_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  const delay = Duration(milliseconds: 1200);
  final eventBus = EventBusService.instance;

  setUpAll(eventBus.connect);

  testWidgets('typing indicator appears after a short delay', (tester) async {
    final viewModel = PersonaChatViewModel(
      router: _FakeMemexRouter(),
      initialCharacterId: 'character-1',
      eventBus: eventBus,
      typingIndicatorDelay: delay,
    );
    addTearDown(viewModel.dispose);

    expect(await viewModel.sendMessage('hello'), isTrue);
    expect(viewModel.isReplying, isFalse);

    await tester.pump(const Duration(milliseconds: 1199));
    expect(viewModel.isReplying, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(viewModel.isReplying, isTrue);
  });

  testWidgets('quick completion cancels the pending typing indicator',
      (tester) async {
    final viewModel = PersonaChatViewModel(
      router: _FakeMemexRouter(),
      initialCharacterId: 'character-1',
      eventBus: eventBus,
      typingIndicatorDelay: delay,
    );
    addTearDown(viewModel.dispose);

    expect(await viewModel.sendMessage('hello'), isTrue);
    eventBus.emitEvent(
      PersonaChatMessageAddedMessage(
        characterId: 'character-1',
        replyPending: false,
      ),
    );
    await tester.pump();
    await tester.pump(delay);

    expect(viewModel.isReplying, isFalse);
  });

  testWidgets('consecutive sends do not restart the display delay',
      (tester) async {
    final viewModel = PersonaChatViewModel(
      router: _FakeMemexRouter(),
      initialCharacterId: 'character-1',
      eventBus: eventBus,
      typingIndicatorDelay: delay,
    );
    addTearDown(viewModel.dispose);

    expect(await viewModel.sendMessage('one'), isTrue);
    await tester.pump(const Duration(milliseconds: 800));
    expect(await viewModel.sendMessage('two'), isTrue);
    await tester.pump(const Duration(milliseconds: 400));

    expect(viewModel.isReplying, isTrue);
  });

  test('history and live updates use cursors without reloading visible rows',
      () async {
    final router = _PagingMemexRouter();
    final viewModel = PersonaChatViewModel(
      router: router,
      initialCharacterId: 'character-1',
      eventBus: eventBus,
    );
    addTearDown(viewModel.dispose);

    await viewModel.init();
    expect(viewModel.messages.map((message) => message.id), [3, 2]);
    expect(router.historyCalls, 0);

    await viewModel.loadMoreHistory();
    expect(viewModel.messages.map((message) => message.id), [3, 2, 1]);
    expect(viewModel.hasMoreHistory, isFalse);
    expect(router.historyCalls, 1);
    expect(router.lastBeforeCursor, 100);

    await viewModel.refreshLatest();
    expect(viewModel.messages.map((message) => message.id), [4, 3, 2, 1]);
    expect(router.liveCalls, 1);
    expect(router.lastAfterCursor, 200);
    expect(router.historyCalls, 1);
  });
}

class _FakeMemexRouter implements MemexRouter {
  int _nextMessageId = 1;

  @override
  Future<Result<int>> sendPersonaChatMessage(
    String characterId,
    String content,
  ) async {
    return Ok(_nextMessageId++);
  }

  @override
  Future<Result<PersonaChatMessagePageModel>> fetchNewPersonaChatMessages(
    String characterId, {
    required int afterCursor,
  }) async {
    return Ok(
      PersonaChatMessagePageModel(
        messages: const [],
        olderCursor: null,
        newestCursor: afterCursor,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PagingMemexRouter implements MemexRouter {
  int historyCalls = 0;
  int liveCalls = 0;
  int? lastBeforeCursor;
  int? lastAfterCursor;

  @override
  Future<Result<PersonaChatThreadModel>> loadPersonaChatThread(
    String characterId, {
    int limit = 30,
  }) async {
    return Ok(
      PersonaChatThreadModel(
        character: CharacterModel(
          id: characterId,
          name: '角色',
          tags: const [],
          persona: '测试角色',
          enabled: true,
        ),
        userId: 'user-1',
        messages: [_message(3), _message(2)],
        olderCursor: 100,
        newestCursor: 200,
      ),
    );
  }

  @override
  Future<Result<PersonaChatMessagePageModel>> fetchPersonaChatMessagePage(
    String characterId, {
    required int limit,
    int? beforeCursor,
  }) async {
    historyCalls += 1;
    lastBeforeCursor = beforeCursor;
    return Ok(
      PersonaChatMessagePageModel(
        messages: [_message(1)],
        olderCursor: null,
        newestCursor: 200,
      ),
    );
  }

  @override
  Future<Result<PersonaChatMessagePageModel>> fetchNewPersonaChatMessages(
    String characterId, {
    required int afterCursor,
  }) async {
    liveCalls += 1;
    lastAfterCursor = afterCursor;
    return Ok(
      PersonaChatMessagePageModel(
        messages: [_message(4)],
        olderCursor: null,
        newestCursor: 250,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PersonaChatMessageModel _message(int id) {
  return PersonaChatMessageModel(
    id: id,
    characterId: 'character-1',
    isFromCharacter: id.isEven,
    content: 'message-$id',
    isRead: true,
    timestamp: DateTime.fromMillisecondsSinceEpoch(id * 1000),
    messageType: 'chat',
    origin: 'conversation',
  );
}
