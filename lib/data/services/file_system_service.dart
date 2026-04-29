import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:synchronized/synchronized.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart'; // For decodeImageFromList
import 'package:memex/utils/logger.dart';
import 'base_file_service.dart';
import 'api_exception.dart';
import 'local_asset_server.dart';
import 'event_log_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:drift/drift.dart' as drift;

/// Result of [FileSystemService.syncSkillsIfNeeded].
class SkillSyncResult {
  /// The path to use as skillDirectoryPath for the agent.
  final String effectivePath;

  /// The original skill directory path (source of truth).
  final String originalPath;

  /// Whether a sync was performed (skill was outside workingDirectory).
  /// When true, [syncSkillsBack] should be called after agent execution.
  final bool didSync;

  const SkillSyncResult({
    required this.effectivePath,
    required this.originalPath,
    required this.didSync,
  });
}

/// File system manager. Maps to backend FileSystemManager; manages user workspace dirs and file ops.
class FileSystemService {
  final BaseFileService _baseService = BaseFileService();
  final Logger _logger = getLogger('FileSystemService');

  /// Data root directory path
  final String dataRoot;

  /// Event log service for tracking workspace changes
  late final EventLogService eventLogService;

  /// Card file lock map: serializes concurrent writes per card. Key: "${userId}:${cardId}"
  final Map<String, Lock> _cardLocks = {};

  /// Lock protecting _cardLocks map access
  final Lock _cardLocksMapLock = Lock();

  /// Flag to indicate if a rebuild is in progress to prevent recursion
  bool _isRebuilding = false;

  static DateTime? _lastServerCheckTime;
  static FileSystemService? _instance;

  static FileSystemService get instance {
    if (_instance == null) {
      throw StateError('FileSystemService not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initialize filesystem service with data root.
  /// Re-calls are allowed to switch workspace root immediately.
  static Future<void> init(String dataRoot) async {
    if (_instance?.dataRoot == dataRoot) {
      // Ensure server knows latest root even if instance is unchanged.
      await LocalAssetServer.startServer(dataRoot: dataRoot, preferredPort: 0);
      return;
    }

    _instance = FileSystemService._(dataRoot: dataRoot);
    await LocalAssetServer.startServer(dataRoot: dataRoot, preferredPort: 0);
    getLogger('FileSystemService')
        .info('FileSystemService switched to new data root: $dataRoot');
  }

  FileSystemService._({required this.dataRoot}) {
    if (!path.isAbsolute(dataRoot)) {
      throw ArgumentError('dataRoot must be an absolute path: $dataRoot');
    }
    eventLogService = EventLogService(dataRoot: dataRoot);
  }

  /// Convert absolute path to relative to dataRoot.
  /// Returns original path if not under dataRoot.
  String toRelativePath(String absolutePath, {String? rootPath}) {
    if (!path.isAbsolute(absolutePath)) {
      return absolutePath;
    }
    try {
      final normalizedDataRoot = path.normalize(rootPath ?? dataRoot);
      final normalizedAbsolutePath = path.normalize(absolutePath);
      if (normalizedAbsolutePath.startsWith(normalizedDataRoot)) {
        final relative =
            path.relative(normalizedAbsolutePath, from: normalizedDataRoot);
        return relative;
      }
    } catch (e) {
      _logger.warning(
          'Failed to convert absolute path to relative: $absolutePath, error: $e');
    }
    return absolutePath;
  }

  /// Convert relative path (to dataRoot) to absolute path.
  String toAbsolutePath(String relativePath) {
    if (path.isAbsolute(relativePath)) {
      return relativePath;
    }
    return path.join(dataRoot, relativePath);
  }

  /// Get userworkspacepath
  ///
  /// Args:
  ///   userId: userID
  ///
  /// Returns:
  ///   workspacepath（absolute path）
  String getWorkspacePath(String userId) {
    final workspaceName = '_$userId';
    return path.join(dataRoot, 'workspace', workspaceName);
  }

  /// List all user IDs
  Future<List<String>> listAllUsers() async {
    final workspaceRoot = path.join(dataRoot, 'workspace');

    if (!await _baseService.exists(workspaceRoot)) {
      return [];
    }

    if (!await _baseService.isDirectory(workspaceRoot)) {
      return [];
    }

    final users = <String>[];
    try {
      final items = await _baseService.listDirectory(workspaceRoot);
      for (final item in items) {
        final itemPath = path.join(workspaceRoot, item);
        if (await _baseService.isDirectory(itemPath)) {
          final name = path.basename(item);
          if (name.startsWith('_')) {
            // _user_id -> user_id
            users.add(name.substring(1));
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to list users: $e');
    }

    return users;
  }

  /// GetFactsdirectory path
  ///
  /// Args:
  ///   userId: userID
  ///
  /// Returns:
  ///   Factsdirectory path（absolute path）
  String getFactsPath(String userId) {
    return path.join(getWorkspacePath(userId), 'Facts');
  }

  /// Getassetsdirectory path
  ///
  /// Args:
  ///   userId: userID
  ///
  /// Returns:
  ///   assetsdirectory path（absolute path）
  ///   assetsdirectory path（absolute path）
  String getAssetsPath(String userId) {
    return path.join(getFactsPath(userId), 'assets');
  }

  /// GetCardsdirectory path
  ///
  /// Args:
  ///   userId: userID
  ///
  /// Returns:
  ///   Cardsdirectory path（absolute path）
  String getCardsPath(String userId) {
    return path.join(getWorkspacePath(userId), 'Cards');
  }

  /// Path for storing user processed hashes
  String getProcessedHashesPath(String userId) {
    return path.join(getSystemPath(userId), 'processed_hashes.txt');
  }

  /// GetCardfile path
  ///
  /// Args:
  ///   userId: userID
  ///   factId: fact ID (format: 2025/11/23.md#ts_1)
  ///
  /// Returns:
  ///   Cardfile path（absolute path）
  ///
  /// Throws:
  ///   ArgumentError: IffactIdformatinvalid
  String getCardPath(String userId, String factId) {
    // Extract date and ts_xxx from fact_id (format: 2025/11/23.md#ts_1)
    final match =
        RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_(\d+)$').firstMatch(factId);
    if (match == null) {
      throw ArgumentError(
          'Invalid fact_id format: $factId, expected format: YYYY/MM/DD.md#ts_N');
    }

    final year = match.group(1)!;
    final month = match.group(2)!;
    final day = match.group(3)!;
    final tsPart = 'ts_${match.group(4)!}';

    final cardsPath = getCardsPath(userId);
    return path.join(cardsPath, year, month, '${day}_$tsPart.yaml');
  }

  /// All card file paths in given date range (start/end inclusive).
  Future<List<String>> getCardFilesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cardsPath = getCardsPath(userId);

    if (!await _baseService.exists(cardsPath)) {
      return [];
    }

    final cardFiles = <String>[];

    // Iterate each day
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final year = currentDate.year.toString();
      final month = currentDate.month.toString().padLeft(2, '0');
      final day = currentDate.day.toString().padLeft(2, '0');

      // Month dir: Cards/YYYY/MM
      final monthDir = path.join(cardsPath, year, month);

      if (await _baseService.exists(monthDir) &&
          await _baseService.isDirectory(monthDir)) {
        // Day's cards: DD_ts_*.yaml
        try {
          final items = await _baseService.listDirectory(monthDir);
          for (final item in items) {
            final itemPath = path.join(monthDir, item);
            if (await _baseService.isFile(itemPath)) {
              final name = path.basename(item);
              if (name.startsWith('${day}_ts_') && name.endsWith('.yaml')) {
                cardFiles.add(itemPath);
              }
            }
          }
        } catch (e) {
          _logger.warning('Failed to read directory $monthDir: $e');
        }
      }

      // Next day
      currentDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day)
              .add(const Duration(days: 1));
    }

    return cardFiles;
  }

  /// Get or create lock for card file. Lock protects map access for thread safety.
  Future<Lock> _getCardLock(String userId, String cardId) async {
    final lockKey = '$userId:$cardId';
    return _cardLocksMapLock.synchronized(() {
      return _cardLocks.putIfAbsent(lockKey, () => Lock());
    });
  }

  /// Safely update card file (locked read-modify-write). Serializes concurrent updates per card.
  /// [updateFn] receives current card data, returns updated data. Returns null if card not found.
  Future<CardData?> updateCardFile(
      String userId, String cardId, CardData Function(CardData) updateFn,
      {bool createIfNotExists = false}) async {
    final lock = await _getCardLock(userId, cardId);

    return lock.synchronized(() async {
      var currentData = await readCardFile(userId, cardId);
      if (currentData == null) {
        if (createIfNotExists) {
          currentData = CardData(
            factId: cardId,
            timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            status: 'processing',
            tags: const [],
            uiConfigs: const [],
          );
        } else {
          _logger.warning('Card not found for update: $cardId');
          return null;
        }
      }

      final updatedData = updateFn(currentData);
      final success =
          await _safeWriteCardFileInternal(userId, cardId, updatedData);
      if (success) {
        return updatedData;
      } else {
        throw Exception('Failed to write card file: $cardId');
      }
    });
  }

  /// Safely write card file (atomic write with lock). For read-modify-write use updateCardFile.
  Future<bool> safeWriteCardFile(
      String userId, String cardId, CardData data) async {
    final lock = await _getCardLock(userId, cardId);

    return lock.synchronized(() async {
      return await _safeWriteCardFileInternal(userId, cardId, data);
    });
  }

  /// Internal write (no lock; caller must hold lock)
  Future<bool> _safeWriteCardFileInternal(
      String userId, String cardId, CardData data) async {
    try {
      final cardPath = getCardPath(userId, cardId);
      final parentDir = path.dirname(cardPath);

      if (!await _baseService.exists(parentDir)) {
        await Directory(parentDir).create(recursive: true);
      }

      final tempDir = Directory(parentDir);
      final tempFile =
          File(path.join(tempDir.path, '${path.basename(cardPath)}.tmp'));

      final yamlContent = _mapToYaml(data.toJson());
      await tempFile.writeAsString(yamlContent, encoding: utf8);
      await tempFile.rename(cardPath);

      updateCardCache(userId, cardId, data);

      return true;
    } catch (e) {
      _logger.severe('Failed to write card file $cardId: $e');
      try {
        final cardPath = getCardPath(userId, cardId);
        final tempFile = File('$cardPath.tmp');
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      return false;
    }
  }

  /// Update the card cache in the local database
  Future<void> updateCardCache(
      String userId, String factId, CardData cardData) async {
    try {
      if (!_isRebuilding && await AppDatabase.instance.cardDao.isCacheEmpty()) {
        _logger.info('Card cache is empty, triggering rebuild...');
        await rebuildCardCache(userId);
      }

      int timestamp;
      final factInfo = await extractFactContentFromFile(userId, factId);
      if (factInfo != null) {
        timestamp = factInfo.timestamp;
      } else {
        timestamp = cardData.timestamp;
      }

      final tagsJson = jsonEncode(cardData.tags);

      // We need the relative path for the card.
      // Since we know the structure, we can reconstruct it from the factId.
      // factId: YYYY/MM/DD.md#ts_N
      final match =
          RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_(\d+)$').firstMatch(factId);
      if (match == null) {
        _logger.warning('Invalid fact_id format for cache update: $factId');
        return;
      }
      final year = match.group(1)!;
      final month = match.group(2)!;
      final day = match.group(3)!;
      final tsPart = 'ts_${match.group(4)!}';
      final relativePath =
          path.join('Cards', year, month, '${day}_$tsPart.yaml');

      final entry = CardCacheCompanion(
        factId: drift.Value(factId),
        cardPath: drift.Value(relativePath),
        timestamp: drift.Value(timestamp),
        tags: drift.Value(tagsJson),
      );

      await AppDatabase.instance.cardDao.upsertCard(entry);

      // Publish card change event for FTS and other subscribers
      try {
        final rawContent = factInfo?.content ?? '';
        final assetAnalysisTexts = (factInfo?.assetAnalyses ?? [])
            .map((a) => a['analysis'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        final assetOcrTexts = (factInfo?.assetOcrTexts ?? [])
            .map((a) => a['ocr_text'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        await GlobalEventBus.instance.publish(
          userId: userId,
          event: SystemEvent<DataChangeRecord>(
            type: SystemEventTypes.dataChanged,
            source: 'file_system_service',
            payload: DataChangeRecord(
              op: DataChangeOp.update,
              ns: DataChangeNs.card,
              documentKey: factId,
              fullDocument: {
                'title': cardData.title,
                'tags': cardData.tags,
                'content': rawContent,
                'asset_analyses': assetAnalysisTexts,
                'asset_ocr': assetOcrTexts,
                'insight': cardData.insight?.text,
              },
            ),
          ),
        );
      } catch (e) {
        _logger.warning('Failed to publish card change event for $factId: $e');
      }
    } catch (e) {
      _logger.warning('Failed to update card cache for $factId: $e');
    }
  }

  /// Delete a card physically and from cache
  Future<bool> deleteCard(String userId, String cardId) async {
    final lock = await _getCardLock(userId, cardId);
    return lock.synchronized(() async {
      try {
        final cardPath = getCardPath(userId, cardId);
        final file = File(cardPath);

        if (await file.exists()) {
          await file.delete();
          _logger.info('Card physically deleted: $cardId');

          // Delete from cache
          try {
            await (AppDatabase.instance.delete(AppDatabase.instance.cardCache)
                  ..where((tbl) => tbl.factId.equals(cardId)))
                .go();
            // Publish card deleted event
            await GlobalEventBus.instance.publish(
              userId: userId,
              event: SystemEvent<DataChangeRecord>(
                type: SystemEventTypes.dataChanged,
                source: 'file_system_service',
                payload: DataChangeRecord(
                  op: DataChangeOp.delete,
                  ns: DataChangeNs.card,
                  documentKey: cardId,
                ),
              ),
            );
          } catch (e) {
            _logger.warning('Failed to delete card from cache $cardId: $e');
          }

          return true;
        } else {
          _logger.warning('Card file not found: $cardPath');
          return false;
        }
      } catch (e) {
        _logger.severe('Failed to delete card $cardId: $e');
        return false;
      }
    });
  }

  /// Rebuild the entire card cache for a user
  Future<void> rebuildCardCache(String userId) async {
    if (_isRebuilding) {
      _logger.info('Card cache rebuild already in progress, skipping...');
      return;
    }

    _isRebuilding = true;
    _logger.info('Starting card cache rebuild for user $userId');
    try {
      // 1. Clear existing cache
      await AppDatabase.instance.delete(AppDatabase.instance.cardCache).go();

      // 2. List all card files
      final cardFiles = await listAllCardFiles(userId);
      _logger.info('Found ${cardFiles.length} card files to index');

      // 3. Process in batches to avoid locking UI too long
      // Note: reading all files might take time.
      int count = 0;
      for (final cardFile in cardFiles) {
        try {
          // Parse factId from path
          // Path: .../Cards/YYYY/MM/DD_ts_X.yaml
          final factId = factIdFromCardPath(cardFile);
          if (factId == null) continue;

          // Read card data
          final cardData = await readCardFile(userId, factId);
          if (cardData == null) continue;

          if (cardData.deleted == true) continue;

          await updateCardCache(userId, factId, cardData);
          count++;
        } catch (e) {
          _logger.warning('Error indexing card file $cardFile: $e');
        }
      }
      _logger.info('Card cache rebuild complete. Indexed $count cards.');
    } catch (e) {
      _logger.severe('Failed to rebuild card cache: $e');
    } finally {
      _isRebuilding = false;
    }
  }

  /// Parse a factId from an absolute card file path.
  /// Path format: .../Cards/YYYY/MM/DD_ts_X.yaml → YYYY/MM/DD.md#ts_X
  /// Returns null if the path doesn't match the expected format.
  String? factIdFromCardPath(String cardFilePath) {
    final parts = path.split(cardFilePath);
    if (parts.length < 3) return null;
    final year = parts[parts.length - 3];
    final month = parts[parts.length - 2];
    final dayTsFile = parts[parts.length - 1];
    final dayTs = dayTsFile.replaceAll('.yaml', '');
    final dayTsParts = dayTs.split('_');
    if (dayTsParts.length < 2) return null;
    final day = dayTsParts[0];
    final tsPart = dayTsParts.sublist(1).join('_');
    return '$year/$month/$day.md#$tsPart';
  }

  /// Convert fs:// path to local HTTP URL (client mode). Maps to backend TimelineService.convert_fs_to_http.
  static Future<String> convertFsToLocalHttp(
      String fsPath, String userId) async {
    if (!fsPath.startsWith('fs://')) {
      return fsPath;
    }

    final filename = fsPath.substring(5); // strip "fs://"

    // Ensure local asset server is running
    try {
      // 1. Check server health (throttled: once per second)
      final now = DateTime.now();
      if (_lastServerCheckTime == null ||
          now.difference(_lastServerCheckTime!) > const Duration(seconds: 1)) {
        final instance = FileSystemService.instance;
        await LocalAssetServer.checkAndRestartIfNeeded(
            dataRoot: instance.dataRoot);
        _lastServerCheckTime = now;
      }

      int port;
      if (LocalAssetServer.isRunning && LocalAssetServer.port != null) {
        port = LocalAssetServer.port!;
      } else {
        // Start server
        final instance = FileSystemService.instance;
        // Use random port (preferredPort: 0)
        port = await LocalAssetServer.startServer(
            dataRoot: instance.dataRoot, preferredPort: 0);
        _lastServerCheckTime = DateTime.now();
      }

      // build HTTP URL
      // URL format: http://127.0.0.1:port/assets/{userId}/{filename}?token={token}
      final encodedUserId = Uri.encodeComponent(userId);
      final encodedFilename =
          filename.split('/').map(Uri.encodeComponent).join('/');
      final token = LocalAssetServer.accessToken;
      if (token == null) {
        getLogger('FileSystemService')
            .warning('Access token unavailable, cannot generate secure URL');
        return 'http://127.0.0.1:$port/assets/$encodedUserId/$encodedFilename?token=$token';
        ;
      }
      return 'http://127.0.0.1:$port/assets/$encodedUserId/$encodedFilename?token=$token';
    } catch (e) {
      getLogger('FileSystemService')
          .severe('Failed to start local asset server: $e');
      return fsPath;
    }
  }

  /// Replace fs:// paths in HTML with local HTTP URLs (client mode). Maps to backend replace_fs_in_html.
  Future<String> replaceFsInHtml(String htmlContent, String userId) async {
    if (htmlContent.isEmpty) {
      return htmlContent;
    }

    // Match fs:// paths in src, href, etc.
    final pattern = RegExp(r'fs://[^\s"' r"'" r'<>]+');
    final matches = pattern.allMatches(htmlContent);

    if (matches.isEmpty) {
      _logger.fine('replaceFsInHtml: No fs:// path found in HTML');
      return htmlContent;
    }

    _logger.info(
        'replaceFsInHtml: Found ${matches.length} fs:// path(s) to replace');

    String result = htmlContent;
    for (final match in matches) {
      final fsPath = match.group(0)!;
      final httpUrl = await convertFsToLocalHttp(fsPath, userId);
      result = result.replaceFirst(fsPath, httpUrl);
      _logger.fine('replaceFsInHtml: Replace $fsPath -> $httpUrl');
    }

    return result;
  }

  /// Render HTML template with data
  String renderHtmlTemplate(String htmlTemplate, Map<String, dynamic> data) {
    return htmlTemplate.replaceAllMapped(
      RegExp(r'\{\{(\w+(?:\.\w+)*)\}\}'),
      (Match match) {
        final varName = match.group(1)!.trim();
        dynamic value = data;

        final keys = varName.split('.');
        for (var i = 0; i < keys.length; i++) {
          final key = keys[i];
          if (value is Map) {
            value = value[key];
          } else if (value is List) {
            try {
              final index = int.parse(key);
              if (index >= 0 && index < value.length) {
                value = value[index];
              } else {
                value = null;
              }
            } catch (_) {
              value = null;
            }
          } else {
            value = null;
          }

          if (value == null) break;
        }

        if (value == null) return '';

        if (value is Map || value is List) {
          try {
            return jsonEncode(value);
          } catch (_) {
            return value.toString();
          }
        }

        return value.toString();
      },
    );
  }

  /// Convert Map to YAML (manual impl; yaml package only provides parse, not serialize).
  String _mapToYaml(Map<String, dynamic> data) {
    return _mapToYamlString(data);
  }

  /// Map to YAML string (manual impl, aligned with backend yaml.dump).
  String _mapToYamlString(Map<String, dynamic> data, {int indent = 0}) {
    final buffer = StringBuffer();
    final indentStr = '  ' * indent;

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map) {
        if (value.isEmpty) {
          buffer.writeln('$indentStr$key: {}');
        } else {
          buffer.writeln('$indentStr$key:');
          buffer.write(_mapToYamlString(Map<String, dynamic>.from(value),
              indent: indent + 1));
        }
      } else if (value is List) {
        if (value.isEmpty) {
          buffer.writeln('$indentStr$key: []');
        } else {
          buffer.writeln('$indentStr$key:');
          for (final item in value) {
            if (item is Map) {
              if (item.isEmpty) {
                buffer.writeln('$indentStr  - {}');
              } else {
                buffer.writeln('$indentStr  -');
                buffer.write(_mapToYamlString(Map<String, dynamic>.from(item),
                    indent: indent + 2));
              }
            } else {
              buffer.writeln('$indentStr  - ${_valueToString(item)}');
            }
          }
        }
      } else {
        buffer.writeln('$indentStr$key: ${_valueToString(value)}');
      }
    }

    final result = buffer.toString();
    return result.endsWith('\n') ? result : '$result\n';
  }

  String _valueToString(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      // Quote if special chars or looks like number (YAML would parse as int)
      final isNumeric = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value);
      // Bool/null keywords parsed as non-string in YAML
      final isKeyword = {'true', 'false', 'null', '~', 'yes', 'no', 'on', 'off'}
          .contains(value.toLowerCase());

      if (value.contains(':') ||
          value.contains('\n') ||
          value.contains('"') ||
          value.contains('#') ||
          value.startsWith(' ') ||
          value.endsWith(' ') ||
          value.startsWith('-') ||
          value.startsWith('*') ||
          value.startsWith('&') ||
          value.startsWith('?') ||
          value.startsWith('!') ||
          value.startsWith('%') ||
          value.startsWith('@') ||
          value.startsWith('`') ||
          value.startsWith('[') ||
          value.startsWith('{') ||
          value.startsWith('|') ||
          value.startsWith('>') ||
          value.isEmpty ||
          isNumeric ||
          isKeyword) {
        return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
      }
      return value;
    } else if (value is bool) {
      return value.toString();
    } else if (value is num) {
      return value.toString();
    } else {
      return value.toString();
    }
  }

  /// Write YAML file (overwrite optional).
  Future<void> writeYamlFile(String absolutePath, Map<String, dynamic> data,
      {bool overwrite = true}) async {
    final file = File(absolutePath);
    if (!overwrite && await file.exists()) {
      throw ApiException('File already exists: $absolutePath');
    }
    await ensureDirectory(path.dirname(absolutePath));

    final yamlContent = _mapToYamlString(data);
    await file.writeAsString(yamlContent);
  }

  /// User settings directory path
  String getUserSettingsPath(String userId) {
    return path.join(getWorkspacePath(userId), '_UserSettings');
  }

  /// Resolve a skill directory path (relative to workspace) to an absolute path.
  /// [skillDirectoryPath] is stored as e.g. `_UserSettings/skills/my-agent`.
  String resolveSkillPath(String userId, String skillDirectoryPath) {
    return path
        .normalize(path.join(getWorkspacePath(userId), skillDirectoryPath));
  }

  /// Ensure the skill directory is accessible from within [workingDirectory].
  ///
  /// If [skillAbsPath] is already under [workingDirAbsPath], returns it as-is
  /// with [SkillSyncResult.didSync] = false.
  /// Otherwise, performs an rsync-like sync of the skill directory into
  /// `<workingDir>/<dirName>/` so that file tools (Read, LS, etc.)
  /// can access skill files. Only changed files are copied (by mtime + size),
  /// and stale files in the destination are removed.
  ///
  /// After agent execution, call [syncSkillsBack] with the returned result
  /// to propagate any changes back to the original skill directory.
  Future<SkillSyncResult> syncSkillsIfNeeded({
    required String skillAbsPath,
    required String workingDirAbsPath,
  }) async {
    final normalizedSkill = path.normalize(skillAbsPath);
    final normalizedWork = path.normalize(workingDirAbsPath);

    // Already inside workingDirectory — nothing to do.
    if (normalizedSkill.startsWith('$normalizedWork/') ||
        normalizedSkill == normalizedWork) {
      return SkillSyncResult(
        effectivePath: normalizedSkill,
        originalPath: normalizedSkill,
        didSync: false,
      );
    }

    final skillDir = Directory(normalizedSkill);
    if (!await skillDir.exists()) {
      _logger.warning(
          'Skill directory does not exist, skipping sync: $normalizedSkill');
      return SkillSyncResult(
        effectivePath: normalizedSkill,
        originalPath: normalizedSkill,
        didSync: false,
      );
    }

    final dirName = path.basename(normalizedSkill);
    final destRoot = path.join(normalizedWork, dirName);
    final destDir = Directory(destRoot);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await _rsyncDirectory(normalizedSkill, destRoot);

    _logger.info('Synced skill directory: $normalizedSkill -> $destRoot');
    return SkillSyncResult(
      effectivePath: destRoot,
      originalPath: normalizedSkill,
      didSync: true,
    );
  }

  /// Sync changes from the working copy back to the original skill directory.
  ///
  /// Should be called after agent execution when [SkillSyncResult.didSync]
  /// is true, to propagate any modifications the agent made to skill files.
  Future<void> syncSkillsBack(SkillSyncResult syncResult) async {
    if (!syncResult.didSync) return;

    final copyDir = Directory(syncResult.effectivePath);
    if (!await copyDir.exists()) {
      _logger
          .warning('Skill working copy no longer exists, skipping sync-back: '
              '${syncResult.effectivePath}');
      return;
    }

    await _rsyncDirectory(syncResult.effectivePath, syncResult.originalPath);
    _logger.info('Synced skill changes back: '
        '${syncResult.effectivePath} -> ${syncResult.originalPath}');
  }

  /// Recursively sync [srcRoot] to [destRoot] (rsync-like).
  /// - Copies files whose mtime or size differ.
  /// - Creates missing directories.
  /// - Removes files/dirs in dest that no longer exist in source.
  Future<void> _rsyncDirectory(String srcRoot, String destRoot) async {
    final srcDir = Directory(srcRoot);
    final destDir = Directory(destRoot);

    // Collect all source relative paths for stale-file cleanup.
    final sourceRelPaths = <String>{};

    await for (final entity
        in srcDir.list(recursive: true, followLinks: false)) {
      final relPath = path.relative(entity.path, from: srcRoot);
      sourceRelPaths.add(relPath);

      final destPath = path.join(destRoot, relPath);

      if (entity is Directory) {
        final d = Directory(destPath);
        if (!await d.exists()) {
          await d.create(recursive: true);
        }
      } else if (entity is File) {
        final destFile = File(destPath);
        bool needsCopy = true;

        if (await destFile.exists()) {
          final srcStat = await entity.stat();
          final destStat = await destFile.stat();
          // Skip if same size and dest is not older than source.
          if (srcStat.size == destStat.size &&
              !srcStat.modified.isAfter(destStat.modified)) {
            needsCopy = false;
          }
        }

        if (needsCopy) {
          final parentDir = Directory(path.dirname(destPath));
          if (!await parentDir.exists()) {
            await parentDir.create(recursive: true);
          }
          await entity.copy(destPath);
        }
      }
    }

    // Remove stale files/dirs in dest that no longer exist in source.
    if (await destDir.exists()) {
      final destEntities = <FileSystemEntity>[];
      await for (final entity
          in destDir.list(recursive: true, followLinks: false)) {
        destEntities.add(entity);
      }
      // Process in reverse order (deepest first) so dirs are empty before removal.
      destEntities.sort((a, b) => b.path.length.compareTo(a.path.length));
      for (final entity in destEntities) {
        final relPath = path.relative(entity.path, from: destRoot);
        if (!sourceRelPaths.contains(relPath)) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            _logger.warning('Failed to remove stale path: ${entity.path}: $e');
          }
        }
      }
    }
  }

  /// Resolve a working directory path (relative to workspace) to an absolute path.
  /// [workingDirectory] is stored as e.g. '' (workspace root) or 'my-data'.
  /// Creates the directory recursively if it does not exist.
  Future<String> resolveWorkingDirectory(
      String userId, String workingDirectory) async {
    final absPath = workingDirectory.isEmpty
        ? getWorkspacePath(userId)
        : path.normalize(path.join(getWorkspacePath(userId), workingDirectory));
    final dir = Directory(absPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return absPath;
  }

  String getProfilePath(String userId) {
    return path.join(getUserSettingsPath(userId), 'profile.md');
  }

  /// Add user custom location (lat, lng, name).
  Future<bool> addUserLocation(
      String userId, double lat, double lng, String name) async {
    try {
      final settingsPath = getUserSettingsPath(userId);
      await ensureDirectory(settingsPath);

      final locationsFile = path.join(settingsPath, 'user_locations.yaml');
      var locations = <Map<String, dynamic>>[];

      if (await _baseService.exists(locationsFile)) {
        try {
          final content = await _baseService.readFile(locationsFile);
          final yamlDoc = loadYaml(content);
          if (yamlDoc is YamlList) {
            locations = yamlDoc
                .map((e) => _yamlToMap(e))
                .toList()
                .cast<Map<String, dynamic>>();
          } else if (yamlDoc is List) {
            // Handle case where loadYaml returns a standard List (rare but possible with some parsers/inputs)
            locations = (yamlDoc)
                .map((e) => _yamlToMap(e))
                .toList()
                .cast<Map<String, dynamic>>();
          }
        } catch (e) {
          _logger.warning('Failed to read existing place: $e');
        }
      }

      final newLocation = {
        'lat': lat,
        'lng': lng,
        'name': name,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      // Simple de-duplication/update by name
      var updated = false;
      for (var i = 0; i < locations.length; i++) {
        if (locations[i]['name'] == name) {
          locations[i] = newLocation;
          updated = true;
          break;
        }
      }

      if (!updated) {
        locations.add(newLocation);
      }

      final yamlContent = _listToYamlString(locations);
      await _baseService.writeFile(locationsFile, yamlContent);

      return true;
    } catch (e) {
      _logger.severe('Failed to add user place: $e');
      return false;
    }
  }

  /// Get nearest user custom location (threshold in meters, default 50). Returns place name or null.
  Future<String?> getNearestUserLocation(String userId, double lat, double lng,
      [double thresholdMeters = 50.0]) async {
    try {
      final settingsPath = getUserSettingsPath(userId);
      final locationsFile = path.join(settingsPath, 'user_locations.yaml');

      if (!await _baseService.exists(locationsFile)) {
        return null;
      }

      var locations = <Map<String, dynamic>>[];
      try {
        final content = await _baseService.readFile(locationsFile);
        final yamlDoc = loadYaml(content);
        if (yamlDoc is YamlList) {
          locations = yamlDoc
              .map((e) => _yamlToMap(e))
              .toList()
              .cast<Map<String, dynamic>>();
        }
      } catch (e) {
        _logger.warning('Failed to read place file: $e');
        return null;
      }

      if (locations.isEmpty) {
        return null;
      }

      String? nearestName;
      double minDist = double.infinity;

      for (final loc in locations) {
        final locLat = loc['lat'] as num?;
        final locLng = loc['lng'] as num?;
        final name = loc['name'] as String?;

        if (locLat == null || locLng == null || name == null) {
          continue;
        }

        final dist =
            _calculateDistance(lat, lng, locLat.toDouble(), locLng.toDouble());

        if (dist < minDist) {
          minDist = dist;
          nearestName = name;
        }
      }

      if (minDist <= thresholdMeters) {
        _logger.info(
            "Found nearest location '$nearestName' at ${minDist.toStringAsFixed(2)}m");
        return nearestName;
      }

      return null;
    } catch (e) {
      _logger.severe('Failed to find nearest user place: $e');
      return null;
    }
  }

  /// Get user custom location by name. Returns (lat, lng, name) or null.
  Future<Map<String, dynamic>?> getUserLocationByName(
      String userId, String name) async {
    try {
      final settingsPath = getUserSettingsPath(userId);
      final locationsFile = path.join(settingsPath, 'user_locations.yaml');

      if (!await _baseService.exists(locationsFile)) {
        return null;
      }

      var locations = <Map<String, dynamic>>[];
      try {
        final content = await _baseService.readFile(locationsFile);
        final yamlDoc = loadYaml(content);
        if (yamlDoc is YamlList) {
          locations = yamlDoc
              .map((e) => _yamlToMap(e))
              .toList()
              .cast<Map<String, dynamic>>();
        }
      } catch (e) {
        _logger.warning('Failed to read place file: $e');
        return null;
      }

      for (final loc in locations) {
        if (loc['name'] == name) {
          return {
            'lat': loc['lat'],
            'lng': loc['lng'],
            'name': loc['name'],
          };
        }
      }

      return null;
    } catch (e) {
      _logger.severe('Failed to find user place by name: $e');
      return null;
    }
  }

  /// Distance between two points (Haversine), in meters.
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  /// Convert list to YAML string
  String _listToYamlString(List<dynamic> list, {int indent = 0}) {
    final buffer = StringBuffer();
    final indentStr = ' ' * indent;

    for (final item in list) {
      if (item is Map) {
        buffer.writeln('$indentStr-');
        buffer.write(_mapToYamlString(Map<String, dynamic>.from(item),
            indent: indent + 2));
      } else {
        buffer.writeln('$indentStr- ${_valueToString(item)}');
      }
    }

    final result = buffer.toString();
    return result.endsWith('\n') ? result : '$result\n';
  }

  /// Get_Systemdirectory path
  String getSystemPath(String userId) {
    return path.join(getWorkspacePath(userId), '_System');
  }

  /// Drafts directory path (input draft files)
  String getDraftsPath(String userId) {
    return path.join(getSystemPath(userId), 'Drafts');
  }

  /// Active draft file path
  String getActiveDraftPath(String userId) {
    return path.join(getDraftsPath(userId), 'active.json');
  }

  /// Templates directory path (card templates)
  String getTemplatesPath(String userId) {
    return path.join(getSystemPath(userId), 'Templates');
  }

  /// Knowledge insights card templates directory path
  String getKnowledgeInsightsCardTemplatesPath(String userId) {
    return path.join(getSystemPath(userId), 'KnowledgeInsightsCardTemplates');
  }

  /// Chart templates path (legacy name, points to new path)
  String getChartTemplatesPath(String userId) {
    return getKnowledgeInsightsCardTemplatesPath(userId);
  }

  /// Template directory path
  String getTemplatePath(String userId, String templateId) {
    return path.join(getTemplatesPath(userId), templateId);
  }

  /// Gettagsfile path
  String getTagsFilePath(String userId) {
    return path.join(getSystemPath(userId), 'tags.md');
  }

  /// ensuredirectoryexists
  Future<void> ensureDirectory(String dirPath) async {
    if (!await _baseService.exists(dirPath)) {
      await Directory(dirPath).create(recursive: true);
    } else if (!await _baseService.isDirectory(dirPath)) {
      throw ApiException('Path exists but is not a directory: $dirPath');
    }
  }

  /// Generate asset filename
  String generateAssetFilename(
    String userId,
    String assetType,
    int index,
    String extension, {
    String? factId,
    String? extraInfo,
  }) {
    String dateStr;
    String mStr;

    if (factId != null) {
      if (factId.startsWith('batch_')) {
        // Allow temporary batch identifiers during auto-input clustering.
        // We'll rename them post-clustering.
        final batchId = factId.substring(6); // remove 'batch_'
        dateStr = 'batch';
        mStr = batchId;
      } else {
        try {
          final match = RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_(\d+)')
              .firstMatch(factId);
          if (match != null) {
            final year = match.group(1)!;
            final month = match.group(2)!;
            final day = match.group(3)!;
            mStr = match.group(4)!;
            dateStr = '$year$month$day';
          } else {
            throw ApiException('Invalid factId format: $factId');
          }
        } catch (e) {
          throw ApiException('Invalid factId format: $factId');
        }
      }
    } else {
      throw ApiException('factId cannot be empty');
    }

    final extraPart = extraInfo != null ? '_$extraInfo' : '';
    return '${assetType}_${dateStr}_ts_${mStr}_no_$index$extraPart.$extension';
  }

  /// Save asset from file (direct copy, no Base64). Returns (filename, relativePath) under dataRoot.
  Future<(String, String)> saveAssetFromFile({
    required String userId,
    required String sourcePath,
    required String assetType,
    required int index,
    String? format,
    String? factId,
    String? extraInfo,
  }) async {
    final assetsPath = getAssetsPath(userId);
    await ensureDirectory(assetsPath);

    String extension;
    if (format != null) {
      extension = format;
    } else {
      extension = path.extension(sourcePath).replaceAll('.', '');
      if (extension.isEmpty) {
        extension = assetType == 'img' ? 'png' : 'm4a';
      }
    }

    if (extraInfo == null) {
      if (assetType == 'img') {
        try {
          final fileBytes = await File(sourcePath).readAsBytes();
          final image = await decodeImageFromList(fileBytes);
          extraInfo = '${image.width}x${image.height}';
        } catch (e) {
          _logger.warning('Failed to extract image dimensions: $e');
        }
      } else if (assetType == 'audio') {
        try {
          final player = AudioPlayer();
          try {
            await player.setSourceDeviceFile(sourcePath);
            // wait for duration to be parsed
            final durationStr = await player.getDuration();
            if (durationStr != null) {
              final durationSeconds =
                  (durationStr.inMilliseconds / 1000).ceil();
              extraInfo = '$durationSeconds';
            }
          } finally {
            await player.dispose();
          }
        } catch (e) {
          _logger.warning('Failed to extract audio duration: $e');
        }
      }
    }

    final filename = generateAssetFilename(
      userId,
      assetType,
      index,
      extension,
      factId: factId,
      extraInfo: extraInfo,
    );
    final absolutePath = path.join(assetsPath, filename);

    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw ApiException('Source file not found: $sourcePath');
      }

      await sourceFile.copy(absolutePath);

      // Convert to relative path to avoid iOS Application ID change issue
      final relativePath = toRelativePath(absolutePath);
      _logger.info('Copied asset from $sourcePath to $absolutePath');
      return (filename, relativePath);
    } catch (e) {
      _logger.severe('Failed to save asset file: $e');
      rethrow;
    }
  }

  /// Daily fact file path
  String getDailyFactPath(String userId, DateTime date) {
    final factsPath = getFactsPath(userId);
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return path.join(factsPath, year, month, '$day.md');
  }

  /// Read daily fact file and parse YAML frontmatter. Returns (yamlData, bodyContent); (null, raw) if no frontmatter.
  Future<({Map<String, dynamic>? yamlData, String bodyContent})>
      readDailyFactFile(String userId, DateTime date) async {
    final filePath = getDailyFactPath(userId, date);

    if (!await _baseService.exists(filePath)) {
      return (yamlData: null, bodyContent: '');
    }

    try {
      final content = await _baseService.readFile(filePath);

      final yamlPattern =
          RegExp(r'^---\s*\n(.*?)\n---\s*\n(.*)$', dotAll: true);
      final match = yamlPattern.firstMatch(content);

      if (match != null) {
        final yamlStr = match.group(1)!;
        final bodyContent = match.group(2)!;

        try {
          final yamlData = _parseYaml(yamlStr);
          return (
            yamlData: yamlData.isEmpty ? null : yamlData,
            bodyContent: bodyContent
          );
        } catch (e) {
          _logger.warning('Failed to parse yaml frontmatter: $e');
          return (yamlData: null, bodyContent: content);
        }
      } else {
        return (yamlData: null, bodyContent: content);
      }
    } catch (e) {
      _logger.severe('Failed to read fact file: $e');
      return (yamlData: null, bodyContent: '');
    }
  }

  /// parseYAMLstringasMap
  Map<String, dynamic> _parseYaml(String yamlStr) {
    try {
      final yamlDoc = loadYaml(yamlStr);
      return _yamlToMap(yamlDoc);
    } catch (e) {
      _logger.severe('YAML parse failed: $e');
      rethrow;
    }
  }

  /// Convert YAML object to Map<String, dynamic>
  Map<String, dynamic> _yamlToMap(dynamic yaml) {
    if (yaml == null) {
      return {};
    }

    if (yaml is YamlMap) {
      final result = <String, dynamic>{};
      yaml.forEach((key, value) {
        final keyStr = key.toString();
        result[keyStr] = _yamlToValue(value);
      });
      return result;
    }

    return yaml as Map<String, dynamic>? ?? {};
  }

  /// Convert YAML value to Dart value
  dynamic _yamlToValue(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is YamlMap) {
      return _yamlToMap(value);
    } else if (value is YamlList) {
      return value.map((item) => _yamlToValue(item)).toList();
    } else {
      return value;
    }
  }

  /// Generate unique fact ID for the day
  Future<String> generateFactId(String userId, DateTime date) async {
    final result = await readDailyFactFile(userId, date);
    final bodyContent = result.bodyContent;

    final pattern = RegExp(r'## <id:ts_(\d+)>');
    final matches = pattern.allMatches(bodyContent);
    final existingIds = matches.map((m) => int.parse(m.group(1)!)).toList();

    final newId = existingIds.isEmpty
        ? 1
        : (existingIds.reduce((a, b) => a > b ? a : b) + 1);

    // If newId is 1, it means this is the first input of the day (for this specific day).
    // This is a good time to rebuild the card cache to ensure consistency.
    if (newId == 1) {
      // Don't await this, let it run in background
      rebuildCardCache(userId);
    }

    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day.md#ts_$newId';
  }

  /// Extract simple format (ts_N) from full fact_id
  String extractSimpleFactId(String factId) {
    final match = RegExp(r'ts_(\d+)$').firstMatch(factId);
    if (match == null) {
      throw ArgumentError('Invalid fact_id format: $factId');
    }
    return 'ts_${match.group(1)!}';
  }

  /// Format time as HH:MM:SS
  String formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  /// Parse date from fact_id
  DateTime parseFactIdDate(String factId) {
    final match =
        RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_\d+$').firstMatch(factId);
    if (match == null) {
      throw ArgumentError(
          'Invalid fact_id format: $factId, expected format: YYYY/MM/DD.md#ts_N');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);

    return DateTime(year, month, day);
  }

  /// GetPKMdirectory path
  String getPkmPath(String userId) {
    return path.join(getWorkspacePath(userId), 'PKM');
  }

  /// GetChatSessionsdirectory path
  String getChatSessionsPath(String userId) {
    return path.join(getWorkspacePath(userId), 'ChatSessions');
  }

  /// GetKnowledgeInsightsdirectory path
  String getKnowledgeInsightsPath(String userId) {
    return path.join(getWorkspacePath(userId), 'KnowledgeInsights');
  }

  /// GetKnowledgeInsights Cardsdirectory path
  String getKnowledgeInsightsCardsPath(String userId) {
    return path.join(getKnowledgeInsightsPath(userId), 'Cards');
  }

  String getInsightTagsPath(String userId) {
    return path.join(getSystemPath(userId), 'insight_tags.md');
  }

  /// Knowledge insight card file path
  String getKnowledgeInsightCardPath(String userId, String cardId) {
    final filename = cardId.endsWith('.yaml') ? cardId : '$cardId.yaml';
    return path.join(getKnowledgeInsightsCardsPath(userId), filename);
  }

  Future<void> updateDailyFactYamlData(
      String userId, DateTime date, Map<String, dynamic> data) async {
    final filePath = getDailyFactPath(userId, date);
    final parentDir = path.dirname(filePath);

    // ensuredirectoryexists
    await ensureDirectory(parentDir);

    // Read existing content and parse yaml
    final result = await readDailyFactFile(userId, date);
    var yamlData = result.yamlData ?? <String, dynamic>{};

    // mergedata（newdataoverwriteolddata）
    yamlData.addAll(data);

    // Build new yaml frontmatter
    final yamlStr = _mapToYaml(yamlData);
    // Ensure yaml string ends with newline
    final yamlContent = yamlStr.endsWith('\n') ? yamlStr : '$yamlStr\n';

    // Combine new content
    final bodyContent = result.bodyContent;
    final newContent = bodyContent.isNotEmpty
        ? '---\n$yamlContent---\n$bodyContent'
        : '---\n$yamlContent---\n';

    // Write back to file
    await _baseService.writeFile(filePath, newContent);
    _logger.info('Updated yaml frontmatter in fact file: $filePath');
  }

  Future<void> appendToDailyFactFile(
      String userId, DateTime date, String content) async {
    final filePath = getDailyFactPath(userId, date);
    final parentDir = path.dirname(filePath);

    // ensuredirectoryexists
    await ensureDirectory(parentDir);

    // Read existing content and parse yaml
    final result = await readDailyFactFile(userId, date);
    final yamlData = result.yamlData;
    var bodyContent = result.bodyContent;

    if (bodyContent.isNotEmpty) {
      // appendcontenttobodypartial
      final trimmed = bodyContent.trim();
      final separator = trimmed.isNotEmpty && !trimmed.endsWith('\n')
          ? (trimmed.contains('\n\n') ? '\n' : '\n\n')
          : '\n';
      bodyContent = '$trimmed$separator$content';

      // If yaml data present, recombine; else use new content
      if (yamlData != null) {
        final yamlStr = _mapToYaml(yamlData);
        final yamlContent = yamlStr.endsWith('\n') ? yamlStr : '$yamlStr\n';
        final newContent = '---\n$yamlContent---\n$bodyContent';
        await _baseService.writeFile(filePath, newContent);
      } else {
        await _baseService.writeFile(filePath, bodyContent);
      }
    } else {
      // Create new file (no yaml frontmatter)
      await _baseService.writeFile(filePath, content);
    }

    _logger.info('Appended to fact file: $filePath');
  }

  /// Read card YAML file and return typed [CardData], or null if missing/invalid.
  Future<CardData?> readCardFile(String userId, String factId) async {
    final cardPath = getCardPath(userId, factId);

    if (!await _baseService.exists(cardPath)) {
      return null;
    }

    try {
      final content = await _baseService.readFile(cardPath);
      final raw = _parseYaml(content);
      if (raw.isEmpty) return null;
      return CardData.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      _logger.severe('Failed to read card file $cardPath: $e');
      return null;
    }
  }

  /// Read card template HTML file
  Future<String?> readTemplateHtml(String userId, String templateId) async {
    final templatePath = getTemplatePath(userId, templateId);
    final viewPath = path.join(templatePath, 'view.html');

    if (!await _baseService.exists(viewPath)) {
      return null;
    }

    try {
      return await _baseService.readFile(viewPath);
    } catch (e) {
      _logger.severe('Failed to read template HTML $viewPath: $e');
      return null;
    }
  }

  /// Read chart template HTML file
  Future<String?> readChartTemplateHtml(
      String userId, String templateId) async {
    final chartTemplatesPath = getChartTemplatesPath(userId);
    final templatePath = path.join(chartTemplatesPath, templateId);
    final viewPath = path.join(templatePath, 'view.html');

    if (!await _baseService.exists(viewPath)) {
      return null;
    }

    try {
      return await _baseService.readFile(viewPath);
    } catch (e) {
      _logger.severe('Failed to read chart template HTML $viewPath: $e');
      return null;
    }
  }

  Future<String?> readKnowledgeInsightCardTemplateHtml(
      String userId, String templateId) async {
    return readChartTemplateHtml(userId, templateId);
  }

  /// Read tags file, return list of tags (name, icon, icon_type)
  Future<List<Map<String, dynamic>>> readTagsFile(String userId) async {
    final tagsPath = getTagsFilePath(userId);
    final tags = <Map<String, dynamic>>[];

    if (!await _baseService.exists(tagsPath)) {
      return tags;
    }

    try {
      final content = await _baseService.readFile(tagsPath);
      final lines = content.split('\n');

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          continue;
        }

        try {
          final tagData = jsonDecode(trimmed) as Map<String, dynamic>;
          // Validate required fields
          if (tagData.containsKey('name')) {
            tags.add({
              'name': tagData['name'],
              'icon': tagData['icon'] ?? '',
              'icon_type': tagData['icon_type'] ?? 'emoji',
            });
          }
        } catch (e) {
          _logger.warning('Failed to parse tag line: $trimmed, error: $e');
          continue;
        }
      }
    } catch (e) {
      _logger.severe('Failed to read tags file $tagsPath: $e');
    }

    return tags;
  }

  /// Ensure tags file is initialized (no default tags).
  Future<void> ensureTagsFileInitialized(String userId) async {
    final tagsPath = getTagsFilePath(userId);
    if (await _baseService.exists(tagsPath)) {
      return;
    }

    // ensuredirectoryexists
    final parentDir = path.dirname(tagsPath);
    await ensureDirectory(parentDir);

    try {
      // Create empty tags file for user/AI to fill
      await _baseService.writeFile(tagsPath, '');
      _logger.info('Initialized empty tags file for user $userId');
    } catch (e) {
      _logger.severe('Failed to init tags file $tagsPath: $e');
      rethrow;
    }
  }

  /// Append new tag definitions (add if name not found)
  Future<void> appendNewTags(
      String userId, List<Map<String, dynamic>> newTags) async {
    if (newTags.isEmpty) {
      return;
    }

    // ensurefileexists
    await ensureTagsFileInitialized(userId);

    // Read existing tags and index
    final existingTags = await readTagsFile(userId);
    final existingNames =
        existingTags.map((tag) => tag['name'] as String).toSet();

    var appendedCount = 0;
    for (final tag in newTags) {
      final name = tag['name'] as String?;
      final icon = tag['icon'] as String?;
      if (name == null || name.isEmpty || icon == null || icon.isEmpty) {
        _logger.warning('Skip invalid tag without name/icon: $tag');
        continue;
      }

      if (existingNames.contains(name)) {
        continue;
      }

      // Keep default icon_type
      final newTag = {
        'name': name,
        'icon': icon,
        'icon_type': tag['icon_type'] ?? 'emoji',
      };
      existingTags.add(newTag);
      existingNames.add(name);
      appendedCount++;
    }

    if (appendedCount == 0) {
      return;
    }

    // Write back (overwrite, JSON Lines format)
    final tagsPath = getTagsFilePath(userId);
    try {
      final lines = existingTags.map((tag) => jsonEncode(tag)).join('\n');
      await _baseService.writeFile(tagsPath, '$lines\n');
      _logger.info('Appended $appendedCount new tags for user $userId');
    } catch (e) {
      _logger.severe('Failed to write tags file $tagsPath: $e');
      rethrow;
    }
  }

  /// Read knowledge insight card file (YAML)
  Future<Map<String, dynamic>?> readKnowledgeInsightCard(
      String userId, String cardId) async {
    final filePath = getKnowledgeInsightCardPath(userId, cardId);

    if (!await _baseService.exists(filePath)) {
      return null;
    }

    try {
      final content = await _baseService.readFile(filePath);
      final data = _parseYaml(content);
      return data.isEmpty ? null : data;
    } catch (e) {
      _logger.severe('Failed to read knowledge insight card $filePath: $e');
      return null;
    }
  }

  /// Write knowledge insight card file (YAML)
  Future<void> writeKnowledgeInsightCard(
    String userId,
    String cardId,
    Map<String, dynamic> data,
  ) async {
    final filePath = getKnowledgeInsightCardPath(userId, cardId);
    final parentDir = path.dirname(filePath);
    await ensureDirectory(parentDir);

    try {
      final yamlContent = _mapToYaml(data);
      await _baseService.writeFile(filePath, yamlContent);
      _logger.info('Knowledge insight card written: $filePath');
    } catch (e) {
      _logger.severe('Failed to write knowledge insight card $filePath: $e');
      rethrow;
    }
  }

  /// Delete knowledge insight card
  Future<bool> deleteKnowledgeInsightCard(String userId, String cardId) async {
    final filePath = getKnowledgeInsightCardPath(userId, cardId);
    if (!await _baseService.exists(filePath)) {
      return false;
    }
    try {
      await _baseService.remove(filePath, recursive: false);
      _logger.info('Knowledge insight card deleted: $filePath');
      return true;
    } catch (e) {
      _logger.severe('Failed to delete knowledge insight card $cardId: $e');
      return false;
    }
  }

  /// List all knowledge insight cards
  Future<List<Map<String, dynamic>>> listKnowledgeInsightCards(
      String userId) async {
    final dirPath = getKnowledgeInsightsCardsPath(userId);
    if (!await _baseService.exists(dirPath)) {
      return [];
    }

    final cards = <Map<String, dynamic>>[];
    try {
      final items = await _baseService.listDirectory(dirPath);
      for (final item in items) {
        if (item.endsWith('.yaml')) {
          final cardId = path.basename(item);
          final data = await readKnowledgeInsightCard(userId, cardId);
          if (data != null) {
            // Ensure card has ID
            if (!data.containsKey('id')) {
              data['id'] = path.basenameWithoutExtension(cardId);
            }
            // Ensure field exists, default false
            if (!data.containsKey('pinned')) {
              data['pinned'] = false;
            }
            cards.add(data);
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to list knowledge insight cards: $e');
    }
    return cards;
  }

  /// Read all insight tags
  Future<List<String>> readInsightTags(String userId) async {
    final filePath = getInsightTagsPath(userId);
    if (!await _baseService.exists(filePath)) {
      return [];
    }
    try {
      final content = await _baseService.readFile(filePath);
      // Assuming tags are stored one per line or comma separated?
      // User requested "insight_tags.md", maybe markdown list?
      // Let's assume one tag per line for simplicity or comma separated.
      // Or maybe a simple text file. Let's use lines.
      // Wait, "md" suggests markdown. Let's assume "- tag" format or just text.
      // Let's stick to simple lines for now, trimming whitespace.
      final lines = content.split('\n');
      return lines
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !e.startsWith('#')) // Ignore comments
          .map((e) =>
              e.replaceAll(RegExp(r'^-\s*'), '')) // Remove bullet if present
          .toSet() // Unique
          .toList();
    } catch (e) {
      _logger.warning('Failed to read insight tags: $e');
      return [];
    }
  }

  /// Save and merge insight tags
  Future<void> saveInsightTags(String userId, List<String> newTags) async {
    final filePath = getInsightTagsPath(userId);
    final currentTags = await readInsightTags(userId);
    final tagSet = currentTags.toSet();
    tagSet.addAll(newTags); // Add new unique tags

    // Sort?
    final sortedTags = tagSet.toList()..sort();

    final content = sortedTags.map((t) => '- $t').join('\n');

    try {
      final parentDir = path.dirname(filePath);
      await ensureDirectory(parentDir);
      await _baseService.writeFile(filePath, content);
    } catch (e) {
      _logger.severe('Failed to save insight tags: $e');
    }
  }

  /// Delete specified insight tags
  Future<void> deleteInsightTags(
      String userId, List<String> tagsToDelete) async {
    final filePath = getInsightTagsPath(userId);
    final currentTags = await readInsightTags(userId);
    final tagSet = currentTags.toSet();

    // Remove specified tags
    tagSet.removeAll(tagsToDelete);

    // Sort
    final sortedTags = tagSet.toList()..sort();

    final content = sortedTags.map((t) => '- $t').join('\n');

    try {
      final parentDir = path.dirname(filePath);
      await ensureDirectory(parentDir);
      await _baseService.writeFile(filePath, content);
      _logger.info('Deleted insight tags: ${tagsToDelete.join(", ")}');
    } catch (e) {
      _logger.severe('Failed to delete insight tags: $e');
    }
  }

  /// List all fact IDs, sorted by date and ts (earliest first). Format: YYYY/MM/DD.md#ts_X
  Future<List<String>> listAllFacts(String userId) async {
    final factsPath = getFactsPath(userId);

    if (!await _baseService.exists(factsPath)) {
      return [];
    }

    final factIds = <String>[];

    // Iterate year directories
    try {
      final yearItems = await _baseService.listDirectory(factsPath);
      for (final yearItem in yearItems) {
        final yearPath = path.join(factsPath, yearItem);
        if (!await _baseService.isDirectory(yearPath)) {
          continue;
        }

        final yearStr = path.basename(yearItem);
        if (!RegExp(r'^\d+$').hasMatch(yearStr)) {
          continue;
        }
        final year = int.parse(yearStr);

        // Iterate month directories
        final monthItems = await _baseService.listDirectory(yearPath);
        for (final monthItem in monthItems) {
          final monthPath = path.join(yearPath, monthItem);
          if (!await _baseService.isDirectory(monthPath)) {
            continue;
          }

          final monthStr = path.basename(monthItem);
          if (!RegExp(r'^\d+$').hasMatch(monthStr)) {
            continue;
          }
          final month = int.parse(monthStr);

          final dayItems = await _baseService.listDirectory(monthPath);
          for (final dayItem in dayItems) {
            final dayPath = path.join(monthPath, dayItem);
            if (!await _baseService.isFile(dayPath) ||
                !dayPath.endsWith('.md')) {
              continue;
            }

            // Extract date from filename
            final filename = path.basenameWithoutExtension(dayItem);
            if (!RegExp(r'^\d+$').hasMatch(filename)) {
              continue;
            }
            final day = int.parse(filename);

            // Read file, extract fact IDs
            try {
              final result = await readDailyFactFile(
                userId,
                DateTime(year, month, day),
              );
              final bodyContent = result.bodyContent;

              // Match fact IDs: ## <id:ts_X> or ## <id:YYYY/MM/DD.md#ts_X>
              final pattern = RegExp(r'##\s*<id:(ts_\d+)>');
              final matches = pattern.allMatches(bodyContent);

              for (final match in matches) {
                final tsPart = match.group(1)!; // ts_X
                final factId =
                    '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}.md#$tsPart';
                factIds.add(factId);
              }
            } catch (e) {
              _logger.warning('Failed to read fact file $dayPath: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to list fact files: $e');
      return [];
    }

    // Sort by timestamp (earliest first)
    final factsWithTimestamp = <({String factId, int timestamp})>[];
    for (final factId in factIds) {
      try {
        final factInfo = await extractFactContentFromFile(userId, factId);
        if (factInfo != null) {
          factsWithTimestamp.add((
            factId: factId,
            timestamp: factInfo.timestamp,
          ));
        }
      } catch (e) {
        _logger.warning('Failed to extract fact timestamp $factId: $e');
        continue;
      }
    }

    factsWithTimestamp.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return factsWithTimestamp.map((item) => item.factId).toList();
  }

  /// List all card file paths, newest first (by date and ts)
  Future<List<String>> listAllCardFiles(String userId) async {
    final cardsPath = getCardsPath(userId);

    if (!await _baseService.exists(cardsPath)) {
      return [];
    }

    final cardFilesWithSortKey = <_CardFileSortKey>[];

    // Iterate year directories
    try {
      final yearItems = await _baseService.listDirectory(cardsPath);
      for (final yearItem in yearItems) {
        final yearPath = path.join(cardsPath, yearItem);
        if (!await _baseService.isDirectory(yearPath)) {
          continue;
        }

        final yearStr = path.basename(yearItem);
        if (!RegExp(r'^\d+$').hasMatch(yearStr)) {
          continue;
        }
        final year = int.parse(yearStr);

        // Iterate month directories
        final monthItems = await _baseService.listDirectory(yearPath);
        for (final monthItem in monthItems) {
          final monthPath = path.join(yearPath, monthItem);
          if (!await _baseService.isDirectory(monthPath)) {
            continue;
          }

          final monthStr = path.basename(monthItem);
          if (!RegExp(r'^\d+$').hasMatch(monthStr)) {
            continue;
          }
          final month = int.parse(monthStr);

          // Iterate all card files in this month
          final cardItems = await _baseService.listDirectory(monthPath);
          for (final cardItem in cardItems) {
            final cardPath = path.join(monthPath, cardItem);
            if (!await _baseService.isFile(cardPath)) {
              continue;
            }

            // Extract date and ts from filename (format: DD_ts_X.yaml)
            final filename = path.basenameWithoutExtension(cardItem);
            try {
              final dayTs = filename.split('_');
              if (dayTs.length < 2) {
                continue;
              }

              final day = int.parse(dayTs[0]);
              final tsPart = dayTs.sublist(1).join('_'); // ts_X

              // Extract ts number
              final tsMatch = RegExp(r'ts_(\d+)$').firstMatch(tsPart);
              if (tsMatch == null) {
                continue;
              }

              final tsNumber = int.parse(tsMatch.group(1)!);

              // Build sort key (date, ts number)
              final cardDate = DateTime(year, month, day);
              cardFilesWithSortKey.add(_CardFileSortKey(
                date: cardDate,
                tsNumber: tsNumber,
                path: cardPath,
              ));
            } catch (e) {
              _logger.warning('Failed to parse card filename $cardPath: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to list card files: $e');
      return [];
    }

    // Sort by key descending (newest first)
    cardFilesWithSortKey.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.tsNumber.compareTo(a.tsNumber);
    });

    // Return sorted file path list
    return cardFilesWithSortKey.map((item) => item.path).toList();
  }

  /// Extract raw content for the given fact_id from facts file. Returns FactContentResult or null if not found.
  Future<FactContentResult?> extractFactContentFromFile(
      String userId, String factId) async {
    // Parse date from fact_id
    final factDate = parseFactIdDate(factId);
    final simpleFactId = extractSimpleFactId(factId);

    // Read day's fact file and parse yaml
    try {
      final result = await readDailyFactFile(userId, factDate);
      final bodyContent = result.bodyContent;
      if (bodyContent.isEmpty) {
        return null;
      }

      // Find matching entry in body_content (format: ## <id:ts_3> HH:MM:SS). Pattern: ## <id:ts_3> or ## <id:2025/11/26.md#ts_3>
      final escapedFactId = RegExp.escape(simpleFactId);
      final pattern =
          RegExp('##\\s*<id:$escapedFactId>\\s*(\\d{2}:\\d{2}:\\d{2})');

      final match = pattern.firstMatch(bodyContent);
      if (match == null) {
        return null;
      }

      // Extract time string (HH:MM:SS)
      final timeStr = match.group(1)!;

      // Entry start position
      final startPos = match.start;

      // End of title line (after first newline)
      final titleEndPos = bodyContent.indexOf('\n', startPos);
      if (titleEndPos == -1) {
        return null;
      }

      // Skip title line and possible blank line to find actual content start
      var contentStartPos = titleEndPos + 1;
      // If next line is blank, skip it too
      if (contentStartPos < bodyContent.length &&
          bodyContent[contentStartPos] == '\n') {
        contentStartPos += 1;
      }

      // Find next entry start position (or end of file)
      final remainingContent = bodyContent.substring(contentStartPos);
      final nextMatch =
          RegExp(r'##\s*<id:ts_\d+>').firstMatch(remainingContent);
      final entryContent = nextMatch != null
          ? remainingContent.substring(0, nextMatch.start).trim()
          : remainingContent.trim();

      // Extract analysis result from media asset analysis files (image/audio markdown links)
      final assetAnalyses = <Map<String, dynamic>>[];
      final assetOcrTexts = <Map<String, dynamic>>[];
      final assetPattern =
          RegExp(r'(?:!\[(?:图片|image)\]|\[(?:音频|audio)\])\(fs://([^)]+)\)');
      final assetMatches = assetPattern.allMatches(entryContent);

      if (assetMatches.isNotEmpty) {
        // Getassetsdirectory path
        final assetsPath = getAssetsPath(userId);

        var idx = 1;
        for (final match in assetMatches) {
          final assetFile = match.group(1)!;
          try {
            // Read corresponding analysis file: {filename}.analysis.txt
            final analysisFilename = '$assetFile.analysis.txt';
            final analysisFilePath = path.join(assetsPath, analysisFilename);

            if (await _baseService.exists(analysisFilePath)) {
              final analysisContent =
                  (await _baseService.readFile(analysisFilePath)).trim();
              if (analysisContent.isNotEmpty) {
                assetAnalyses.add({
                  'index': idx,
                  'name': assetFile,
                  'analysis': analysisContent,
                });
              }
            }
          } catch (e) {
            _logger
                .warning('Failed to read asset analysis file $assetFile: $e');
          }

          // Read OCR text if .ocr.txt file exists
          try {
            final ocrFilename = '$assetFile.ocr.txt';
            final ocrFilePath = path.join(assetsPath, ocrFilename);

            if (await _baseService.exists(ocrFilePath)) {
              final ocrContent =
                  (await _baseService.readFile(ocrFilePath)).trim();
              if (ocrContent.isNotEmpty) {
                assetOcrTexts.add({
                  'index': idx,
                  'name': assetFile,
                  'ocr_text': ocrContent,
                });
              }
            }
          } catch (e) {
            _logger.warning('Failed to read OCR file for $assetFile: $e');
          }

          idx++;
        }
      }

      // Combine date and time into datetime
      final dateStr =
          '${factDate.year}-${factDate.month.toString().padLeft(2, '0')}-${factDate.day.toString().padLeft(2, '0')}';
      final datetimeStr = '$dateStr $timeStr';
      final entryDatetime = DateTime.parse(datetimeStr);
      final timestamp = entryDatetime.millisecondsSinceEpoch ~/ 1000;

      return FactContentResult(
        timestamp: timestamp,
        datetime: entryDatetime,
        content: entryContent,
        assetAnalyses: assetAnalyses,
        assetOcrTexts: assetOcrTexts,
      );
    } catch (e) {
      _logger.severe('Failed to extract fact content $factId: $e');
      return null;
    }
  }

  /// Get agent state directory path and ensure it exists (creates if not found).
  Future<String> getAgentStateDirectory(String userId) async {
    final stateDir = Directory(path.join(getSystemPath(userId), 'state_dir'));
    if (!stateDir.existsSync()) {
      stateDir.createSync(recursive: true);
      _logger.info('Created agent state directory: ${stateDir.path}');
    }
    return stateDir.path;
  }

  /// Convert factId to a filesystem-safe string (replace '/', '.', '#' with '_' for use in file names/paths).
  String makeFactIdSafe(String factId) {
    return factId
        .replaceAll('/', '_')
        .replaceAll('.', '_')
        .replaceAll('#', '_');
  }

  /// Get recently modified PKM files
  Future<List<Map<String, dynamic>>> getRecentPkmFiles(String userId,
      {int limit = 10}) async {
    final pkmPath = getPkmPath(userId);
    final dir = Directory(pkmPath);

    if (!await dir.exists()) {
      return [];
    }

    List<FileSystemEntity> entities = [];
    try {
      // Recursively get all files
      entities = await dir.list(recursive: true, followLinks: false).toList();
    } catch (e) {
      _logger.warning('Error listing PKM directory: $e');
      return [];
    }

    // Filter for files only, and .md extension
    final files = entities.whereType<File>().where((f) {
      final ext = path.extension(f.path).toLowerCase();
      // Exclude hidden files
      final name = path.basename(f.path);
      if (name.startsWith('.')) return false;
      return ext == '.md';
    }).toList();

    // Get stat for each file (async map)
    final List<Map<String, dynamic>> fileList = [];
    for (final file in files) {
      try {
        final stat = await file.stat();
        // Calculate relative path
        final relativePath = path.relative(file.path, from: pkmPath);

        fileList.add({
          'name': path.basename(file.path),
          'path': relativePath, // API expects relative path usually
          'modified': stat.modified.millisecondsSinceEpoch,
          'size': stat.size,
          // 'isAiGenerated': check content? too slow? Default false.
          'isAiGenerated': false, // TODO: Check metadata if needed
        });
      } catch (e) {
        // Ignore file error
      }
    }

    // Sort by modified desc
    fileList
        .sort((a, b) => (b['modified'] as int).compareTo(a['modified'] as int));

    // Take limit
    return fileList.take(limit).toList();
  }

  /// Grep PKM files by keyword — scans file names and content on disk.
  ///
  /// This is a brute-force search that reads every text file in the PKM
  /// directory. It does not depend on any index and always reflects the
  /// current file-system state.
  Future<List<Map<String, dynamic>>> grepPkmFiles(String userId, String query,
      {int limit = 50}) async {
    final pkmPath = getPkmPath(userId);
    final dir = Directory(pkmPath);

    if (!await dir.exists() || query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.trim().toLowerCase();
    final results = <Map<String, dynamic>>[];

    List<FileSystemEntity> entities = [];
    try {
      entities = await dir.list(recursive: true, followLinks: false).toList();
    } catch (e) {
      _logger.warning('Error listing PKM directory for grep: $e');
      return [];
    }

    final files = entities.whereType<File>().where((f) {
      final name = path.basename(f.path);
      return !name.startsWith('.');
    }).toList();

    for (final file in files) {
      if (results.length >= limit) break;
      final name = path.basename(file.path);
      final relativePath = path.relative(file.path, from: pkmPath);
      final nameMatch = name.toLowerCase().contains(lowerQuery);

      String? snippet;
      bool contentMatch = false;

      final ext = path.extension(file.path).toLowerCase();
      if (['.md', '.txt', '.json', '.yaml', '.yml'].contains(ext)) {
        try {
          final content = await file.readAsString();
          final lowerContent = content.toLowerCase();
          final idx = lowerContent.indexOf(lowerQuery);
          if (idx >= 0) {
            contentMatch = true;
            final start = (idx - 40).clamp(0, content.length);
            final end = (idx + query.length + 60).clamp(0, content.length);
            snippet = (start > 0 ? '...' : '') +
                content.substring(start, end).replaceAll('\n', ' ') +
                (end < content.length ? '...' : '');
          }
        } catch (_) {}
      }

      if (nameMatch || contentMatch) {
        results.add({
          'name': name,
          'path': relativePath,
          'is_directory': false,
          'snippet': snippet,
          'name_match': nameMatch,
        });
      }
    }

    return results;
  }

  /// Get count of child items under given PKM paths (batch).
  Future<Map<String, int>> countPkmItems(
      String userId, List<String> paths) async {
    final pkmRoot = getPkmPath(userId);
    final result = <String, int>{};

    // Mapping for English to Chinese PKM categories
    final Map<String, String> categoryMapping = {
      'Projects': '项目',
      'Areas': '领域',
      'Resources': '资源',
      'Archives': '归档',
    };

    for (final relativePath in paths) {
      int totalCount = 0;

      // Check both English and Chinese names if it's a known category
      List<String> pathsToCheck = [relativePath];
      if (categoryMapping.containsKey(relativePath)) {
        pathsToCheck.add(categoryMapping[relativePath]!);
      } else if (categoryMapping.containsValue(relativePath)) {
        // Find the English key for the Chinese value
        final engKey = categoryMapping.entries
            .firstWhere((e) => e.value == relativePath)
            .key;
        pathsToCheck.add(engKey);
      }

      // Track which paths we've already counted to avoid double counting if someone uses both
      final Set<String> checkedFullPaths = {};

      for (final pToCheck in pathsToCheck) {
        final fullPath = path.join(pkmRoot, pToCheck);
        if (checkedFullPaths.contains(fullPath)) continue;
        checkedFullPaths.add(fullPath);

        final dir = Directory(fullPath);
        if (await dir.exists()) {
          try {
            final entities =
                await dir.list(recursive: false, followLinks: false).toList();
            // Filter out hidden files
            final count = entities
                .where((e) => !path.basename(e.path).startsWith('.'))
                .length;
            totalCount += count;
          } catch (e) {
            _logger.warning('Error counting items in $fullPath: $e');
          }
        }
      }
      result[relativePath] = totalCount;
    }
    return result;
  }

  /// Record hashes that have been processed to avoid duplicates
  Future<void> recordProcessedHashes(String userId, List<String> hashes) async {
    if (hashes.isEmpty) return;

    final path = getProcessedHashesPath(userId);
    final List<String> existing = [];

    // Simple pseudo-locking string via file operation blocking
    try {
      if (await _baseService.exists(path)) {
        final content = await _baseService.readFile(path);
        if (content.isNotEmpty) {
          existing.addAll(content
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty));
        }
      }

      existing.addAll(hashes);
      final trimList = existing.length > 200
          ? existing.sublist(existing.length - 200)
          : existing;

      await _baseService.writeFile(path, trimList.join('\n'));
    } catch (e) {
      _logger.warning('Failed to record hashes: $e');
    }
  }

  /// Check which hashes have not been processed yet
  Future<List<String>> checkUnprocessedHashes(
      String userId, List<String> hashes) async {
    if (hashes.isEmpty) return [];
    final path = getProcessedHashesPath(userId);

    if (!await _baseService.exists(path)) return hashes;

    try {
      final content = await _baseService.readFile(path);
      // Use Set for O(N+M) lookup instead of O(N*M)
      final existingSet = content
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();

      return hashes.where((h) => !existingSet.contains(h)).toList();
    } catch (e) {
      _logger.warning('Failed to check hashes: $e');
      return hashes;
    }
  }
}

/// Card file sort key (internal class)
class _CardFileSortKey {
  final DateTime date;
  final int tsNumber;
  final String path;

  _CardFileSortKey({
    required this.date,
    required this.tsNumber,
    required this.path,
  });
}

/// Factcontentextractresult
class FactContentResult {
  final int timestamp;
  final DateTime datetime;
  final String content;
  final List<Map<String, dynamic>> assetAnalyses;

  /// On-device OCR text extracted from image assets.
  /// Each entry: {'index': int, 'name': String, 'ocr_text': String}.
  /// Populated from persisted `.ocr.txt` files.
  final List<Map<String, dynamic>> assetOcrTexts;

  FactContentResult({
    required this.timestamp,
    required this.datetime,
    required this.content,
    required this.assetAnalyses,
    this.assetOcrTexts = const [],
  });
}
