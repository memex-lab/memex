import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';

final _logger = getLogger('UpdateCardUiConfigEndpoint');
FileSystemService get _fileSystemService => FileSystemService.instance;

/// Update card UI config data
///
/// Args:
///   cardId: card ID (fact_id)
///   configIndex: index in ui_configs list
///   updates: map to merge
///
/// Returns:
///   bool: success
Future<bool> updateCardUiConfigEndpoint(
    String cardId, int configIndex, Map<String, dynamic> updates) async {
  _logger.info(
      'updateCardUiConfig called: cardId=$cardId, index=$configIndex, updates=$updates');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot update card config');
    }

    String? templateId;
    Map<String, dynamic>? previousData;
    Map<String, dynamic>? updatedData;

    // Use updateCardFile for ui_configs, concurrency-safe
    final updatedCardData = await _fileSystemService.updateCardFile(
      userId,
      cardId,
      (card) {
        if (card.uiConfigs.isEmpty) {
          throw Exception('No ui_configs found in card $cardId');
        }
        if (configIndex < 0 || configIndex >= card.uiConfigs.length) {
          throw Exception('Config index out of bounds: $configIndex');
        }
        final target = card.uiConfigs[configIndex];
        final newData = {...target.data, ...updates};
        templateId = target.templateId;
        previousData = Map<String, dynamic>.from(target.data);
        updatedData = Map<String, dynamic>.from(newData);
        final updatedList = card.uiConfigs.toList();
        updatedList[configIndex] =
            UiConfig(templateId: target.templateId, data: newData);
        return card.copyWith(uiConfigs: updatedList);
      },
    );

    if (updatedCardData == null) {
      _logger.warning('Card not found: $cardId');
      return false;
    }

    _logger.info('Updated ui_config at index $configIndex for $cardId');
    await _publishCardUiConfigUpdated(
      userId: userId,
      cardId: cardId,
      configIndex: configIndex,
      templateId: templateId,
      updates: updates,
      previousData: previousData,
      updatedData: updatedData,
    );
    await _logUserStatsEventIfNeeded(
      userId: userId,
      cardId: cardId,
      templateId: templateId,
      updates: updates,
      previousData: previousData,
      updatedData: updatedData,
    );
    try {
      await emitTimelineCardUpdated(
        userId: userId,
        cardId: cardId,
        cardData: updatedCardData,
      );
    } catch (e, st) {
      _logger.warning('Failed to emit timeline card updated event', e, st);
    }
    return true;
  } catch (e) {
    _logger.severe('Failed to update card ui config for $cardId: $e');
    return false;
  }
}

Future<void> _logUserStatsEventIfNeeded({
  required String userId,
  required String cardId,
  required String? templateId,
  required Map<String, dynamic> updates,
  required Map<String, dynamic>? previousData,
  required Map<String, dynamic>? updatedData,
}) async {
  if (templateId != 'task' && templateId != 'todo') return;
  if (!updates.containsKey('is_completed')) return;
  if (previousData == null || updatedData == null) return;

  final wasCompleted = previousData['is_completed'] == true;
  final isCompleted = updatedData['is_completed'] == true;
  if (wasCompleted == isCompleted) return;

  final title = updatedData['title']?.toString();
  await _fileSystemService.eventLogService.logEvent(
    userId: userId,
    eventType: isCompleted ? 'todo_completed' : 'todo_reopened',
    description: isCompleted ? 'User completed todo' : 'User reopened todo',
    filePath: _cardRelativePath(cardId),
    metadata: {
      'card_id': cardId,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
    },
  );
}

String? _cardRelativePath(String cardId) {
  final match = RegExp(
    r'^(\d{4})/(\d{2})/(\d{2})\.md#(ts_\d+)$',
  ).firstMatch(cardId);
  if (match == null) return null;
  return 'Cards/${match.group(1)}/${match.group(2)}/${match.group(3)}_${match.group(4)}.yaml';
}

Future<void> _publishCardUiConfigUpdated({
  required String userId,
  required String cardId,
  required int configIndex,
  required String? templateId,
  required Map<String, dynamic> updates,
  required Map<String, dynamic>? previousData,
  required Map<String, dynamic>? updatedData,
}) async {
  if (templateId == null || previousData == null || updatedData == null) {
    return;
  }

  try {
    await GlobalEventBus.instance.publish(
      userId: userId,
      event: SystemEvent<CardUiConfigUpdatedPayload>(
        type: SystemEventTypes.cardUiConfigUpdated,
        source: 'update_card_ui_config',
        payload: CardUiConfigUpdatedPayload(
          cardId: cardId,
          configIndex: configIndex,
          templateId: templateId,
          updates: updates,
          previousData: previousData,
          updatedData: updatedData,
        ),
      ),
    );
  } catch (e, st) {
    _logger.warning('Failed to publish card ui_config update event', e, st);
  }
}
