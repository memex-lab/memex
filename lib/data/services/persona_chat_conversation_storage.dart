import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/migration_state_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

class PersonaChatConversationRecord {
  const PersonaChatConversationRecord({
    required this.id,
    required this.seq,
    required this.characterId,
    required this.isFromCharacter,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.messageType,
    required this.origin,
    this.factId,
    this.contactEpisodeId,
  });

  final String id;
  final int seq;
  final String characterId;
  final bool isFromCharacter;
  final String content;
  final String? factId;
  final bool isRead;
  final DateTime timestamp;
  final String messageType;
  final String origin;
  final String? contactEpisodeId;

  String get speaker => isFromCharacter ? 'character' : 'user';

  PersonaChatConversationRecord copyWith({
    bool? isRead,
  }) {
    return PersonaChatConversationRecord(
      id: id,
      seq: seq,
      characterId: characterId,
      isFromCharacter: isFromCharacter,
      content: content,
      factId: factId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
      messageType: messageType,
      origin: origin,
      contactEpisodeId: contactEpisodeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seq': seq,
      'character_id': characterId,
      'speaker': speaker,
      'is_from_character': isFromCharacter,
      'content': content,
      if (factId != null) 'fact_id': factId,
      'is_read': isRead,
      'timestamp': timestamp.toIso8601String(),
      'unix_seconds': timestamp.millisecondsSinceEpoch ~/ 1000,
      'type': messageType,
      'message_type': messageType,
      'origin': origin,
      if (contactEpisodeId != null) 'contact_episode_id': contactEpisodeId,
    };
  }

  static PersonaChatConversationRecord? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final characterId = json['character_id']?.toString();
    final content = json['content']?.toString();
    if (id == null ||
        id.isEmpty ||
        characterId == null ||
        characterId.isEmpty ||
        content == null) {
      return null;
    }
    final speaker = json['speaker']?.toString();
    final isFromCharacter =
        json['is_from_character'] == true || speaker == 'character';
    final timestampRaw = json['timestamp']?.toString();
    final unixSeconds = json['unix_seconds'];
    DateTime timestamp;
    if (timestampRaw != null) {
      timestamp = DateTime.tryParse(timestampRaw) ?? DateTime.now();
    } else if (unixSeconds is num) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        unixSeconds.toInt() * 1000,
      );
    } else {
      timestamp = DateTime.now();
    }
    final type = (json['message_type'] ?? json['type'])?.toString() ??
        PersonaChatMessageTypes.text;
    return PersonaChatConversationRecord(
      id: id,
      seq: json['seq'] is num ? (json['seq'] as num).toInt() : 0,
      characterId: characterId,
      isFromCharacter: isFromCharacter,
      content: content,
      factId: json['fact_id']?.toString(),
      isRead: json['is_read'] == true,
      timestamp: timestamp,
      messageType: type == 'text' ? PersonaChatMessageTypes.text : type,
      origin: json['origin']?.toString() ?? 'conversation',
      contactEpisodeId: json['contact_episode_id']?.toString(),
    );
  }
}

class PersonaChatConversationState {
  const PersonaChatConversationState({
    required this.schemaVersion,
    required this.nextSeq,
    this.consumedThroughMessageId,
    this.updatedAt,
    this.clearedAt,
  });

  final int schemaVersion;
  final int nextSeq;
  final String? consumedThroughMessageId;
  final DateTime? updatedAt;
  final DateTime? clearedAt;

  factory PersonaChatConversationState.initial() {
    return const PersonaChatConversationState(
      schemaVersion: PersonaChatConversationStorage.schemaVersion,
      nextSeq: 1,
    );
  }

  PersonaChatConversationState copyWith({
    int? schemaVersion,
    int? nextSeq,
    String? consumedThroughMessageId,
    bool clearConsumedThroughMessageId = false,
    DateTime? updatedAt,
    DateTime? clearedAt,
    bool clearClearedAt = false,
  }) {
    return PersonaChatConversationState(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      nextSeq: nextSeq ?? this.nextSeq,
      consumedThroughMessageId: clearConsumedThroughMessageId
          ? null
          : (consumedThroughMessageId ?? this.consumedThroughMessageId),
      updatedAt: updatedAt ?? this.updatedAt,
      clearedAt: clearClearedAt ? null : (clearedAt ?? this.clearedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'next_message_seq': nextSeq,
      'consumed_through_message_id': consumedThroughMessageId,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (clearedAt != null) 'cleared_at': clearedAt!.toIso8601String(),
    };
  }

  static PersonaChatConversationState fromJson(Map<String, dynamic> json) {
    return PersonaChatConversationState(
      schemaVersion: json['schema_version'] is num
          ? (json['schema_version'] as num).toInt()
          : PersonaChatConversationStorage.schemaVersion,
      nextSeq: json['next_message_seq'] is num
          ? (json['next_message_seq'] as num).toInt()
          : 1,
      consumedThroughMessageId: json['consumed_through_message_id']?.toString(),
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      clearedAt: json['cleared_at'] is String
          ? DateTime.tryParse(json['cleared_at'] as String)
          : null,
    );
  }
}

/// Durable character-conversation store. Workspace files are the source of
/// truth; SQLite is a rebuildable projection.
///
/// Single-message appends may leave only an invalid final JSONL row after a
/// crash, which [_readRecordsUnlocked] removes at a UTF-8 byte boundary.
/// Multi-record episodes replace the JSONL file once so they become visible
/// together; a count mismatch on retry replaces an incomplete episode.
class PersonaChatConversationStorage {
  PersonaChatConversationStorage({
    FileSystemService? fileSystem,
    MigrationStateService? migrationState,
    Uuid? uuid,
  })  : _injectedFileSystem = fileSystem,
        _migrationState = migrationState ?? MigrationStateService.instance,
        _uuid = uuid ?? const Uuid();

  static final PersonaChatConversationStorage instance =
      PersonaChatConversationStorage();

  static const int schemaVersion = 1;
  static const String storageMigrationKey = 'persona_chat_workspace_v1';

  final FileSystemService? _injectedFileSystem;
  final MigrationStateService _migrationState;
  final Uuid _uuid;
  final _logger = getLogger('PersonaChatConversationStorage');
  final Map<String, Lock> _locks = {};

  FileSystemService get _fileSystem =>
      _injectedFileSystem ?? FileSystemService.instance;

  Lock _lockFor(String userId, String characterId) {
    return _locks.putIfAbsent('$userId:$characterId', Lock.new);
  }

  Future<void> ensureLayout(String userId, String characterId) {
    return _lockFor(userId, characterId).synchronized(
      () => _ensureLayoutUnlocked(userId, characterId),
    );
  }

  Future<void> ensureMigrated({
    required String userId,
    required AppDatabase db,
  }) {
    return _migrationState.runOnce(
      userId: userId,
      key: storageMigrationKey,
      migrate: () => _exportSqliteToWorkspace(userId, db),
    );
  }

  Future<PersonaChatConversationRecord> appendMessage({
    required String userId,
    required String characterId,
    required bool isFromCharacter,
    required String content,
    required DateTime timestamp,
    required String messageType,
    required String origin,
    String? factId,
    bool isRead = false,
    String? contactEpisodeId,
    String? stableId,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      var state = await _readStateUnlocked(userId, characterId);
      final record = PersonaChatConversationRecord(
        id: stableId ?? _uuid.v4(),
        seq: state.nextSeq,
        characterId: characterId,
        isFromCharacter: isFromCharacter,
        content: content,
        factId: factId,
        isRead: isRead,
        timestamp: timestamp,
        messageType: messageType,
        origin: origin,
        contactEpisodeId: contactEpisodeId,
      );
      await _appendLineUnlocked(userId, characterId, record);
      await _writeStateUnlocked(
        userId,
        characterId,
        state.copyWith(
          nextSeq: state.nextSeq + 1,
          updatedAt: DateTime.now(),
          clearClearedAt: true,
        ),
      );
      return record;
    });
  }

  Future<List<PersonaChatConversationRecord>> appendEpisode({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> Function(int nextSeq) records,
    required String contactEpisodeId,
    required int expectedRecordCount,
  }) {
    if (contactEpisodeId.trim().isEmpty) {
      throw ArgumentError.value(contactEpisodeId, 'contactEpisodeId');
    }
    if (expectedRecordCount <= 0) {
      throw ArgumentError.value(expectedRecordCount, 'expectedRecordCount');
    }
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      final existing = await _readRecordsUnlocked(userId, characterId);
      final state = await _readStateUnlocked(userId, characterId);
      final already = existing
          .where((record) => record.contactEpisodeId == contactEpisodeId)
          .toList(growable: false);
      if (already.length == expectedRecordCount && already.isNotEmpty) {
        await _repairNextSeqIfNeeded(
          userId: userId,
          characterId: characterId,
          state: state,
          records: existing,
        );
        return already;
      }
      final nextSeq = _nextSeq(state, existing);
      final toWrite = records(nextSeq);
      if (toWrite.length != expectedRecordCount) {
        throw StateError(
          'Episode $contactEpisodeId produced ${toWrite.length} records; '
          'expected $expectedRecordCount.',
        );
      }
      for (var index = 0; index < toWrite.length; index++) {
        final record = toWrite[index];
        if (record.characterId != characterId ||
            record.contactEpisodeId != contactEpisodeId ||
            record.seq != nextSeq + index) {
          throw StateError(
            'Episode $contactEpisodeId produced an invalid record at $index.',
          );
        }
      }

      var retained = existing;
      if (already.isNotEmpty) {
        _logger.warning(
          'Replacing incomplete conversation episode $contactEpisodeId for '
          '$characterId (${already.length}/${toWrite.length} records)',
        );
        retained = existing
            .where((record) => record.contactEpisodeId != contactEpisodeId)
            .toList(growable: false);
      }
      final updated = [...retained, ...toWrite];
      final stableIds = <String>{};
      if (updated.any((record) => !stableIds.add(record.id))) {
        throw StateError(
          'Conversation $characterId contains duplicate stable message IDs.',
        );
      }
      await _writeMessagesFile(
        File(_fileSystem.getCharacterConversationMessagesPath(
          userId,
          characterId,
        )),
        updated,
      );
      await _writeStateUnlocked(
        userId,
        characterId,
        state.copyWith(
          nextSeq: _nextSeq(state, updated),
          updatedAt: DateTime.now(),
          clearClearedAt: true,
        ),
      );
      return toWrite;
    });
  }

  Future<List<PersonaChatConversationRecord>> loadMessages({
    required String userId,
    required String characterId,
  }) {
    return _lockFor(userId, characterId).synchronized(
      () => _readRecordsUnlocked(userId, characterId),
    );
  }

  Future<PersonaChatConversationState> loadState({
    required String userId,
    required String characterId,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      return _readStateUnlocked(userId, characterId);
    });
  }

  Future<void> advanceCursor({
    required String userId,
    required String characterId,
    required String consumedThroughMessageId,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      final records = await _readRecordsUnlocked(userId, characterId);
      final current = await _readStateUnlocked(userId, characterId);
      if (!_cursorIsAhead(
        records: records,
        currentId: current.consumedThroughMessageId,
        nextId: consumedThroughMessageId,
      )) {
        return;
      }
      await _writeStateUnlocked(
        userId,
        characterId,
        current.copyWith(
          consumedThroughMessageId: consumedThroughMessageId,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> clearConversation({
    required String userId,
    required String characterId,
    required DateTime clearedAt,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      await _writeMessagesFile(
        File(_fileSystem.getCharacterConversationMessagesPath(
          userId,
          characterId,
        )),
        const [],
      );
      await _writeStateUnlocked(
        userId,
        characterId,
        PersonaChatConversationState(
          schemaVersion: schemaVersion,
          nextSeq: 1,
          clearedAt: clearedAt,
          updatedAt: clearedAt,
        ),
      );
    });
  }

  Future<void> markAllRead({
    required String userId,
    required String characterId,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      final records = await _readRecordsUnlocked(userId, characterId);
      final updated = records
          .map(
            (record) =>
                record.isFromCharacter ? record.copyWith(isRead: true) : record,
          )
          .toList(growable: false);
      await _writeMessagesFile(
        File(_fileSystem.getCharacterConversationMessagesPath(
          userId,
          characterId,
        )),
        updated,
      );
    });
  }

  Future<void> rebuildSqliteProjection({
    required String userId,
    required String characterId,
    required AppDatabase db,
  }) {
    return _lockFor(userId, characterId).synchronized(() async {
      await _ensureLayoutUnlocked(userId, characterId);
      await _rebuildSqliteUnlocked(
        userId: userId,
        characterId: characterId,
        db: db,
      );
    });
  }

  Future<void> reconcileAll({
    required String userId,
    required AppDatabase db,
  }) async {
    final characterIds = await _characterIds(userId, db);
    for (final characterId in characterIds) {
      await rebuildSqliteProjection(
        userId: userId,
        characterId: characterId,
        db: db,
      );
    }
  }

  Future<void> _ensureLayoutUnlocked(String userId, String characterId) async {
    final directory = Directory(
      _fileSystem.getCharacterConversationPath(userId, characterId),
    );
    await directory.create(recursive: true);
    final messages = File(
      _fileSystem.getCharacterConversationMessagesPath(userId, characterId),
    );
    if (!await messages.exists()) {
      await messages.writeAsString('', flush: true);
    }
    final stateFile = File(
      _fileSystem.getCharacterConversationStatePath(userId, characterId),
    );
    if (!await stateFile.exists()) {
      await _writeJsonFile(
        stateFile,
        PersonaChatConversationState.initial().toJson(),
      );
    }
  }

  Future<bool> _exportSqliteToWorkspace(String userId, AppDatabase db) async {
    final characterIds = await _characterIdsFromSqlite(db);
    for (final characterId in characterIds) {
      await _lockFor(userId, characterId).synchronized(() async {
        await _ensureLayoutUnlocked(userId, characterId);
        final existing = await _readRecordsUnlocked(userId, characterId);
        if (existing.isNotEmpty) return;

        final rows = await (db.select(db.personaChatMessages)
              ..where((row) => row.characterId.equals(characterId))
              ..orderBy([
                (row) => OrderingTerm.asc(row.timestamp),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
        if (rows.isEmpty) return;

        var seq = 1;
        final records = <PersonaChatConversationRecord>[];
        for (final row in rows) {
          final stableId = (row.stableId != null && row.stableId!.isNotEmpty)
              ? row.stableId!
              : 'legacy-${row.id}';
          records.add(
            PersonaChatConversationRecord(
              id: stableId,
              seq: seq++,
              characterId: characterId,
              isFromCharacter: row.isFromCharacter,
              content: row.content,
              factId: row.factId,
              isRead: row.isRead,
              timestamp: row.timestamp,
              messageType: row.messageType,
              origin: row.origin,
              contactEpisodeId: row.contactEpisodeId,
            ),
          );
        }
        await _writeMessagesFile(
          File(_fileSystem.getCharacterConversationMessagesPath(
            userId,
            characterId,
          )),
          records,
        );

        final cursor = await (db.select(db.personaChatReplyCursors)
              ..where((row) => row.characterId.equals(characterId)))
            .getSingleOrNull();
        String? consumedStableId;
        if (cursor != null && cursor.consumedThroughMessageId > 0) {
          PersonaChatMessage? consumedRow;
          for (final row in rows) {
            if (row.id == cursor.consumedThroughMessageId) {
              consumedRow = row;
              break;
            }
          }
          if (consumedRow != null) {
            consumedStableId = (consumedRow.stableId != null &&
                    consumedRow.stableId!.isNotEmpty)
                ? consumedRow.stableId
                : 'legacy-${consumedRow.id}';
          } else {
            consumedStableId = 'legacy-${cursor.consumedThroughMessageId}';
          }
        }
        await _writeStateUnlocked(
          userId,
          characterId,
          PersonaChatConversationState(
            schemaVersion: schemaVersion,
            nextSeq: seq,
            consumedThroughMessageId: consumedStableId,
            updatedAt: DateTime.now(),
          ),
        );
      });
    }
    return true;
  }

  Future<void> _rebuildSqliteUnlocked({
    required String userId,
    required String characterId,
    required AppDatabase db,
  }) async {
    final records = await _readRecordsUnlocked(userId, characterId);
    final state = await _readStateUnlocked(userId, characterId);
    await db.transaction(() async {
      await (db.delete(db.personaChatMessages)
            ..where((row) => row.characterId.equals(characterId)))
          .go();
      await (db.delete(db.personaChatReplyCursors)
            ..where((row) => row.characterId.equals(characterId)))
          .go();
      final idByStable = <String, int>{};
      for (final record in records) {
        final id = await db.into(db.personaChatMessages).insert(
              PersonaChatMessagesCompanion.insert(
                characterId: record.characterId,
                isFromCharacter: record.isFromCharacter,
                content: record.content,
                factId: Value(record.factId),
                isRead: Value(record.isRead),
                timestamp: record.timestamp,
                messageType: Value(record.messageType),
                origin: Value(record.origin),
                contactEpisodeId: Value(record.contactEpisodeId),
                stableId: Value(record.id),
              ),
            );
        idByStable[record.id] = id;
      }
      final consumedStableId = state.consumedThroughMessageId;
      if (consumedStableId != null &&
          consumedStableId.isNotEmpty &&
          idByStable.containsKey(consumedStableId)) {
        await db.into(db.personaChatReplyCursors).insert(
              PersonaChatReplyCursorsCompanion.insert(
                characterId: characterId,
                consumedThroughMessageId: Value(idByStable[consumedStableId]!),
                updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              ),
            );
      }
    });
  }

  Future<List<PersonaChatConversationRecord>> _readRecordsUnlocked(
    String userId,
    String characterId,
  ) async {
    final file = File(
      _fileSystem.getCharacterConversationMessagesPath(userId, characterId),
    );
    if (!await file.exists()) return const [];
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return const [];
    final records = <PersonaChatConversationRecord>[];
    var lastValidOffset = 0;
    var lineStart = 0;

    Future<void> readLine(int lineEnd, {required bool terminated}) async {
      final endOffset = terminated ? lineEnd + 1 : lineEnd;
      try {
        final line = utf8.decode(bytes.sublist(lineStart, lineEnd));
        if (line.trim().isEmpty) {
          lastValidOffset = endOffset;
          return;
        }
        final decoded = jsonDecode(line);
        if (decoded is! Map) {
          throw const FormatException(
              'Conversation JSONL row is not an object');
        }
        final record = PersonaChatConversationRecord.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        if (record == null) {
          throw const FormatException('Conversation JSONL row is incomplete');
        }
        records.add(record);
        lastValidOffset = endOffset;
        return;
      } catch (error) {
        if (!terminated) {
          _logger.warning(
            'Truncating incomplete conversation JSONL tail in ${file.path}',
          );
          await file.writeAsBytes(
            bytes.sublist(0, lastValidOffset),
            flush: true,
          );
          return;
        }
        _logger.warning(
          'Skipping malformed conversation JSONL row in ${file.path}: $error',
        );
        lastValidOffset = endOffset;
      }
    }

    for (var index = 0; index < bytes.length; index++) {
      if (bytes[index] != 0x0A) continue;
      await readLine(index, terminated: true);
      lineStart = index + 1;
    }
    if (lineStart < bytes.length) {
      await readLine(bytes.length, terminated: false);
    }
    return records;
  }

  int _nextSeq(
    PersonaChatConversationState state,
    List<PersonaChatConversationRecord> records,
  ) {
    var nextSeq = state.nextSeq;
    for (final record in records) {
      if (record.seq >= nextSeq) nextSeq = record.seq + 1;
    }
    return nextSeq;
  }

  Future<void> _repairNextSeqIfNeeded({
    required String userId,
    required String characterId,
    required PersonaChatConversationState state,
    required List<PersonaChatConversationRecord> records,
  }) async {
    final nextSeq = _nextSeq(state, records);
    if (nextSeq == state.nextSeq) return;
    await _writeStateUnlocked(
      userId,
      characterId,
      state.copyWith(nextSeq: nextSeq, updatedAt: DateTime.now()),
    );
  }

  Future<PersonaChatConversationState> _readStateUnlocked(
    String userId,
    String characterId,
  ) async {
    final file = File(
      _fileSystem.getCharacterConversationStatePath(userId, characterId),
    );
    if (!await file.exists()) {
      return PersonaChatConversationState.initial();
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        return PersonaChatConversationState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to parse conversation state ${file.path}',
        error,
        stackTrace,
      );
    }
    return PersonaChatConversationState.initial();
  }

  Future<void> _appendLineUnlocked(
    String userId,
    String characterId,
    PersonaChatConversationRecord record,
  ) async {
    final file = File(
      _fileSystem.getCharacterConversationMessagesPath(userId, characterId),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(record.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  Future<void> _writeStateUnlocked(
    String userId,
    String characterId,
    PersonaChatConversationState state,
  ) {
    return _writeJsonFile(
      File(_fileSystem.getCharacterConversationStatePath(userId, characterId)),
      state.toJson(),
    );
  }

  Future<void> _writeMessagesFile(
    File file,
    List<PersonaChatConversationRecord> records,
  ) async {
    await file.parent.create(recursive: true);
    final content = records.isEmpty
        ? ''
        : '${records.map((record) => jsonEncode(record.toJson())).join('\n')}\n';
    await _replaceFile(file, content);
  }

  Future<void> _writeJsonFile(File file, Map<String, dynamic> data) async {
    const encoder = JsonEncoder.withIndent('  ');
    await _replaceFile(file, '${encoder.convert(data)}\n');
  }

  Future<void> _replaceFile(File file, String content) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(content, encoding: utf8, flush: true);
    try {
      await temporary.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    }
  }

  bool _cursorIsAhead({
    required List<PersonaChatConversationRecord> records,
    required String? currentId,
    required String nextId,
  }) {
    if (currentId == null || currentId.isEmpty) return true;
    if (currentId == nextId) return false;
    final currentIndex = records.indexWhere((record) => record.id == currentId);
    final nextIndex = records.indexWhere((record) => record.id == nextId);
    if (nextIndex < 0) return false;
    if (currentIndex < 0) return true;
    return nextIndex > currentIndex;
  }

  Future<Set<String>> _characterIds(String userId, AppDatabase db) async {
    final ids = await _characterIdsFromSqlite(db);
    final root = Directory(_fileSystem.getCharacterWorkspacesPath(userId));
    if (await root.exists()) {
      await for (final entity in root.list(followLinks: false)) {
        if (entity is! Directory) continue;
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue;
        ids.add(name);
      }
    }
    return ids;
  }

  Future<Set<String>> _characterIdsFromSqlite(AppDatabase db) async {
    final rows = await db
        .customSelect(
          'SELECT DISTINCT character_id FROM persona_chat_messages',
        )
        .get();
    return rows
        .map((row) => row.data['character_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
  }
}
