import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_detail_notifier.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/user_notification_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/system_event.dart';

void main() {
  const user = 'reader';
  const card = '2025/01/15.md#ts_3';
  final bus = GlobalEventBus.instance;
  final notifier = CardDetailNotifier.instance;
  final notifications = UserNotificationService.instance;

  setUp(() {
    AppDatabase.setTestInstance(
        AppDatabase.forTesting(NativeDatabase.memory()));
    notifier.init();
  });
  tearDown(() async {
    bus.unsubscribeSync(
        eventType: SystemEventTypes.dataChanged,
        subscriptionId: 'card_detail_notifier');
    await AppDatabase.closeCurrent();
  });

  Future<void> publish({
    String userId = user,
    String subject = card,
    String namespace = DataChangeNs.card,
    DataChangeOp op = DataChangeOp.update,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  }) async {
    await bus.publish(
        userId: userId,
        event: SystemEvent(
          type: SystemEventTypes.dataChanged,
          source: 'file_system_service',
          payload: DataChangeRecord(
              op: op,
              ns: namespace,
              documentKey: subject,
              before: before,
              after: after),
        ));
  }

  const comment = {
    'comments': [
      {'id': 'c1', 'content': 'Hello'}
    ]
  };
  const insight = {
    'insight': {'text': 'A new insight'}
  };
  Future<List<UserNotification>> inbox([String userId = user]) => notifications
      .list(userId: userId, notificationType: 'card_detail_update');

  test('published comment and insight merge into the same inbox row', () async {
    await publish(before: {}, after: comment);
    final first = (await inbox()).single;
    expect(first.subjectKey, card);
    expect(jsonDecode(first.payload!)['signals'], ['comments']);
    await publish(before: comment, after: {...comment, ...insight});
    final updated = (await inbox()).single;
    expect(updated.id, first.id);
    expect(jsonDecode(updated.payload!)['signals'], ['comments', 'insight']);
  });

  test('viewing and deleting a card clear only its notification', () async {
    await publish(before: {}, after: comment);
    await publish(subject: 'neighbor', before: {}, after: comment);
    await publish(userId: 'other', before: {}, after: comment);
    expect((await inbox()).map((n) => n.subjectKey),
        unorderedEquals([card, 'neighbor']));
    notifier.registerForeground(card);
    try {
      await publish(before: {}, after: insight);
      expect((await inbox()).single.subjectKey, 'neighbor');
    } finally {
      notifier.unregisterForeground(card);
    }
    await publish(before: {}, after: comment);
    expect((await inbox()).map((n) => n.subjectKey), contains(card));
    await publish(op: DataChangeOp.delete, before: comment);
    expect((await inbox()).single.subjectKey, 'neighbor');
    expect((await inbox('other')).single.subjectKey, card);
  });

  test('PKM changes and title-only changes leave the inbox empty', () async {
    // Legacy PKM deletes carry no before/after snapshots.
    await publish(before: {}, after: comment);
    await publish(namespace: DataChangeNs.pkmFile, op: DataChangeOp.delete);
    expect((await inbox()).single.subjectKey, card);
    await notifier.dismissOnViewed(user, card);
    await publish(namespace: DataChangeNs.pkmFile, before: {}, after: comment);
    expect(await inbox(), isEmpty);
    await publish(
        before: {...comment, 'title': 'Old'},
        after: {...comment, 'title': 'New'});
    expect(await inbox(), isEmpty);
  });
}
