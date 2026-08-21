import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/jsonl_conversation_journal.dart';
import 'package:memex/data/services/jsonl_file_store.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

class PersonaChatConversationRecord {
  const PersonaChatConversationRecord({
    required this.id,
    required this.characterId,
    required this.isFromCharacter,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.messageType,
    required this.origin,
    this.factId,
    this.turnId,
  });

  final int id;
  final String characterId;
  final bool isFromCharacter;
  final String content;
  final String? factId;
  final bool isRead;
  final DateTime timestamp;
  final String messageType;
  final String origin;
  final String? turnId;

  PersonaChatConversationRecord copyWith({bool? isRead}) {
    return PersonaChatConversationRecord(
      id: id,
      characterId: characterId,
      isFromCharacter: isFromCharacter,
      content: content,
      factId: factId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
      messageType: messageType,
      origin: origin,
      turnId: turnId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': isFromCharacter ? 'assistant' : 'user',
        'content': [
          {
            'type': messageType == PersonaChatMessageTypes.text
                ? 'text'
                : messageType,
            'text': content,
          },
        ],
        if (factId != null) 'fact_id': factId,
        'created_at': timestamp.toIso8601String(),
        'unix_seconds': timestamp.millisecondsSinceEpoch ~/ 1000,
        'origin': origin,
        if (turnId != null) 'turn_id': turnId,
      };

  static PersonaChatConversationRecord? fromJson(
    Map<String, dynamic> json, {
    required String characterId,
  }) {
    final id = json['id'];
    final role = json['role']?.toString();
    final contentBlocks = json['content'];
    if (id is! num ||
        id.toInt() <= 0 ||
        (role != 'user' && role != 'assistant') ||
        contentBlocks is! List) {
      return null;
    }

    Map<String, dynamic>? block;
    for (final candidate in contentBlocks) {
      if (candidate is Map && candidate['text'] != null) {
        block = Map<String, dynamic>.from(candidate);
        break;
      }
    }
    if (block == null) return null;
    final content = block['text']?.toString();
    if (content == null) return null;

    final timestampText = json['created_at']?.toString();
    final unixSeconds = json['unix_seconds'];
    final timestamp = timestampText == null
        ? unixSeconds is num
            ? DateTime.fromMillisecondsSinceEpoch(unixSeconds.toInt() * 1000)
            : DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.tryParse(timestampText) ??
            DateTime.fromMillisecondsSinceEpoch(0);
    final blockType = block['type']?.toString() ?? 'text';
    return PersonaChatConversationRecord(
      id: id.toInt(),
      characterId: characterId,
      isFromCharacter: role == 'assistant',
      content: content,
      factId: json['fact_id']?.toString(),
      isRead: false,
      timestamp: timestamp,
      messageType:
          blockType == 'text' ? PersonaChatMessageTypes.text : blockType,
      origin: json['origin']?.toString() ?? 'conversation',
      turnId: json['turn_id']?.toString(),
    );
  }
}

class PersonaChatConversationMetadata {
  const PersonaChatConversationMetadata({
    required this.schemaVersion,
    required this.generation,
    required this.nextMessageId,
    required this.messageCount,
    required this.unreadCount,
    required this.messagesByteLength,
    required this.readThroughMessageId,
    required this.agentProcessedThroughUserMessageId,
    required this.lastMessageId,
    required this.latestUserMessageId,
    this.lastTurnId,
    this.lastTurnFirstMessageId,
    this.lastTurnLastMessageId,
    this.updatedAt,
    this.clearedAt,
  });

  factory PersonaChatConversationMetadata.initial() {
    return const PersonaChatConversationMetadata(
      schemaVersion: PersonaChatConversationStorage.schemaVersion,
      generation: 1,
      nextMessageId: 1,
      messageCount: 0,
      unreadCount: 0,
      messagesByteLength: 0,
      readThroughMessageId: 0,
      agentProcessedThroughUserMessageId: 0,
      lastMessageId: 0,
      latestUserMessageId: 0,
    );
  }

  final int schemaVersion;
  final int generation;
  final int nextMessageId;
  final int messageCount;
  final int unreadCount;
  final int messagesByteLength;
  final int readThroughMessageId;
  final int agentProcessedThroughUserMessageId;
  final int lastMessageId;
  final int latestUserMessageId;
  final String? lastTurnId;
  final int? lastTurnFirstMessageId;
  final int? lastTurnLastMessageId;
  final DateTime? updatedAt;
  final DateTime? clearedAt;

  PersonaChatConversationMetadata copyWith({
    int? generation,
    int? nextMessageId,
    int? messageCount,
    int? unreadCount,
    int? messagesByteLength,
    int? readThroughMessageId,
    int? agentProcessedThroughUserMessageId,
    int? lastMessageId,
    int? latestUserMessageId,
    String? lastTurnId,
    bool clearLastTurn = false,
    int? lastTurnFirstMessageId,
    int? lastTurnLastMessageId,
    DateTime? updatedAt,
    DateTime? clearedAt,
    bool clearClearedAt = false,
  }) {
    return PersonaChatConversationMetadata(
      schemaVersion: schemaVersion,
      generation: generation ?? this.generation,
      nextMessageId: nextMessageId ?? this.nextMessageId,
      messageCount: messageCount ?? this.messageCount,
      unreadCount: unreadCount ?? this.unreadCount,
      messagesByteLength: messagesByteLength ?? this.messagesByteLength,
      readThroughMessageId: readThroughMessageId ?? this.readThroughMessageId,
      agentProcessedThroughUserMessageId: agentProcessedThroughUserMessageId ??
          this.agentProcessedThroughUserMessageId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      latestUserMessageId: latestUserMessageId ?? this.latestUserMessageId,
      lastTurnId: clearLastTurn ? null : lastTurnId ?? this.lastTurnId,
      lastTurnFirstMessageId: clearLastTurn
          ? null
          : lastTurnFirstMessageId ?? this.lastTurnFirstMessageId,
      lastTurnLastMessageId: clearLastTurn
          ? null
          : lastTurnLastMessageId ?? this.lastTurnLastMessageId,
      updatedAt: updatedAt ?? this.updatedAt,
      clearedAt: clearClearedAt ? null : clearedAt ?? this.clearedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'generation': generation,
        'next_message_id': nextMessageId,
        'read_through_message_id': readThroughMessageId,
        'agent_processed_through_user_message_id':
            agentProcessedThroughUserMessageId,
        'summary': {
          'message_count': messageCount,
          'unread_count': unreadCount,
          'messages_byte_length': messagesByteLength,
          'last_message_id': lastMessageId,
          'latest_user_message_id': latestUserMessageId,
        },
        if (lastTurnId != null)
          'last_committed_turn': {
            'id': lastTurnId,
            'first_message_id': lastTurnFirstMessageId,
            'last_message_id': lastTurnLastMessageId,
          },
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (clearedAt != null) 'cleared_at': clearedAt!.toIso8601String(),
      };

  static PersonaChatConversationMetadata? fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['schema_version'] !=
        PersonaChatConversationStorage.schemaVersion) {
      return null;
    }
    final summary = json['summary'];
    if (summary is! Map) return null;
    final turn = json['last_committed_turn'];
    final turnMap = turn is Map ? Map<String, dynamic>.from(turn) : null;
    return PersonaChatConversationMetadata(
      schemaVersion: PersonaChatConversationStorage.schemaVersion,
      generation: _positiveInt(json['generation'], fallback: 1),
      nextMessageId: _positiveInt(json['next_message_id'], fallback: 1),
      messageCount: _nonNegativeInt(summary['message_count']),
      unreadCount: _nonNegativeInt(summary['unread_count']),
      messagesByteLength: _nonNegativeInt(summary['messages_byte_length']),
      readThroughMessageId: _nonNegativeInt(json['read_through_message_id']),
      agentProcessedThroughUserMessageId:
          _nonNegativeInt(json['agent_processed_through_user_message_id']),
      lastMessageId: _nonNegativeInt(summary['last_message_id']),
      latestUserMessageId: _nonNegativeInt(summary['latest_user_message_id']),
      lastTurnId: turnMap?['id']?.toString(),
      lastTurnFirstMessageId: _positiveIntOrNull(turnMap?['first_message_id']),
      lastTurnLastMessageId: _positiveIntOrNull(turnMap?['last_message_id']),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      clearedAt: DateTime.tryParse(json['cleared_at']?.toString() ?? ''),
    );
  }

  static int _nonNegativeInt(dynamic value) =>
      value is num && value >= 0 ? value.toInt() : 0;

  static int _positiveInt(dynamic value, {required int fallback}) =>
      value is num && value > 0 ? value.toInt() : fallback;

  static int? _positiveIntOrNull(dynamic value) =>
      value is num && value > 0 ? value.toInt() : null;
}

class PersonaChatConversationPage {
  const PersonaChatConversationPage({
    required this.records,
    required this.olderCursor,
    required this.newestCursor,
  });

  final List<PersonaChatConversationRecord> records;
  final int? olderCursor;
  final int newestCursor;
}

typedef PersonaChatCommitPhase = JsonlConversationCommitPhase;
typedef PersonaChatCommitObserver = JsonlConversationCommitObserver;

/// Workspace-authoritative persona conversation storage.
///
/// Every line in `messages.jsonl` is one immutable message. Mutable read and
/// agent-processing boundaries live in `metadata.json`. Agent-produced turns
/// are committed with a single transient write-ahead file so multiple bubbles
/// and their state transition recover together after a process interruption.
class PersonaChatConversationStorage {
  PersonaChatConversationStorage({
    FileSystemService? fileSystem,
    JsonlFileStore? jsonl,
    PersonaChatCommitObserver? commitObserver,
  })  : _injectedFileSystem = fileSystem,
        _jsonl = jsonl ?? JsonlFileStore(loggerName: 'PersonaChatJsonl') {
    _journal = JsonlConversationJournal(
      jsonl: _jsonl,
      observer: commitObserver,
    );
  }

  static final PersonaChatConversationStorage instance =
      PersonaChatConversationStorage();

  // This is the first released workspace format. The episode-based format
  // existed only inside the unmerged pull request and is intentionally not a
  // migration source.
  static const int schemaVersion = 1;
  static const String storageMigrationKey = 'persona_chat_workspace_v1';
  static const int _scanPageSize = 64;
  static final Map<String, Lock> _processLocks = {};

  final FileSystemService? _injectedFileSystem;
  final JsonlFileStore _jsonl;
  late final JsonlConversationJournal _journal;

  FileSystemService get _fileSystem =>
      _injectedFileSystem ?? FileSystemService.instance;

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
    String? turnId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final record = PersonaChatConversationRecord(
        id: metadata.nextMessageId,
        characterId: characterId,
        isFromCharacter: isFromCharacter,
        content: content,
        factId: factId,
        isRead: isRead || !isFromCharacter,
        timestamp: timestamp,
        messageType: messageType,
        origin: origin,
        turnId: turnId,
      );
      final append = await _jsonl.append(
        _messagesFile(userId, characterId),
        [record.toJson()],
      );
      final next = _metadataAfterAppend(
        metadata,
        [record],
        messagesByteLength: append.endOffset,
        readThroughMessageId: isFromCharacter && isRead ? record.id : null,
        lastTurnId: turnId,
      );
      await _writeMetadata(userId, characterId, next);
      return _withEffectiveRead(record, next);
    });
  }

  Future<List<PersonaChatConversationRecord>> appendTurn({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> Function(int firstMessageId)
        records,
    required String turnId,
    required int expectedRecordCount,
    int? agentProcessedThroughUserMessageId,
    int? expectedGeneration,
  }) {
    _validateTurn(turnId, expectedRecordCount);
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      if (expectedGeneration != null &&
          metadata.generation != expectedGeneration) {
        throw StateError(
          'Persona conversation changed while the reply was generated.',
        );
      }
      final alreadyProcessed = agentProcessedThroughUserMessageId != null &&
          metadata.agentProcessedThroughUserMessageId >=
              agentProcessedThroughUserMessageId;
      final existing = await _loadCommittedTurn(
        userId,
        characterId,
        metadata,
        turnId,
        searchHistory: alreadyProcessed,
      );
      if (existing != null) {
        _verifyTurnCount(existing, expectedRecordCount);
        if (agentProcessedThroughUserMessageId != null &&
            metadata.agentProcessedThroughUserMessageId <
                agentProcessedThroughUserMessageId) {
          await _commitUnlocked(
            userId: userId,
            characterId: characterId,
            metadata: metadata,
            records: const [],
            nextMetadata: metadata.copyWith(
              agentProcessedThroughUserMessageId:
                  agentProcessedThroughUserMessageId,
              updatedAt: DateTime.now(),
            ),
          );
        }
        return existing
            .map((record) => _withEffectiveRead(record, metadata))
            .toList(growable: false);
      }
      if (alreadyProcessed) {
        throw StateError(
          'Conversation input was already finalized without turn $turnId.',
        );
      }

      if (agentProcessedThroughUserMessageId != null) {
        _validateProcessedBoundary(
          metadata,
          agentProcessedThroughUserMessageId,
        );
      }
      final toWrite = records(metadata.nextMessageId);
      _verifyNewTurn(
        characterId,
        turnId,
        metadata.nextMessageId,
        expectedRecordCount,
        toWrite,
      );
      final next = _metadataAfterAppend(
        metadata,
        toWrite,
        messagesByteLength: metadata.messagesByteLength +
            _encodedRowsLength(toWrite.map((record) => record.toJson())),
        readThroughMessageId: _readBoundaryFromRecords(toWrite),
        agentProcessedThroughUserMessageId: agentProcessedThroughUserMessageId,
        lastTurnId: turnId,
      );
      await _commitUnlocked(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: toWrite,
        nextMetadata: next,
      );
      return toWrite.map((record) => _withEffectiveRead(record, next)).toList();
    });
  }

  Future<bool> tryAppendInitiativeTurn({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> Function(int firstMessageId)
        records,
    required String turnId,
    required int expectedRecordCount,
    int? expectedGeneration,
  }) {
    _validateTurn(turnId, expectedRecordCount);
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      if (expectedGeneration != null &&
          metadata.generation != expectedGeneration) {
        return false;
      }
      final existing = await _loadCommittedTurn(
        userId,
        characterId,
        metadata,
        turnId,
        // Initiative is infrequent and has no processing cursor. Scanning on
        // a cache miss keeps messages.jsonl as the only idempotency fact.
        searchHistory: true,
      );
      if (existing != null) {
        _verifyTurnCount(existing, expectedRecordCount);
        return true;
      }
      if (metadata.latestUserMessageId >
          metadata.agentProcessedThroughUserMessageId) {
        return false;
      }

      final toWrite = records(metadata.nextMessageId);
      _verifyNewTurn(
        characterId,
        turnId,
        metadata.nextMessageId,
        expectedRecordCount,
        toWrite,
      );
      final next = _metadataAfterAppend(
        metadata,
        toWrite,
        messagesByteLength: metadata.messagesByteLength +
            _encodedRowsLength(toWrite.map((record) => record.toJson())),
        readThroughMessageId: _readBoundaryFromRecords(toWrite),
        lastTurnId: turnId,
      );
      await _commitUnlocked(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: toWrite,
        nextMetadata: next,
      );
      return true;
    });
  }

  Future<PersonaChatConversationPage> loadMessagePage({
    required String userId,
    required String characterId,
    required int limit,
    int? beforeCursor,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      if (limit <= 0) {
        return PersonaChatConversationPage(
          records: const [],
          olderCursor: null,
          newestCursor: metadata.messagesByteLength,
        );
      }
      final page = await _jsonl.readPageBefore(
        _messagesFile(userId, characterId),
        limit: limit,
        beforeOffset: beforeCursor,
      );
      final records = page.rows
          .map(
            (row) => PersonaChatConversationRecord.fromJson(
              row,
              characterId: characterId,
            ),
          )
          .whereType<PersonaChatConversationRecord>()
          .toList(growable: false)
          .reversed
          .map((record) => _withEffectiveRead(record, metadata))
          .toList(growable: false);
      return PersonaChatConversationPage(
        records: records,
        olderCursor: page.olderOffset,
        newestCursor: metadata.messagesByteLength,
      );
    });
  }

  Future<PersonaChatConversationPage> loadMessagesAfter({
    required String userId,
    required String characterId,
    required int afterCursor,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final file = _messagesFile(userId, characterId);
      final safeCursor =
          afterCursor.clamp(0, metadata.messagesByteLength).toInt();
      if (safeCursor == metadata.messagesByteLength) {
        return PersonaChatConversationPage(
          records: const [],
          olderCursor: null,
          newestCursor: metadata.messagesByteLength,
        );
      }
      final handle = await file.open();
      late List<int> bytes;
      try {
        await handle.setPosition(safeCursor);
        bytes = await handle.read(metadata.messagesByteLength - safeCursor);
      } finally {
        await handle.close();
      }
      final records = <PersonaChatConversationRecord>[];
      for (final line in utf8.decode(bytes).split('\n')) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = jsonDecode(line);
          if (decoded is! Map) continue;
          final record = PersonaChatConversationRecord.fromJson(
            Map<String, dynamic>.from(decoded),
            characterId: characterId,
          );
          if (record != null) records.add(_withEffectiveRead(record, metadata));
        } catch (_) {
          continue;
        }
      }
      return PersonaChatConversationPage(
        records: records.reversed.toList(growable: false),
        olderCursor: null,
        newestCursor: metadata.messagesByteLength,
      );
    });
  }

  Future<List<PersonaChatConversationRecord>> loadMessages({
    required String userId,
    required String characterId,
    int? limit,
    int offset = 0,
  }) async {
    if (limit == null || limit <= 0) {
      return _synchronized(userId, characterId, () async {
        final metadata = await _prepareUnlocked(userId, characterId);
        return (await _readAllRecords(userId, characterId))
            .reversed
            .map((record) => _withEffectiveRead(record, metadata))
            .toList(growable: false);
      });
    }
    final page = await loadMessagePage(
      userId: userId,
      characterId: characterId,
      limit: limit + offset,
    );
    return page.records.skip(offset).take(limit).toList(growable: false);
  }

  Future<List<PersonaChatConversationRecord>> loadMessagesBefore({
    required String userId,
    required String characterId,
    required int beforeMessageId,
    int limit = 50,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final records = await _scanBackwards(
        userId,
        characterId,
        include: (record) => record.id < beforeMessageId,
        stop: (collected, record) =>
            record.id < beforeMessageId && collected.length >= limit,
      );
      return records
          .take(limit)
          .map((record) => _withEffectiveRead(record, metadata))
          .toList(growable: false);
    });
  }

  Future<List<PersonaChatConversationRecord>> loadPendingUserMessages({
    required String userId,
    required String characterId,
    int limit = 50,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final newestFirst = await _scanBackwards(
        userId,
        characterId,
        include: (record) =>
            record.id > metadata.agentProcessedThroughUserMessageId &&
            !record.isFromCharacter,
        stop: (_, record) =>
            record.id <= metadata.agentProcessedThroughUserMessageId,
      );
      return newestFirst.reversed.take(limit).toList(growable: false);
    });
  }

  Future<int> getReplyCursor({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _prepareUnlocked(userId, characterId))
          .agentProcessedThroughUserMessageId;
    });
  }

  Future<PersonaChatConversationMetadata> loadMetadata({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(
      userId,
      characterId,
      () => _prepareUnlocked(userId, characterId),
    );
  }

  Future<int> conversationGeneration({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _prepareUnlocked(userId, characterId)).generation;
    });
  }

  Future<void> advanceCursor({
    required String userId,
    required String characterId,
    required int processedThroughUserMessageId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      _validateProcessedBoundary(metadata, processedThroughUserMessageId);
      if (metadata.agentProcessedThroughUserMessageId >=
          processedThroughUserMessageId) {
        return;
      }
      await _writeMetadata(
        userId,
        characterId,
        metadata.copyWith(
          agentProcessedThroughUserMessageId: processedThroughUserMessageId,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<int> unreadCount({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _prepareUnlocked(userId, characterId)).unreadCount;
    });
  }

  Future<int> totalUnreadCount(String userId) async {
    var total = 0;
    for (final characterId in await characterIds(userId)) {
      total += await unreadCount(userId: userId, characterId: characterId);
    }
    return total;
  }

  Future<int> markAllRead({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final changed = metadata.unreadCount;
      if (changed == 0) return 0;
      await _writeMetadata(
        userId,
        characterId,
        metadata.copyWith(
          unreadCount: 0,
          readThroughMessageId: metadata.lastMessageId,
          updatedAt: DateTime.now(),
        ),
      );
      return changed;
    });
  }

  Future<PersonaChatConversationRecord?> lastMessage({
    required String userId,
    required String characterId,
  }) async {
    final page = await loadMessagePage(
      userId: userId,
      characterId: characterId,
      limit: 1,
    );
    return page.records.isEmpty ? null : page.records.first;
  }

  Future<int> latestMessageId({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _prepareUnlocked(userId, characterId)).lastMessageId;
    });
  }

  Future<int> clearConversation({
    required String userId,
    required String characterId,
    required DateTime clearedAt,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      final next = PersonaChatConversationMetadata.initial().copyWith(
        generation: metadata.generation + 1,
        nextMessageId: metadata.nextMessageId,
        clearedAt: clearedAt,
        updatedAt: clearedAt,
      );
      await _commitUnlocked(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: const [],
        nextMetadata: next,
        baseOffset: 0,
        truncateBeforeAppend: true,
      );
      return metadata.messageCount;
    });
  }

  /// Imports SQLite history only when the workspace conversation is empty.
  Future<bool> importLegacySnapshot({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> records,
    int? agentProcessedThroughUserMessageId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _prepareUnlocked(userId, characterId);
      if (metadata.messageCount > 0 || records.isEmpty) return false;
      _verifyContiguousRecords(characterId, records);
      final readThrough = records
          .where((record) => record.isFromCharacter && record.isRead)
          .fold<int>(0,
              (current, record) => record.id > current ? record.id : current);
      final next = _metadataFromRecords(
        records,
        previous: metadata,
        messagesByteLength:
            _encodedRowsLength(records.map((record) => record.toJson())),
        readThroughMessageId: readThrough,
        agentProcessedThroughUserMessageId:
            agentProcessedThroughUserMessageId ?? 0,
      );
      await _commitUnlocked(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: records,
        nextMetadata: next,
        baseOffset: 0,
        truncateBeforeAppend: true,
      );
      return true;
    });
  }

  Future<Set<String>> characterIds(String userId) async {
    final root = Directory(_fileSystem.getCharacterWorkspacesPath(userId));
    if (!await root.exists()) return <String>{};
    final ids = <String>{};
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = p.basename(entity.path);
      if (id.startsWith('.')) continue;
      if (await _messagesFile(userId, id).exists() ||
          await _metadataFile(userId, id).exists()) {
        ids.add(id);
      }
    }
    return ids;
  }

  Future<Set<String>> charactersWithPendingUserMessages(String userId) async {
    final result = <String>{};
    for (final characterId in await characterIds(userId)) {
      final metadata = await loadMetadata(
        userId: userId,
        characterId: characterId,
      );
      if (metadata.latestUserMessageId >
          metadata.agentProcessedThroughUserMessageId) {
        result.add(characterId);
      }
    }
    return result;
  }

  Future<void> _commitUnlocked({
    required String userId,
    required String characterId,
    required PersonaChatConversationMetadata metadata,
    required List<PersonaChatConversationRecord> records,
    required PersonaChatConversationMetadata nextMetadata,
    int? baseOffset,
    bool truncateBeforeAppend = false,
  }) async {
    await _journal.commit(
      messagesFile: _messagesFile(userId, characterId),
      metadataFile: _metadataFile(userId, characterId),
      pendingFile: _pendingCommitFile(userId, characterId),
      baseOffset: baseOffset ?? metadata.messagesByteLength,
      messages: records.map((record) => record.toJson()).toList(),
      targetMetadata: nextMetadata.toJson(),
      truncateBeforeAppend: truncateBeforeAppend,
    );
  }

  Future<PersonaChatConversationMetadata> _prepareUnlocked(
    String userId,
    String characterId,
  ) async {
    await _ensureLayout(userId, characterId);
    await _recoverPendingCommit(userId, characterId);
    return _readMetadataRepairingIfNeeded(userId, characterId);
  }

  Future<void> _recoverPendingCommit(
    String userId,
    String characterId,
  ) async {
    await _journal.recover(
      messagesFile: _messagesFile(userId, characterId),
      metadataFile: _metadataFile(userId, characterId),
      pendingFile: _pendingCommitFile(userId, characterId),
      validateMetadata: (target) =>
          PersonaChatConversationMetadata.fromJson(target) != null,
    );
  }

  Future<PersonaChatConversationMetadata> _readMetadataRepairingIfNeeded(
    String userId,
    String characterId,
  ) async {
    final file = _metadataFile(userId, characterId);
    PersonaChatConversationMetadata? metadata;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        metadata = PersonaChatConversationMetadata.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      metadata = null;
    }
    final messagesLength = await _messagesFile(userId, characterId).length();
    if (metadata != null && metadata.messagesByteLength == messagesLength) {
      return metadata;
    }

    final records = await _readAllRecords(userId, characterId);
    final repaired = _metadataFromRecords(
      records,
      previous: metadata ?? PersonaChatConversationMetadata.initial(),
      messagesByteLength: await _messagesFile(userId, characterId).length(),
      readThroughMessageId: metadata?.readThroughMessageId ?? 0,
      agentProcessedThroughUserMessageId:
          metadata?.agentProcessedThroughUserMessageId ?? 0,
    );
    await _writeMetadata(userId, characterId, repaired);
    return repaired;
  }

  PersonaChatConversationMetadata _metadataAfterAppend(
    PersonaChatConversationMetadata metadata,
    List<PersonaChatConversationRecord> records, {
    required int messagesByteLength,
    int? readThroughMessageId,
    int? agentProcessedThroughUserMessageId,
    String? lastTurnId,
  }) {
    final effectiveReadThrough = readThroughMessageId == null
        ? metadata.readThroughMessageId
        : readThroughMessageId > metadata.readThroughMessageId
            ? readThroughMessageId
            : metadata.readThroughMessageId;
    final unreadAdded = records
        .where(
          (record) =>
              record.isFromCharacter && record.id > effectiveReadThrough,
        )
        .length;
    final latestUser = records
        .where((record) => !record.isFromCharacter)
        .fold<int>(metadata.latestUserMessageId, (current, record) {
      return record.id > current ? record.id : current;
    });
    final last = records.last;
    return metadata.copyWith(
      nextMessageId: last.id + 1,
      messageCount: metadata.messageCount + records.length,
      unreadCount: metadata.unreadCount + unreadAdded,
      messagesByteLength: messagesByteLength,
      readThroughMessageId: effectiveReadThrough,
      agentProcessedThroughUserMessageId: agentProcessedThroughUserMessageId,
      lastMessageId: last.id,
      latestUserMessageId: latestUser,
      lastTurnId: lastTurnId,
      lastTurnFirstMessageId: lastTurnId == null ? null : records.first.id,
      lastTurnLastMessageId: lastTurnId == null ? null : records.last.id,
      updatedAt: DateTime.now(),
      clearClearedAt: true,
    );
  }

  PersonaChatConversationMetadata _metadataFromRecords(
    List<PersonaChatConversationRecord> records, {
    required PersonaChatConversationMetadata previous,
    required int messagesByteLength,
    required int readThroughMessageId,
    required int agentProcessedThroughUserMessageId,
  }) {
    final lastId = records.isEmpty ? 0 : records.last.id;
    final latestUser = records
        .where((record) => !record.isFromCharacter)
        .fold<int>(
            0, (current, record) => record.id > current ? record.id : current);
    final unread = records
        .where(
          (record) =>
              record.isFromCharacter && record.id > readThroughMessageId,
        )
        .length;
    final lastTurnId = records.isEmpty ? null : records.last.turnId;
    int? firstTurnId;
    if (lastTurnId != null) {
      for (final record in records.reversed) {
        if (record.turnId != lastTurnId) break;
        firstTurnId = record.id;
      }
    }
    return PersonaChatConversationMetadata(
      schemaVersion: schemaVersion,
      generation: previous.generation,
      nextMessageId: previous.nextMessageId > lastId + 1
          ? previous.nextMessageId
          : lastId + 1,
      messageCount: records.length,
      unreadCount: unread,
      messagesByteLength: messagesByteLength,
      readThroughMessageId: readThroughMessageId,
      agentProcessedThroughUserMessageId: agentProcessedThroughUserMessageId,
      lastMessageId: lastId,
      latestUserMessageId: latestUser,
      lastTurnId: lastTurnId,
      lastTurnFirstMessageId: firstTurnId,
      lastTurnLastMessageId: lastTurnId == null ? null : lastId,
      updatedAt: DateTime.now(),
      clearedAt: records.isEmpty ? previous.clearedAt : null,
    );
  }

  Future<List<PersonaChatConversationRecord>?> _loadCommittedTurn(
      String userId,
      String characterId,
      PersonaChatConversationMetadata metadata,
      String turnId,
      {required bool searchHistory}) async {
    if (metadata.lastTurnId == turnId &&
        metadata.lastTurnFirstMessageId != null &&
        metadata.lastTurnLastMessageId != null) {
      final newestFirst = await _scanBackwards(
        userId,
        characterId,
        include: (record) =>
            record.id >= metadata.lastTurnFirstMessageId! &&
            record.id <= metadata.lastTurnLastMessageId! &&
            record.turnId == turnId,
        stop: (_, record) => record.id < metadata.lastTurnFirstMessageId!,
      );
      return newestFirst.reversed.toList(growable: false);
    }
    if (!searchHistory) return null;

    final newestFirst = await _scanBackwards(
      userId,
      characterId,
      include: (record) => record.turnId == turnId,
      stop: (collected, record) =>
          collected.isNotEmpty && record.turnId != turnId,
    );
    return newestFirst.isEmpty
        ? null
        : newestFirst.reversed.toList(growable: false);
  }

  Future<List<PersonaChatConversationRecord>> _readAllRecords(
    String userId,
    String characterId,
  ) async {
    final rows = await _jsonl.readAllRecoveringTail(
      _messagesFile(userId, characterId),
    );
    return rows
        .map(
          (row) => PersonaChatConversationRecord.fromJson(
            row,
            characterId: characterId,
          ),
        )
        .whereType<PersonaChatConversationRecord>()
        .toList(growable: false);
  }

  Future<List<PersonaChatConversationRecord>> _scanBackwards(
    String userId,
    String characterId, {
    required bool Function(PersonaChatConversationRecord record) include,
    required bool Function(
      List<PersonaChatConversationRecord> collected,
      PersonaChatConversationRecord record,
    ) stop,
  }) async {
    int? cursor;
    final collected = <PersonaChatConversationRecord>[];
    while (true) {
      final page = await _jsonl.readPageBefore(
        _messagesFile(userId, characterId),
        limit: _scanPageSize,
        beforeOffset: cursor,
      );
      if (page.rows.isEmpty) return collected;
      for (final row in page.rows.reversed) {
        final record = PersonaChatConversationRecord.fromJson(
          row,
          characterId: characterId,
        );
        if (record == null) continue;
        if (include(record)) collected.add(record);
        if (stop(collected, record)) return collected;
      }
      cursor = page.olderOffset;
      if (cursor == null) return collected;
    }
  }

  int? _readBoundaryFromRecords(
    List<PersonaChatConversationRecord> records,
  ) {
    int? result;
    for (final record in records) {
      if (record.isFromCharacter && record.isRead) result = record.id;
    }
    return result;
  }

  PersonaChatConversationRecord _withEffectiveRead(
    PersonaChatConversationRecord record,
    PersonaChatConversationMetadata metadata,
  ) {
    if (!record.isFromCharacter || record.id <= metadata.readThroughMessageId) {
      return record.copyWith(isRead: true);
    }
    return record.copyWith(isRead: false);
  }

  void _validateProcessedBoundary(
    PersonaChatConversationMetadata metadata,
    int value,
  ) {
    if (value <= 0 || value >= metadata.nextMessageId) {
      throw ArgumentError.value(
        value,
        'agentProcessedThroughUserMessageId',
      );
    }
  }

  Future<void> _ensureLayout(String userId, String characterId) async {
    final directory = Directory(
      _fileSystem.getCharacterConversationPath(userId, characterId),
    );
    await directory.create(recursive: true);
    final messages = _messagesFile(userId, characterId);
    if (!await messages.exists()) await messages.writeAsString('', flush: true);
    final metadata = _metadataFile(userId, characterId);
    if (!await metadata.exists()) {
      await _writeMetadata(
        userId,
        characterId,
        PersonaChatConversationMetadata.initial(),
      );
    }
  }

  Future<T> _synchronized<T>(
    String userId,
    String characterId,
    Future<T> Function() action,
  ) {
    final lockPath = _fileSystem.getCharacterConversationWriteLockPath(
      userId,
      characterId,
    );
    return _processLocks.putIfAbsent(lockPath, Lock.new).synchronized(() async {
      await Directory(
        _fileSystem.getCharacterConversationPath(userId, characterId),
      ).create(recursive: true);
      final handle = await File(lockPath).open(mode: FileMode.append);
      await handle.lock(FileLock.exclusive);
      try {
        return await action();
      } finally {
        await handle.unlock();
        await handle.close();
      }
    });
  }

  File _messagesFile(String userId, String characterId) => File(
        _fileSystem.getCharacterConversationMessagesPath(userId, characterId),
      );

  File _metadataFile(String userId, String characterId) => File(
        _fileSystem.getCharacterConversationMetadataPath(userId, characterId),
      );

  File _pendingCommitFile(String userId, String characterId) => File(
        _fileSystem.getCharacterConversationPendingCommitPath(
          userId,
          characterId,
        ),
      );

  Future<void> _writeMetadata(
    String userId,
    String characterId,
    PersonaChatConversationMetadata metadata,
  ) {
    return _writeJsonFile(
      _metadataFile(userId, characterId),
      metadata.toJson(),
    );
  }

  Future<void> _writeJsonFile(File file, Map<String, dynamic> value) {
    return _journal.writeJsonFile(file, value);
  }

  int _encodedRowsLength(Iterable<Map<String, dynamic>> rows) {
    final materialized = rows.toList(growable: false);
    if (materialized.isEmpty) return 0;
    return utf8.encode('${materialized.map(jsonEncode).join('\n')}\n').length;
  }

  void _validateTurn(String turnId, int expectedCount) {
    if (turnId.trim().isEmpty) {
      throw ArgumentError.value(turnId, 'turnId');
    }
    if (expectedCount <= 0) {
      throw ArgumentError.value(expectedCount, 'expectedRecordCount');
    }
  }

  void _verifyTurnCount(
    List<PersonaChatConversationRecord> records,
    int expectedCount,
  ) {
    if (records.length != expectedCount) {
      throw StateError(
        'Persisted turn contains ${records.length} messages; '
        'expected $expectedCount.',
      );
    }
  }

  void _verifyNewTurn(
    String characterId,
    String turnId,
    int firstMessageId,
    int expectedCount,
    List<PersonaChatConversationRecord> records,
  ) {
    _verifyTurnCount(records, expectedCount);
    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      if (record.characterId != characterId ||
          record.turnId != turnId ||
          record.id != firstMessageId + index) {
        throw StateError('Turn $turnId has an invalid message at $index.');
      }
    }
  }

  void _verifyContiguousRecords(
    String characterId,
    List<PersonaChatConversationRecord> records,
  ) {
    for (var index = 0; index < records.length; index++) {
      if (records[index].characterId != characterId ||
          records[index].id != index + 1) {
        throw StateError('Legacy conversation snapshot is not contiguous.');
      }
    }
  }
}
