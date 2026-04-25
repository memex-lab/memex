import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/analyze_assets_handler.dart';
import 'package:memex/data/services/task_handlers/card_agent_handler.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/logger.dart';

final Logger _logger = getLogger('ReprocessCardsHandler');

/// Number of cards to process per batch (concurrently).
const int _batchSize = 10;

/// Task Handler implementation for `reprocess_cards_task`.
///
/// Supports resuming from where the previous run left off.
Future<void> handleReprocessCardsImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info('Starting reprocess cards task for user: $userId');

  try {
    // 1. Get or restore progress.
    Map<String, dynamic>? progress;
    try {
      final existingResult = await LocalTaskExecutor.instance.getTaskResult(
        context.taskId,
      );
      if (existingResult != null && existingResult.containsKey('progress')) {
        progress = existingResult['progress'] as Map<String, dynamic>;
        _logger.info(
          'Resuming from progress: ${progress['currentIndex']}/${progress['total']}',
        );
      }
    } catch (e) {
      _logger.warning('Failed to retrieve progress: $e');
    }

    // 2. Get the fact list to process.
    List<String> factIds;
    int currentIndex;
    int successCount;
    int failCount;

    if (progress != null) {
      // Restore from saved progress; safely perform type conversion.
      final rawFactIds = progress['factIds'] as List;
      factIds = rawFactIds.map((e) => e.toString()).toList();
      currentIndex = progress['currentIndex'] as int;
      successCount = progress['successCount'] as int? ?? 0;
      failCount = progress['failCount'] as int? ?? 0;
      _logger.info('Resuming from index $currentIndex');
    } else {
      // First run: build fact list.
      final fileSystem = FileSystemService.instance;

      // Get filter conditions from payload.
      final dateFromStr = payload['date_from'] as String?;
      final dateToStr = payload['date_to'] as String?;
      final limit = payload['limit'] as int?;

      DateTime? dateFrom;
      DateTime? dateTo;

      if (dateFromStr != null) {
        try {
          dateFrom = DateTime.parse(dateFromStr);
        } catch (e) {
          _logger.warning('Invalid date_from format: $dateFromStr');
        }
      }

      if (dateToStr != null) {
        try {
          dateTo = DateTime.parse(dateToStr);
          dateTo = DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);
        } catch (e) {
          _logger.warning('Invalid date_to format: $dateToStr');
        }
      }

      // List all facts.
      _logger.info('Listing all facts...');
      final allFactIds = await fileSystem.listAllFacts(userId);
      _logger.info('Found ${allFactIds.length} facts');

      // filter facts
      factIds = <String>[];
      for (final factId in allFactIds) {
        try {
          final factDate = fileSystem.parseFactIdDate(factId);
          final cardDate = DateTime(
            factDate.year,
            factDate.month,
            factDate.day,
          );

          if (dateFrom != null && cardDate.isBefore(dateFrom)) {
            continue;
          }
          if (dateTo != null && cardDate.isAfter(dateTo)) {
            continue;
          }

          factIds.add(factId);
        } catch (e) {
          _logger.warning('Failed to parse fact date for $factId: $e');
          continue;
        }
      }

      // Apply limit.
      if (limit != null && limit > 0 && factIds.length > limit) {
        factIds = factIds.take(limit).toList();
      }

      currentIndex = 0;
      successCount = 0;
      failCount = 0;

      // Save initial progress.
      await _saveProgress(
        context.taskId,
        factIds,
        currentIndex,
        successCount,
        failCount,
      );
    }

    final total = factIds.length;
    _logger.info(
      'Processing ${total - currentIndex} cards (starting from index $currentIndex), batch size: $_batchSize',
    );

    final reanalyzeAssets = payload['reanalyze_assets'] as bool? ?? false;

    // 3. Process in batches: up to [_batchSize] cards per batch concurrently; run next batch after current batch completes.
    while (currentIndex < factIds.length) {
      final endIndex = (currentIndex + _batchSize).clamp(0, total);
      final batch = factIds.sublist(currentIndex, endIndex);
      final batchNumber = currentIndex ~/ _batchSize + 1;
      final totalBatches = (total + _batchSize - 1) ~/ _batchSize;

      _logger.info(
        'Processing batch $batchNumber/$totalBatches: cards ${currentIndex + 1}-$endIndex of $total',
      );

      final results = await Future.wait(
        batch.map(
          (factId) =>
              _processOneCard(userId, factId, reanalyzeAssets: reanalyzeAssets),
        ),
      );

      for (var i = 0; i < results.length; i++) {
        if (results[i]) {
          successCount++;
          _logger.info('Successfully processed card: ${batch[i]}');
        } else {
          failCount++;
        }
      }

      currentIndex = endIndex;

      // Save progress after each batch completes.
      await _saveProgress(
        context.taskId,
        factIds,
        currentIndex,
        successCount,
        failCount,
      );
    }

    // 4. Save final result.
    final result = {
      'success': successCount,
      'failed': failCount,
      'total': total,
      'completed': true,
    };

    await LocalTaskExecutor.instance.updateTaskResult(
      context.taskId,
      jsonEncode(result),
    );

    _logger.info(
      'Reprocess cards task completed. Success: $successCount, Failed: $failCount, Total: $total',
    );
  } catch (e, stack) {
    _logger.severe('Error in reprocess cards task: $e', e, stack);
    rethrowIfNonRetryable(e);
  }
}

/// Processes one card: extract content, optionally refresh media analysis, ensure card exists, call card_agent. Returns whether it succeeded.
Future<bool> _processOneCard(
  String userId,
  String factId, {
  required bool reanalyzeAssets,
}) async {
  FactContentResult? factInfo;
  try {
    final fileSystem = FileSystemService.instance;
    factInfo = await fileSystem.extractFactContentFromFile(userId, factId);

    if (factInfo == null) {
      _logger.warning('Failed to extract fact content for: $factId');
      return false;
    }

    await _ensureCardExists(fileSystem, userId, factId, factInfo.datetime);

    var assetAnalyses = factInfo.assetAnalyses;
    if (reanalyzeAssets) {
      final assetPaths = _extractAssetPaths(
        fileSystem,
        userId,
        factInfo.content,
      );
      if (assetPaths.isNotEmpty) {
        _logger.info('Re-analyzing ${assetPaths.length} asset(s) for $factId');
        final refreshedAnalyses = await analyzeAssetsForFact(
          userId: userId,
          factId: factId,
          assetPaths: assetPaths,
        );
        assetAnalyses = refreshedAnalyses.map((e) => e.toJson()).toList();
      }
    }

    await processWithCardAgent(
      userId: userId,
      factId: factId,
      contentText: factInfo.content,
      assetAnalyses: assetAnalyses,
      inputDateTime: factInfo.datetime,
      dryRun: false,
    );

    await renderAndPushCardUpdate(userId, factId, factInfo.content);

    return true;
  } catch (e, stack) {
    _logger.severe('Failed to reprocess card $factId: $e', e, stack);
    return false;
  } finally {
    factInfo = null;
  }
}

List<String> _extractAssetPaths(
  FileSystemService fileSystem,
  String userId,
  String content,
) {
  final assetsDir = fileSystem.getAssetsPath(userId);
  return RegExp(r'fs://([^\s\)]+)').allMatches(content).map((m) {
    final filename = m.group(1)!;
    final absolutePath = '$assetsDir/$filename';
    return fileSystem.toRelativePath(absolutePath);
  }).toList();
}

/// Ensures the card exists; creates an initial card if not found.
Future<void> _ensureCardExists(
  FileSystemService fileSystem,
  String userId,
  String factId,
  DateTime? factDateTime,
) async {
  // Check whether the card exists.
  final existingCard = await fileSystem.readCardFile(userId, factId);
  if (existingCard != null) {
    // Card already exists; no need to create.
    return;
  }

  // Card not found; create initial card.
  _logger.info('Card not found for $factId, creating initial card');

  final now = factDateTime ?? DateTime.now();
  final initialCard = CardData(
    factId: factId,
    title: '',
    timestamp: now.millisecondsSinceEpoch ~/ 1000,
    status: 'processing',
    tags: const [],
    uiConfigs: const [UiConfig(templateId: 'classic_card', data: {})],
  );

  try {
    final success = await fileSystem.safeWriteCardFile(
      userId,
      factId,
      initialCard,
    );
    if (success) {
      _logger.info('Created initial card for: $factId');
    } else {
      _logger.warning('Failed to create initial card for: $factId');
    }
  } catch (e) {
    _logger.warning('Error creating initial card for $factId: $e');
    // Continue; let the subsequent flow handle the error.
  }
}

/// Saves progress to the task result.
Future<void> _saveProgress(
  String taskId,
  List<String> factIds,
  int currentIndex,
  int successCount,
  int failCount,
) async {
  final progress = {
    'factIds': factIds,
    'currentIndex': currentIndex,
    'successCount': successCount,
    'failCount': failCount,
    'total': factIds.length,
  };

  final result = {
    'progress': progress,
    'success': successCount,
    'failed': failCount,
    'total': factIds.length,
  };

  await LocalTaskExecutor.instance.updateTaskResult(taskId, jsonEncode(result));
}
