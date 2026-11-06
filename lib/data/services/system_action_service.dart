import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/native_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/logger.dart';
import 'package:uuid/uuid.dart';

class SystemActionService {
  static final SystemActionService instance = SystemActionService._internal();
  SystemActionService._internal();

  final _logger = getLogger('SystemActionService');
  AppDatabase get _db => AppDatabase.instance;

  /// Record proposals are reviewable attachments, never implicit OS writes.
  /// A deterministic ID preserves completed/rejected state across tool retries.
  Future<String> prepareForRecord({
    required String userId,
    required String factId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final db = _db;
    if (!RegExp(r'^\d{4}/\d{2}/\d{2}\.md#ts_\d+$').hasMatch(factId)) {
      throw ArgumentError.value(factId, 'factId', 'Expected a saved record ID');
    }
    final card = await FileSystemService.instance.readCardFile(userId, factId);
    if (card == null || card.deleted == true || card.status != 'completed') {
      throw StateError('Save the source record successfully before proposing.');
    }
    final time = parseLocalDateTime(
      type == 'calendar' ? data['start_time'] : data['due_date'],
    );
    if (!{'calendar', 'reminder'}.contains(type) ||
        time == null ||
        !time.isAfter(DateTime.now())) {
      throw ArgumentError('Record proposals require a concrete future time.');
    }
    final keys = data.keys.toList()..sort();
    final canonical = {for (final key in keys) key: data[key]};
    final id = const Uuid().v5(
        Namespace.url.value,
        jsonEncode(
            ['memex-record-device-action', userId, factId, type, canonical]));
    if (!identical(db, _db)) throw StateError('Workspace changed.');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.into(db.systemActions).insert(
          SystemActionsCompanion.insert(
            id: id,
            actionType: type,
            actionData: Value(jsonEncode(canonical)),
            status: 'pending',
            factId: Value(factId),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return id;
  }

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
  final Map<String, Future<bool?>> _inFlight = {};

  Future<bool?> applyToDevice(SystemAction action) {
    final existing = _inFlight[action.id];
    if (existing != null) return existing;
    final future = _applyToDevice(action.id);
    _inFlight[action.id] = future;
    return future.whenComplete(() => _inFlight.remove(action.id));
  }

  Future<bool?> _applyToDevice(String actionId) async {
    try {
      final action = await getAction(actionId);
      if (action == null) return false;
      if (action.status == 'completed') return true;
      if (!{'pending', 'dismissed'}.contains(action.status)) return false;
      final data = decodeActionData(action);
      final title = _optionalText(data['title']);
      if (title == null) {
        _logger.warning('System action ${action.id} has no title');
        return false;
      }

      final bool? applied;
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

      if (applied == null) {
        return null; // System editor cancelled; keep pending.
      }
      if (!applied) return false;
      return updateActionStatus(action.id, 'completed');
    } catch (error, stackTrace) {
      _logger.severe(
        'Failed to apply system action $actionId',
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
    return getVisibleForFacts([factId]);
  }

  /// Gets non-rejected actions for many facts in one query.
  Future<List<SystemAction>> getVisibleForFacts(List<String> factIds) async {
    if (factIds.isEmpty) return [];
    return (_db.select(_db.systemActions)
          ..where(
              (t) => t.factId.isIn(factIds) & t.status.isNotIn(['rejected'])))
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
