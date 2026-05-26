import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/data/services/clarification_request_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/table_change_notifier.dart';
import 'package:memex/data/services/user_notification_service.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/utils/user_storage.dart';

/// Attachment type constants.
class CardAttachmentType {
  static const systemAction = 'system_action';
  static const clarificationRequest = 'clarification_request';
  static const cardDetailNotification = 'card_detail_notification';
}

/// Aggregates all attachment data sources for a given factId into a single
/// sorted list.
///
/// Data flow:
/// 1. Initial load: called during timeline card list fetch.
/// 2. Incremental updates: [init] registers table-change watchers that emit
///    [AttachmentsChangedMessage] via EventBus. ViewModel listens and
///    re-fetches only the affected cards.
class CardAttachmentService {
  CardAttachmentService._();
  static final instance = CardAttachmentService._();

  /// Register table-change watchers. Call once after [TableChangeNotifier.init].
  void init() {
    final notifier = TableChangeNotifier.instance;
    notifier.watch('system_actions', (_) => _emitChanged());
    notifier.watch('clarification_requests', (_) => _emitChanged());
    notifier.watch('user_notifications', (_) => _emitChanged());
  }

  void _emitChanged() {
    EventBusService.instance.emitEvent(AttachmentsChangedMessage());
  }

  /// Dismiss all pending items of a specific type, or all types if null.
  /// Returns the total number of items dismissed.
  Future<int> dismissAllPending({String? type}) async {
    int total = 0;
    final userId = await UserStorage.getUserId();

    if (type == null || type == CardAttachmentType.systemAction) {
      total +=
          await SystemActionService.instance.dismissPendingFromActionCenter();
    }
    if (type == null || type == CardAttachmentType.clarificationRequest) {
      total += await ClarificationRequestService.instance.dismissAllPending();
    }
    if ((type == null || type == CardAttachmentType.cardDetailNotification) &&
        userId != null) {
      total += await UserNotificationService.instance.dismissAll(
        userId: userId,
        notificationType: 'card_detail_update',
      );
    }

    return total;
  }

  /// Fetches all pending attachments (for the action center / notification badge).
  Future<List<CardAttachmentData>> getPendingAttachments() async {
    final userId = await UserStorage.getUserId();
    final results = await Future.wait([
      _getPendingSystemActions(),
      _getPendingClarificationRequests(),
      if (userId != null)
        _getPendingCardDetailNotifications(userId)
      else
        Future.value(<CardAttachmentData>[]),
    ]);
    final merged = results.expand((e) => e).toList()
      ..sort((a, b) {
        final k = a.sortKey.compareTo(b.sortKey);
        if (k != 0) return k;
        final aUpdated = a.data['updated_at'] as int? ?? 0;
        final bUpdated = b.data['updated_at'] as int? ?? 0;
        return bUpdated.compareTo(aUpdated);
      });
    return merged;
  }

  /// Fetches all attachments for a single [factId], sorted by [sortKey].
  Future<List<CardAttachmentData>> getAttachments(String factId) async {
    final results = await Future.wait([
      _getSystemActions(factId),
      _getClarificationRequests(factId),
    ]);
    final merged = results.expand((e) => e).toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return merged;
  }

  /// Fetches attachments for multiple factIds in one call.
  /// Returns a map of factId → sorted attachment list.
  Future<Map<String, List<CardAttachmentData>>> getAttachmentsForFacts(
    List<String> factIds,
  ) async {
    final map = <String, List<CardAttachmentData>>{};
    final futures = factIds.map((id) async {
      map[id] = await getAttachments(id);
    });
    await Future.wait(futures);
    return map;
  }

  // ---------------------------------------------------------------------------
  // Data sources — add new attachment types here
  // ---------------------------------------------------------------------------

  Future<List<CardAttachmentData>> _getSystemActions(String factId) async {
    final actions =
        await SystemActionService.instance.getVisibleForFact(factId);
    return actions
        .map((a) => CardAttachmentData(
              id: 'system_action_${a.id}',
              type: CardAttachmentType.systemAction,
              data: {'action': a},
              sortKey: 100,
            ))
        .toList();
  }

  Future<List<CardAttachmentData>> _getClarificationRequests(
      String factId) async {
    final requests =
        await ClarificationRequestService.instance.getVisibleForFact(factId);
    return requests
        .map((r) => CardAttachmentData(
              id: 'clarification_${r.id}',
              type: CardAttachmentType.clarificationRequest,
              data: {'request': r},
              sortKey: 50,
            ))
        .toList();
  }

  Future<List<CardAttachmentData>> _getPendingSystemActions() async {
    final actions = await SystemActionService.instance.getPending();
    return actions
        .map((a) => CardAttachmentData(
              id: 'system_action_${a.id}',
              type: CardAttachmentType.systemAction,
              data: {'action': a},
              sortKey: 100,
            ))
        .toList();
  }

  Future<List<CardAttachmentData>> _getPendingClarificationRequests() async {
    final requests = await ClarificationRequestService.instance.getPending();
    return requests
        .map((r) => CardAttachmentData(
              id: 'clarification_${r.id}',
              type: CardAttachmentType.clarificationRequest,
              data: {'request': r},
              sortKey: 50,
            ))
        .toList();
  }

  Future<List<CardAttachmentData>> _getPendingCardDetailNotifications(
    String userId,
  ) async {
    final rows = await UserNotificationService.instance.list(
      userId: userId,
      notificationType: 'card_detail_update',
    );
    return rows
        .map((r) => CardAttachmentData(
              id: 'card_detail_notification_${r.id}',
              type: CardAttachmentType.cardDetailNotification,
              data: {
                'notification': r,
                'fact_id': r.subjectKey,
                'updated_at': r.updatedAt,
              },
              sortKey: 200,
            ))
        .toList();
  }
}
