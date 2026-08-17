import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:synchronized/synchronized.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:memex/data/services/asset_safety_service.dart';
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

class TimelineTemplateFieldMeta {
  final String name;
  final String type;
  final bool required;
  final String description;

  const TimelineTemplateFieldMeta({
    required this.name,
    required this.type,
    required this.required,
    required this.description,
  });

  factory TimelineTemplateFieldMeta.fromJson(Map<String, dynamic> json) {
    return TimelineTemplateFieldMeta(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      required: json['required'] == true,
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'required': required,
      'description': description,
    };
  }
}

class TimelineTemplateMeta {
  final String templateId;
  final String description;
  final String useCase;
  final List<TimelineTemplateFieldMeta> fields;

  const TimelineTemplateMeta({
    required this.templateId,
    required this.description,
    required this.useCase,
    required this.fields,
  });

  factory TimelineTemplateMeta.fromJson(
    String templateId,
    Map<String, dynamic> json,
  ) {
    final rawFields = json['fields'];
    return TimelineTemplateMeta(
      templateId: templateId,
      description: json['description']?.toString() ?? '',
      useCase: json['use_case']?.toString() ?? '',
      fields: rawFields is List
          ? rawFields
              .whereType<Map>()
              .map((field) => TimelineTemplateFieldMeta.fromJson(
                    Map<String, dynamic>.from(field),
                  ))
              .toList()
          : const [],
    );
  }

  List<String> get fieldNames => fields.map((field) => field.name).toList();

  String get dataStructure {
    return fields
        .map(
          (field) =>
              '- `${field.name}` (${field.type}, ${field.required ? "required" : "optional"}): ${field.description}',
        )
        .join('\n');
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'use_case': useCase,
      'data_structure': dataStructure,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}

class TimelineTemplateCardUsage {
  final String cardId;
  final Map<String, dynamic> data;

  const TimelineTemplateCardUsage({
    required this.cardId,
    required this.data,
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

  /// Serializes filename allocation + copy for daily captured assets so two
  /// concurrent saves on the same day can't pick the same `no_` index.
  final Lock _dailyAssetLock = Lock();

  /// Serializes card fact_id allocation so two concurrent saves on the same
  /// day can't pick the same `ts_N` slot.
  final Lock _cardFactIdLock = Lock();

  /// Serializes updates to the user's reusable location marks file.
  final Lock _userLocationsLock = Lock();

  /// Flag to indicate if a rebuild is in progress to prevent recursion
  bool _isRebuilding = false;

  static DateTime? _lastServerCheckTime;
  static FileSystemService? _instance;

  static bool get isInitialized => _instance != null;

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

  /// Creates a file-system service for background workers without replacing
  /// the app singleton or starting the local asset server.
  factory FileSystemService.detached({required String dataRoot}) {
    return FileSystemService._(dataRoot: dataRoot);
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

  /// Path for storing hashes of user-submitted media/text used by lightweight
  /// local duplicate filters such as photo suggestions.
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
      // Capture prior data ONCE before running updateFn.
      final priorData = await readCardFile(userId, cardId);

      CardData currentData;
      final DataChangeOp op;
      final Map<String, dynamic>? beforeMap;

      if (priorData == null) {
        if (createIfNotExists) {
          // No prior file and caller wants creation → insert.
          currentData = _buildProcessingPlaceholderCard(
            cardId,
            DateTime.now(),
          );
          op = DataChangeOp.insert;
          beforeMap = null;
        } else {
          // Corrupt YAML / unreadable prior file: keep op == update,
          // before == null (R1.7 semantics).
          _logger.warning('Card not found for update: $cardId');
          return null;
        }
      } else {
        currentData = priorData;
        op = DataChangeOp.update;
        beforeMap = priorData.toJson();
      }

      final updatedData = updateFn(currentData);
      final success = await _safeWriteCardFileInternal(
          userId, cardId, updatedData,
          beforeSnapshot: beforeMap, op: op);
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
      final previous = await readCardFile(userId, cardId);
      final beforeMap = previous?.toJson();
      final op = previous == null ? DataChangeOp.insert : DataChangeOp.update;
      return await _safeWriteCardFileInternal(userId, cardId, data,
          beforeSnapshot: beforeMap, op: op);
    });
  }

  /// Publish a card-change event via [GlobalEventBus].
  ///
  /// Asserts the card-path invariant: at least one of [before] / [after] must
  /// be non-null. Catches and warn-logs any publish failure so it never
  /// propagates to the write caller.
  Future<void> _publishCardChange({
    required String userId,
    required DataChangeOp op,
    required String factId,
    required Map<String, dynamic>? before,
    required Map<String, dynamic>? after,
  }) async {
    assert(before != null || after != null,
        'Card publish invariant violated: both before and after are null');
    try {
      await GlobalEventBus.instance.publish(
        userId: userId,
        event: SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'file_system_service',
          payload: DataChangeRecord(
            op: op,
            ns: DataChangeNs.card,
            documentKey: factId,
            before: before,
            after: after,
          ),
        ),
      );
    } catch (e) {
      _logger.warning('Failed to publish card change event for $factId: $e');
    }
  }

  /// Internal write (no lock; caller must hold lock).
  ///
  /// On success, updates the card cache and publishes the raw card snapshot via
  /// [_publishCardChange].
  Future<bool> _safeWriteCardFileInternal(
      String userId, String cardId, CardData data,
      {Map<String, dynamic>? beforeSnapshot, required DataChangeOp op}) async {
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

      final afterMap = data.toJson();

      // Update the Drift cache row.
      await updateCardCache(userId, cardId, data);

      // Publish the change event with before/after snapshots.
      await _publishCardChange(
        userId: userId,
        op: op,
        factId: cardId,
        before: beforeSnapshot,
        after: afterMap,
      );

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

      final timestamp = cardData.createdAt ?? cardData.timestamp;

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

      // NOTE: Publish responsibility now belongs to _safeWriteCardFileInternal.
      // updateCardCache is also called from rebuildCardCache where we do NOT
      // want to emit change events, so keeping publish here was a latent bug.
    } catch (e) {
      _logger.warning('Failed to update card cache for $factId: $e');
    }
  }

  /// Delete a card physically and from cache
  Future<bool> deleteCard(String userId, String cardId) async {
    final lock = await _getCardLock(userId, cardId);
    return lock.synchronized(() async {
      try {
        // Read the previous file for the before snapshot.
        final previous = await readCardFile(userId, cardId);

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
          } catch (e) {
            _logger.warning('Failed to delete card from cache $cardId: $e');
          }

          // Publish delete event only when we had a previous state.
          // Deleting a file that never existed has no observable data change.
          if (previous != null) {
            await _publishCardChange(
              userId: userId,
              op: DataChangeOp.delete,
              factId: cardId,
              before: previous.toJson(),
              after: null,
            );
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

  /// List to YAML string (manual impl, aligned with [_mapToYamlString]).
  String _listToYamlString(List<dynamic> list, {int indent = 0}) {
    final buffer = StringBuffer();
    final indentStr = '  ' * indent;

    for (final item in list) {
      if (item is Map) {
        if (item.isEmpty) {
          buffer.writeln('$indentStr- {}');
        } else {
          buffer.writeln('$indentStr-');
          buffer.write(_mapToYamlString(Map<String, dynamic>.from(item),
              indent: indent + 1));
        }
      } else {
        buffer.writeln('$indentStr- ${_valueToString(item)}');
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

  /// Imported source files waiting for optional agent organization.
  String getImportedFilesPath(String userId) {
    return path.join(getUserSettingsPath(userId), 'Imported');
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

  String getProfileMetaPath(String userId) {
    return path.join(getUserSettingsPath(userId), 'profile.json');
  }

  Future<Map<String, dynamic>> readProfileMeta(String userId) async {
    try {
      final filePath = getProfileMetaPath(userId);
      if (!await _baseService.exists(filePath)) {
        return {};
      }

      final content = await _baseService.readFile(filePath);
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (e) {
      _logger.warning('Failed to read profile meta: $e');
    }
    return {};
  }

  Future<void> writeProfileMeta(
      String userId, Map<String, dynamic> profileMeta) async {
    final settingsPath = getUserSettingsPath(userId);
    await ensureDirectory(settingsPath);
    final filePath = getProfileMetaPath(userId);
    const encoder = JsonEncoder.withIndent('  ');
    await _baseService.writeFile(filePath, encoder.convert(profileMeta));
  }

  /// Comment settings file path
  String getCommentSettingsPath(String userId) {
    return path.join(getUserSettingsPath(userId), 'comment_settings.yaml');
  }

  /// Add or update a user reusable location mark.
  Future<bool> addUserLocation(
      String userId, double lat, double lng, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return false;
    }

    return _userLocationsLock.synchronized(() async {
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
              locations = yamlDoc
                  .map((e) => _yamlToMap(e))
                  .toList()
                  .cast<Map<String, dynamic>>();
            }
          } catch (e) {
            _logger.warning('Failed to read existing user locations: $e');
          }
        }

        final newLocation = {
          'lat': lat,
          'lng': lng,
          'name': trimmedName,
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };

        var updated = false;
        for (var i = 0; i < locations.length; i++) {
          if (locations[i]['name'] == trimmedName) {
            locations[i] = newLocation;
            updated = true;
            break;
          }
        }

        if (!updated) {
          locations.add(newLocation);
        }

        await _baseService.writeFile(
          locationsFile,
          _listToYamlString(locations),
        );
        return true;
      } catch (e) {
        _logger.severe('Failed to add user location: $e');
        return false;
      }
    });
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

  /// Get_Systemdirectory path
  String getSystemPath(String userId) {
    return path.join(getWorkspacePath(userId), '_System');
  }

  /// Root for private, character-owned workspaces.
  String getCharacterWorkspacesPath(String userId) {
    return path.join(getSystemPath(userId), 'character_workspaces');
  }

  String getCharacterWorkspacePath(String userId, String characterId) {
    return path.join(getCharacterWorkspacesPath(userId), characterId);
  }

  String getCharacterIdentityPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'Identity.md',
    );
  }

  String getCharacterWorldPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'World',
    );
  }

  String getCharacterPkmPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'PKM',
    );
  }

  String getCharacterJournalPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'Journal',
    );
  }

  String getCharacterHistoryAcquaintancePath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'history_acquaintance.json',
    );
  }

  String getCharacterUserMemoryEntriesPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterPkmPath(userId, characterId),
      'user_provided_memories.jsonl',
    );
  }

  String getCharacterImportedRelationshipPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterPkmPath(userId, characterId),
      'imported_relationship.md',
    );
  }

  String getCharacterUserWorldEntriesPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterWorldPath(userId, characterId),
      'user_provided_world.jsonl',
    );
  }

  String getCharacterPendingThoughtsPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'pending_thoughts.jsonl',
    );
  }

  String getLegacyCharacterMemoryPath(String userId, String characterId) {
    return path.join(getSystemPath(userId), 'character_memory', characterId);
  }

  String getLegacyCharactersPath(String userId) {
    return path.join(getWorkspacePath(userId), 'Characters');
  }

  String getLegacyCharacterRelationshipPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getLegacyCharactersPath(userId),
      '${characterId}_relationship.md',
    );
  }

  String getLegacyCharacterMemoryEntriesPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getLegacyCharacterMemoryPath(userId, characterId),
      'memory_entries.jsonl',
    );
  }

  String getLegacyCharacterWorldEntriesPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getLegacyCharacterMemoryPath(userId, characterId),
      'world_entries.jsonl',
    );
  }

  String getCharacterInboxPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'inbox.jsonl',
    );
  }

  String getCharacterInteractionIndexPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'interaction_index.jsonl',
    );
  }

  String getCharacterRuntimePath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'runtime.json',
    );
  }

  String getCharacterConversationPath(String userId, String characterId) {
    return path.join(
      getCharacterWorkspacePath(userId, characterId),
      'Conversation',
    );
  }

  String getCharacterConversationMessagesPath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterConversationPath(userId, characterId),
      'messages.jsonl',
    );
  }

  String getCharacterConversationStatePath(
    String userId,
    String characterId,
  ) {
    return path.join(
      getCharacterConversationPath(userId, characterId),
      'state.json',
    );
  }

  /// Unified media pool directory — all user-uploaded images/audio/etc.
  /// land here with a canonical filename (see [MediaService]).
  String getMediaPath(String userId) {
    return path.join(getSystemPath(userId), 'media');
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
    return path.join(getUserSettingsPath(userId), 'Templates');
  }

  /// Knowledge insights card templates directory path
  String getKnowledgeInsightsCardTemplatesPath(String userId) {
    return path.join(getSystemPath(userId), 'KnowledgeInsightsCardTemplates');
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

  /// Generate a filename for a captured asset.
  String _generateAssetFilename(
    String assetType,
    int index,
    String extension, {
    String? extraInfo,
    DateTime? date,
  }) {
    // Records are now captured through Super Agent chat before a card fact_id
    // exists. Store assets under a stable daily `ts_0` namespace; cards later
    // reference these files by `fs://` id.
    final now = date ?? DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final dateStr = '$year$month$day';

    final extraPart = extraInfo != null ? '_$extraInfo' : '';
    return '${assetType}_${dateStr}_ts_0_no_$index$extraPart.$extension';
  }

  /// Save asset from file (direct copy, no Base64). Returns (filename, relativePath) under dataRoot.
  Future<(String, String)> saveAssetFromFile({
    required String userId,
    required String sourcePath,
    required String assetType,
    String? format,
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
          final safety =
              await AssetSafetyService.instance.inspectFile(sourcePath);
          if (safety.width != null && safety.height != null) {
            extraInfo = '${safety.width}x${safety.height}';
          }
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

    Future<(String, String)> doSave(int resolvedIndex, DateTime? date) async {
      final filename = _generateAssetFilename(
        assetType,
        resolvedIndex,
        extension,
        extraInfo: extraInfo,
        date: date,
      );
      final absolutePath = path.join(assetsPath, filename);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw ApiException('Source file not found: $sourcePath');
      }
      await sourceFile.copy(absolutePath);

      // Convert to relative path to avoid iOS Application ID change issue
      final relativePath = toRelativePath(absolutePath);
      _logger.info('Copied asset from $sourcePath to $absolutePath');
      return (filename, relativePath);
    }

    try {
      // Captured assets are named by today's date + ts_0; their `no_` index is
      // the running count of files for the day. Allocate the index and copy
      // under a lock so concurrent saves can't collide on the same name.
      return await _dailyAssetLock.synchronized(() async {
        final now = DateTime.now();
        final nextIndex = await _nextDailyAssetIndex(assetsPath, now);
        return doSave(nextIndex, now);
      });
    } catch (e) {
      _logger.severe('Failed to save asset file: $e');
      rethrow;
    }
  }

  /// Next running `no_` index for daily captured assets on [date].
  ///
  /// Scans [assetsPath] for files named `*_<YYYYMMDD>_ts_0_no_<N>*` (both
  /// image and audio share one daily counter, so the index reflects "the Nth
  /// file captured today") and returns the highest N seen plus one, starting
  /// at 1. Must be called while holding [_dailyAssetLock].
  Future<int> _nextDailyAssetIndex(String assetsPath, DateTime date) async {
    final dateStr = '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final pattern = RegExp('_${dateStr}_ts_0_no_(\\d+)');

    final dir = Directory(assetsPath);
    if (!await dir.exists()) return 1;

    var maxIndex = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final match = pattern.firstMatch(path.basename(entity.path));
      if (match == null) continue;
      final n = int.tryParse(match.group(1)!) ?? 0;
      if (n > maxIndex) maxIndex = n;
    }
    return maxIndex + 1;
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

  /// Allocate a fresh fact_id for a brand-new card on the current local day.
  ///
  /// Cards are created directly through SuperAgent, so the id space is driven
  /// by the Cards directory: this scans existing cards for the day
  /// (`Cards/YYYY/MM/DD_ts_N.yaml`), takes the max `ts_N` + 1, and immediately
  /// reserves the slot by writing a `processing` placeholder card so two
  /// concurrent saves on the same day can't pick the same id. The caller
  /// overwrites the placeholder with the real card via [updateCardFile].
  Future<String> allocateCardFactId(String userId) async {
    return _cardFactIdLock.synchronized(() async {
      final now = DateTime.now().toLocal();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      var maxTs = 0;

      // Existing cards: Cards/YYYY/MM/DD_ts_N.yaml
      final monthDir = path.join(getCardsPath(userId), year, month);
      if (await _baseService.exists(monthDir) &&
          await _baseService.isDirectory(monthDir)) {
        try {
          final pattern = RegExp('^${day}_ts_(\\d+)\\.yaml\$');
          for (final item in await _baseService.listDirectory(monthDir)) {
            final m = pattern.firstMatch(path.basename(item));
            if (m != null) {
              final n = int.tryParse(m.group(1)!) ?? 0;
              if (n > maxTs) maxTs = n;
            }
          }
        } catch (e) {
          _logger.warning('Failed to scan cards for fact_id allocation: $e');
        }
      }

      final factId = '$year/$month/$day.md#ts_${maxTs + 1}';

      // Reserve the slot so a concurrent allocation advances past it.
      await safeWriteCardFile(
        userId,
        factId,
        _buildProcessingPlaceholderCard(factId, now),
      );

      return factId;
    });
  }

  CardData _buildProcessingPlaceholderCard(String factId, DateTime createdAt) {
    final timestamp = createdAt.millisecondsSinceEpoch ~/ 1000;
    return CardData(
      factId: factId,
      createdAt: timestamp,
      timestamp: timestamp,
      status: 'processing',
      tags: const [],
      uiConfigs: const [
        UiConfig(templateId: 'classic_card', data: {'content': ''}),
      ],
    );
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

  Future<TimelineTemplateMeta?> readTimelineTemplateMeta(
    String userId,
    String templateId,
  ) async {
    final metaPath =
        path.join(getTemplatePath(userId, templateId), 'meta.json');
    if (!await _baseService.exists(metaPath)) {
      return null;
    }

    try {
      final content = await _baseService.readFile(metaPath);
      final decoded = jsonDecode(content);
      if (decoded is! Map) return null;
      return TimelineTemplateMeta.fromJson(
        templateId,
        Map<String, dynamic>.from(decoded),
      );
    } catch (e) {
      _logger.severe('Failed to read timeline template meta $metaPath: $e');
      return null;
    }
  }

  Future<void> saveTimelineTemplateMeta({
    required String userId,
    required String templateId,
    required String description,
    required String useCase,
    required List<TimelineTemplateFieldMeta> fields,
  }) async {
    final templatePath = getTemplatePath(userId, templateId);
    await ensureDirectory(templatePath);

    final metaPath = path.join(templatePath, 'meta.json');
    const encoder = JsonEncoder.withIndent('  ');
    await _baseService.writeFile(
      metaPath,
      '${encoder.convert(TimelineTemplateMeta(
        templateId: templateId,
        description: description,
        useCase: useCase,
        fields: fields,
      ).toJson())}\n',
    );
  }

  Future<List<TimelineTemplateMeta>> listTimelineTemplateMetas(
      String userId) async {
    final templatesPath = getTemplatesPath(userId);
    if (!await _baseService.exists(templatesPath)) {
      return const [];
    }

    final metas = <TimelineTemplateMeta>[];
    try {
      final items = await _baseService.listDirectory(templatesPath);
      for (final item in items) {
        final templatePath = path.join(templatesPath, item);
        if (!await _baseService.isDirectory(templatePath)) continue;
        final templateId = path.basename(item);
        final meta = await readTimelineTemplateMeta(userId, templateId);
        if (meta != null) {
          metas.add(meta);
        }
      }
    } catch (e) {
      _logger.warning('Failed to list timeline template metas: $e');
    }
    metas.sort((a, b) => a.templateId.compareTo(b.templateId));
    return metas;
  }

  Future<List<TimelineTemplateCardUsage>> findCardTemplateUsages(
    String userId,
    String templateId,
  ) async {
    final cardPaths = await listAllCardFiles(userId);
    final cardsPath = getCardsPath(userId);
    final result = <TimelineTemplateCardUsage>[];

    for (final cardPath in cardPaths) {
      try {
        final content = await _baseService.readFile(cardPath);
        final raw = _parseYaml(content);
        if (raw.isEmpty) continue;
        final card = CardData.fromJson(Map<String, dynamic>.from(raw));
        final matchingConfigs = card.uiConfigs
            .where((config) => config.templateId == templateId)
            .toList();
        if (matchingConfigs.isEmpty) {
          continue;
        }
        final relative = path.relative(cardPath, from: cardsPath);
        final parts = path.split(relative);
        var cardId = card.factId;
        if (parts.length != 3) {
          cardId = card.factId;
        } else {
          final year = parts[0];
          final month = parts[1];
          final filename = path.basenameWithoutExtension(parts[2]);
          final match = RegExp(r'^(\d{2})_(ts_\d+)$').firstMatch(filename);
          if (match != null) {
            cardId = '$year/$month/${match.group(1)}.md#${match.group(2)}';
          }
        }

        for (final config in matchingConfigs) {
          result.add(TimelineTemplateCardUsage(
            cardId: cardId,
            data: config.data,
          ));
        }
      } catch (e) {
        _logger.warning('Failed to inspect card template usage $cardPath: $e');
      }
    }

    return result;
  }

  Future<String?> readKnowledgeInsightCardTemplateHtml(
      String userId, String templateId) async {
    final templatesPath = getKnowledgeInsightsCardTemplatesPath(userId);
    final templatePath = path.join(templatesPath, templateId);
    final viewPath = path.join(templatePath, 'view.html');

    if (!await _baseService.exists(viewPath)) {
      return null;
    }

    try {
      return await _baseService.readFile(viewPath);
    } catch (e) {
      _logger.severe(
          'Failed to read knowledge insight card template HTML $viewPath: $e');
      return null;
    }
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
