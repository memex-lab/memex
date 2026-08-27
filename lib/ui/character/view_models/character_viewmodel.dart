import 'package:flutter/foundation.dart';

import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

/// ViewModel for the Character config page. Holds character list and
/// delegates CRUD to [MemexRouter].
class CharacterViewModel extends ChangeNotifier {
  CharacterViewModel({required MemexRouter router}) : _router = router;

  final MemexRouter _router;

  List<CharacterModel> characters = [];
  bool isLoading = false;
  String? errorMessage;

  Future<bool> loadCharacters() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    var succeeded = false;
    final result = await _router.fetchCharacters();
    result.when(
      onOk: (list) {
        characters = list;
        succeeded = true;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    isLoading = false;
    notifyListeners();
    return succeeded;
  }

  Future<bool> setCharacterEnabled(
      CharacterModel character, bool enabled) async {
    errorMessage = null;
    var succeeded = false;
    final result = await _router.setCharacterEnabled(character.id, enabled);
    result.when(
      onOk: (updated) {
        succeeded = updated;
        if (!updated) {
          errorMessage = UserStorage.l10n.unknownError;
          notifyListeners();
          return;
        }
        final index = characters.indexWhere((c) => c.id == character.id);
        if (index != -1) {
          characters[index] = character.copyWith(enabled: enabled);
          notifyListeners();
        }
      },
      onError: (error, _) {
        errorMessage = error.toString();
        notifyListeners();
      },
    );
    return succeeded;
  }

  Future<bool> deleteCharacter(CharacterModel character) async {
    errorMessage = null;
    var succeeded = false;
    final result = await _router.deleteCharacter(character.id);
    result.when(
      onOk: (deleted) {
        succeeded = deleted;
        if (deleted) {
          characters.removeWhere((c) => c.id == character.id);
        } else {
          errorMessage = UserStorage.l10n.unknownError;
        }
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    notifyListeners();
    return succeeded;
  }
}
