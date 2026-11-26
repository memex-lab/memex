import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/user_notification_service.dart';

void main() {
  late AppDatabase db;
  final service = UserNotificationService.instance;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });
  tearDown(() => db.close());

  group('UserNotificationService', () {
    group('upsert', () {
      test('first upsert inserts a new row', () async {
        final id = await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-123',
          payload: {
            'signals': ['comments']
          },
        );

        expect(id, isNotEmpty);

        final rows = await service.list(userId: 'user-a');
        expect(rows, hasLength(1));
        expect(rows.first.id, id);
        expect(rows.first.userId, 'user-a');
        expect(rows.first.notificationType, 'card_detail_update');
        expect(rows.first.subjectKey, 'fact-123');

        final decoded = jsonDecode(rows.first.payload!) as Map<String, dynamic>;
        expect(decoded['signals'], ['comments']);
      });

      test(
          'second upsert with same triple updates in place, bumps updatedAt, '
          'does NOT add a row', () async {
        final id1 = await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-123',
          payload: {
            'signals': ['comments']
          },
        );

        // Seed an older persisted notification without depending on the wall clock.
        await (db.update(db.userNotifications)
              ..where((row) => row.id.equals(id1)))
            .write(const UserNotificationsCompanion(
                createdAt: Value(1), updatedAt: Value(1)));

        final id2 = await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-123',
          payload: {
            'signals': ['comments', 'insight']
          },
        );

        // Same row id returned
        expect(id2, id1);

        // Still only one row
        final rows = await service.list(userId: 'user-a');
        expect(rows, hasLength(1));

        // Payload updated
        final decoded = jsonDecode(rows.first.payload!) as Map<String, dynamic>;
        expect(
          (decoded['signals'] as List).toSet(),
          {'comments', 'insight'},
        );

        expect(rows.first.createdAt, 1);
        expect(rows.first.updatedAt, greaterThan(rows.first.createdAt));
      });
    });

    group('dismiss', () {
      test('dismiss(id) deletes exactly one row', () async {
        final id1 = await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
          payload: {
            'signals': ['comments']
          },
        );
        await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-2',
          payload: {
            'signals': ['insight']
          },
        );

        await service.dismiss(id1);

        final rows = await service.list(userId: 'user-a');
        expect(rows, hasLength(1));
        expect(rows.first.subjectKey, 'fact-2');
      });

      test('dismissBy(triple) deletes exactly one row', () async {
        await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
          payload: {
            'signals': ['comments']
          },
        );
        await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-2',
          payload: {
            'signals': ['insight']
          },
        );

        await service.dismissBy(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
        );

        final rows = await service.list(userId: 'user-a');
        expect(rows, hasLength(1));
        expect(rows.first.subjectKey, 'fact-2');
      });
    });

    group('list', () {
      test('list(userA) never returns userB rows', () async {
        await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
          payload: {
            'signals': ['comments']
          },
        );
        await service.upsert(
          userId: 'user-b',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
          payload: {
            'signals': ['insight']
          },
        );

        final rowsA = await service.list(userId: 'user-a');
        expect(rowsA, hasLength(1));
        expect(rowsA.first.subjectKey, 'fact-1');
        expect(jsonDecode(rowsA.first.payload!)['signals'], ['comments']);

        final rowsB = await service.list(userId: 'user-b');
        expect(rowsB, hasLength(1));
        expect(rowsB.first.subjectKey, 'fact-1');
        expect(jsonDecode(rowsB.first.payload!)['signals'], ['insight']);
        await service.dismiss(rowsA.single.id);
        expect(await service.list(userId: 'user-a'), isEmpty);
        expect(
            (await service.list(userId: 'user-b')).single.id, rowsB.single.id);
      });

      test('list with notificationType filter works', () async {
        await service.upsert(
          userId: 'user-a',
          notificationType: 'card_detail_update',
          subjectKey: 'fact-1',
          payload: {
            'signals': ['comments']
          },
        );
        // Simulate a different notification type (future use)
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await db.into(db.userNotifications).insert(
              UserNotificationsCompanion.insert(
                id: 'other-type-id',
                userId: 'user-a',
                notificationType: 'task_failed',
                subjectKey: 'task-xyz',
                payload: const Value('{}'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        final filtered = await service.list(
          userId: 'user-a',
          notificationType: 'card_detail_update',
        );
        expect(filtered, hasLength(1));
        expect(filtered.first.notificationType, 'card_detail_update');

        final all = await service.list(userId: 'user-a');
        expect(all, hasLength(2));
      });
    });
  });
}
