import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memex/data/services/native_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/logger.dart';

class SystemActionService {
  static final SystemActionService instance = SystemActionService._internal();
  SystemActionService._internal();

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
              status: 'pending',
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
      final count = await (_db.update(_db.systemActions)
            ..where((t) => t.id.equals(actionId)))
          .write(SystemActionsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ));

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

  /// Applies an action through the device-native bridge.
  ///
  /// Permission prompting stays in the UI. This service owns payload parsing,
  /// native dispatch, and persistence so widgets do not contain action
  /// execution business logic.
  Future<bool> applyToDevice(SystemAction action) async {
    try {
      final data = decodeActionData(action);
      final title = _optionalText(data['title']);
      if (title == null) {
        _logger.warning('System action ${action.id} has no title');
        return false;
      }

      final bool applied;
      switch (action.actionType) {
        case 'calendar':
          final start = parseLocalDateTime(data['start_time']);
          final end = parseLocalDateTime(data['end_time']);
          if (start == null || (end != null && !end.isAfter(start))) {
            _logger.warning(
              'System action ${action.id} has an invalid calendar range',
            );
            return false;
          }
          applied = await NativeActionService.addCalendarEvent(
            title: title,
            startTime: start,
            endTime: end,
            location: _optionalText(data['location']),
            notes: _optionalText(data['notes']),
          );
          break;
        case 'reminder':
          final due = parseLocalDateTime(data['due_date']);
          if (due == null) {
            _logger.warning(
              'System action ${action.id} has no valid reminder due date',
            );
            return false;
          }
          applied = await NativeActionService.addReminder(
            title: title,
            dueDate: due,
            notes: _optionalText(data['notes']),
          );
          break;
        default:
          _logger.warning(
            'System action ${action.id} has unsupported type '
            '${action.actionType}',
          );
          return false;
      }

      if (!applied) return false;
      return updateActionStatus(action.id, 'completed');
    } catch (error, stackTrace) {
      _logger.severe(
        'Failed to apply system action ${action.id}',
        error,
        stackTrace,
      );
      return false;
    }
  }

  /// Decodes action payload for presentation. Invalid legacy data is rendered
  /// as an empty object instead of leaking parsing concerns into widgets.
  Map<String, dynamic> decodeActionData(SystemAction action) {
    final rawData = action.actionData;
    if (rawData == null) return const {};
    try {
      final decoded = jsonDecode(rawData);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to decode system action ${action.id}',
        error,
        stackTrace,
      );
      return const {};
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

  /// Gets non-rejected actions for a given factId (one-shot query).
  Future<List<SystemAction>> getVisibleForFact(String factId) async {
    return (_db.select(_db.systemActions)
          ..where(
              (t) => t.factId.equals(factId) & t.status.isNotIn(['rejected'])))
        .get();
  }

  /// Gets all pending actions.
  Future<List<SystemAction>> getPending() async {
    return (_db.select(_db.systemActions)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Hide all pending actions from the action center without rejecting them.
  Future<int> dismissPendingFromActionCenter() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final count = await (_db.update(_db.systemActions)
            ..where((t) => t.status.equals('pending')))
          .write(SystemActionsCompanion(
        status: const Value('dismissed'),
        updatedAt: Value(now),
      ));
      _logger.info('Dismissed all pending system actions (count=$count)');
      return count;
    } catch (e) {
      _logger.severe('Failed to dismiss pending actions: $e');
      return 0;
    }
  }

  String? _optionalText(dynamic value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
