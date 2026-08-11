import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
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
  Future<Result<List<PersonaChatMessageModel>>> fetchPersonaChatMessages(
    String characterId, {
    required int limit,
    int offset = 0,
  }) async {
    return const Ok([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
