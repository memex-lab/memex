import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logging/logging.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/table_change_notifier.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Generic per-user notification service. Owns CRUD for the
/// `user_notifications` Drift table. Agnostic to `notificationType` —
/// all type-specific logic lives in the producing consumer
/// (e.g. `CardDetailNotifier`).
class UserNotificationService {
  UserNotificationService._();
  static final UserNotificationService instance = UserNotificationService._();

  /// Protected constructor for testing subclasses.
  @visibleForTesting
  UserNotificationService.forTest();

  final Logger _logger = getLogger('UserNotificationService');
  AppDatabase get _db => AppDatabase.instance;

  /// Register table-change watch. Emits [AttachmentsChangedMessage] on any
  /// mutation so the Action Center and Timeline badge refresh.
  /// Call once after [TableChangeNotifier.init].
  void init() {
    TableChangeNotifier.instance.watch(
      'user_notifications',
      (_) => EventBusService.instance.emitEvent(AttachmentsChangedMessage()),
    );
  }

  /// Insert or in-place update the single row for
  /// (userId, notificationType, subjectKey). Returns the row id on success,
  /// or empty string on failure.
  Future<String> upsert({
    required String userId,
    required String notificationType,
    required String subjectKey,
    required Map<String, dynamic> payload,
  }) async {
    if (!AppDatabase.isInitialized) return '';

    try {
      return await _upsertInternal(
        userId: userId,
        notificationType: notificationType,
        subjectKey: subjectKey,
        payload: payload,
      );
    } on SqliteException catch (e) {
      // One-shot retry on constraint error — the second attempt takes the
      // UPDATE branch because the conflicting row now exists.
      if (_isConstraintError(e)) {
        _logger.info(
          'Constraint conflict on upsert for '
          'userId=$userId, type=$notificationType, key=$subjectKey — retrying',
        );
        try {
          return await _upsertInternal(
            userId: userId,
            notificationType: notificationType,
            subjectKey: subjectKey,
            payload: payload,
          );
        } catch (retryError) {
          _logger.severe(
            'Retry failed for upsert '
            'userId=$userId, type=$notificationType, key=$subjectKey: '
            '$retryError',
          );
          return '';
        }
      }
      _logger.severe(
        'Failed to upsert notification '
        'userId=$userId, type=$notificationType, key=$subjectKey: $e',
      );
      return '';
    } catch (e) {
      _logger.severe(
        'Failed to upsert notification '
        'userId=$userId, type=$notificationType, key=$subjectKey: $e',
      );
      return '';
    }
  }

  Future<String> _upsertInternal({
    required String userId,
    required String notificationType,
    required String subjectKey,
    required Map<String, dynamic> payload,
  }) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.userNotifications)
            ..where((t) =>
                t.userId.equals(userId) &
                t.notificationType.equals(notificationType) &
                t.subjectKey.equals(subjectKey)))
          .getSingleOrNull();

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (existing != null) {
        await (_db.update(_db.userNotifications)
              ..where((t) => t.id.equals(existing.id)))
            .write(UserNotificationsCompanion(
          payload: Value(jsonEncode(payload)),
          updatedAt: Value(now),
        ));
        _logger.info(
          'Updated notification '
          'userId=$userId, type=$notificationType, key=$subjectKey',
        );
        return existing.id;
      }

      final id = const Uuid().v4();
      await _db.into(_db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: id,
              userId: userId,
              notificationType: notificationType,
              subjectKey: subjectKey,
              payload: Value(jsonEncode(payload)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      _logger.info(
        'Inserted notification '
        'userId=$userId, type=$notificationType, key=$subjectKey',
      );
      return id;
    });
  }

  /// Delete a notification by its primary key.
  Future<void> dismiss(String id) async {
    if (!AppDatabase.isInitialized) return;

    try {
      final count = await (_db.delete(_db.userNotifications)
            ..where((t) => t.id.equals(id)))
          .go();
      _logger.info('Dismissed notification id=$id (deleted=$count)');
    } catch (e) {
      _logger.severe('Failed to dismiss notification id=$id: $e');
    }
  }

  /// Delete the notification matching the (userId, notificationType, subjectKey) triple.
  Future<void> dismissBy({
    required String userId,
    required String notificationType,
    required String subjectKey,
  }) async {
    if (!AppDatabase.isInitialized) return;

    try {
      final count = await (_db.delete(_db.userNotifications)
            ..where((t) =>
                t.userId.equals(userId) &
                t.notificationType.equals(notificationType) &
                t.subjectKey.equals(subjectKey)))
          .go();
      _logger.info(
        'DismissedBy '
        'userId=$userId, type=$notificationType, key=$subjectKey '
        '(deleted=$count)',
      );
    } catch (e) {
      _logger.severe(
        'Failed to dismissBy '
        'userId=$userId, type=$notificationType, key=$subjectKey: $e',
      );
    }
  }

  /// List all notifications for a user, optionally filtered by type.
  /// Ordered by `updatedAt DESC`. Returns empty list on any failure.
  Future<List<UserNotification>> list({
    required String userId,
    String? notificationType,
  }) async {
    if (!AppDatabase.isInitialized) return [];

    try {
      final query = _db.select(_db.userNotifications)
        ..where((t) {
          var condition = t.userId.equals(userId);
          if (notificationType != null) {
            condition = condition & t.notificationType.equals(notificationType);
          }
          return condition;
        })
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

      return await query.get();
    } catch (e) {
      _logger.severe('Failed to list notifications for userId=$userId: $e');
      return [];
    }
  }

  /// Dismiss all notifications for a user, optionally filtered by type.
  Future<int> dismissAll({
    required String userId,
    String? notificationType,
  }) async {
    if (!AppDatabase.isInitialized) return 0;

    try {
      final stmt = _db.delete(_db.userNotifications)
        ..where((t) {
          var condition = t.userId.equals(userId);
          if (notificationType != null) {
            condition = condition & t.notificationType.equals(notificationType);
          }
          return condition;
        });
      final count = await stmt.go();
      _logger.info(
        'DismissAll userId=$userId, type=$notificationType (deleted=$count)',
      );
      return count;
    } catch (e) {
      _logger.severe('Failed to dismissAll for userId=$userId: $e');
      return 0;
    }
  }

  /// Check if a [SqliteException] is a constraint violation.
  bool _isConstraintError(SqliteException e) {
    // extendedResultCode 2067 = SQLITE_CONSTRAINT_UNIQUE
    // extendedResultCode 1555 = SQLITE_CONSTRAINT_PRIMARYKEY
    return e.extendedResultCode == 2067 || e.extendedResultCode == 1555;
  }
}
