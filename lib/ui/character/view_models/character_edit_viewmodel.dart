import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/character_editor.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/result.dart';

class CharacterEditViewModel extends ChangeNotifier {
  CharacterEditViewModel({
    required MemexRouter router,
    this.character,
  }) : _router = router;

  final MemexRouter _router;
  final CharacterModel? character;

  List<Map<String, dynamic>> worldEntries = [];
  List<Map<String, dynamic>> memoryEntries = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<bool> load() async {
    final current = character;
    if (current == null) return true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    var succeeded = false;
    final result = await _router.loadCharacterEditor(current);
    result.when(
      onOk: (data) {
        worldEntries = data.worldEntries
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList();
        memoryEntries = data.memoryEntries
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList();
        succeeded = true;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    isLoading = false;
    notifyListeners();
    return succeeded;
  }

  Future<bool> save(CharacterDraft draft) async {
    if (isSaving) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    var succeeded = false;
    final result = await _router.saveCharacterDraft(draft);
    result.when(
      onOk: (_) => succeeded = true,
      onError: (error, _) => errorMessage = error.toString(),
    );
    isSaving = false;
    notifyListeners();
    return succeeded;
  }

  Future<CharacterEditorMedia?> importImage(String sourcePath) async {
    CharacterEditorMedia? media;
    final result = await _router.importCharacterEditorImage(sourcePath);
    result.when(
      onOk: (value) {
        media = value;
        errorMessage = null;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    notifyListeners();
    return media;
  }

  void removeWorldEntry(int index) {
    worldEntries.removeAt(index);
    notifyListeners();
  }

  void upsertWorldEntry(int? index, Map<String, dynamic> entry) {
    if (index == null) {
      worldEntries.add(entry);
    } else {
      worldEntries[index] = entry;
    }
    notifyListeners();
  }

  void removeMemoryEntry(int index) {
    memoryEntries.removeAt(index);
    notifyListeners();
  }

  void upsertMemoryEntry(int? index, Map<String, dynamic> entry) {
    if (index == null) {
      memoryEntries.add(entry);
    } else {
      memoryEntries[index] = entry;
    }
    notifyListeners();
  }
}
