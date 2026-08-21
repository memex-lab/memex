import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/jsonl_file_store.dart';
import 'package:memex/domain/models/character_message.dart';
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

  PersonaChatConversationRecord copyWith({bool? isRead}) {
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'seq': seq,
        'character_id': characterId,
        'speaker': isFromCharacter ? 'character' : 'user',
        'content': content,
        if (factId != null) 'fact_id': factId,
        'is_read': isRead,
        'timestamp': timestamp.toIso8601String(),
        'unix_seconds': timestamp.millisecondsSinceEpoch ~/ 1000,
        'message_type': messageType,
        'origin': origin,
        if (contactEpisodeId != null) 'contact_episode_id': contactEpisodeId,
      };

  static PersonaChatConversationRecord? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final characterId = json['character_id']?.toString();
    final content = json['content']?.toString();
    final seq = json['seq'];
    if (id == null ||
        id.isEmpty ||
        characterId == null ||
        characterId.isEmpty ||
        content == null ||
        seq is! num ||
        seq.toInt() <= 0) {
      return null;
    }
    final timestampText = json['timestamp']?.toString();
    final unixSeconds = json['unix_seconds'];
    final timestamp = timestampText == null
        ? unixSeconds is num
            ? DateTime.fromMillisecondsSinceEpoch(unixSeconds.toInt() * 1000)
            : DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.tryParse(timestampText) ??
            DateTime.fromMillisecondsSinceEpoch(0);
    return PersonaChatConversationRecord(
      id: id,
      seq: seq.toInt(),
      characterId: characterId,
      isFromCharacter:
          json['speaker'] == 'character' || json['is_from_character'] == true,
      content: content,
      factId: json['fact_id']?.toString(),
      isRead: json['is_read'] == true,
      timestamp: timestamp,
      messageType: (json['message_type'] ?? json['type'])?.toString() ??
          PersonaChatMessageTypes.text,
      origin: json['origin']?.toString() ?? 'conversation',
      contactEpisodeId: json['contact_episode_id']?.toString(),
    );
  }
}

class PersonaChatConversationMetadata {
  const PersonaChatConversationMetadata({
    required this.schemaVersion,
    required this.nextSeq,
    required this.messageCount,
    required this.unreadCount,
    required this.messagesByteLength,
    required this.readThroughSeq,
    this.consumedThroughSeq,
    this.lastMessage,
    this.updatedAt,
    this.clearedAt,
  });

  factory PersonaChatConversationMetadata.initial() {
    return const PersonaChatConversationMetadata(
      schemaVersion: PersonaChatConversationStorage.schemaVersion,
      nextSeq: 1,
      messageCount: 0,
      unreadCount: 0,
      messagesByteLength: 0,
      readThroughSeq: 0,
    );
  }

  final int schemaVersion;
  final int nextSeq;
  final int messageCount;
  final int unreadCount;
  final int messagesByteLength;
  final int readThroughSeq;
  final int? consumedThroughSeq;
  final PersonaChatConversationRecord? lastMessage;
  final DateTime? updatedAt;
  final DateTime? clearedAt;

  PersonaChatConversationMetadata copyWith({
    int? nextSeq,
    int? messageCount,
    int? unreadCount,
    int? messagesByteLength,
    int? readThroughSeq,
    int? consumedThroughSeq,
    bool clearConsumedThroughSeq = false,
    PersonaChatConversationRecord? lastMessage,
    bool clearLastMessage = false,
    DateTime? updatedAt,
    DateTime? clearedAt,
    bool clearClearedAt = false,
  }) {
    return PersonaChatConversationMetadata(
      schemaVersion: schemaVersion,
      nextSeq: nextSeq ?? this.nextSeq,
      messageCount: messageCount ?? this.messageCount,
      unreadCount: unreadCount ?? this.unreadCount,
      messagesByteLength: messagesByteLength ?? this.messagesByteLength,
      readThroughSeq: readThroughSeq ?? this.readThroughSeq,
      consumedThroughSeq: clearConsumedThroughSeq
          ? null
          : consumedThroughSeq ?? this.consumedThroughSeq,
      lastMessage: clearLastMessage ? null : lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      clearedAt: clearClearedAt ? null : clearedAt ?? this.clearedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'next_message_seq': nextSeq,
        'message_count': messageCount,
        'unread_count': unreadCount,
        'messages_byte_length': messagesByteLength,
        'read_through_seq': readThroughSeq,
        if (consumedThroughSeq != null)
          'consumed_through_seq': consumedThroughSeq,
        if (lastMessage != null) 'last_message': lastMessage!.toJson(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (clearedAt != null) 'cleared_at': clearedAt!.toIso8601String(),
      };

  static PersonaChatConversationMetadata? fromJson(Map<String, dynamic> json) {
    if (json['schema_version'] !=
        PersonaChatConversationStorage.schemaVersion) {
      return null;
    }
    final lastRaw = json['last_message'];
    return PersonaChatConversationMetadata(
      schemaVersion: PersonaChatConversationStorage.schemaVersion,
      nextSeq: _positiveInt(json['next_message_seq'], fallback: 1),
      messageCount: _nonNegativeInt(json['message_count']),
      unreadCount: _nonNegativeInt(json['unread_count']),
      messagesByteLength: _nonNegativeInt(json['messages_byte_length']),
      readThroughSeq: _nonNegativeInt(json['read_through_seq']),
      consumedThroughSeq: json['consumed_through_seq'] is num
          ? (json['consumed_through_seq'] as num).toInt()
          : null,
      lastMessage: lastRaw is Map
          ? PersonaChatConversationRecord.fromJson(
              Map<String, dynamic>.from(lastRaw),
            )
          : null,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      clearedAt: DateTime.tryParse(json['cleared_at']?.toString() ?? ''),
    );
  }

  static int _nonNegativeInt(dynamic value) =>
      value is num && value >= 0 ? value.toInt() : 0;

  static int _positiveInt(dynamic value, {required int fallback}) =>
      value is num && value > 0 ? value.toInt() : fallback;
}

/// File-only persona conversation store.
///
/// `messages.jsonl` is the sole durable message history. `metadata.json` is a
/// rebuildable summary used for O(1) unread/cursor/last-message queries. An
/// episode is one JSONL envelope, so all bubbles become visible together.
class PersonaChatConversationStorage {
  PersonaChatConversationStorage({
    FileSystemService? fileSystem,
    JsonlFileStore? jsonl,
    Uuid? uuid,
  })  : _injectedFileSystem = fileSystem,
        _jsonl = jsonl ?? JsonlFileStore(loggerName: 'PersonaChatJsonl'),
        _uuid = uuid ?? const Uuid();

  static final PersonaChatConversationStorage instance =
      PersonaChatConversationStorage();

  static const int schemaVersion = 2;
  static const String storageMigrationKey = 'persona_chat_workspace_v2';
  static const String _episodeRecordType = 'episode';
  static const String _readBoundaryRecordType = 'read_boundary';
  static const String _replyCursorRecordType = 'reply_cursor';
  static final Map<String, Lock> _processLocks = {};

  final FileSystemService? _injectedFileSystem;
  final JsonlFileStore _jsonl;
  final Uuid _uuid;

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
    String? contactEpisodeId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata = await _readMetadataRepairingIfNeeded(
        userId,
        characterId,
      );
      final record = PersonaChatConversationRecord(
        id: _uuid.v4(),
        seq: metadata.nextSeq,
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
      await _appendRecords(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: [record],
        jsonRow: record.toJson(),
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
    int? consumedThroughSeq,
  }) {
    _validateEpisode(contactEpisodeId, expectedRecordCount);
    return _synchronized(userId, characterId, () async {
      var metadata = await _readMetadataRepairingIfNeeded(userId, characterId);
      final receiptFile = _episodeReceiptFile(
        userId,
        characterId,
        contactEpisodeId,
      );
      final receipt = await _readEpisodeReceipt(
        receiptFile,
        contactEpisodeId,
      );
      final persisted = await _loadEpisodeFromReceiptOrLog(
        userId: userId,
        characterId: characterId,
        episodeId: contactEpisodeId,
        receiptFile: receiptFile,
        receipt: receipt,
      );
      if (persisted != null) {
        _verifyEpisodeCount(persisted, expectedRecordCount);
        if (consumedThroughSeq != null) {
          await _advanceCursorUnlocked(
            userId,
            characterId,
            metadata,
            consumedThroughSeq,
          );
        }
        return persisted;
      }

      if (receipt == null) {
        await _writeEpisodeReceipt(
          receiptFile,
          contactEpisodeId,
        );
      }

      final toWrite = records(metadata.nextSeq);
      _verifyNewEpisode(
        characterId,
        contactEpisodeId,
        metadata.nextSeq,
        expectedRecordCount,
        toWrite,
      );
      final lineOffset = metadata.messagesByteLength;
      metadata = await _appendRecords(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: toWrite,
        jsonRow: {
          'record_type': _episodeRecordType,
          'episode_id': contactEpisodeId,
          'messages': toWrite.map((record) => record.toJson()).toList(),
        },
        consumedThroughSeq: consumedThroughSeq,
      );
      await _writeEpisodeReceipt(
        receiptFile,
        contactEpisodeId,
        lineOffset: lineOffset,
      );
      return toWrite;
    });
  }

  Future<bool> tryAppendInitiativeEpisode({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> Function(int nextSeq) records,
    required String contactEpisodeId,
    required int expectedRecordCount,
  }) {
    _validateEpisode(contactEpisodeId, expectedRecordCount);
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      final receipt = await _readEpisodeReceipt(
        _episodeReceiptFile(userId, characterId, contactEpisodeId),
        contactEpisodeId,
      );
      if (receipt != null &&
          await _loadEpisodeFromReceiptOrLog(
                userId: userId,
                characterId: characterId,
                episodeId: contactEpisodeId,
                receiptFile: _episodeReceiptFile(
                  userId,
                  characterId,
                  contactEpisodeId,
                ),
                receipt: receipt,
              ) !=
              null) {
        return true;
      }
      final pending = await _loadPendingUserMessagesUnlocked(
        userId,
        characterId,
        metadata.consumedThroughSeq ?? 0,
        limit: 1,
      );
      if (pending.isNotEmpty) return false;
      await _appendEpisodeUnlocked(
        userId: userId,
        characterId: characterId,
        metadata: metadata,
        records: records,
        contactEpisodeId: contactEpisodeId,
        expectedRecordCount: expectedRecordCount,
      );
      return true;
    });
  }

  Future<List<PersonaChatConversationRecord>> loadMessages({
    required String userId,
    required String characterId,
    int? limit,
    int offset = 0,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      if (limit == null || limit <= 0) {
        final records = await _readAllRecords(userId, characterId);
        return _applyReadState(records.reversed, metadata).toList();
      }
      final records = await _readNewestRecords(
        userId,
        characterId,
        limit + offset,
      );
      return _applyReadState(records, metadata)
          .skip(offset)
          .take(limit)
          .toList(growable: false);
    });
  }

  Future<List<PersonaChatConversationRecord>> loadMessagesBefore({
    required String userId,
    required String characterId,
    required int beforeSeq,
    int limit = 50,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      final records = await _scanBackwards(
        userId,
        characterId,
        stop: (collected, record) =>
            record.seq < beforeSeq && collected.length >= limit,
        include: (record) => record.seq < beforeSeq,
      );
      return _applyReadState(records.take(limit), metadata)
          .toList(growable: false);
    });
  }

  Future<List<PersonaChatConversationRecord>> loadPendingUserMessages({
    required String userId,
    required String characterId,
    int limit = 50,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      return _loadPendingUserMessagesUnlocked(
        userId,
        characterId,
        metadata.consumedThroughSeq ?? 0,
        limit: limit,
      );
    });
  }

  Future<int> getReplyCursor({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _readMetadataRepairingIfNeeded(userId, characterId))
              .consumedThroughSeq ??
          0;
    });
  }

  Future<PersonaChatConversationMetadata> loadMetadata({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(
      userId,
      characterId,
      () => _readMetadataRepairingIfNeeded(userId, characterId),
    );
  }

  Future<void> advanceCursor({
    required String userId,
    required String characterId,
    required int consumedThroughSeq,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      await _advanceCursorUnlocked(
        userId,
        characterId,
        metadata,
        consumedThroughSeq,
      );
    });
  }

  Future<int> unreadCount({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      return (await _readMetadataRepairingIfNeeded(userId, characterId))
          .unreadCount;
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
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      final changed = metadata.unreadCount;
      if (changed == 0) return 0;
      final readThroughSeq = metadata.nextSeq - 1;
      final append = await _jsonl.append(
        _messagesFile(userId, characterId),
        [
          {
            'record_type': _readBoundaryRecordType,
            'read_through_seq': readThroughSeq,
          },
        ],
      );
      await _writeMetadata(
        userId,
        characterId,
        metadata.copyWith(
          unreadCount: 0,
          readThroughSeq: readThroughSeq,
          messagesByteLength: append.endOffset,
          updatedAt: DateTime.now(),
        ),
      );
      return changed;
    });
  }

  Future<PersonaChatConversationRecord?> lastMessage({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      final last = metadata.lastMessage;
      return last == null ? null : _withEffectiveRead(last, metadata);
    });
  }

  Future<int> latestMessageSeq({
    required String userId,
    required String characterId,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      return metadata.nextSeq - 1;
    });
  }

  Future<int> clearConversation({
    required String userId,
    required String characterId,
    required DateTime clearedAt,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      await _replaceFile(_messagesFile(userId, characterId), '');
      final receipts = Directory(
        _fileSystem.getCharacterConversationEpisodeReceiptsPath(
          userId,
          characterId,
        ),
      );
      if (await receipts.exists()) await receipts.delete(recursive: true);
      await _writeMetadata(
        userId,
        characterId,
        PersonaChatConversationMetadata.initial().copyWith(
          clearedAt: clearedAt,
          updatedAt: clearedAt,
        ),
      );
      return metadata.messageCount;
    });
  }

  /// Imports a legacy snapshot only when the new conversation log is empty.
  Future<bool> importLegacySnapshot({
    required String userId,
    required String characterId,
    required List<PersonaChatConversationRecord> records,
    int? consumedThroughSeq,
  }) {
    return _synchronized(userId, characterId, () async {
      final metadata =
          await _readMetadataRepairingIfNeeded(userId, characterId);
      if (metadata.messageCount > 0 || records.isEmpty) return false;
      _verifyContiguousRecords(characterId, records);
      final file = _messagesFile(userId, characterId);
      final rows = <Map<String, dynamic>>[
        ...records.map((record) => record.toJson()),
        if (consumedThroughSeq != null)
          {
            'record_type': _replyCursorRecordType,
            'consumed_through_seq': consumedThroughSeq,
          },
      ];
      await _replaceFile(
        file,
        '${rows.map(jsonEncode).join('\n')}\n',
      );
      await _writeMetadata(
        userId,
        characterId,
        _metadataFromRecords(
          records,
          messagesByteLength: await file.length(),
          consumedThroughSeq: consumedThroughSeq,
        ),
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

  Future<List<PersonaChatConversationRecord>> _appendEpisodeUnlocked({
    required String userId,
    required String characterId,
    required PersonaChatConversationMetadata metadata,
    required List<PersonaChatConversationRecord> Function(int nextSeq) records,
    required String contactEpisodeId,
    required int expectedRecordCount,
  }) async {
    final receiptFile = _episodeReceiptFile(
      userId,
      characterId,
      contactEpisodeId,
    );
    final existing = await _readEpisodeReceipt(receiptFile, contactEpisodeId);
    final persisted = await _loadEpisodeFromReceiptOrLog(
      userId: userId,
      characterId: characterId,
      episodeId: contactEpisodeId,
      receiptFile: receiptFile,
      receipt: existing,
    );
    if (persisted != null) {
      _verifyEpisodeCount(persisted, expectedRecordCount);
      return persisted;
    }
    if (existing == null) {
      await _writeEpisodeReceipt(receiptFile, contactEpisodeId);
    }
    final toWrite = records(metadata.nextSeq);
    _verifyNewEpisode(
      characterId,
      contactEpisodeId,
      metadata.nextSeq,
      expectedRecordCount,
      toWrite,
    );
    final lineOffset = metadata.messagesByteLength;
    await _appendRecords(
      userId: userId,
      characterId: characterId,
      metadata: metadata,
      records: toWrite,
      jsonRow: {
        'record_type': _episodeRecordType,
        'episode_id': contactEpisodeId,
        'messages': toWrite.map((record) => record.toJson()).toList(),
      },
    );
    await _writeEpisodeReceipt(
      receiptFile,
      contactEpisodeId,
      lineOffset: lineOffset,
    );
    return toWrite;
  }

  Future<List<PersonaChatConversationRecord>?> _loadEpisodeFromReceiptOrLog({
    required String userId,
    required String characterId,
    required String episodeId,
    required File receiptFile,
    required _EpisodeReceipt? receipt,
  }) async {
    Map<String, dynamic>? row;
    var lineOffset = receipt?.lineOffset;
    if (receipt?.isComplete == true && lineOffset != null) {
      row = await _jsonl.readObjectAt(
        _messagesFile(userId, characterId),
        lineOffset,
      );
      if (!_isEpisodeRow(row, episodeId)) row = null;
    }
    if (row == null && receipt != null) {
      final located = await _jsonl.findLastObject(
        _messagesFile(userId, characterId),
        (candidate) => _isEpisodeRow(candidate, episodeId),
      );
      if (located != null) {
        row = located.value;
        lineOffset = located.startOffset;
        await _writeEpisodeReceipt(
          receiptFile,
          episodeId,
          lineOffset: lineOffset,
        );
      }
    }
    if (row == null) return null;
    final records = _recordsFromRow(row).toList(growable: false);
    return records.isEmpty ? null : records;
  }

  bool _isEpisodeRow(Map<String, dynamic>? row, String episodeId) =>
      row?['record_type'] == _episodeRecordType &&
      row?['episode_id'] == episodeId;

  Future<PersonaChatConversationMetadata> _appendRecords({
    required String userId,
    required String characterId,
    required PersonaChatConversationMetadata metadata,
    required List<PersonaChatConversationRecord> records,
    required Map<String, dynamic> jsonRow,
    int? consumedThroughSeq,
  }) async {
    final append = await _jsonl.append(
      _messagesFile(userId, characterId),
      [
        {
          ...jsonRow,
          if (consumedThroughSeq != null)
            'consumed_through_seq': consumedThroughSeq,
        },
      ],
    );
    final unreadAdded = records
        .where((record) => record.isFromCharacter && !record.isRead)
        .length;
    final next = metadata.copyWith(
      nextSeq: records.last.seq + 1,
      messageCount: metadata.messageCount + records.length,
      unreadCount: metadata.unreadCount + unreadAdded,
      messagesByteLength: append.endOffset,
      consumedThroughSeq: consumedThroughSeq,
      lastMessage: records.last,
      updatedAt: DateTime.now(),
      clearClearedAt: true,
    );
    await _writeMetadata(userId, characterId, next);
    return next;
  }

  Future<List<PersonaChatConversationRecord>> _readAllRecords(
    String userId,
    String characterId,
  ) async {
    return (await _readSnapshot(userId, characterId)).records;
  }

  Future<List<PersonaChatConversationRecord>> _readNewestRecords(
    String userId,
    String characterId,
    int count,
  ) async {
    if (count <= 0) return const [];
    return _scanBackwards(
      userId,
      characterId,
      include: (_) => true,
      stop: (collected, _) => collected.length >= count,
    );
  }

  Future<_ConversationSnapshot> _readSnapshot(
    String userId,
    String characterId,
  ) async {
    final rows = await _jsonl.readAllRecoveringTail(
      _messagesFile(userId, characterId),
    );
    final records = <PersonaChatConversationRecord>[];
    var readThroughSeq = 0;
    int? consumedThroughSeq;
    for (final row in rows) {
      records.addAll(_recordsFromRow(row));
      final rowReadThrough = row['read_through_seq'];
      if (rowReadThrough is num && rowReadThrough > readThroughSeq) {
        readThroughSeq = rowReadThrough.toInt();
      }
      final rowConsumedThrough = row['consumed_through_seq'];
      if (rowConsumedThrough is num &&
          rowConsumedThrough > (consumedThroughSeq ?? 0)) {
        consumedThroughSeq = rowConsumedThrough.toInt();
      }
    }
    return _ConversationSnapshot(
      records: records,
      readThroughSeq: readThroughSeq,
      consumedThroughSeq: consumedThroughSeq,
    );
  }

  Future<List<PersonaChatConversationRecord>> _scanBackwards(
    String userId,
    String characterId, {
    required bool Function(
      List<PersonaChatConversationRecord> collected,
      PersonaChatConversationRecord record,
    ) stop,
    required bool Function(PersonaChatConversationRecord record) include,
  }) async {
    const pageSize = 64;
    int? cursor;
    final collected = <PersonaChatConversationRecord>[];
    while (true) {
      final page = await _jsonl.readPageBefore(
        _messagesFile(userId, characterId),
        limit: pageSize,
        beforeOffset: cursor,
      );
      if (page.rows.isEmpty) return collected;
      final records =
          page.rows.expand(_recordsFromRow).toList(growable: false).reversed;
      for (final record in records) {
        if (include(record)) collected.add(record);
        if (stop(collected, record)) return collected;
      }
      cursor = page.olderOffset;
      if (cursor == null) return collected;
    }
  }

  Future<List<PersonaChatConversationRecord>> _loadPendingUserMessagesUnlocked(
    String userId,
    String characterId,
    int cursorSeq, {
    required int limit,
  }) async {
    final newestFirst = await _scanBackwards(
      userId,
      characterId,
      include: (record) => record.seq > cursorSeq && !record.isFromCharacter,
      stop: (_, record) => record.seq <= cursorSeq,
    );
    return newestFirst.reversed.take(limit).toList(growable: false);
  }

  Iterable<PersonaChatConversationRecord> _recordsFromRow(
    Map<String, dynamic> row,
  ) sync* {
    if (row['record_type'] == _episodeRecordType) {
      final messages = row['messages'];
      if (messages is! List) return;
      for (final raw in messages) {
        if (raw is! Map) continue;
        final record = PersonaChatConversationRecord.fromJson(
          Map<String, dynamic>.from(raw),
        );
        if (record != null) yield record;
      }
      return;
    }
    final record = PersonaChatConversationRecord.fromJson(row);
    if (record != null) yield record;
  }

  Future<PersonaChatConversationMetadata> _readMetadataRepairingIfNeeded(
    String userId,
    String characterId,
  ) async {
    await _ensureLayout(userId, characterId);
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
    final snapshot = await _readSnapshot(userId, characterId);
    final repaired = _metadataFromRecords(
      snapshot.records,
      messagesByteLength: await _messagesFile(userId, characterId).length(),
      readThroughSeq: snapshot.readThroughSeq,
      consumedThroughSeq: snapshot.consumedThroughSeq,
      clearedAt: metadata?.clearedAt,
    );
    await _writeMetadata(userId, characterId, repaired);
    return repaired;
  }

  PersonaChatConversationMetadata _metadataFromRecords(
    List<PersonaChatConversationRecord> records, {
    required int messagesByteLength,
    int readThroughSeq = 0,
    int? consumedThroughSeq,
    DateTime? clearedAt,
  }) {
    final unread = records
        .where(
          (record) =>
              record.isFromCharacter &&
              !record.isRead &&
              record.seq > readThroughSeq,
        )
        .length;
    return PersonaChatConversationMetadata(
      schemaVersion: schemaVersion,
      nextSeq: records.isEmpty ? 1 : records.last.seq + 1,
      messageCount: records.length,
      unreadCount: unread,
      messagesByteLength: messagesByteLength,
      readThroughSeq: readThroughSeq,
      consumedThroughSeq: consumedThroughSeq,
      lastMessage: records.isEmpty ? null : records.last,
      updatedAt: DateTime.now(),
      clearedAt: records.isEmpty ? clearedAt : null,
    );
  }

  Future<PersonaChatConversationMetadata> _advanceCursorUnlocked(
    String userId,
    String characterId,
    PersonaChatConversationMetadata metadata,
    int nextSeq,
  ) async {
    if (nextSeq <= 0 || nextSeq >= metadata.nextSeq) {
      throw ArgumentError.value(nextSeq, 'consumedThroughSeq');
    }
    if ((metadata.consumedThroughSeq ?? 0) >= nextSeq) return metadata;
    final append = await _jsonl.append(
      _messagesFile(userId, characterId),
      [
        {
          'record_type': _replyCursorRecordType,
          'consumed_through_seq': nextSeq,
        },
      ],
    );
    final next = metadata.copyWith(
      consumedThroughSeq: nextSeq,
      messagesByteLength: append.endOffset,
      updatedAt: DateTime.now(),
    );
    await _writeMetadata(userId, characterId, next);
    return next;
  }

  Iterable<PersonaChatConversationRecord> _applyReadState(
    Iterable<PersonaChatConversationRecord> records,
    PersonaChatConversationMetadata metadata,
  ) =>
      records.map((record) => _withEffectiveRead(record, metadata));

  PersonaChatConversationRecord _withEffectiveRead(
    PersonaChatConversationRecord record,
    PersonaChatConversationMetadata metadata,
  ) {
    if (!record.isFromCharacter ||
        record.isRead ||
        record.seq > metadata.readThroughSeq) {
      return record;
    }
    return record.copyWith(isRead: true);
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
      final lockFile = File(lockPath);
      final handle = await lockFile.open(mode: FileMode.append);
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

  File _episodeReceiptFile(
    String userId,
    String characterId,
    String episodeId,
  ) {
    final name = sha256.convert(utf8.encode(episodeId)).toString();
    return File(
      _fileSystem.getCharacterConversationEpisodeReceiptPath(
        userId,
        characterId,
        name,
      ),
    );
  }

  Future<_EpisodeReceipt?> _readEpisodeReceipt(
    File file,
    String expectedEpisodeId,
  ) async {
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map || decoded['episode_id'] != expectedEpisodeId) {
        throw const FormatException('Episode receipt identity mismatch');
      }
      return _EpisodeReceipt(
        isComplete: decoded['status'] == 'complete',
        lineOffset: decoded['line_offset'] is num
            ? (decoded['line_offset'] as num).toInt()
            : null,
      );
    } catch (_) {
      return const _EpisodeReceipt(isComplete: false);
    }
  }

  Future<void> _writeEpisodeReceipt(File file, String episodeId,
      {int? lineOffset}) {
    return _writeJsonFile(file, {
      'episode_id': episodeId,
      'status': lineOffset == null ? 'pending' : 'complete',
      if (lineOffset != null) 'line_offset': lineOffset,
    });
  }

  Future<void> _writeMetadata(
    String userId,
    String characterId,
    PersonaChatConversationMetadata metadata,
  ) {
    return _writeJsonFile(
        _metadataFile(userId, characterId), metadata.toJson());
  }

  Future<void> _writeJsonFile(File file, Map<String, dynamic> value) {
    const encoder = JsonEncoder.withIndent('  ');
    return _replaceFile(file, '${encoder.convert(value)}\n');
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

  void _validateEpisode(String episodeId, int expectedCount) {
    if (episodeId.trim().isEmpty) {
      throw ArgumentError.value(episodeId, 'contactEpisodeId');
    }
    if (expectedCount <= 0) {
      throw ArgumentError.value(expectedCount, 'expectedRecordCount');
    }
  }

  void _verifyEpisodeCount(
    List<PersonaChatConversationRecord> records,
    int expectedCount,
  ) {
    if (records.length != expectedCount) {
      throw StateError(
        'Persisted episode contains ${records.length} messages; '
        'expected $expectedCount.',
      );
    }
  }

  void _verifyNewEpisode(
    String characterId,
    String episodeId,
    int nextSeq,
    int expectedCount,
    List<PersonaChatConversationRecord> records,
  ) {
    _verifyEpisodeCount(records, expectedCount);
    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      if (record.characterId != characterId ||
          record.contactEpisodeId != episodeId ||
          record.seq != nextSeq + index) {
        throw StateError(
            'Episode $episodeId has an invalid message at $index.');
      }
    }
  }

  void _verifyContiguousRecords(
    String characterId,
    List<PersonaChatConversationRecord> records,
  ) {
    for (var index = 0; index < records.length; index++) {
      if (records[index].characterId != characterId ||
          records[index].seq != index + 1) {
        throw StateError('Legacy conversation snapshot is not contiguous.');
      }
    }
  }
}

class _EpisodeReceipt {
  const _EpisodeReceipt({required this.isComplete, this.lineOffset});

  final bool isComplete;
  final int? lineOffset;
}

class _ConversationSnapshot {
  const _ConversationSnapshot({
    required this.records,
    required this.readThroughSeq,
    this.consumedThroughSeq,
  });

  final List<PersonaChatConversationRecord> records;
  final int readThroughSeq;
  final int? consumedThroughSeq;
}
