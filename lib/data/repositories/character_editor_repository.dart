import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/media_service.dart';
import 'package:memex/domain/models/character_editor.dart';
import 'package:memex/domain/models/character_model.dart';

class CharacterEditorRepository {
  CharacterEditorRepository({
    CharacterService? characterService,
    CharacterWorkspaceService? workspaceService,
    MediaService? mediaService,
  })  : _characterService = characterService ?? CharacterService.instance,
        _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance,
        _mediaService = mediaService ?? MediaService.instance;

  final CharacterService _characterService;
  final CharacterWorkspaceService _workspaceService;
  final MediaService _mediaService;

  Future<CharacterEditorData> load({
    required String userId,
    required CharacterModel character,
  }) async {
    await _workspaceService.ensureInitialized(userId, character);
    final results = await Future.wait<List<Map<String, dynamic>>>([
      _workspaceService.loadUserProvidedWorldEntries(userId, character.id),
      _workspaceService.loadUserProvidedMemoryEntries(userId, character.id),
    ]);
    return CharacterEditorData(
      worldEntries: results[0],
      memoryEntries: results[1],
    );
  }

  Future<CharacterModel> save({
    required String userId,
    required CharacterDraft draft,
  }) async {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError.value(draft.name, 'name');
    }
    if (draft.persona.trim().isEmpty) {
      throw ArgumentError.value(draft.persona, 'persona');
    }

    final data = draft.toCharacterData();
    final characterId = draft.characterId;
    final CharacterModel saved;
    if (characterId == null) {
      saved = await _characterService.createCharacter(
        userId: userId,
        characterData: data,
      );
    } else {
      final updated = await _characterService.updateCharacter(
        userId: userId,
        characterId: characterId,
        updates: data,
      );
      if (updated == null) {
        throw StateError('Character $characterId was not found.');
      }
      saved = updated;
    }

    await _workspaceService.ensureInitialized(userId, saved);
    await _workspaceService.replaceUserProvidedWorldEntries(
      userId,
      saved.id,
      draft.worldEntries,
    );
    await _workspaceService.replaceUserProvidedMemoryEntries(
      userId,
      saved.id,
      draft.memoryEntries,
    );
    return saved;
  }

  Future<CharacterEditorMedia> importImage({
    required String userId,
    required String sourcePath,
  }) async {
    final imported = await _mediaService.importImage(
      userId: userId,
      sourcePath: sourcePath,
    );
    return CharacterEditorMedia(
      relativePath: imported.relativePath,
      absolutePath: imported.absolutePath,
    );
  }
}
