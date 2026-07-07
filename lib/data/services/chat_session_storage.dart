import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/migration_state_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:yaml/yaml.dart';

class ChatSessionStorage {
  ChatSessionStorage._();

  static final ChatSessionStorage instance = ChatSessionStorage._();

  static const int storageSchemaVersion = 1;
  static const String metadataFileName = 'metadata.json';
  static const String messagesFileName = 'messages.jsonl';
  static const String legacyArchiveDirName = '_legacy_yaml';
  static const String storageSchemaVersionKey = 'storage_schema_version';
  static const String storageMigrationKey = 'chat_sessions_jsonl_v1';

  final _logger = getLogger('ChatSessionStorage');
  final Map<String, Future<void>> _migrationFutures = {};
  final Map<String, Lock> _sessionLocks = {};
  final Lock _lockMapLock = Lock();

  FileSystemService get _fileService => FileSystemService.instance;

  Future<void> ensureMigrated(String userId) {
    final rootPath = _sessionsPath(userId);
    final migrationFutureKey = '$userId:$rootPath';
    return _migrationFutures.putIfAbsent(
      migrationFutureKey,
      () async {
        var migrationStateSatisfied = false;
        try {
          migrationStateSatisfied =
              await MigrationStateService.instance.runOnce(
            userId: userId,
            key: storageMigrationKey,
            migrate: () => _migrateLegacyYamlSessions(userId),
          );
        } finally {
          if (!migrationStateSatisfied) {
            _migrationFutures.remove(migrationFutureKey);
          }
        }
      },
    );
  }

  Future<bool> sessionExists(String userId, String sessionId) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    return _metadataFile(userId, sessionId).exists();
  }

  Future<List<Map<String, dynamic>>> listSessionMetadata(String userId) async {
    await ensureMigrated(userId);
    final root = Directory(_sessionsPath(userId));
    if (!await root.exists()) return const [];

    final result = <Map<String, dynamic>>[];
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('_')) continue;
      if (!_isSafeSessionId(name)) continue;
      final metadataFile = File(p.join(entity.path, metadataFileName));
      if (!await metadataFile.exists()) continue;
      try {
        final metadata = await _readMetadataFile(metadataFile);
        final sessionId = _stringOrNull(metadata['session_id']) ?? name;
        if (sessionId != name) {
          metadata['session_id'] = name;
        }
        metadata['last_message_preview'] ??=
            await lastMessagePreview(userId, name);
        result.add(metadata);
      } catch (e, st) {
        _logger.warning(
          'Failed to load chat session metadata: ${metadataFile.path}',
          e,
          st,
        );
      }
    }

    result.sort((a, b) {
      final bTime = _sortTime(b);
      final aTime = _sortTime(a);
      return bTime.compareTo(aTime);
    });
    return result;
  }

  Future<Map<String, dynamic>> loadMetadata(
    String userId,
    String sessionId,
  ) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final file = _metadataFile(userId, sessionId);
    if (!await file.exists()) {
      throw StateError('Session not found: $sessionId');
    }
    return _readMetadataFile(file);
  }

  Future<List<Map<String, dynamic>>> loadMessages(
    String userId,
    String sessionId,
  ) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    return _readMessagesFile(_messagesFile(userId, sessionId));
  }

  Future<ChatSessionMessagePage> loadMessagePage(
    String userId,
    String sessionId, {
    int? limit,
    String? beforeCursor,
  }) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final messagesFile = _messagesFile(userId, sessionId);

    if (limit == null || limit <= 0) {
      final messages = await _readMessagesFile(messagesFile);
      return ChatSessionMessagePage(
        messages: messages,
        olderCursor: null,
        limit: limit,
        beforeCursor: beforeCursor,
      );
    }

    final linePage = await _readMessageTurnGroupsBefore(
      messagesFile,
      limit: limit,
      beforeCursor: beforeCursor,
    );
    final messages = <Map<String, dynamic>>[];
    for (final line in linePage.lines) {
      try {
        final decoded = jsonDecode(line.text);
        if (decoded is Map) {
          messages.add(Map<String, dynamic>.from(decoded));
        }
      } catch (e) {
        _logger.warning('Failed to parse chat message JSONL page line: $e');
      }
    }

    return ChatSessionMessagePage(
      messages: messages,
      olderCursor: linePage.olderCursor,
      limit: limit,
      beforeCursor: beforeCursor,
    );
  }

  Future<Map<String, dynamic>> loadSessionData(
    String userId,
    String sessionId,
  ) async {
    final metadata = await loadMetadata(userId, sessionId);
    final messages = await loadMessages(userId, sessionId);
    return {
      ...metadata,
      'messages': messages,
    };
  }

  Future<void> createSession({
    required String userId,
    required String sessionId,
    required Map<String, dynamic> metadata,
    List<Map<String, dynamic>> messages = const [],
    bool overwrite = false,
  }) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final lock = await _lockFor(userId, sessionId);
    await lock.synchronized(() async {
      final dir = _sessionDir(userId, sessionId);
      final metadataFile = _metadataFile(userId, sessionId);
      if (!overwrite && await metadataFile.exists()) {
        throw StateError('Session already exists: $sessionId');
      }

      await dir.create(recursive: true);
      final normalizedMessages = messages.map(_normalizeMessage).toList();
      await _writeMessagesFile(
        _messagesFile(userId, sessionId),
        normalizedMessages,
      );
      final nextMetadata = _normalizeMetadataForWrite(
        metadata,
        sessionId: sessionId,
        messages: normalizedMessages,
      );
      await _writeJsonFile(metadataFile, nextMetadata);
    });
  }

  Future<Map<String, dynamic>> updateMetadata(
    String userId,
    String sessionId,
    Map<String, dynamic> Function(Map<String, dynamic> metadata) update,
  ) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final lock = await _lockFor(userId, sessionId);
    return lock.synchronized(() async {
      final metadataFile = _metadataFile(userId, sessionId);
      if (!await metadataFile.exists()) {
        throw StateError('Session not found: $sessionId');
      }
      final current = await _readMetadataFile(metadataFile);
      final next = _normalizeMetadataForWrite(
        update(Map<String, dynamic>.from(current)),
        sessionId: sessionId,
      );
      await _writeJsonFile(metadataFile, next);
      return next;
    });
  }

  Future<Map<String, dynamic>?> appendMessage({
    required String userId,
    required String sessionId,
    required Map<String, dynamic> message,
    Map<String, dynamic>? usage,
    bool? isQuickQuery,
  }) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final lock = await _lockFor(userId, sessionId);
    return lock.synchronized(() async {
      final metadataFile = _metadataFile(userId, sessionId);
      if (!await metadataFile.exists()) return null;

      final normalizedMessage = _normalizeMessage(message);
      final messagesFile = _messagesFile(userId, sessionId);
      await messagesFile.parent.create(recursive: true);
      await messagesFile.writeAsString(
        '${jsonEncode(normalizedMessage)}\n',
        mode: FileMode.append,
        encoding: utf8,
        flush: true,
      );

      final metadata = await _readMetadataFile(metadataFile);
      metadata['last_message_preview'] = previewForMessage(normalizedMessage);
      metadata['last_message_role'] = normalizedMessage['role'];
      metadata['last_message_at'] = normalizedMessage['timestamp'];

      if (usage != null) {
        final currentTotal = metadata['total_usage'] as Map<String, dynamic>? ??
            {
              'prompt_tokens': 0,
              'completion_tokens': 0,
              'cached_tokens': 0,
              'total_tokens': 0,
              'total_cost': 0.0,
            };
        metadata['total_usage'] = {
          'prompt_tokens': _intValue(currentTotal['prompt_tokens']) +
              _intValue(usage['prompt_tokens']),
          'completion_tokens': _intValue(currentTotal['completion_tokens']) +
              _intValue(usage['completion_tokens']),
          'cached_tokens': _intValue(currentTotal['cached_tokens']) +
              _intValue(usage['cached_tokens']),
          'total_tokens': _intValue(currentTotal['total_tokens']) +
              _intValue(usage['total_tokens']),
          'total_cost': _doubleValue(currentTotal['total_cost']) +
              _doubleValue(usage['total_cost']),
        };
      }

      if (isQuickQuery != null) {
        metadata['is_quick_query'] = isQuickQuery;
      }

      final updatedAt = DateTime.now();
      metadata['updated_at'] = updatedAt.toIso8601String();
      metadata['updated_at_local'] = formatLocalDateTimeWithZone(updatedAt);
      metadata['updated_at_unix_seconds'] = unixSecondsFromDateTime(updatedAt);

      final nextMetadata = _normalizeMetadataForWrite(
        metadata,
        sessionId: sessionId,
      );
      await _writeJsonFile(metadataFile, nextMetadata);
      return nextMetadata['total_usage'] as Map<String, dynamic>?;
    });
  }

  Future<bool> hasAssistantMessageForTurn(
    String userId,
    String sessionId,
    String turnId,
  ) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    const batchSize = 100;
    final file = _messagesFile(userId, sessionId);
    String? cursor;

    while (true) {
      final page = await _readMessageTurnGroupsBefore(
        file,
        limit: batchSize,
        beforeCursor: cursor,
      );
      final lines = page.lines;
      if (lines.isEmpty) return false;
      for (final line in lines.reversed) {
        try {
          final decoded = jsonDecode(line.text);
          if (decoded is Map &&
              decoded['role'] == 'ai' &&
              decoded['turn_id'] == turnId) {
            return true;
          }
        } catch (_) {
          continue;
        }
      }
      if (!page.hasMore) return false;
      cursor = page.olderCursor;
    }
  }

  Future<String?> lastMessagePreview(String userId, String sessionId) async {
    _validateSessionId(sessionId);
    final messagesFile = _messagesFile(userId, sessionId);
    final page = await _readMessageTurnGroupsBefore(messagesFile, limit: 1);
    if (page.lines.isEmpty) return null;
    try {
      final decoded = jsonDecode(page.lines.last.text);
      if (decoded is Map) {
        return previewForMessage(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> deleteSession(String userId, String sessionId) async {
    await ensureMigrated(userId);
    _validateSessionId(sessionId);
    final dir = _sessionDir(userId, sessionId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  String sessionDirectoryPath(String userId, String sessionId) {
    _validateSessionId(sessionId);
    return _sessionDir(userId, sessionId).path;
  }

  String metadataPath(String userId, String sessionId) {
    _validateSessionId(sessionId);
    return _metadataFile(userId, sessionId).path;
  }

  String messagesPath(String userId, String sessionId) {
    _validateSessionId(sessionId);
    return _messagesFile(userId, sessionId).path;
  }

  String legacyYamlPath(String userId, String sessionId) {
    _validateSessionId(sessionId);
    return p.join(_sessionsPath(userId), '$sessionId.yaml');
  }

  static String? previewForMessage(Map<String, dynamic> message) {
    final contentList = message['content'] as List<dynamic>? ?? [];
    final textParts = <String>[];
    var imageCount = 0;
    for (final item in contentList) {
      if (item is Map<String, dynamic> &&
          item['type'] == 'text' &&
          item['text'] != null) {
        textParts.add(item['text'] as String);
      } else if (item is Map<String, dynamic> && item['type'] == 'image_url') {
        imageCount += 1;
      }
    }
    if (textParts.isNotEmpty) {
      final preview = textParts.join(' ');
      return preview.length > 100 ? preview.substring(0, 100) : preview;
    }
    if (imageCount > 0) {
      return 'Sent $imageCount image(s)';
    }
    return null;
  }

  Future<bool> _migrateLegacyYamlSessions(String userId) async {
    final root = Directory(_sessionsPath(userId));
    if (!await root.exists()) {
      await root.create(recursive: true);
      return true;
    }

    var hadFailures = false;
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.yaml')) continue;
      try {
        await _migrateLegacyYamlSessionFile(userId, entity);
      } catch (e, st) {
        hadFailures = true;
        _logger.warning(
          'Failed to migrate legacy chat session YAML: ${entity.path}',
          e,
          st,
        );
      }
    }

    final removedLegacyCounts = await _removeLegacyMessageCounts(userId, root);
    return !hadFailures && removedLegacyCounts;
  }

  Future<bool> _removeLegacyMessageCounts(String userId, Directory root) async {
    var succeeded = true;
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final sessionId = p.basename(entity.path);
      if (sessionId.startsWith('_') || !_isSafeSessionId(sessionId)) continue;
      final metadataFile = File(p.join(entity.path, metadataFileName));
      if (!await metadataFile.exists()) continue;
      try {
        final metadata = await _readMetadataFile(metadataFile);
        if (!metadata.containsKey('message_count')) continue;
        metadata.remove('message_count');
        await _writeJsonFile(
          metadataFile,
          _normalizeMetadataForWrite(metadata, sessionId: sessionId),
        );
      } catch (e, st) {
        succeeded = false;
        _logger.warning(
          'Failed to remove legacy chat message count for $userId/$sessionId',
          e,
          st,
        );
      }
    }
    return succeeded;
  }

  Future<void> _migrateLegacyYamlSessionFile(
    String userId,
    File legacyFile,
  ) async {
    final rawContent = await legacyFile.readAsString();
    final doc = loadYaml(rawContent);
    final decoded = jsonDecode(jsonEncode(doc));
    if (decoded is! Map) {
      throw const FormatException('Legacy chat session YAML is not a map');
    }

    final sessionData = Map<String, dynamic>.from(decoded);
    final fileSessionId = p.basenameWithoutExtension(legacyFile.path);
    final rawSessionId = _stringOrNull(sessionData['session_id']);
    final sessionId =
        _isSafeSessionId(rawSessionId) ? rawSessionId! : fileSessionId;
    _validateSessionId(sessionId);
    sessionData['session_id'] = sessionId;
    ChatArtifactSessionMigration.migrateSessionData(sessionData);
    _backfillSessionTimeContext(sessionData);

    final rawMessages = sessionData['messages'];
    final messages = <Map<String, dynamic>>[];
    if (rawMessages is List) {
      for (final raw in rawMessages) {
        if (raw is Map) {
          messages.add(_normalizeMessage(Map<String, dynamic>.from(raw)));
        }
      }
    }

    final metadata = Map<String, dynamic>.from(sessionData)..remove('messages');
    final dir = _sessionDir(userId, sessionId);
    final metadataFile = _metadataFile(userId, sessionId);
    if (!await metadataFile.exists()) {
      await dir.create(recursive: true);
      await _writeMessagesFile(_messagesFile(userId, sessionId), messages);
      await _writeJsonFile(
        metadataFile,
        _normalizeMetadataForWrite(
          metadata,
          sessionId: sessionId,
          messages: messages,
        ),
      );
    }

    await _archiveLegacyYaml(userId, legacyFile);
  }

  Future<void> _archiveLegacyYaml(String userId, File legacyFile) async {
    final archiveDir =
        Directory(p.join(_sessionsPath(userId), legacyArchiveDirName));
    await archiveDir.create(recursive: true);
    var target = File(p.join(archiveDir.path, p.basename(legacyFile.path)));
    if (await target.exists()) {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      target = File(p.join(
        archiveDir.path,
        '${p.basenameWithoutExtension(legacyFile.path)}.$stamp.yaml',
      ));
    }
    try {
      await legacyFile.rename(target.path);
    } catch (_) {
      await legacyFile.copy(target.path);
      await legacyFile.delete();
    }
  }

  Future<List<Map<String, dynamic>>> _readMessagesFile(File file) async {
    if (!await file.exists()) return const [];
    final messages = <Map<String, dynamic>>[];
    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map) {
          messages.add(Map<String, dynamic>.from(decoded));
        }
      } catch (e) {
        _logger.warning('Failed to parse chat message JSONL line: $e');
      }
    }
    return messages;
  }

  Future<_MessageLinePage> _readMessageTurnGroupsBefore(
    File file, {
    required int limit,
    String? beforeCursor,
  }) async {
    if (limit <= 0 || !await file.exists()) {
      return const _MessageLinePage(lines: [], olderCursor: null);
    }
    final length = await file.length();
    if (length == 0) {
      return const _MessageLinePage(lines: [], olderCursor: null);
    }

    final parsedCursor = int.tryParse(beforeCursor ?? '');
    var endExclusive = parsedCursor == null
        ? length
        : math.max(0, math.min(length, parsedCursor));
    if (endExclusive <= 0) {
      return const _MessageLinePage(lines: [], olderCursor: null);
    }

    const chunkSize = 8192;
    final chunks = <List<int>>[];
    var position = endExclusive;
    var bufferStart = endExclusive;

    final raf = await file.open();
    try {
      while (position > 0) {
        final readSize = math.min(chunkSize, position);
        position -= readSize;
        bufferStart = position;
        await raf.setPosition(position);
        final chunk = await raf.read(readSize);
        chunks.insert(0, chunk);

        final lineRecords = _lineRecordsFromChunks(
          chunks,
          bufferStart: bufferStart,
        );
        if (lineRecords.isEmpty) continue;

        final page = _selectTurnGroupPage(
          lineRecords,
          limit: limit,
          bufferStartsAtFileStart: bufferStart == 0,
        );
        if (page != null) return page;
      }
    } finally {
      await raf.close();
    }

    return const _MessageLinePage(lines: [], olderCursor: null);
  }

  List<_MessageLineRecord> _lineRecordsFromChunks(
    List<List<int>> chunks, {
    required int bufferStart,
  }) {
    final bytes = chunks.expand((chunk) => chunk).toList();
    var localStart = 0;
    if (bufferStart > 0) {
      final firstNewline = bytes.indexOf(0x0A);
      if (firstNewline < 0) return const [];
      localStart = firstNewline + 1;
    }
    return _decodeLineRecords(
      bytes.sublist(localStart),
      absoluteStart: bufferStart + localStart,
    );
  }

  _MessageLinePage? _selectTurnGroupPage(
    List<_MessageLineRecord> lineRecords, {
    required int limit,
    required bool bufferStartsAtFileStart,
  }) {
    if (lineRecords.isEmpty) {
      return const _MessageLinePage(lines: [], olderCursor: null);
    }

    var groupCount = 0;
    var pageStartIndex = 0;
    String? previousGroupKey;
    for (var i = lineRecords.length - 1; i >= 0; i--) {
      final groupKey = _messageTurnGroupKey(lineRecords[i]);
      if (previousGroupKey != groupKey) {
        groupCount++;
        previousGroupKey = groupKey;
        if (groupCount > limit) {
          pageStartIndex = i + 1;
          break;
        }
      }
    }

    if (groupCount <= limit) {
      if (!bufferStartsAtFileStart) return null;
      return _MessageLinePage(lines: lineRecords, olderCursor: null);
    }

    final returned = lineRecords.sublist(pageStartIndex);
    return _MessageLinePage(
      lines: returned,
      olderCursor: returned.first.startOffset.toString(),
    );
  }

  String _messageTurnGroupKey(_MessageLineRecord record) {
    try {
      final decoded = jsonDecode(record.text);
      if (decoded is Map) {
        final turnId = _stringOrNull(decoded['turn_id']);
        if (turnId != null) return 'turn:$turnId';
      }
    } catch (_) {
      // Invalid JSONL rows are isolated so they cannot merge with neighbors.
    }
    return 'line:${record.startOffset}';
  }

  List<_MessageLineRecord> _decodeLineRecords(
    List<int> bytes, {
    required int absoluteStart,
  }) {
    final records = <_MessageLineRecord>[];
    var localLineStart = 0;
    for (var i = 0; i < bytes.length; i++) {
      if (bytes[i] != 0x0A) continue;
      _addLineRecord(
        records,
        bytes,
        localLineStart,
        i,
        absoluteStart,
      );
      localLineStart = i + 1;
    }
    if (localLineStart < bytes.length) {
      _addLineRecord(
        records,
        bytes,
        localLineStart,
        bytes.length,
        absoluteStart,
      );
    }
    return records;
  }

  void _addLineRecord(
    List<_MessageLineRecord> records,
    List<int> bytes,
    int localStart,
    int localEnd,
    int absoluteStart,
  ) {
    var end = localEnd;
    if (end > localStart && bytes[end - 1] == 0x0D) {
      end -= 1;
    }
    if (end <= localStart) return;
    final text = utf8.decode(bytes.sublist(localStart, end));
    if (text.trim().isEmpty) return;
    records.add(
      _MessageLineRecord(
        startOffset: absoluteStart + localStart,
        text: text,
      ),
    );
  }

  Future<void> _writeMessagesFile(
    File file,
    List<Map<String, dynamic>> messages,
  ) async {
    await file.parent.create(recursive: true);
    final content =
        messages.isEmpty ? '' : '${messages.map(jsonEncode).join('\n')}\n';
    await file.writeAsString(content, encoding: utf8, flush: true);
  }

  Future<Map<String, dynamic>> _readMetadataFile(File file) async {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw FormatException('Chat session metadata is not a map: ${file.path}');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _writeJsonFile(File file, Map<String, dynamic> data) async {
    await file.parent.create(recursive: true);
    final tempFile = File('${file.path}.tmp');
    const encoder = JsonEncoder.withIndent('  ');
    await tempFile.writeAsString(
      '${encoder.convert(_jsonSafe(data))}\n',
      encoding: utf8,
      flush: true,
    );
    await tempFile.rename(file.path);
  }

  Map<String, dynamic> _normalizeMetadataForWrite(
    Map<String, dynamic> metadata, {
    required String sessionId,
    List<Map<String, dynamic>>? messages,
  }) {
    final next = Map<String, dynamic>.from(metadata)
      ..remove('messages')
      ..remove('message_count')
      ..['session_id'] = sessionId
      ..[storageSchemaVersionKey] = storageSchemaVersion
      ..['messages_file'] = messagesFileName
      ..[ChatArtifactSessionMigration.schemaVersionKey] =
          ChatArtifact.schemaVersion;

    final now = DateTime.now().toIso8601String();
    next['created_at'] ??= now;
    next['updated_at'] ??= next['created_at'];
    _backfillSessionTimeContext(next);
    if (messages != null) {
      final preview =
          messages.isEmpty ? null : previewForMessage(messages.last);
      if (preview == null) {
        next.remove('last_message_preview');
      } else {
        next['last_message_preview'] = preview;
      }
      if (messages.isNotEmpty) {
        next['last_message_role'] = messages.last['role'];
        next['last_message_at'] = messages.last['timestamp'];
      }
    }
    return Map<String, dynamic>.from(_jsonSafe(next) as Map);
  }

  static Map<String, dynamic> _normalizeMessage(Map<String, dynamic> message) {
    final next = Map<String, dynamic>.from(message);
    final parsed = tryParseDateTime(next['timestamp']);
    if (parsed != null) {
      next['local_time'] ??= formatLocalDateTimeWithZone(parsed);
      next['unix_seconds'] ??= unixSecondsFromDateTime(parsed);
    }
    return Map<String, dynamic>.from(_jsonSafe(next) as Map);
  }

  static void _backfillSessionTimeContext(Map<String, dynamic> sessionData) {
    final createdAt = tryParseDateTime(sessionData['created_at']);
    if (createdAt != null) {
      sessionData['created_at_local'] ??= formatLocalDateTimeWithZone(
        createdAt,
      );
      sessionData['created_at_unix_seconds'] ??= unixSecondsFromDateTime(
        createdAt,
      );
    }

    final updatedAt = tryParseDateTime(sessionData['updated_at']);
    if (updatedAt != null) {
      sessionData['updated_at_local'] ??= formatLocalDateTimeWithZone(
        updatedAt,
      );
      sessionData['updated_at_unix_seconds'] ??= unixSecondsFromDateTime(
        updatedAt,
      );
    }
  }

  Future<Lock> _lockFor(String userId, String sessionId) async {
    final rootPath = _sessionsPath(userId);
    return _lockMapLock.synchronized(() {
      return _sessionLocks.putIfAbsent('$rootPath:$sessionId', () => Lock());
    });
  }

  int _sortTime(Map<String, dynamic> metadata) {
    final unix = metadata['updated_at_unix_seconds'];
    if (unix is num) return unix.toInt();
    final parsed = tryParseDateTime(metadata['updated_at']);
    if (parsed != null) return unixSecondsFromDateTime(parsed);
    return 0;
  }

  String _sessionsPath(String userId) =>
      _fileService.getChatSessionsPath(userId);

  Directory _sessionDir(String userId, String sessionId) {
    return Directory(p.join(_sessionsPath(userId), sessionId));
  }

  File _metadataFile(String userId, String sessionId) {
    return File(p.join(_sessionDir(userId, sessionId).path, metadataFileName));
  }

  File _messagesFile(String userId, String sessionId) {
    return File(p.join(_sessionDir(userId, sessionId).path, messagesFileName));
  }

  static dynamic _jsonSafe(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is List) return value.map(_jsonSafe).toList();
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _jsonSafe(entry.value),
      };
    }
    return value.toString();
  }

  static String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static bool _isSafeSessionId(String? sessionId) {
    if (sessionId == null || sessionId.isEmpty) return false;
    if (sessionId.contains('/') || sessionId.contains('\\')) return false;
    if (sessionId == '.' || sessionId == '..') return false;
    return true;
  }

  static void _validateSessionId(String sessionId) {
    if (!_isSafeSessionId(sessionId)) {
      throw ArgumentError.value(sessionId, 'sessionId', 'invalid session id');
    }
  }

  static int _intValue(dynamic value) {
    return value is num ? value.toInt() : 0;
  }

  static double _doubleValue(dynamic value) {
    return value is num ? value.toDouble() : 0.0;
  }
}

class ChatSessionMessagePage {
  const ChatSessionMessagePage({
    required this.messages,
    required this.olderCursor,
    required this.limit,
    required this.beforeCursor,
  });

  final List<Map<String, dynamic>> messages;
  final String? olderCursor;
  final int? limit;
  final String? beforeCursor;

  bool get hasMoreMessages => olderCursor != null;
}

class _MessageLinePage {
  const _MessageLinePage({
    required this.lines,
    required this.olderCursor,
  });

  final List<_MessageLineRecord> lines;
  final String? olderCursor;

  bool get hasMore => olderCursor != null;
}

class _MessageLineRecord {
  const _MessageLineRecord({
    required this.startOffset,
    required this.text,
  });

  final int startOffset;
  final String text;
}
