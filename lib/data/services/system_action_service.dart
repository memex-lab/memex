import 'dart:convert';
import 'package:memex/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/logger.dart';

class SystemActionService {
  static final SystemActionService instance = SystemActionService._internal();
  SystemActionService._internal();

  static const statusPending = 'pending';
  static const statusCompleted = 'completed';
  static const statusDismissed = 'dismissed';
  static const statusRejected = 'rejected';
  static const statusPastDue = 'past_due';

  final _logger = getLogger('SystemActionService');
  AppDatabase get _db => AppDatabase.instance;

  /// Creates a new system action (Calendar or Reminder) in the local database.
  /// Status is initialized to 'pending' for user review.
  Future<String> createAction({
    required String id,
    required String type,
    required Map<String, dynamic> data,
    String? factId,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _db.into(_db.systemActions).insert(
            SystemActionsCompanion.insert(
              id: id,
              actionType: type,
              actionData: Value(jsonEncode(data)),
              status: statusPending,
              factId: Value(factId),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      _logger.info('Created new local system action: $id ($type)');
      return id;
    } catch (e) {
      _logger.severe('Failed to create system action: $e');
      rethrow;
    }
  }

  /// Updates the status of an existing action.
  Future<bool> updateActionStatus(String actionId, String status) async {
    try {
      final count = await (_db.update(
        _db.systemActions,
      )..where((t) => t.id.equals(actionId)))
          .write(
        SystemActionsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        ),
      );

      final success = count > 0;
      if (success) {
        _logger.info('Updated system action $actionId status to $status');
      } else {
        _logger.warning('Action $actionId not found for status update.');
      }
      return success;
    } catch (e) {
      _logger.severe('Failed to update action status for $actionId: $e');
      return false;
    }
  }

  /// Cancels (deletes) an action.
  Future<bool> cancelAction(String actionId) async {
    try {
      final count = await (_db.delete(
        _db.systemActions,
      )..where((t) => t.id.equals(actionId)))
          .go();
      return count > 0;
    } catch (e) {
      _logger.severe('Failed to cancel action $actionId: $e');
      return false;
    }
  }

  Future<SystemAction?> getAction(String actionId) async {
    try {
      return await (_db.select(_db.systemActions)
            ..where((t) => t.id.equals(actionId))
            ..limit(1))
          .getSingleOrNull();
    } catch (e) {
      _logger.severe('Failed to get system action $actionId: $e');
      return null;
    }
  }

  /// Cancels only an action that has not been applied to the device yet.
  Future<bool> cancelPendingAction(String actionId) async {
    try {
      final count = await (_db.delete(_db.systemActions)
            ..where(
              (t) => t.id.equals(actionId) & t.status.equals(statusPending),
            ))
          .go();
      if (count == 0) {
        _logger.info(
          'Skipped cancelling system action $actionId because it is not pending',
        );
      }
      return count > 0;
    } catch (e) {
      _logger.severe('Failed to cancel pending action $actionId: $e');
      return false;
    }
  }

  /// Gets non-rejected actions for a given factId (one-shot query).
  Future<List<SystemAction>> getVisibleForFact(String factId) async {
    return (_db.select(_db.systemActions)
          ..where(
            (t) => t.factId.equals(factId) & t.status.isNotIn([statusRejected]),
          ))
        .get();
  }

  /// Gets schedule-relevant actions that should still be visible.
  ///
  /// `dismissed` only means hidden from the action center; it is intentionally
  /// still visible in source-card attachments and schedule aggregation.
  Future<List<SystemAction>> getVisibleForSchedule() async {
    return (_db.select(_db.systemActions)
          ..where(
            (t) =>
                t.status.isNotIn([statusRejected]) &
                t.actionType.isIn(['calendar', 'reminder']),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Gets all pending actions.
  Future<List<SystemAction>> getPending({DateTime? now}) async {
    await markPastCalendarActionsPastDue(now: now);
    return (_db.select(_db.systemActions)
          ..where((t) => t.status.equals(statusPending))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Gets actions that should appear in the Action Center.
  ///
  /// Future pending actions still require user confirmation. Calendar actions
  /// whose event window has already passed are first moved to [statusPastDue]
  /// and shown in a historical section instead of contributing to the badge.
  Future<List<SystemAction>> getActionCenterActions({DateTime? now}) async {
    await markPastCalendarActionsPastDue(now: now);
    return (_db.select(_db.systemActions)
          ..where((t) => t.status.isIn([statusPending, statusPastDue]))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Move pending calendar actions whose start/end has passed into past-due.
  Future<int> markPastCalendarActionsPastDue({DateTime? now}) async {
    final current = now ?? DateTime.now();
    try {
      final pendingCalendars = await (_db.select(_db.systemActions)
            ..where(
              (t) =>
                  t.status.equals(statusPending) &
                  t.actionType.equals('calendar'),
            ))
          .get();

      var updated = 0;
      for (final action in pendingCalendars) {
        if (!isPastDueCalendarAction(action, now: current)) {
          continue;
        }
        final changed = await updateActionStatus(action.id, statusPastDue);
        if (changed) updated++;
      }
      return updated;
    } catch (e) {
      _logger.severe('Failed to mark past calendar actions past-due: $e');
      return 0;
    }
  }

  static bool isPastDueCalendarAction(SystemAction action, {DateTime? now}) {
    if (action.actionType != 'calendar') return false;
    final deadline = actionReviewDeadline(action);
    if (deadline == null) return false;
    return !(now ?? DateTime.now()).isBefore(deadline);
  }

  static bool countsForPrimaryBadge(SystemAction action, {DateTime? now}) {
    if (action.status != statusPending) return false;
    return !isPastDueCalendarAction(action, now: now);
  }

  static DateTime? actionReviewDeadline(SystemAction action) {
    if (action.actionData == null) return null;
    try {
      final data = jsonDecode(action.actionData!) as Map<String, dynamic>;
      if (action.actionType == 'calendar') {
        return parseLocalDateTime(data['end_time']?.toString()) ??
            parseLocalDateTime(data['start_time']?.toString());
      }
      if (action.actionType == 'reminder') {
        return parseLocalDateTime(data['due_date']?.toString());
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Reject all pending actions (batch dismiss).
  Future<int> rejectAllPending() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final count = await (_db.update(
        _db.systemActions,
      )..where((t) => t.status.equals(statusPending)))
          .write(
        SystemActionsCompanion(
          status: const Value(statusRejected),
          updatedAt: Value(now),
        ),
      );
      _logger.info('Rejected all pending system actions (count=$count)');
      return count;
    } catch (e) {
      _logger.severe('Failed to reject all pending actions: $e');
      return 0;
    }
  }

  /// Hide all pending actions from the action center without rejecting them.
  Future<int> dismissPendingFromActionCenter() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final count = await (_db.update(
        _db.systemActions,
      )..where((t) => t.status.isIn([statusPending, statusPastDue])))
          .write(
        SystemActionsCompanion(
          status: const Value(statusDismissed),
          updatedAt: Value(now),
        ),
      );
      _logger.info('Dismissed all pending system actions (count=$count)');
      return count;
    } catch (e) {
      _logger.severe('Failed to dismiss pending actions: $e');
      return 0;
    }
  }

  /// Gets recent actions for agent context.
  Future<List<SystemAction>> getRecentActions({int limit = 20}) async {
    try {
      return await (_db.select(_db.systemActions)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();
    } catch (e) {
      _logger.severe('Failed to fetch recent actions: $e');
      return [];
    }
  }
}
