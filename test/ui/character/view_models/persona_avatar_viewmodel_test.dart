import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  final eventBus = EventBusService.instance;

  setUpAll(eventBus.connect);

  test('ensureLoaded is a no-op until first call and stays idempotent',
      () async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final router = _FakeMemexRouter([
      PersonaAvatarSummary(character: character, unreadCount: 2),
    ]);
    final viewModel = PersonaAvatarViewModel(router: router);
    addTearDown(viewModel.dispose);

    expect(viewModel.character, isNull);
    expect(router.loadCount, 0);

    await viewModel.ensureLoaded();
    await viewModel.ensureLoaded();

    expect(viewModel.character?.id, 'friend');
    expect(viewModel.unreadCount, 2);
    expect(router.loadCount, 1);
  });

  test('loads avatar summary and refreshes when chat unread state changes',
      () async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final router = _FakeMemexRouter([
      PersonaAvatarSummary(character: character, unreadCount: 2),
      PersonaAvatarSummary(character: character, unreadCount: 0),
    ]);
    final viewModel = PersonaAvatarViewModel(
      router: router,
      eventBus: eventBus,
    );
    addTearDown(viewModel.dispose);

    await viewModel.init();
    expect(viewModel.character?.id, 'friend');
    expect(viewModel.unreadCount, 2);

    eventBus.emitEvent(
      PersonaChatUnreadChangedMessage(characterId: 'friend'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.unreadCount, 0);
    expect(router.loadCount, 2);
  });

  test('exposes load failures without discarding the current summary',
      () async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final router = _FakeMemexRouter([
      PersonaAvatarSummary(character: character, unreadCount: 1),
    ]);
    final viewModel = PersonaAvatarViewModel(router: router);
    addTearDown(viewModel.dispose);

    await viewModel.refresh();
    router.error = StateError('unavailable');
    await viewModel.refresh();

    expect(viewModel.character?.id, 'friend');
    expect(viewModel.unreadCount, 1);
    expect(viewModel.errorMessage, contains('unavailable'));
  });

  test('ignores a stale refresh that completes after a newer refresh',
      () async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final router = _ControlledMemexRouter();
    final viewModel = PersonaAvatarViewModel(router: router);
    addTearDown(viewModel.dispose);

    final olderRefresh = viewModel.refresh();
    final newerRefresh = viewModel.refresh();
    router.requests[1].complete(
      Ok(PersonaAvatarSummary(character: character, unreadCount: 0)),
    );
    await newerRefresh;
    router.requests[0].complete(
      Ok(PersonaAvatarSummary(character: character, unreadCount: 3)),
    );
    await olderRefresh;

    expect(viewModel.unreadCount, 0);
  });
}

class _FakeMemexRouter implements MemexRouter {
  _FakeMemexRouter(this.summaries);

  final List<PersonaAvatarSummary> summaries;
  int loadCount = 0;
  Object? error;

  @override
  Future<Result<PersonaAvatarSummary>> loadPersonaAvatarSummary() async {
    loadCount += 1;
    final failure = error;
    if (failure != null) return Error(failure, StackTrace.current);
    final index = (loadCount - 1).clamp(0, summaries.length - 1);
    return Ok(summaries[index]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ControlledMemexRouter implements MemexRouter {
  final requests = <Completer<Result<PersonaAvatarSummary>>>[];

  @override
  Future<Result<PersonaAvatarSummary>> loadPersonaAvatarSummary() {
    final request = Completer<Result<PersonaAvatarSummary>>();
    requests.add(request);
    return request.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
