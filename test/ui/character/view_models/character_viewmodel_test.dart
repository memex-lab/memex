import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/ui/character/view_models/character_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  final character = CharacterModel(
    id: 'friend',
    name: '小安',
    tags: const [],
    persona: '温柔的朋友',
    enabled: true,
  );

  test('loads characters and reports failures explicitly', () async {
    final router = _FakeMemexRouter(characters: [character]);
    final viewModel = CharacterViewModel(router: router);

    expect(await viewModel.loadCharacters(), isTrue);
    expect(viewModel.characters, [character]);

    router.fetchError = StateError('load failed');
    expect(await viewModel.loadCharacters(), isFalse);
    expect(viewModel.characters, [character]);
    expect(viewModel.errorMessage, contains('load failed'));
  });

  test('does not update enabled state when persistence fails', () async {
    final router = _FakeMemexRouter(characters: [character]);
    final viewModel = CharacterViewModel(router: router);
    await viewModel.loadCharacters();
    router.enabledError = StateError('write failed');

    expect(await viewModel.setCharacterEnabled(character, false), isFalse);
    expect(viewModel.characters.single.enabled, isTrue);
    expect(viewModel.errorMessage, contains('write failed'));
  });

  test('removes a character only after a successful delete', () async {
    final router = _FakeMemexRouter(characters: [character]);
    final viewModel = CharacterViewModel(router: router);
    await viewModel.loadCharacters();
    router.deleteResult = const Ok(false);

    expect(await viewModel.deleteCharacter(character), isFalse);
    expect(viewModel.characters, [character]);

    router.deleteResult = const Ok(true);
    expect(await viewModel.deleteCharacter(character), isTrue);
    expect(viewModel.characters, isEmpty);
  });
}

class _FakeMemexRouter implements MemexRouter {
  _FakeMemexRouter({required this.characters});

  final List<CharacterModel> characters;
  Object? fetchError;
  Object? enabledError;
  Result<bool> deleteResult = const Ok(true);

  @override
  Future<Result<List<CharacterModel>>> fetchCharacters() async {
    final error = fetchError;
    return error == null
        ? Ok(characters)
        : Error<List<CharacterModel>>(error, StackTrace.current);
  }

  @override
  Future<Result<bool>> setCharacterEnabled(
    String characterId,
    bool enabled,
  ) async {
    final error = enabledError;
    return error == null
        ? const Ok(true)
        : Error<bool>(error, StackTrace.current);
  }

  @override
  Future<Result<bool>> deleteCharacter(String characterId) async {
    return deleteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
