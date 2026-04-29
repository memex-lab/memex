import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:memex/db/app_database.dart';
import 'package:memex/db/daos/search_dao.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/data/services/task_handlers/fts_index_handler.dart';
import 'package:memex/utils/jieba.dart';
import 'package:memex/utils/logger.dart';

/// Service responsible for maintaining FTS5 full-text search indexes.
///
/// Follows the observer pattern: listens to [DataChangeRecord] events on the
/// [GlobalEventBus] and incrementally updates the corresponding FTS index.
/// Also bridges [FileOperationService] file-change callbacks into the event
/// bus so that PKM file mutations are captured regardless of call-site.
///
/// Architecture:
///   FileOperationService (infra) ──callback──▶ SearchService
///       ──publish DataChangeRecord──▶ GlobalEventBus
///       ──subscribe (EventTaskSubscription)──▶ LocalTaskExecutor
///       ──▶ fts_index_handler ──▶ SearchDao (db/daos)
///
/// Usage:
///   Called once during [MemexRouter._init] after DB and event bus are ready.
class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  final Logger _logger = getLogger('SearchService');

  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Wire up event subscriptions and file-change callback.
  /// Safe to call multiple times; only the first call takes effect.
  ///
  /// When FTS tables were just created via DB migration (existing users
  /// upgrading to schema v10), triggers a one-time full rebuild in the
  /// background so historical data gets indexed.
  void init(String userId) {
    if (_initialized) return;
    _initialized = true;

    // Jieba segmenter loads lazily on first use and auto-releases after idle.
    // No explicit initialization needed here.

    _subscribeToDataChanges();
    _bridgeFileOperationEvents(userId);

    // Check if a post-migration FTS rebuild is needed.
    if (AppDatabase.isInitialized && AppDatabase.instance.needsFtsRebuild) {
      AppDatabase.instance.clearFtsRebuildFlag();
      _logger.info(
          'FTS tables newly created via migration — scheduling full rebuild');
      // Fire-and-forget so app startup is not blocked.
      Future(() async {
        try {
          await rebuildAll(userId);
          _logger.info('Post-migration FTS rebuild completed');
        } catch (e) {
          _logger.warning('Post-migration FTS rebuild failed: $e');
        }
      });
    }
  }

  /// Reset state on logout so the next login re-initializes.
  void reset() {
    _initialized = false;
    FileOperationService.instance.onFileChanged = null;
    JiebaSegmenter.instance.dispose();
  }

  // ---------------------------------------------------------------------------
  // Query interface (delegates to SearchDao)
  // ---------------------------------------------------------------------------

  SearchDao? get _dao =>
      AppDatabase.isInitialized ? AppDatabase.instance.searchDao : null;

  /// Search PKM knowledge-base files using multiple strategies:
  ///   1. FTS5 index search (fast, tokenized)
  ///   2. Card FTS → fact_id association (finds PKM files linked to matching cards)
  ///   3. File-system grep (brute-force content scan, always available)
  /// Results are deduplicated by file path.
  Future<List<Map<String, dynamic>>> searchPkmFiles(String userId, String query,
      {int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final seenPaths = <String>{};
    final results = <Map<String, dynamic>>[];
    final fs = FileSystemService.instance;
    final pkmPath = fs.getPkmPath(userId);

    // Strategy 1: File-system grep (exact substring match — highest relevance)
    try {
      final grepResults = await fs.grepPkmFiles(userId, trimmed, limit: limit);
      for (final r in grepResults) {
        final filePath = r['path'] as String;
        if (seenPaths.add(filePath)) {
          results.add(r);
        }
      }
    } catch (e) {
      _logger.warning('File grep search failed: $e');
    }

    // Strategy 2 & 3: FTS index search + card fact_id association
    // Appended after grep results; deduped by path.
    if (results.length < limit) {
      try {
        final dao = _dao;
        if (dao != null) {
          await JiebaSegmenter.instance.ensureLoaded();

          final candidatePaths = <String>[];

          // 2a. Direct PKM FTS match
          final ftsResults = await dao.searchPkmFiles(trimmed, limit: limit);
          for (final r in ftsResults) {
            candidatePaths.add(r['path'] as String);
          }

          // 2b. Card FTS → fact_id → associated PKM files
          if (candidatePaths.length < limit) {
            final remaining = limit - candidatePaths.length;
            final cardResults =
                await dao.searchCards(trimmed, limit: remaining);
            if (cardResults.isNotEmpty) {
              final factIds = cardResults
                  .map((r) => r['fact_id'] as String)
                  .toSet()
                  .toList();
              final associated = await findPkmFilesByFactIds(userId, factIds,
                  limit: limit - candidatePaths.length);
              for (final f in associated) {
                candidatePaths.add(f['path'] as String);
              }
            }
          }

          for (final relativePath in candidatePaths) {
            if (results.length >= limit) break;
            if (!seenPaths.add(relativePath)) continue;
            try {
              final result =
                  await _buildResultFromFile(pkmPath, relativePath, trimmed);
              if (result != null) results.add(result);
            } catch (_) {}
          }
        }
      } catch (e) {
        _logger.warning('FTS search failed: $e');
      }
    }

    return results.take(limit).toList();
  }

  /// Search timeline cards. Returns ranked results with snippets.
  Future<List<Map<String, dynamic>>> searchCards(String query,
      {int limit = 50}) async {
    return await _dao?.searchCards(query, limit: limit) ?? [];
  }

  /// Find PKM files that reference any of the given fact_ids.
  /// Uses file-system grep because fact_id markers contain special characters
  /// that get broken up by FTS tokenization.
  Future<List<Map<String, dynamic>>> findPkmFilesByFactIds(
      String userId, List<String> factIds,
      {int limit = 20}) async {
    if (factIds.isEmpty) return [];
    final fs = FileSystemService.instance;
    final seenPaths = <String>{};
    final results = <Map<String, dynamic>>[];
    for (final fid in factIds) {
      if (results.length >= limit) break;
      final matches =
          await fs.grepPkmFiles(userId, fid, limit: limit - results.length);
      for (final m in matches) {
        final path = m['path'] as String;
        if (seenPaths.add(path)) results.add(m);
      }
    }
    return results;
  }

  /// Read the original file and build a search result map with a raw snippet,
  /// identical to what [FileSystemService.grepPkmFiles] produces.
  Future<Map<String, dynamic>?> _buildResultFromFile(
      String pkmPath, String relativePath, String query) async {
    final absPath = '$pkmPath/$relativePath';
    final file = File(absPath);
    if (!await file.exists()) return null;

    final name = relativePath.contains('/')
        ? relativePath.substring(relativePath.lastIndexOf('/') + 1)
        : relativePath;
    final nameMatch = name.toLowerCase().contains(query.toLowerCase());

    String? snippet;
    final ext = p.extension(absPath).toLowerCase();
    if (['.md', '.txt', '.json', '.yaml', '.yml'].contains(ext)) {
      try {
        final content = await file.readAsString();
        final lowerContent = content.toLowerCase();
        final lowerQuery = query.toLowerCase();

        // Try exact match first
        var idx = lowerContent.indexOf(lowerQuery);

        // If no exact match, find the first query word that appears
        if (idx < 0) {
          final words = JiebaSegmenter.instance.isLoaded
              ? JiebaSegmenter.instance.cut(query)
              : query.split(' ');
          for (final w in words) {
            final tw = w.trim().toLowerCase();
            if (tw.isEmpty) continue;
            idx = lowerContent.indexOf(tw);
            if (idx >= 0) break;
          }
        }

        if (idx >= 0) {
          final start = (idx - 40).clamp(0, content.length);
          final end = (idx + query.length + 60).clamp(0, content.length);
          snippet = (start > 0 ? '...' : '') +
              content.substring(start, end).replaceAll('\n', ' ') +
              (end < content.length ? '...' : '');
        } else if (content.isNotEmpty) {
          // No token found (index out of sync?) — show file beginning
          final end = content.length.clamp(0, 100);
          snippet = content.substring(0, end).replaceAll('\n', ' ') +
              (content.length > 100 ? '...' : '');
        }
      } catch (_) {}
    }

    return {
      'name': name,
      'path': relativePath,
      'is_directory': false,
      'snippet': snippet,
      'name_match': nameMatch,
    };
  }

  // ---------------------------------------------------------------------------
  // Full rebuild (manual trigger from debug page)
  // ---------------------------------------------------------------------------

  /// Rebuild all FTS indexes from scratch (cards + PKM files).
  Future<void> rebuildAll(String userId) async {
    await rebuildCardFtsIndex(userId);
    await rebuildPkmFtsIndex(userId);
  }

  /// Rebuild the card FTS index by scanning all card files independently.
  Future<void> rebuildCardFtsIndex(String userId) async {
    final dao = _dao;
    if (dao == null) return;
    _logger.info('Rebuilding card FTS index for user $userId');

    // Ensure jieba is loaded for tokenization during rebuild
    await JiebaSegmenter.instance.ensureLoaded();
    await dao.clearCardFts();
    final fs = FileSystemService.instance;
    final cardFiles = await fs.listAllCardFiles(userId);

    int count = 0;
    for (final cardFile in cardFiles) {
      try {
        final factId = fs.factIdFromCardPath(cardFile);
        if (factId == null) continue;

        final cardData = await fs.readCardFile(userId, factId);
        if (cardData == null || cardData.deleted == true) continue;

        final factInfo = await fs.extractFactContentFromFile(userId, factId);
        final rawContent = factInfo?.content ?? '';
        final assetAnalysisTexts = (factInfo?.assetAnalyses ?? [])
            .map((a) => a['analysis'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        final assetText = assetAnalysisTexts.join(' ');
        final assetOcrTexts = (factInfo?.assetOcrTexts ?? [])
            .map((a) => a['ocr_text'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        final ocrText = assetOcrTexts.join(' ');
        final combined = [rawContent, assetText, ocrText]
            .where((s) => s.isNotEmpty)
            .join(' ');

        await dao.upsertCardFts(
          factId: factId,
          title: cardData.title ?? '',
          tags: cardData.tags.join(' '),
          content: combined,
          insight: cardData.insight?.text ?? '',
        );
        count++;
      } catch (e) {
        _logger.warning('Error indexing card file $cardFile: $e');
      }
    }
    _logger.info('Card FTS rebuild complete. Indexed $count cards.');
  }

  /// Rebuild only the PKM FTS index by scanning all PKM files.
  Future<void> rebuildPkmFtsIndex(String userId) async {
    final dao = _dao;
    if (dao == null) return;
    _logger.info('Rebuilding PKM FTS index for user $userId');

    // Ensure jieba is loaded for tokenization during rebuild
    await JiebaSegmenter.instance.ensureLoaded();
    await dao.clearPkmFts();
    final fs = FileSystemService.instance;
    final pkmPath = fs.getPkmPath(userId);
    final dir = Directory(pkmPath);
    if (!await dir.exists()) return;

    List<FileSystemEntity> entities = [];
    try {
      entities = await dir.list(recursive: true, followLinks: false).toList();
    } catch (e) {
      _logger.warning('Error listing PKM directory for FTS rebuild: $e');
      return;
    }

    int count = 0;
    for (final file in entities.whereType<File>()) {
      final name = p.basename(file.path);
      if (name.startsWith('.')) continue;
      try {
        final relativePath = p.relative(file.path, from: pkmPath);
        final ext = p.extension(file.path).toLowerCase();
        String content = '';
        if (['.md', '.txt', '.json', '.yaml', '.yml'].contains(ext)) {
          try {
            content = await file.readAsString();
          } catch (_) {}
        }
        await dao.upsertPkmFts(
          filePath: relativePath,
          fileName: name,
          content: content,
        );
        count++;
      } catch (e) {
        _logger.warning('Error indexing PKM file ${file.path}: $e');
      }
    }
    _logger.info('PKM FTS rebuild complete. Indexed $count files.');
  }

  // ---------------------------------------------------------------------------
  // Event subscription (consumer side) — uses persistent task queue
  // ---------------------------------------------------------------------------

  /// Subscribe to dataChanged events via the persistent task queue.
  /// Tasks survive app restarts — if the app is killed before FTS is updated,
  /// the task will be retried on next launch.
  void _subscribeToDataChanges() {
    GlobalEventBus.instance.subscribe(
      eventType: SystemEventTypes.dataChanged,
      subscription: EventTaskSubscription(
        subscriptionId: 'fts_index_update',
        taskType: 'fts_index_update',
        priority: -1, // Lower priority than agent tasks
        maxRetries: 3,
        payloadBuilder: (_, event) async {
          final record = event.payload as DataChangeRecord;
          return dataChangeRecordToPayload(record);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // File-change bridge (producer side)
  // ---------------------------------------------------------------------------

  /// Hook into [FileOperationService.onFileChanged] and translate file-system
  /// mutations inside the PKM directory into [DataChangeRecord] events.
  void _bridgeFileOperationEvents(String userId) {
    final pkmRoot = FileSystemService.instance.getPkmPath(userId);

    FileOperationService.instance.onFileChanged =
        (String filePath, String changeType, {String? oldFilePath}) {
      final inPkm = filePath.startsWith(pkmRoot);
      final oldInPkm = oldFilePath != null && oldFilePath.startsWith(pkmRoot);
      if (!inPkm && !oldInPkm) return;

      // Fire-and-forget publish
      Future(() async {
        try {
          await _publishPkmFileChange(
              userId, pkmRoot, filePath, changeType, oldFilePath);
        } catch (e) {
          _logger.warning('Failed to publish PKM dataChanged event: $e');
        }
      });
    };
  }

  Future<void> _publishPkmFileChange(String userId, String pkmRoot,
      String filePath, String changeType, String? oldFilePath) async {
    final bus = GlobalEventBus.instance;

    if (changeType == 'moved') {
      // A move is modeled as delete(old) + insert(new), same as oplog.
      if (oldFilePath != null && oldFilePath.startsWith(pkmRoot)) {
        await bus.publish(
          userId: userId,
          event: SystemEvent<DataChangeRecord>(
            type: SystemEventTypes.dataChanged,
            source: 'file_operation_service',
            payload: DataChangeRecord(
              op: DataChangeOp.delete,
              ns: DataChangeNs.pkmFile,
              documentKey: _pkmRelative(pkmRoot, oldFilePath),
            ),
          ),
        );
      }
      if (filePath.startsWith(pkmRoot)) {
        await bus.publish(
          userId: userId,
          event: SystemEvent<DataChangeRecord>(
            type: SystemEventTypes.dataChanged,
            source: 'file_operation_service',
            payload: DataChangeRecord(
              op: DataChangeOp.insert,
              ns: DataChangeNs.pkmFile,
              documentKey: _pkmRelative(pkmRoot, filePath),
              fullDocument: await _readPkmDocument(filePath),
            ),
          ),
        );
      }
      return;
    }

    final rel = _pkmRelative(pkmRoot, filePath);

    if (changeType == 'deleted') {
      await bus.publish(
        userId: userId,
        event: SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'file_operation_service',
          payload: DataChangeRecord(
            op: DataChangeOp.delete,
            ns: DataChangeNs.pkmFile,
            documentKey: rel,
          ),
        ),
      );
    } else {
      await bus.publish(
        userId: userId,
        event: SystemEvent<DataChangeRecord>(
          type: SystemEventTypes.dataChanged,
          source: 'file_operation_service',
          payload: DataChangeRecord(
            op: changeType == 'created'
                ? DataChangeOp.insert
                : DataChangeOp.update,
            ns: DataChangeNs.pkmFile,
            documentKey: rel,
            fullDocument: await _readPkmDocument(filePath),
          ),
        ),
      );
    }
  }

  String _pkmRelative(String pkmRoot, String absPath) =>
      absPath.substring(pkmRoot.length).replaceAll(RegExp(r'^/'), '');

  Future<Map<String, dynamic>> _readPkmDocument(String absPath) async {
    final ext = p.extension(absPath).toLowerCase();
    String content = '';
    if (['.md', '.txt', '.json', '.yaml', '.yml'].contains(ext)) {
      try {
        content = await File(absPath).readAsString();
      } catch (_) {}
    }
    return {
      'file_name': p.basename(absPath),
      'absolute_path': absPath,
      'content': content,
    };
  }
}
