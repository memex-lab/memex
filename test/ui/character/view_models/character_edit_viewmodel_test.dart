import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/character_editor.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/ui/character/view_models/character_edit_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  final character = CharacterModel(
    id: 'friend',
    name: '小安',
    tags: const [],
    persona: '温柔的朋友',
    enabled: true,
  );

  test('loads and edits character-owned world and memory entries', () async {
    final router = _FakeMemexRouter();
    final viewModel = CharacterEditViewModel(
      router: router,
      character: character,
    );

    expect(await viewModel.load(), isTrue);
    expect(viewModel.worldEntries.single['content'], '旧书店在街角');
    expect(viewModel.memoryEntries.single['label'], '称呼');

    viewModel.upsertWorldEntry(null, {'content': '周末会下雨'});
    viewModel.removeMemoryEntry(0);
    expect(viewModel.worldEntries, hasLength(2));
    expect(viewModel.memoryEntries, isEmpty);
  });

  test('saves one draft through the router and exposes persistence errors',
      () async {
    final router = _FakeMemexRouter();
    final viewModel = CharacterEditViewModel(
      router: router,
      character: character,
    );
    final draft = _draft(characterId: character.id);

    expect(await viewModel.save(draft), isTrue);
    expect(router.savedDraft, same(draft));

    router.saveError = StateError('save failed');
    expect(await viewModel.save(draft), isFalse);
    expect(viewModel.errorMessage, contains('save failed'));
    expect(viewModel.isSaving, isFalse);
  });

  test('reports workspace load failures', () async {
    final router = _FakeMemexRouter()
      ..loadError = StateError('workspace unavailable');
    final viewModel = CharacterEditViewModel(
      router: router,
      character: character,
    );

    expect(await viewModel.load(), isFalse);
    expect(viewModel.errorMessage, contains('workspace unavailable'));
    expect(viewModel.isLoading, isFalse);
  });
}

CharacterDraft _draft({String? characterId}) {
  return CharacterDraft(
    characterId: characterId,
    name: '小安',
    tags: const ['朋友'],
    persona: '温柔的朋友',
    enabled: true,
    worldEntries: const [],
    memoryEntries: const [],
  );
}

class _FakeMemexRouter implements MemexRouter {
  Object? loadError;
  Object? saveError;
  CharacterDraft? savedDraft;

  @override
  Future<Result<CharacterEditorData>> loadCharacterEditor(
    CharacterModel character,
  ) async {
    final error = loadError;
    if (error != null) {
      return Error<CharacterEditorData>(error, StackTrace.current);
    }
    return const Ok(CharacterEditorData(
      worldEntries: [
        {'content': '旧书店在街角'}
      ],
      memoryEntries: [
        {'label': '称呼', 'content': '喜欢被叫姐姐'}
      ],
    ));
  }

  @override
  Future<Result<CharacterModel>> saveCharacterDraft(
    CharacterDraft draft,
  ) async {
    savedDraft = draft;
    final error = saveError;
    if (error != null) {
      return Error<CharacterModel>(error, StackTrace.current);
    }
    return Ok(CharacterModel(
      id: draft.characterId ?? 'new-character',
      name: draft.name,
      tags: draft.tags,
      persona: draft.persona,
      enabled: draft.enabled,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
