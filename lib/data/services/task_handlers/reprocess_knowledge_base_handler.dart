import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/pkm_agent_handler.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/logger.dart';

final Logger _logger = getLogger('ReprocessKnowledgeBaseHandler');

/// Task Handler implementation for `reprocess_knowledge_base_task`.
///
/// Supports resuming from where the previous run left off.
Future<void> handleReprocessKnowledgeBaseImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info('Starting reprocess knowledge base task for user: $userId');

  try {
    // 1. Get or restore progress.
    Map<String, dynamic>? progress;
    try {
      final existingResult =
          await LocalTaskExecutor.instance.getTaskResult(context.taskId);
      if (existingResult != null && existingResult.containsKey('progress')) {
        progress = existingResult['progress'] as Map<String, dynamic>;
        _logger.info(
            'Resuming from progress: ${progress['currentIndex']}/${progress['total']}');
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
          final cardDate =
              DateTime(factDate.year, factDate.month, factDate.day);

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
        'Processing ${total - currentIndex} facts (starting from index $currentIndex)');

    // 3. Process facts one by one.
    for (int idx = currentIndex; idx < factIds.length; idx++) {
      final factId = factIds[idx];

      _logger.info('Processing fact ${idx + 1}/$total: $factId');

      // Use local scope so the object can be released when done.
      FactContentResult? factInfo;
      try {
        // Extract fact content.
        final fileSystem = FileSystemService.instance;
        factInfo = await fileSystem.extractFactContentFromFile(userId, factId);

        if (factInfo == null) {
          _logger.warning('Failed to extract fact content for: $factId');
          failCount++;
          continue;
        }

        // Ensure card exists; create initial card if not found.
        await _ensureCardExists(fileSystem, userId, factId, factInfo.datetime);

        // Process using pkm_agent_handler.
        await processWithPkmAgent(
          userId: userId,
          factId: factId,
          contentText: factInfo.content,
          assetAnalyses: factInfo.assetAnalyses,
          inputDateTime: factInfo.datetime,
          dryRun: false,
        );

        successCount++;
        _logger.info('Successfully processed fact: $factId');
      } catch (e, stack) {
        _logger.severe('Failed to reprocess fact $factId: $e', e, stack);
        failCount++;
        // Continue to next; do not abort.
      } finally {
        // Explicitly release factInfo.
        factInfo = null;
      }

      // Update progress (save after each fact).
      await _saveProgress(
        context.taskId,
        factIds,
        idx + 1, // Next index to process.
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
        'Reprocess knowledge base task completed. Success: $successCount, Failed: $failCount, Total: $total');
  } catch (e, stack) {
    _logger.severe('Error in reprocess knowledge base task: $e', e, stack);
    rethrowIfNonRetryable(e);
  }
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
    uiConfigs: [
      const UiConfig(templateId: 'classic_card', data: {}),
    ],
  );

  try {
    final success =
        await fileSystem.safeWriteCardFile(userId, factId, initialCard);
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

  await LocalTaskExecutor.instance.updateTaskResult(
    taskId,
    jsonEncode(result),
  );
}
