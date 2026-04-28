import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';

import 'package:memex/utils/logger.dart';

class CharacterService {
  static final CharacterService _instance = CharacterService._();
  static CharacterService get instance => _instance;

  /// Bump this whenever new default characters need to be seeded to existing users.
  /// New users get all characters from l10n.defaultCharacters at once.
  static const int _currentSeedVersion = 1;
  static const String _seedVersionFile = '.characters_seed_version';

  /// Migrations: version -> list of character IDs to seed for existing users.
  /// Only append new entries; never modify existing ones.
  static const Map<int, List<String>> _migrations = {
    1: ['counselor'],
  };

  final Logger _logger = getLogger('CharacterService');
  final FileSystemService _fileSystem = FileSystemService.instance;

  CharacterService._();

  /// Get the Characters directory path for a user
  String getCharactersPath(String userId) {
    return p.join(_fileSystem.getWorkspacePath(userId), 'Characters');
  }

  /// Ensure Characters directory exists and create default characters if empty
  Future<String> _ensureCharactersDirectory(String userId) async {
    final charsPath = getCharactersPath(userId);
    final dir = Directory(charsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Check if empty (ignore hidden files)
    final entities = await dir.list().toList();
    final visibleFiles = entities.where((e) {
      final name = p.basename(e.path);
      return !name.startsWith('.') && name.endsWith('.yaml');
    }).toList();

    if (visibleFiles.isEmpty) {
      await _createDefaultCharacters(userId, charsPath);
      await _writeSeedVersion(charsPath, _currentSeedVersion);
    } else {
      await _runMigrations(userId, charsPath);
    }

    return charsPath;
  }

  /// Create default characters
  Future<void> _createDefaultCharacters(String userId, String charsPath) async {
    final defaultCharacters = UserStorage.l10n.defaultCharacters;

    for (var charData in defaultCharacters) {
      final charId = charData['id'] as String;
      await _seedCharacterFromData(userId, charsPath, charId, charData);
    }
  }

  /// Build merged persona string from character data map.
  String _buildPersona(Map<String, dynamic> charData) {
    var persona = charData['persona'] as String;
    if (charData.containsKey('style_guide')) {
      persona += "\n\n## Style Guide\n${charData['style_guide']}";
    }
    if (charData.containsKey('pkm_interest_filter')) {
      persona +=
          "\n\n## PKM Interest Filter\n${charData['pkm_interest_filter']}";
    }
    if (charData.containsKey('example_dialogue')) {
      persona += "\n\n## Example Dialogue\n${charData['example_dialogue']}";
    }
    return persona;
  }

  /// Seed a single character from its data map. Skips if file already exists.
  Future<void> _seedCharacterFromData(
    String userId,
    String charsPath,
    String charId,
    Map<String, dynamic> charData,
  ) async {
    final charFile = p.join(charsPath, '$charId.yaml');
    if (await File(charFile).exists()) return;

    final charDict = {
      "name": charData['name'],
      "tags": charData['tags'],
      "persona": _buildPersona(charData),
      "avatar": charData['avatar'],
      "enabled": true,
    };

    try {
      await _fileSystem.writeYamlFile(charFile, charDict);
      _logger.info("Created default character $charId for user $userId");
    } catch (e) {
      _logger.severe("Failed to create character $charId for user $userId: $e");
    }
  }

  /// Seed a single character by ID if it doesn't exist. Looks up data from l10n defaults.
  Future<void> _seedCharacterById(
    String userId,
    String charsPath,
    String charId,
  ) async {
    final allDefaults = UserStorage.l10n.defaultCharacters;
    final charData = allDefaults.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c!['id'] == charId,
          orElse: () => null,
        );
    if (charData == null) return;
    await _seedCharacterFromData(userId, charsPath, charId, charData);
  }

  /// Read the current seed version (0 if file doesn't exist).
  Future<int> _readSeedVersion(String charsPath) async {
    final file = File(p.join(charsPath, _seedVersionFile));
    if (!await file.exists()) return 0;
    try {
      return int.parse((await file.readAsString()).trim());
    } catch (_) {
      return 0;
    }
  }

  /// Write the seed version marker.
  Future<void> _writeSeedVersion(String charsPath, int version) async {
    try {
      final file = File(p.join(charsPath, _seedVersionFile));
      await file.writeAsString(version.toString());
    } catch (e) {
      _logger.warning('Failed to write seed version: $e');
    }
  }

  /// Run all pending migrations from current version to [_currentSeedVersion].
  Future<void> _runMigrations(String userId, String charsPath) async {
    final currentVersion = await _readSeedVersion(charsPath);
    if (currentVersion >= _currentSeedVersion) return;

    for (int v = currentVersion + 1; v <= _currentSeedVersion; v++) {
      final charIds = _migrations[v];
      if (charIds == null) continue;
      for (final charId in charIds) {
        await _seedCharacterById(userId, charsPath, charId);
      }
    }

    await _writeSeedVersion(charsPath, _currentSeedVersion);
  }

  /// Get all characters for a user
  Future<List<CharacterModel>> getAllCharacters(String userId) async {
    final charsPath = await _ensureCharactersDirectory(userId);
    final dir = Directory(charsPath);
    final characters = <CharacterModel>[];

    await for (final entity in dir.list()) {
      if (entity is File &&
          !p.basename(entity.path).startsWith('.') &&
          entity.path.endsWith('.yaml')) {
        try {
          final content = await entity.readAsString();
          final doc = loadYaml(content);
          final data = jsonDecode(jsonEncode(doc)); // Convert YamlMap to Map
          final charId = p.basenameWithoutExtension(entity.path);

          // Use CharacterModel.fromJson but handle id separately as it's not in the file sometimes or is filename
          // CharacterModel expects 'id' in json.
          data['id'] = charId;

          final character = CharacterModel.fromJson(data);
          characters.add(character);
        } catch (e) {
          _logger.warning("Failed to load character from ${entity.path}: $e");
        }
      }
    }

    // Sort by ID to be consistent
    characters.sort((a, b) => a.id.compareTo(b.id));
    return characters;
  }

  /// Get specific character
  Future<CharacterModel?> getCharacter(String userId, String characterId,
      {bool returnPlaceholder = true}) async {
    if (characterId == "0") {
      return CharacterModel(
          id: "0", name: "memex", tags: [], persona: "", enabled: true);
    }

    final charsPath = await _ensureCharactersDirectory(userId);
    var charFile = File(p.join(charsPath, '$characterId.yaml'));
    if (!await charFile.exists()) {
      _logger.warning("Character $characterId not found for user $userId");
      if (returnPlaceholder) {
        return CharacterModel(
          id: characterId,
          name: "[Deleted character]",
          tags: [],
          persona: "This character has been deleted",
          enabled: false,
          avatar: null,
        );
      }
      return null;
    }

    try {
      final content = await charFile.readAsString();
      final doc = loadYaml(content);
      final data = jsonDecode(jsonEncode(doc));
      data['id'] = characterId;

      final character = CharacterModel.fromJson(
          data); // CharacterModel.fromJson defines its own defaults

      return character;
    } catch (e) {
      _logger.severe("Failed to load character $characterId: $e");
      return null;
    }
  }

  /// Create new character
  Future<CharacterModel> createCharacter({
    required String userId,
    required Map<String, dynamic> characterData,
  }) async {
    final charsPath = await _ensureCharactersDirectory(userId);
    final dir = Directory(charsPath);

    // Generate new ID (max + 1)
    final existingIds = <int>{};
    await for (final entity in dir.list()) {
      if (entity is File && !p.basename(entity.path).startsWith('.')) {
        final name = p.basenameWithoutExtension(entity.path);
        try {
          existingIds.add(int.parse(name));
        } catch (_) {}
      }
    }

    var newId = "1";
    if (existingIds.isNotEmpty) {
      newId = (existingIds.reduce(max) + 1).toString();
    }

    final charFile = p.join(charsPath, '$newId.yaml');
    final charDict = {
      "name": characterData['name'] ?? "",
      "tags": characterData['tags'] ?? [],
      "persona": characterData['persona'] ?? "",
      "avatar": characterData['avatar'],
      "enabled": characterData['enabled'] ?? true,
      "memory": characterData['memory'] ?? [],
    };

    try {
      await _fileSystem.writeYamlFile(charFile, charDict);
      _logger.info("Created character $newId for user $userId");

      charDict['id'] = newId;
      return CharacterModel.fromJson(charDict);
    } catch (e) {
      _logger.severe("Failed to create character for user $userId: $e");
      rethrow;
    }
  }

  /// Update existing character
  Future<CharacterModel?> updateCharacter({
    required String userId,
    required String characterId,
    required Map<String, dynamic> updates,
  }) async {
    final charsPath = await _ensureCharactersDirectory(userId);
    var charFile = File(p.join(charsPath, '$characterId.yaml'));
    if (!await charFile.exists()) {
      _logger.warning("Character $characterId not found for user $userId");
      return null;
    }

    try {
      final content = await charFile.readAsString();
      final doc = loadYaml(content);
      final charData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

      // Update fields
      if (updates.containsKey('name')) {
        charData['name'] = updates['name'];
      }
      if (updates.containsKey('tags')) {
        charData['tags'] = updates['tags'];
      }
      if (updates.containsKey('persona')) {
        charData['persona'] = updates['persona'];
      }
      if (updates.containsKey('avatar')) {
        charData['avatar'] = updates['avatar'];
      }
      if (updates.containsKey('enabled')) {
        charData['enabled'] = updates['enabled'];
      }
      if (updates.containsKey('memory')) {
        charData['memory'] = updates['memory'];
      }
      if (updates.containsKey('is_primary_companion')) {
        charData['is_primary_companion'] = updates['is_primary_companion'];
      }
      if (updates.containsKey('interest_filter')) {
        charData['interest_filter'] = updates['interest_filter'];
      }

      // Remove legacy fields if they exist (merged into persona already by backend logic usually, but cleanup is good)
      charData.remove('style_guide');
      charData.remove('example_dialogue');
      charData.remove('pkm_interest_filter');

      await _fileSystem.writeYamlFile(charFile.path, charData);

      _logger.info("Updated character $characterId for user $userId");
      charData['id'] = characterId;
      return CharacterModel.fromJson(charData);
    } catch (e) {
      _logger.severe(
          "Failed to update character $characterId for user $userId: $e");
      rethrow;
    }
  }

  /// Physically delete character
  Future<bool> deleteCharacter(String userId, String characterId) async {
    final charsPath = await _ensureCharactersDirectory(userId);
    var charFile = File(p.join(charsPath, '$characterId.yaml'));
    if (!await charFile.exists()) {
      _logger.warning("Character $characterId not found for deletion");
      return false;
    }

    try {
      await charFile.delete();
      _logger
          .info("Physically deleted character $characterId for user $userId");
      return true;
    } catch (e) {
      _logger.severe("Failed to delete character $characterId: $e");
      return false;
    }
  }

  /// Set character enabled status
  Future<bool> setCharacterEnabled(
      String userId, String characterId, bool enabled) async {
    final result = await updateCharacter(
      userId: userId,
      characterId: characterId,
      updates: {"enabled": enabled},
    );
    return result != null;
  }

  /// Set a character as the primary companion.
  /// Clears the flag on all other characters first.
  Future<bool> setPrimaryCompanion(String userId, String characterId) async {
    final characters = await getAllCharacters(userId);
    // Clear existing primary
    for (final char in characters) {
      if (char.isPrimaryCompanion && char.id != characterId) {
        await updateCharacter(
          userId: userId,
          characterId: char.id,
          updates: {'is_primary_companion': false},
        );
      }
    }
    // Set new primary
    final result = await updateCharacter(
      userId: userId,
      characterId: characterId,
      updates: {'is_primary_companion': true, 'enabled': true},
    );
    return result != null;
  }

  /// Get the user's primary companion character.
  /// Returns the first enabled character if none is explicitly set.
  Future<CharacterModel?> getPrimaryCompanion(String userId) async {
    final characters = await getAllCharacters(userId);
    final primary = characters.where((c) => c.isPrimaryCompanion).firstOrNull;
    if (primary != null) return primary;
    // Fallback: first enabled character
    return characters.where((c) => c.enabled).firstOrNull;
  }
}
