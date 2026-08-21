import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_workspace.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

/// Owns all persistence inside a character's private workspace.
class CharacterWorkspaceService {
  CharacterWorkspaceService({FileSystemService? fileSystem})
      : _injectedFileSystem = fileSystem;

  static final CharacterWorkspaceService instance = CharacterWorkspaceService();

  final FileSystemService? _injectedFileSystem;
  final _logger = getLogger('CharacterWorkspaceService');
  final Map<String, Lock> _workspaceLocks = {};

  FileSystemService get _fileSystem =>
      _injectedFileSystem ?? FileSystemService.instance;

  Lock _lockFor(String userId, String characterId) {
    return _workspaceLocks.putIfAbsent(
      '$userId:$characterId',
      Lock.new,
    );
  }

  Future<void> ensureInitialized(
    String userId,
    CharacterModel character,
  ) {
    _validateCharacterId(character.id);
    return _lockFor(userId, character.id).synchronized(
      () => _ensureInitializedUnlocked(userId, character),
    );
  }

  Future<bool> isHistoryAcquaintanceComplete(
    String userId,
    String characterId,
  ) async {
    _validateCharacterId(characterId);
    final marker = File(
      _fileSystem.getCharacterHistoryAcquaintancePath(userId, characterId),
    );
    if (!await marker.exists()) return false;
    try {
      final value = jsonDecode(await marker.readAsString());
      return value is Map && value['completed'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> completeHistoryAcquaintance({
    required String userId,
    required String characterId,
    required DateTime completedAt,
  }) {
    _validateCharacterId(characterId);
    return _lockFor(userId, characterId).synchronized(
      () => _writeText(
        File(
          _fileSystem.getCharacterHistoryAcquaintancePath(
            userId,
            characterId,
          ),
        ),
        '${const JsonEncoder.withIndent('  ').convert({
              'version': 1,
              'completed': true,
              'completed_at': completedAt.toIso8601String(),
            })}\n',
      ),
    );
  }

  Future<CharacterObservation?> enqueueObservation({
    required String userId,
    required CharacterModel character,
    required String sourceEventId,
    required String source,
    required String content,
    required DateTime observedAt,
    String? factId,
  }) {
    _validateCharacterId(character.id);
    if (sourceEventId.trim().isEmpty) {
      throw ArgumentError.value(sourceEventId, 'sourceEventId');
    }
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content');
    }

    return _lockFor(userId, character.id).synchronized(() async {
      await _ensureInitializedUnlocked(userId, character);

      final pending = await _readInbox(userId, character.id);
      final existing = pending
          .where((item) => item.sourceEventId == sourceEventId)
          .firstOrNull;
      if (existing != null) return existing;

      final index = await _readInteractionIndex(userId, character.id);
      final wasDigested = index.any(
        (item) => item['source_event_id'] == sourceEventId,
      );
      if (wasDigested) return null;

      final runtime = await _readRuntime(userId, character.id);
      var highestSequence = runtime.lastDigestedSequence;
      for (final item in pending) {
        if (item.sequence > highestSequence) highestSequence = item.sequence;
      }
      for (final item in index) {
        final sequence = (item['sequence'] as num?)?.toInt() ?? 0;
        if (sequence > highestSequence) highestSequence = sequence;
      }
      final sequence = runtime.nextObservationSequence > highestSequence
          ? runtime.nextObservationSequence
          : highestSequence + 1;
      final observation = CharacterObservation(
        id: _observationId(source, sourceEventId),
        sequence: sequence,
        sourceEventId: sourceEventId,
        source: source,
        factId: factId,
        content: content.trim(),
        observedAt: observedAt,
      );

      await _writeJsonLines(
        _fileSystem.getCharacterInboxPath(userId, character.id),
        [...pending.map((item) => item.toJson()), observation.toJson()],
      );
      await _writeRuntime(
        userId,
        character.id,
        runtime.copyWith(nextObservationSequence: sequence + 1),
      );
      return observation;
    });
  }

  Future<List<CharacterObservation>> loadPendingObservations(
    String userId,
    String characterId,
  ) async {
    _validateCharacterId(characterId);
    final observations = await _readInbox(userId, characterId);
    observations.sort((a, b) => a.sequence.compareTo(b.sequence));
    return observations;
  }

  Future<List<Map<String, dynamic>>> loadUserProvidedMemoryEntries(
    String userId,
    String characterId,
  ) {
    _validateCharacterId(characterId);
    return _readJsonLines(
      _fileSystem.getCharacterUserMemoryEntriesPath(userId, characterId),
    );
  }

  Future<void> replaceUserProvidedMemoryEntries(
    String userId,
    String characterId,
    List<Map<String, dynamic>> entries,
  ) {
    _validateCharacterId(characterId);
    return _lockFor(userId, characterId).synchronized(
      () => _writeJsonLines(
        _fileSystem.getCharacterUserMemoryEntriesPath(userId, characterId),
        entries,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> loadUserProvidedWorldEntries(
    String userId,
    String characterId,
  ) {
    _validateCharacterId(characterId);
    return _readJsonLines(
      _fileSystem.getCharacterUserWorldEntriesPath(userId, characterId),
    );
  }

  Future<void> replaceUserProvidedWorldEntries(
    String userId,
    String characterId,
    List<Map<String, dynamic>> entries,
  ) {
    _validateCharacterId(characterId);
    return _lockFor(userId, characterId).synchronized(
      () => _writeJsonLines(
        _fileSystem.getCharacterUserWorldEntriesPath(userId, characterId),
        entries,
      ),
    );
  }

  Future<List<CharacterPendingThought>> loadPendingThoughts(
    String userId,
    String characterId,
  ) async {
    _validateCharacterId(characterId);
    final rows = await _readJsonLines(
      _fileSystem.getCharacterPendingThoughtsPath(userId, characterId),
    );
    final thoughts = <CharacterPendingThought>[];
    for (final row in rows) {
      try {
        thoughts.add(CharacterPendingThought.fromJson(row));
      } catch (error) {
        _logger.warning(
          'Ignoring malformed pending thought for $characterId: $error',
        );
      }
    }
    thoughts.sort((a, b) => a.wakeAt.compareTo(b.wakeAt));
    return thoughts;
  }

  Future<CharacterPendingThought?> getPendingThought(
    String userId,
    String characterId,
    String thoughtId,
  ) async {
    final thoughts = await loadPendingThoughts(userId, characterId);
    return thoughts.where((thought) => thought.id == thoughtId).firstOrNull;
  }

  /// Stores one future intention. Reconsidering the same source updates the
  /// existing thought so stale scheduled tasks can be ignored safely.
  Future<CharacterPendingThought> rememberPendingThought({
    required String userId,
    required String characterId,
    required String sourceEventId,
    required String reason,
    required DateTime wakeAt,
    required DateTime now,
    String? factId,
    String? thoughtId,
  }) {
    _validateCharacterId(characterId);
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(reason, 'reason');
    }
    if (!wakeAt.isAfter(now)) {
      throw ArgumentError.value(wakeAt, 'wakeAt');
    }
    return _lockFor(userId, characterId).synchronized(() async {
      final rows = await _readJsonLines(
        _fileSystem.getCharacterPendingThoughtsPath(userId, characterId),
      );
      final thoughts = <CharacterPendingThought>[];
      for (final row in rows) {
        try {
          thoughts.add(CharacterPendingThought.fromJson(row));
        } catch (_) {
          // Malformed operational rows are discarded when the agenda rewrites.
        }
      }
      final id = thoughtId ?? _pendingThoughtId(sourceEventId);
      final index = thoughts.indexWhere((thought) => thought.id == id);
      final thought = index < 0
          ? CharacterPendingThought(
              id: id,
              sourceEventId: sourceEventId,
              factId: factId,
              reason: normalizedReason,
              createdAt: now,
              wakeAt: wakeAt,
            )
          : thoughts[index].copyWith(
              reason: normalizedReason,
              wakeAt: wakeAt,
              factId: factId,
            );
      if (index < 0) {
        thoughts.add(thought);
      } else {
        thoughts[index] = thought;
      }
      await _writeJsonLines(
        _fileSystem.getCharacterPendingThoughtsPath(userId, characterId),
        thoughts.map((item) => item.toJson()).toList(),
      );
      return thought;
    });
  }

  Future<void> resolvePendingThought(
    String userId,
    String characterId,
    String thoughtId,
  ) {
    _validateCharacterId(characterId);
    return _lockFor(userId, characterId).synchronized(() async {
      final path =
          _fileSystem.getCharacterPendingThoughtsPath(userId, characterId);
      final rows = await _readJsonLines(path);
      rows.removeWhere((row) => row['id'] == thoughtId);
      await _writeJsonLines(path, rows);
    });
  }

  Future<bool> isObservationPending(
    String userId,
    String characterId,
    String observationId,
  ) async {
    final pending = await loadPendingObservations(userId, characterId);
    return pending.any((item) => item.id == observationId);
  }

  /// Marks one observation as digested and removes its raw content.
  Future<void> completeObservation({
    required String userId,
    required String characterId,
    required String observationId,
  }) {
    _validateCharacterId(characterId);
    return _lockFor(userId, characterId).synchronized(() async {
      final pending = await _readInbox(userId, characterId);
      final index = await _readInteractionIndex(userId, characterId);
      final pendingPosition =
          pending.indexWhere((item) => item.id == observationId);
      final indexedPosition =
          index.indexWhere((item) => item['observation_id'] == observationId);

      if (pendingPosition < 0 && indexedPosition >= 0) return;
      if (pendingPosition < 0) {
        throw StateError('Observation $observationId is not pending.');
      }

      final observation = pending[pendingPosition];
      if (indexedPosition < 0) {
        index.add({
          'observation_id': observation.id,
          'sequence': observation.sequence,
          'source_event_id': observation.sourceEventId,
          'source': observation.source,
          if (observation.factId != null) 'fact_id': observation.factId,
          'digested_at': DateTime.now().toIso8601String(),
        });
        await _writeJsonLines(
          _fileSystem.getCharacterInteractionIndexPath(
            userId,
            characterId,
          ),
          index,
        );
      }

      pending.removeAt(pendingPosition);
      await _writeJsonLines(
        _fileSystem.getCharacterInboxPath(userId, characterId),
        pending.map((item) => item.toJson()).toList(),
      );

      final runtime = await _readRuntime(userId, characterId);
      final lastDigested = observation.sequence > runtime.lastDigestedSequence
          ? observation.sequence
          : runtime.lastDigestedSequence;
      await _writeRuntime(
        userId,
        characterId,
        runtime.copyWith(lastDigestedSequence: lastDigested),
      );
    });
  }

  /// Creates or replaces one character-authored Markdown note under PKM/.
  Future<void> writePkmNote({
    required String userId,
    required String characterId,
    required String relativePath,
    required String content,
  }) {
    _validateCharacterId(characterId);
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content');
    }
    return _lockFor(userId, characterId).synchronized(() async {
      final pkmRoot = _fileSystem.getCharacterPkmPath(userId, characterId);
      final target = _resolveMarkdownPath(pkmRoot, relativePath);
      await Directory(p.dirname(target)).create(recursive: true);
      await _writeText(File(target), '${content.trim()}\n');
    });
  }

  /// Writes one idempotent, character-authored journal entry.
  Future<void> writeJournalEntry({
    required String userId,
    required String characterId,
    required CharacterObservation observation,
    required String content,
  }) {
    _validateCharacterId(characterId);
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content');
    }
    return _lockFor(userId, characterId).synchronized(() async {
      final localTime = observation.observedAt.toLocal();
      final journalRoot =
          _fileSystem.getCharacterJournalPath(userId, characterId);
      final journalPath = p.join(
        journalRoot,
        localTime.year.toString().padLeft(4, '0'),
        localTime.month.toString().padLeft(2, '0'),
        '${localTime.day.toString().padLeft(2, '0')}.md',
      );
      final file = File(journalPath);
      await file.parent.create(recursive: true);
      final existing = await file.exists() ? await file.readAsString() : '';
      final start = '<!-- observation:${observation.id}:start -->';
      final end = '<!-- observation:${observation.id}:end -->';
      final entry = '$start\n'
          '## ${localTime.hour.toString().padLeft(2, '0')}:'
          '${localTime.minute.toString().padLeft(2, '0')}\n\n'
          '${content.trim()}\n'
          '$end';

      final startIndex = existing.indexOf(start);
      final endIndex = existing.indexOf(end);
      String updated;
      if (startIndex >= 0 && endIndex >= startIndex) {
        updated = existing.replaceRange(
          startIndex,
          endIndex + end.length,
          entry,
        );
      } else {
        final separator = existing.trim().isEmpty ? '' : '\n\n';
        updated = '${existing.trimRight()}$separator$entry\n';
      }
      await _writeText(file, updated);
    });
  }

  Future<void> _ensureInitializedUnlocked(
    String userId,
    CharacterModel character,
  ) async {
    final workspace =
        _fileSystem.getCharacterWorkspacePath(userId, character.id);
    await Directory(workspace).create(recursive: true);
    await Directory(_fileSystem.getCharacterWorldPath(userId, character.id))
        .create(recursive: true);
    await Directory(_fileSystem.getCharacterPkmPath(userId, character.id))
        .create(recursive: true);
    await Directory(_fileSystem.getCharacterJournalPath(userId, character.id))
        .create(recursive: true);
    await Directory(
      _fileSystem.getCharacterConversationPath(userId, character.id),
    ).create(recursive: true);

    await _migrateLegacyConfiguredMemoryUnlocked(userId, character.id);

    final identity =
        File(_fileSystem.getCharacterIdentityPath(userId, character.id));
    if (!await identity.exists()) {
      await _writeText(identity, _buildInitialIdentity(character));
    }

    final inbox = File(
      _fileSystem.getCharacterInboxPath(userId, character.id),
    );
    if (!await inbox.exists()) await inbox.writeAsString('');

    final index = File(
      _fileSystem.getCharacterInteractionIndexPath(userId, character.id),
    );
    if (!await index.exists()) await index.writeAsString('');

    final runtime = File(
      _fileSystem.getCharacterRuntimePath(userId, character.id),
    );
    if (!await runtime.exists()) {
      await _writeText(
        runtime,
        '${const JsonEncoder.withIndent('  ').convert(
          const CharacterWorkspaceRuntime.initial().toJson(),
        )}\n',
      );
    }

    final pendingThoughts = File(
      _fileSystem.getCharacterPendingThoughtsPath(userId, character.id),
    );
    if (!await pendingThoughts.exists()) {
      await pendingThoughts.writeAsString('');
    }
  }

  Future<void> _migrateLegacyConfiguredMemoryUnlocked(
    String userId,
    String characterId,
  ) async {
    await _importLegacyJsonLinesIfNeeded(
      legacyPath:
          _fileSystem.getLegacyCharacterMemoryEntriesPath(userId, characterId),
      targetPath:
          _fileSystem.getCharacterUserMemoryEntriesPath(userId, characterId),
      characterId: characterId,
      kind: 'memory',
    );
    await _importLegacyJsonLinesIfNeeded(
      legacyPath:
          _fileSystem.getLegacyCharacterWorldEntriesPath(userId, characterId),
      targetPath:
          _fileSystem.getCharacterUserWorldEntriesPath(userId, characterId),
      characterId: characterId,
      kind: 'world',
    );
    await _importLegacyRelationshipIfNeeded(userId, characterId);
  }

  Future<void> _importLegacyRelationshipIfNeeded(
    String userId,
    String characterId,
  ) async {
    final target = File(
      _fileSystem.getCharacterImportedRelationshipPath(userId, characterId),
    );
    if (await target.exists()) return;

    final currentPath =
        _fileSystem.getLegacyCharacterRelationshipPath(userId, characterId);
    final directory = Directory(_fileSystem.getLegacyCharactersPath(userId));
    final current = File(currentPath);
    File? source;
    if (await current.exists()) {
      source = current;
    } else if (await directory.exists()) {
      final candidates = <File>[];
      final deprecatedPrefix = '${p.basename(currentPath)}.deprecated_';
      await for (final entity in directory.list()) {
        if (entity is File &&
            p.basename(entity.path).startsWith(deprecatedPrefix)) {
          candidates.add(entity);
        }
      }
      candidates.sort((a, b) => b.path.compareTo(a.path));
      source = candidates.firstOrNull;
    }
    if (source == null) return;

    final content = (await source.readAsString()).trim();
    if (content.isEmpty) return;
    await _writeText(
      target,
      '# Imported Relationship Memory\n\n$content\n',
    );
    _logger.info('Imported legacy relationship memory for $characterId');
  }

  Future<void> _importLegacyJsonLinesIfNeeded({
    required String legacyPath,
    required String targetPath,
    required String characterId,
    required String kind,
  }) async {
    final target = File(targetPath);
    if (await target.exists()) return;

    final rows = await _readJsonLines(legacyPath);
    await _writeJsonLines(targetPath, rows);
    if (rows.isNotEmpty) {
      _logger.info(
        'Imported ${rows.length} legacy $kind entries into the private '
        'workspace for $characterId',
      );
    }
  }

  String _buildInitialIdentity(CharacterModel character) {
    final buffer = StringBuffer()
      ..writeln('# ${character.name}')
      ..writeln()
      ..writeln(
          'This is the character\'s starting point, not a live state model.')
      ..writeln('Durable understanding should grow in PKM/ and Journal/.')
      ..writeln()
      ..writeln('## Initial Persona')
      ..writeln()
      ..writeln(character.persona.trim());
    if (character.tags.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Tags')
        ..writeln()
        ..writeln(character.tags.join(', '));
    }
    if (character.mesExample?.trim().isNotEmpty ?? false) {
      buffer
        ..writeln()
        ..writeln('## Voice Examples')
        ..writeln()
        ..writeln(character.mesExample!.trim());
    }
    return buffer.toString();
  }

  Future<List<CharacterObservation>> _readInbox(
    String userId,
    String characterId,
  ) async {
    final rows = await _readJsonLines(
      _fileSystem.getCharacterInboxPath(userId, characterId),
    );
    final result = <CharacterObservation>[];
    for (final row in rows) {
      try {
        result.add(CharacterObservation.fromJson(row));
      } catch (error) {
        _logger.warning(
          'Ignoring malformed character observation for $characterId: $error',
        );
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _readInteractionIndex(
    String userId,
    String characterId,
  ) {
    return _readJsonLines(
      _fileSystem.getCharacterInteractionIndexPath(userId, characterId),
    );
  }

  Future<CharacterWorkspaceRuntime> _readRuntime(
    String userId,
    String characterId,
  ) async {
    final file = File(
      _fileSystem.getCharacterRuntimePath(userId, characterId),
    );
    if (!await file.exists()) return const CharacterWorkspaceRuntime.initial();
    try {
      final value = jsonDecode(await file.readAsString());
      return CharacterWorkspaceRuntime.fromJson(
        Map<String, dynamic>.from(value as Map),
      );
    } catch (error) {
      _logger.warning(
        'Using a fresh runtime for malformed character workspace '
        '$characterId: $error',
      );
      return const CharacterWorkspaceRuntime.initial();
    }
  }

  Future<void> _writeRuntime(
    String userId,
    String characterId,
    CharacterWorkspaceRuntime runtime,
  ) {
    return _writeText(
      File(_fileSystem.getCharacterRuntimePath(userId, characterId)),
      '${const JsonEncoder.withIndent(' ').convert(runtime.toJson())}\n',
    );
  }

  Future<List<Map<String, dynamic>>> _readJsonLines(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return [];
    final result = <Map<String, dynamic>>[];
    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      try {
        final value = jsonDecode(line);
        result.add(Map<String, dynamic>.from(value as Map));
      } catch (error) {
        _logger.warning('Ignoring malformed JSONL row in $filePath: $error');
      }
    }
    return result;
  }

  Future<void> _writeJsonLines(
    String filePath,
    List<Map<String, dynamic>> rows,
  ) {
    final content = rows.isEmpty
        ? ''
        : '${rows.map((row) => jsonEncode(row)).join('\n')}\n';
    return _writeText(File(filePath), content);
  }

  Future<void> _writeText(File file, String content) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(content, flush: true);
    try {
      await temporary.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    }
  }

  String _resolveMarkdownPath(String root, String relativePath) {
    final normalized = p.normalize(relativePath.trim());
    if (normalized.isEmpty ||
        p.isAbsolute(normalized) ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('..${p.separator}') ||
        p.extension(normalized).toLowerCase() != '.md') {
      throw ArgumentError.value(relativePath, 'relativePath');
    }
    final target = p.normalize(p.join(root, normalized));
    if (!p.isWithin(root, target)) {
      throw ArgumentError.value(relativePath, 'relativePath');
    }
    return target;
  }

  String _observationId(String source, String sourceEventId) {
    return sha256
        .convert(utf8.encode('$source\u0000$sourceEventId'))
        .toString();
  }

  String _pendingThoughtId(String sourceEventId) {
    return sha256
        .convert(utf8.encode('pending_initiative\u0000$sourceEventId'))
        .toString();
  }

  void _validateCharacterId(String characterId) {
    FileSystemService.validateCharacterId(characterId);
  }
}
