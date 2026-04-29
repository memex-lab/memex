import 'package:logging/logging.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/db/daos/search_dao.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/jieba.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/domain/models/system_event.dart';

final Logger _logger = getLogger('FtsIndexHandler');

/// Task handler for `fts_index_update` tasks.
///
/// Persisted via [LocalTaskExecutor] so that FTS updates survive app restarts.
/// Payload contains a serialized [DataChangeRecord].
Future<void> handleFtsIndexUpdateImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final op = payload['op'] as String?;
  final ns = payload['ns'] as String?;
  final documentKey = payload['document_key'] as String?;
  final fullDocument = payload['full_document'] as Map<String, dynamic>?;

  if (op == null || ns == null || documentKey == null) {
    _logger.warning('Invalid FTS index task payload: $payload');
    return;
  }

  if (!AppDatabase.isInitialized) {
    _logger.warning('Database not initialized, skipping FTS update');
    return;
  }

  // Ensure jieba is loaded for tokenization
  await JiebaSegmenter.instance.ensureLoaded();

  final searchDao = AppDatabase.instance.searchDao;

  switch (ns) {
    case DataChangeNs.pkmFile:
      await _handlePkmFts(searchDao, op, documentKey, fullDocument);
      break;
    case DataChangeNs.card:
      await _handleCardFts(searchDao, op, documentKey, fullDocument);
      break;
    default:
      _logger.fine('Unknown FTS namespace: $ns');
  }
}

Future<void> _handlePkmFts(SearchDao searchDao, String op, String documentKey,
    Map<String, dynamic>? doc) async {
  switch (op) {
    case 'insert':
    case 'update':
      if (doc == null) return;
      await searchDao.upsertPkmFts(
        filePath: documentKey,
        fileName: doc['file_name'] as String? ?? '',
        content: doc['content'] as String? ?? '',
      );
      break;
    case 'delete':
      await searchDao.deletePkmFts(documentKey);
      break;
  }
}

Future<void> _handleCardFts(SearchDao searchDao, String op, String documentKey,
    Map<String, dynamic>? doc) async {
  switch (op) {
    case 'insert':
    case 'update':
      if (doc == null) return;
      final raw = doc['content'] as String? ?? '';
      final analyses = doc['asset_analyses'];
      final assetText =
          analyses is List ? analyses.whereType<String>().join(' ') : '';
      final ocrTexts = doc['asset_ocr'];
      final ocrText =
          ocrTexts is List ? ocrTexts.whereType<String>().join(' ') : '';
      final combined =
          [raw, assetText, ocrText].where((s) => s.isNotEmpty).join(' ');
      await searchDao.upsertCardFts(
        factId: documentKey,
        title: doc['title'] as String? ?? '',
        tags: (doc['tags'] as List?)?.whereType<String>().join(' ') ?? '',
        content: combined,
        insight: doc['insight'] as String? ?? '',
      );
      break;
    case 'delete':
      await searchDao.deleteCardFts(documentKey);
      break;
  }
}

/// Serialize a [DataChangeRecord] into a task payload map.
Map<String, dynamic> dataChangeRecordToPayload(DataChangeRecord record) {
  return {
    'op': record.op.name,
    'ns': record.ns,
    'document_key': record.documentKey,
    if (record.fullDocument != null) 'full_document': record.fullDocument,
  };
}
