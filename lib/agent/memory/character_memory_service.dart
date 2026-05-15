import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;

enum CharacterMemoryScene { chat, comment }

enum CharacterMemoryEventType {
  userChatMessage,
  characterChatMessage,
  postObserved,
  characterComment,
  userCommentReply,

  /// Narrative / action description sent by the character (e.g. *leans closer*).
  characterActionMessage,
}

class CharacterMemoryService {
  CharacterMemoryService._();

  static final CharacterMemoryService instance = CharacterMemoryService._();

  final _logger = getLogger('CharacterMemoryService');
  FileSystemService get _fileSystem => FileSystemService.instance;

  static final Map<String, Future<void>> _locks = {};

  Future<T> _withLock<T>(String key, Future<T> Function() operation) async {
    while (_locks.containsKey(key)) {
      await _locks[key];
    }
    final completer = Completer<void>();
    _locks[key] = completer.future;
    try {
      return await operation();
    } finally {
      completer.complete();
      _locks.remove(key);
    }
  }

  String _characterMemoryDir(String userId, String characterId) {
    return p.join(
      _fileSystem.getSystemPath(userId),
      'character_memory',
      characterId,
    );
  }

  String _timelinePath(String userId, String characterId) {
    return p.join(_characterMemoryDir(userId, characterId), 'timeline.jsonl');
  }

  String _archivedTimelinePath(String userId, String characterId) {
    return p.join(
        _characterMemoryDir(userId, characterId), 'archived_timeline.jsonl');
  }

  String _indexesPath(String userId, String characterId) {
    return p.join(_characterMemoryDir(userId, characterId), 'indexes.json');
  }

  String _checkpointsPath(String userId, String characterId) {
    return p.join(
        _characterMemoryDir(userId, characterId), 'checkpoints.jsonl');
  }

  String _memoriesPath(String userId, String characterId) {
    return p.join(
        _characterMemoryDir(userId, characterId), 'memory_entries.jsonl');
  }

  String _worldEntriesPath(String userId, String characterId) {
    return p.join(
        _characterMemoryDir(userId, characterId), 'world_entries.jsonl');
  }

  Future<void> _ensureDir(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<Map<String, dynamic>> _loadIndexes(
      String userId, String characterId) async {
    final path = _indexesPath(userId, characterId);
    final file = File(path);
    if (!await file.exists()) {
      return {
        'migration_version': 0,
        'last_timeline_event_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      };
    }
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      _logger.warning('Failed to parse indexes.json for $characterId: $e');
    }
    return {
      'migration_version': 0,
      'last_timeline_event_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _writeIndexes(
    String userId,
    String characterId,
    Map<String, dynamic> indexes,
  ) async {
    final dir = _characterMemoryDir(userId, characterId);
    await _ensureDir(dir);
    final path = _indexesPath(userId, characterId);
    final tmpPath = '$path.tmp';
    indexes['updated_at'] = DateTime.now().toIso8601String();
    const encoder = JsonEncoder.withIndent('  ');
    final tmpFile = File(tmpPath);
    await tmpFile.writeAsString(encoder.convert(indexes));
    await tmpFile.rename(path);
  }

  Future<Map<String, dynamic>> loadIndexes(
      String userId, String characterId) async {
    await ensureMigrated(userId, characterId);
    return _loadIndexes(userId, characterId);
  }

  Future<void> saveIndexes(
      String userId, String characterId, Map<String, dynamic> indexes) async {
    await ensureMigrated(userId, characterId);
    await _writeIndexes(userId, characterId, indexes);
  }

  Future<void> ensureMigrated(String userId, String characterId) async {
    final lockKey = 'migrate:$userId:$characterId';
    await _withLock(lockKey, () async {
      final indexes = await _loadIndexes(userId, characterId);
      final migrationVersion =
          (indexes['migration_version'] as num?)?.toInt() ?? 0;
      if (migrationVersion >= 1) {
        return;
      }

      // Delete legacy relationship/emotional_state files.
      await _renameLegacyMemoryFiles(userId, characterId);

      indexes['migration_version'] = 1;
      await _writeIndexes(userId, characterId, indexes);
    });
  }

  /// Rename legacy per-character relationship.md and emotional_state.md files
  /// to .deprecated suffix so they are no longer read but can be recovered.
  Future<void> _renameLegacyMemoryFiles(
      String userId, String characterId) async {
    final charsPath =
        p.join(_fileSystem.getWorkspacePath(userId), 'Characters');
    final now = DateTime.now();
    final dateSuffix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final relationshipFile =
        File(p.join(charsPath, '${characterId}_relationship.md'));
    final emotionalStateFile =
        File(p.join(charsPath, '${characterId}_emotional_state.md'));
    try {
      if (await relationshipFile.exists()) {
        await relationshipFile
            .rename('${relationshipFile.path}.deprecated_$dateSuffix');
        _logger.info(
            'Renamed legacy relationship file for character $characterId');
      }
    } catch (e) {
      _logger.warning('Failed to rename legacy relationship file: $e');
    }
    try {
      if (await emotionalStateFile.exists()) {
        await emotionalStateFile
            .rename('${emotionalStateFile.path}.deprecated_$dateSuffix');
        _logger.info(
            'Renamed legacy emotional_state file for character $characterId');
      }
    } catch (e) {
      _logger.warning('Failed to rename legacy emotional_state file: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadMemoryEntries(
      String userId, String characterId) async {
    await ensureMigrated(userId, characterId);
    final file = File(_memoriesPath(userId, characterId));
    if (!await file.exists()) return [];
    final entries = <Map<String, dynamic>>[];
    for (final line in await file.readAsLines()) {
      try {
        final obj = jsonDecode(line);
        if (obj is Map) entries.add(Map<String, dynamic>.from(obj));
      } catch (_) {}
    }
    return entries;
  }

  Future<void> replaceMemoryEntries(
    String userId,
    String characterId,
    List<Map<String, dynamic>> entries,
  ) async {
    final lockKey = 'memory_entries:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final file = File(_memoriesPath(userId, characterId));
      final content =
          entries.isEmpty ? '' : '${entries.map(jsonEncode).join('\n')}\n';
      await file.writeAsString(content);
    });
  }

  /// Maximum recommended total character count for all memory entries.
  /// Beyond this, the agent is warned to consolidate or remove low-value entries.
  static const int _memoryCharBudget = 8000;

  // ---------------------------------------------------------------------------
  // Memory CRUD — label is the unique key
  // ---------------------------------------------------------------------------

  /// Write (create or overwrite) a memory entry by label.
  Future<String> writeMemoryEntry({
    required String userId,
    required String characterId,
    required String label,
    required String content,
    double salience = 0.5,
  }) async {
    if (label.trim().isEmpty) return 'Error: label cannot be empty.';
    if (content.trim().isEmpty) return 'Error: content cannot be empty.';
    final entries = await loadMemoryEntries(userId, characterId);
    final normalized = content.trim();
    final trimmedLabel = label.trim();
    final now = DateTime.now().toIso8601String();

    final existingIdx =
        entries.indexWhere((e) => (e['label'] ?? '') == trimmedLabel);
    if (existingIdx >= 0) {
      // Overwrite existing entry.
      entries[existingIdx] = {
        'label': trimmedLabel,
        'content': normalized,
        'salience': salience.clamp(0.0, 1.0),
        'updated_at': now,
      };
    } else {
      // Create new entry.
      entries.add({
        'label': trimmedLabel,
        'content': normalized,
        'salience': salience.clamp(0.0, 1.0),
        'created_at': now,
        'updated_at': now,
      });
    }
    await replaceMemoryEntries(userId, characterId, entries);

    // Warn if total memory size exceeds budget.
    final totalChars = entries.fold<int>(
        0, (sum, e) => sum + ((e['content'] as String?)?.length ?? 0));
    if (totalChars > _memoryCharBudget) {
      return "Memory block '$trimmedLabel' written. WARNING: Total memory size "
          '($totalChars chars) exceeds recommended budget ($_memoryCharBudget chars). '
          'Consider consolidating or removing low-value entries.';
    }
    return "Memory block '$trimmedLabel' written successfully.";
  }

  /// Edit a memory entry by performing string replacement within its content.
  Future<String> editMemoryEntry({
    required String userId,
    required String characterId,
    required String label,
    required String oldString,
    required String newString,
    bool replaceAll = false,
  }) async {
    if (label.trim().isEmpty) return 'Error: label cannot be empty.';
    final entries = await loadMemoryEntries(userId, characterId);
    final trimmedLabel = label.trim();
    final idx = entries.indexWhere((e) => (e['label'] ?? '') == trimmedLabel);

    if (idx < 0) {
      if (oldString.isEmpty) {
        // Create new entry with newString as content.
        return writeMemoryEntry(
          userId: userId,
          characterId: characterId,
          label: trimmedLabel,
          content: newString,
        );
      }
      return "Error: Memory block '$trimmedLabel' not found.";
    }

    final currentValue = (entries[idx]['content'] as String?) ?? '';
    if (oldString.isEmpty) {
      return "Error: old_string is empty. Use MemoryWrite to overwrite the entire block.";
    }
    if (!currentValue.contains(oldString)) {
      return "Error: old_string not found in memory block '$trimmedLabel'.";
    }
    final matches = oldString.allMatches(currentValue).length;
    if (matches > 1 && !replaceAll) {
      return 'Error: old_string matches $matches times. Provide more context '
          'to match uniquely, or set replace_all to true.';
    }
    final newValue = replaceAll
        ? currentValue.replaceAll(oldString, newString)
        : currentValue.replaceFirst(oldString, newString);
    entries[idx] = Map<String, dynamic>.from(entries[idx])
      ..['content'] = newValue
      ..['updated_at'] = DateTime.now().toIso8601String();
    await replaceMemoryEntries(userId, characterId, entries);
    return "Memory block '$trimmedLabel' updated successfully.";
  }

  /// Remove a memory entry by label.
  Future<String> removeMemoryEntry({
    required String userId,
    required String characterId,
    required String label,
  }) async {
    if (label.trim().isEmpty) return 'Error: label cannot be empty.';
    final entries = await loadMemoryEntries(userId, characterId);
    final trimmedLabel = label.trim();
    final idx = entries.indexWhere((e) => (e['label'] ?? '') == trimmedLabel);
    if (idx < 0) return "Error: Memory block '$trimmedLabel' not found.";
    entries.removeAt(idx);
    await replaceMemoryEntries(userId, characterId, entries);
    return "Memory block '$trimmedLabel' removed.";
  }

  /// Read memory entries, optionally filtered by labels.
  Future<String> readMemoryEntries({
    required String userId,
    required String characterId,
    List<String>? labels,
  }) async {
    final entries = await loadMemoryEntries(userId, characterId);
    if (entries.isEmpty) return 'No memory entries.';
    final filtered = (labels != null && labels.isNotEmpty)
        ? entries
            .where((e) => labels.contains((e['label'] ?? '').toString()))
            .toList()
        : entries;
    if (filtered.isEmpty) return 'No matching memory entries.';
    return _formatMemoryEntries(filtered);
  }

  /// Build all memories as text for context injection.
  Future<String> buildAllMemoriesText({
    required String userId,
    required String characterId,
  }) async {
    final entries = await loadMemoryEntries(userId, characterId);
    if (entries.isEmpty) return '';
    return _formatMemoryEntries(entries);
  }

  String _formatMemoryEntries(Iterable<Map<String, dynamic>> entries) {
    final b = StringBuffer();
    for (final entry in entries) {
      final label = entry['label'] ?? 'memory';
      b.writeln('- [$label] ${entry['content']}');
    }
    return b.toString().trim();
  }

  Future<List<Map<String, dynamic>>> loadWorldEntries(
      String userId, String characterId) async {
    await ensureMigrated(userId, characterId);
    final file = File(_worldEntriesPath(userId, characterId));
    if (!await file.exists()) return [];
    final entries = <Map<String, dynamic>>[];
    for (final line in await file.readAsLines()) {
      try {
        final obj = jsonDecode(line);
        if (obj is Map) entries.add(Map<String, dynamic>.from(obj));
      } catch (_) {}
    }
    return entries;
  }

  Future<void> replaceWorldEntries(
    String userId,
    String characterId,
    List<Map<String, dynamic>> entries,
  ) async {
    final lockKey = 'world_entries:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final file = File(_worldEntriesPath(userId, characterId));
      final content =
          entries.isEmpty ? '' : '${entries.map(jsonEncode).join('\n')}\n';
      await file.writeAsString(content);
      await _rebuildWorldFts(characterId, entries);
    });
  }

  Future<void> _rebuildWorldFts(
    String characterId,
    List<Map<String, dynamic>> entries,
  ) async {
    if (!AppDatabase.isInitialized) return;
    try {
      final dao = AppDatabase.instance.searchDao;
      await dao.createCharacterFtsTables();
      await dao.clearCharacterWorldFts(characterId);
      for (final entry in entries) {
        final id = (entry['uid'] ?? entry['id'] ?? '').toString();
        if (id.isEmpty) continue;
        await dao.upsertCharacterWorldFts(
          characterId: characterId,
          entryId: id,
          keys: ((entry['keys'] as List?) ?? const []).join(' '),
          comment: (entry['comment'] ?? '').toString(),
          content: (entry['content'] ?? '').toString(),
        );
      }
    } catch (e) {
      _logger.warning('Failed to rebuild character world FTS: $e');
    }
  }

  Future<String> buildTriggeredWorldEntriesText({
    required String userId,
    required String characterId,
    required String queryHint,
    int maxEntries = 6,
  }) async {
    if (!AppDatabase.isInitialized) return '';
    final entries = await loadWorldEntries(userId, characterId);
    if (entries.isEmpty) return '';
    final activated = <Map<String, dynamic>>[
      for (final entry in entries)
        if (entry['enabled'] != false && entry['constant'] == true) entry,
    ];
    if (queryHint.trim().isNotEmpty) {
      final byId = {
        for (final entry in entries)
          (entry['uid'] ?? entry['id'] ?? '').toString(): entry
      };
      final seen = activated
          .map((e) => (e['uid'] ?? e['id'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toSet();
      for (final entry in entries) {
        if (entry['enabled'] == false) continue;
        final id = (entry['uid'] ?? entry['id'] ?? '').toString();
        final text =
            '$id ${entry['comment'] ?? ''} ${entry['content'] ?? ''} ${((entry['keys'] as List?) ?? const []).join(' ')}'
                .toLowerCase();
        if (text.contains(queryHint.toLowerCase()) && seen.add(id)) {
          activated.add(entry);
        }
        if (activated.length >= maxEntries) break;
      }
      if (activated.length < maxEntries) {
        final results = await AppDatabase.instance.searchDao
            .searchCharacterWorldEntries(characterId, queryHint,
                limit: maxEntries);
        for (final result in results) {
          final id = (result['id'] ?? '').toString();
          final entry = byId[id];
          if (entry != null && seen.add(id)) activated.add(entry);
          if (activated.length >= maxEntries) break;
        }
      }
    }
    return _formatWorldEntries(activated, maxEntries);
  }

  String _formatWorldEntries(
      List<Map<String, dynamic>> entries, int maxEntries) {
    final b = StringBuffer();
    final seen = <String>{};
    for (final entry in entries) {
      if (entry['enabled'] == false) continue;
      final id =
          (entry['uid'] ?? entry['id'] ?? entry['content'] ?? '').toString();
      if (id.isNotEmpty && !seen.add(id)) continue;
      if (seen.length > maxEntries) break;
      final comment = entry['comment'] as String?;
      if (comment != null && comment.trim().isNotEmpty) {
        b.writeln('### $comment');
      }
      b.writeln(entry['content'] ?? '');
      b.writeln('');
    }
    return b.toString().trim();
  }

  Future<void> appendTimelineEvent({
    required String userId,
    required String characterId,
    required CharacterMemoryScene scene,
    required CharacterMemoryEventType type,
    required String content,
    String? threadId,
    String? factId,
    String? messageId,
    String? commentId,
    String? replyToId,
    String? parentEventId,
    String? sourceId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) async {
    if (content.trim().isEmpty) {
      return;
    }
    final lockKey = 'timeline:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final timelineFile = File(_timelinePath(userId, characterId));
      final effectiveThreadId = threadId ??
          (scene == CharacterMemoryScene.comment
              ? factId
              : 'chat:$characterId');
      if (type == CharacterMemoryEventType.postObserved &&
          effectiveThreadId != null &&
          await timelineFile.exists()) {
        final existing = await timelineFile.readAsLines();
        for (final line in existing) {
          try {
            final obj = jsonDecode(line);
            if (obj is Map &&
                obj['scene'] == CharacterMemoryScene.comment.name &&
                obj['event_type'] ==
                    CharacterMemoryEventType.postObserved.name &&
                obj['thread_id'] == effectiveThreadId) {
              return;
            }
          } catch (_) {}
        }
      }
      final eventTime = timestamp ?? DateTime.now();
      final event = <String, dynamic>{
        'event_id':
            '${eventTime.microsecondsSinceEpoch}_${scene.name}_${type.name}',
        'ts': eventTime.toIso8601String(),
        'scene': scene.name,
        'event_type': type.name,
        if (effectiveThreadId != null) 'thread_id': effectiveThreadId,
        'content': content,
        if (factId != null) 'fact_id': factId,
        if (messageId != null) 'message_id': messageId,
        if (commentId != null) 'comment_id': commentId,
        if (replyToId != null) 'reply_to_id': replyToId,
        if (parentEventId != null) 'parent_event_id': parentEventId,
        if (sourceId != null) 'source_id': sourceId,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      };

      final line = '${jsonEncode(event)}\n';
      await timelineFile.writeAsString(line, mode: FileMode.append);
      await _upsertTimelineFts(characterId, event, source: 'recent');

      final indexes = await _loadIndexes(userId, characterId);
      indexes['last_timeline_event_at'] = eventTime.toIso8601String();
      await _writeIndexes(userId, characterId, indexes);
    });
  }

  Future<List<String>> loadTimelineLines(
      String userId, String characterId) async {
    await ensureMigrated(userId, characterId);
    final file = File(_timelinePath(userId, characterId));
    if (!await file.exists()) return [];
    return file.readAsLines();
  }

  Future<void> replaceTimelineLines(
    String userId,
    String characterId,
    List<String> lines,
  ) async {
    final lockKey = 'timeline:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final path = _timelinePath(userId, characterId);
      final content = lines.isEmpty
          ? ''
          : '${lines.map((e) => e.trimRight()).join('\n')}\n';
      await File(path).writeAsString(content);
      await _rebuildTimelineFts(characterId, lines, source: 'recent');
    });
  }

  Future<void> appendArchivedTimelineLines(
    String userId,
    String characterId,
    List<String> lines,
  ) async {
    if (lines.isEmpty) return;
    final lockKey = 'archived_timeline:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final path = _archivedTimelinePath(userId, characterId);
      final content = '${lines.map((e) => e.trimRight()).join('\n')}\n';
      await File(path).writeAsString(content, mode: FileMode.append);
      for (final line in lines) {
        await _upsertTimelineFtsFromLine(characterId, line, source: 'archived');
      }
    });
  }

  /// Count the number of lines in the archived timeline file.
  Future<int> countArchivedTimelineLines(
      String userId, String characterId) async {
    final path = _archivedTimelinePath(userId, characterId);
    final file = File(path);
    if (!await file.exists()) return 0;
    final lines = await file.readAsLines();
    return lines.where((l) => l.trim().isNotEmpty).length;
  }

  Future<void> _rebuildTimelineFts(
    String characterId,
    List<String> lines, {
    required String source,
  }) async {
    if (!AppDatabase.isInitialized) return;
    try {
      final dao = AppDatabase.instance.searchDao;
      await dao.createCharacterFtsTables();
      if (source == 'recent') {
        await dao.clearCharacterTimelineFts(characterId, source: 'recent');
      }
      for (final line in lines) {
        await _upsertTimelineFtsFromLine(characterId, line, source: source);
      }
    } catch (e) {
      _logger.warning('Failed to rebuild character timeline FTS: $e');
    }
  }

  Future<void> _upsertTimelineFtsFromLine(
    String characterId,
    String line, {
    required String source,
  }) async {
    if (!AppDatabase.isInitialized) return;
    try {
      final obj = jsonDecode(line);
      if (obj is Map) {
        await _upsertTimelineFts(
          characterId,
          Map<String, dynamic>.from(obj),
          source: source,
        );
      }
    } catch (_) {}
  }

  Future<void> _upsertTimelineFts(
    String characterId,
    Map<String, dynamic> event, {
    required String source,
  }) async {
    if (!AppDatabase.isInitialized) return;
    try {
      final eventId = (event['event_id'] ?? '').toString();
      if (eventId.isEmpty) return;
      final dao = AppDatabase.instance.searchDao;
      await dao.createCharacterFtsTables();
      await dao.upsertCharacterTimelineFts(
        characterId: characterId,
        eventId: eventId,
        source: source,
        scene: (event['scene'] ?? '').toString(),
        threadId: (event['thread_id'] ?? '').toString(),
        ts: (event['ts'] ?? '').toString(),
        eventType: (event['event_type'] ?? '').toString(),
        content: (event['content'] ?? '').toString(),
        factId: (event['fact_id'] ?? '').toString(),
      );
    } catch (e) {
      _logger.warning('Failed to upsert character timeline FTS: $e');
    }
  }

  Future<String> searchTimelineEvents({
    required String userId,
    required String characterId,
    required String query,
    int limit = 8,
    bool includeArchived = true,
    CharacterMemoryScene? scene,
    String? threadId,
  }) async {
    await ensureMigrated(userId, characterId);
    if (!AppDatabase.isInitialized) return 'History search is unavailable.';
    final cappedLimit = limit.clamp(1, 20);
    final recent = await _loadTimelineEventsById(userId, characterId);
    final archived =
        await _loadTimelineEventsById(userId, characterId, archived: true);
    final ordered = <({Map<String, dynamic> event, String source})>[];
    final seen = <String>{};
    void grep(Map<String, Map<String, dynamic>> sourceEvents, String source) {
      for (final event in sourceEvents.values) {
        if (scene != null && event['scene'] != scene.name) continue;
        if (threadId != null &&
            threadId.isNotEmpty &&
            event['thread_id'] != threadId) {
          continue;
        }
        final text =
            '${event['content'] ?? ''} ${event['event_type'] ?? ''} ${event['thread_id'] ?? ''} ${event['fact_id'] ?? ''}'
                .toLowerCase();
        final id = (event['event_id'] ?? '').toString();
        if (text.contains(query.toLowerCase()) && seen.add('$source:$id')) {
          ordered.add((event: event, source: source));
        }
        if (ordered.length >= cappedLimit) break;
      }
    }

    grep(recent, 'recent');
    if (includeArchived && ordered.length < cappedLimit) {
      grep(archived, 'archived');
    }
    if (ordered.length < cappedLimit) {
      final results =
          await AppDatabase.instance.searchDao.searchCharacterTimeline(
        characterId,
        query,
        limit: cappedLimit,
        scene: scene?.name,
        threadId: threadId,
        includeArchived: includeArchived,
      );
      for (final result in results) {
        final source = (result['source'] ?? '').toString();
        final id = (result['event_id'] ?? '').toString();
        final event = source == 'archived' ? archived[id] : recent[id];
        if (event != null && seen.add('$source:$id')) {
          ordered.add((event: event, source: source));
        }
        if (ordered.length >= cappedLimit) break;
      }
    }
    if (ordered.isEmpty) return 'No matching interaction history.';

    final b = StringBuffer();
    for (final item in ordered) {
      b.writeln(_formatTimelineSearchResult(item.event, item.source));
      b.writeln('');
    }
    final text = b.toString().trim();
    return text.isEmpty ? 'No matching interaction history.' : text;
  }

  Future<Map<String, Map<String, dynamic>>> _loadTimelineEventsById(
    String userId,
    String characterId, {
    bool archived = false,
  }) async {
    final file = File(archived
        ? _archivedTimelinePath(userId, characterId)
        : _timelinePath(userId, characterId));
    if (!await file.exists()) return {};
    final result = <String, Map<String, dynamic>>{};
    for (final line in await file.readAsLines()) {
      try {
        final obj = jsonDecode(line);
        if (obj is Map) {
          final event = Map<String, dynamic>.from(obj);
          final id = (event['event_id'] ?? '').toString();
          if (id.isNotEmpty) result[id] = event;
        }
      } catch (_) {}
    }
    return result;
  }

  String _formatTimelineSearchResult(Map<String, dynamic> event, String src) {
    final ts = event['ts'] ?? 'unknown time';
    final scene = event['scene'] ?? 'unknown scene';
    final type = event['event_type'] ?? 'event';
    final thread = event['thread_id'] ?? '';
    final content = (event['content'] as String?)?.trim() ?? '';
    final clipped =
        content.length > 1200 ? '${content.substring(0, 1200)}...' : content;
    final b = StringBuffer();
    b.writeln(
        '### [$src] $scene/$type · $ts${thread.toString().isEmpty ? '' : ' · thread=$thread'}');
    if (event['comment_id'] != null) {
      b.writeln('comment_id: ${event['comment_id']}');
    }
    if (event['reply_to_id'] != null) {
      b.writeln('reply_to_id: ${event['reply_to_id']}');
    }
    b.writeln(clipped);
    return b.toString().trim();
  }

  /// Replace the checkpoint file with a single rolling summary.
  Future<void> replaceCheckpoint(
    String userId,
    String characterId,
    Map<String, dynamic> checkpoint,
  ) async {
    final lockKey = 'checkpoint:$userId:$characterId';
    await _withLock(lockKey, () async {
      await ensureMigrated(userId, characterId);
      final dir = _characterMemoryDir(userId, characterId);
      await _ensureDir(dir);
      final file = File(_checkpointsPath(userId, characterId));
      await file.writeAsString('${jsonEncode(checkpoint)}\n');

      final indexes = await _loadIndexes(userId, characterId);
      indexes['last_checkpoint_at'] = DateTime.now().toIso8601String();
      await _writeIndexes(userId, characterId, indexes);
    });
  }

  /// Load the single rolling checkpoint summary text.
  /// Returns the summary string directly, or empty if none exists.
  Future<String> loadCheckpointSummary(
    String userId,
    String characterId,
  ) async {
    await ensureMigrated(userId, characterId);
    final file = File(_checkpointsPath(userId, characterId));
    if (!await file.exists()) return '';
    final lines = await file.readAsLines();
    if (lines.isEmpty) return '';
    // Take the last line (the most recent / only checkpoint in rolling mode)
    final lastLine = lines.last;
    try {
      final obj = jsonDecode(lastLine);
      if (obj is Map) {
        return (obj['summary'] as String?) ?? '';
      }
    } catch (_) {}
    return '';
  }
}
