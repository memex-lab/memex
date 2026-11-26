import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const user = 'writer';
  const id = '2025/01/15.md#ts_3';
  late FileSystemService fs;
  late List<(String, SystemEvent<DataChangeRecord>)> events;
  setUp(() async {
    final root = await Directory.systemTemp.createTemp('memex-card-events');
    addTearDown(() => root.delete(recursive: true));
    await FileSystemService.init(root.path);
    addTearDown(LocalAssetServer.stopServer);
    fs = FileSystemService.instance;
    AppDatabase.setTestInstance(
        AppDatabase.forTesting(NativeDatabase.memory()));
    addTearDown(AppDatabase.closeCurrent);
    events = [];
    GlobalEventBus.instance.subscribeSync<DataChangeRecord>(
      eventType: SystemEventTypes.dataChanged,
      subscription: EventSyncSubscription(
        subscriptionId: 'observe_card_write',
        handler: (userId, event) async => events.add((userId, event)),
      ),
    );
    addTearDown(() => GlobalEventBus.instance.unsubscribeSync(
          eventType: SystemEventTypes.dataChanged,
          subscriptionId: 'observe_card_write',
        ));
  });

  test('writing, replacing and deleting a file publish matching snapshots once',
      () async {
    const card = CardData(
        factId: id,
        timestamp: 1,
        status: 'completed',
        title: 'Original',
        uiConfigs: [],
        tags: ['walk']);
    expect(await fs.safeWriteCardFile(user, id, card), isTrue);
    final stored = (await fs.readCardFile(user, id))!.toJson();
    final updated = card.copyWith(title: 'Edited', tags: ['river']);
    expect(await fs.safeWriteCardFile(user, id, updated), isTrue);
    final edited = (await fs.readCardFile(user, id))!.toJson();
    expect(edited['title'], 'Edited');
    expect(await fs.deleteCard(user, id), isTrue);
    expect(await fs.readCardFile(user, id), isNull);
    expect(await fs.deleteCard(user, id), isFalse);
    expect(events.map((entry) => entry.$2.payload.op), [
      DataChangeOp.insert,
      DataChangeOp.update,
      DataChangeOp.delete,
    ]);
    for (final (owner, event) in events) {
      expect(owner, user);
      expect(event.source, 'file_system_service');
      expect(event.payload.ns, DataChangeNs.card);
      expect(event.payload.documentKey, id);
    }
    expect(events.map((e) => e.$2.payload.before), [null, stored, edited]);
    expect(events.map((e) => e.$2.payload.after), [stored, edited, null]);
  });

  test('an unreadable card stays untouched and emits no update', () async {
    final file = File(fs.getCardPath(user, id));
    await file.parent.create(recursive: true);
    const broken = 'title: [unterminated list';
    await file.writeAsString(broken);
    final result = await fs.updateCardFile(
        user, id, (_) => fail('unreadable card was passed to updater'));
    expect(result, isNull);
    expect(await file.readAsString(), broken);
    expect(events, isEmpty);
  });
}
