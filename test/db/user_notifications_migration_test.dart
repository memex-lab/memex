import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/db/tables.dart';

part 'user_notifications_migration_test.g.dart';

/// Minimal Drift database for testing the UserNotifications table schema
/// and indices in isolation.
@DriftDatabase(tables: [UserNotifications])
class TestNotificationsDb extends _$TestNotificationsDb {
  TestNotificationsDb(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_notifications_unique '
              'ON user_notifications(user_id, notification_type, subject_key)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_user_notifications_list '
              'ON user_notifications(user_id, notification_type, updated_at)');
        },
      );
}

void main() {
  group('UserNotifications migration', () {
    late TestNotificationsDb db;

    setUp(() {
      db = TestNotificationsDb(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('table is queryable after creation', () async {
      // Verify the table exists and is empty
      final rows = await db.select(db.userNotifications).get();
      expect(rows, isEmpty);
    });

    test('can insert and query a notification row', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'test-id-1',
              userId: 'user-a',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-123',
              payload: const Value('{"signals":["comments"]}'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await db.select(db.userNotifications).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'test-id-1');
      expect(rows.first.userId, 'user-a');
      expect(rows.first.notificationType, 'card_detail_update');
      expect(rows.first.subjectKey, 'fact-123');
      expect(rows.first.payload, '{"signals":["comments"]}');
      expect(rows.first.createdAt, now);
      expect(rows.first.updatedAt, now);
    });

    test('payload column is nullable', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'test-id-2',
              userId: 'user-a',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-456',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await db.select(db.userNotifications).get();
      expect(rows, hasLength(1));
      expect(rows.first.payload, isNull);
    });

    test(
        'UNIQUE index rejects duplicate (userId, notificationType, subjectKey) triple',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // First insert succeeds
      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'id-1',
              userId: 'user-a',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-123',
              payload: const Value('{"signals":["comments"]}'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Second insert with same triple but different id should fail
      expect(
        () => db.into(db.userNotifications).insert(
              UserNotificationsCompanion.insert(
                id: 'id-2',
                userId: 'user-a',
                notificationType: 'card_detail_update',
                subjectKey: 'fact-123',
                payload: const Value('{"signals":["insight"]}'),
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('UNIQUE index allows different triples', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Same user, same type, different subjectKey
      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'id-1',
              userId: 'user-a',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-123',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'id-2',
              userId: 'user-a',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-456',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Different user, same type and subjectKey
      await db.into(db.userNotifications).insert(
            UserNotificationsCompanion.insert(
              id: 'id-3',
              userId: 'user-b',
              notificationType: 'card_detail_update',
              subjectKey: 'fact-123',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await db.select(db.userNotifications).get();
      expect(rows, hasLength(3));
    });
  });
}
