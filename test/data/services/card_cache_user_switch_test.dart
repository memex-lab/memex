import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    tempDir = await Directory.systemTemp.createTemp('memex_card_cache_switch_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('a user switch does not receive the previous rebuild', () async {
    const userId = 'user-a';
    await _writeCards(userId, 100);
    final userA = AppDatabase.forTesting(NativeDatabase.memory());
    final userB = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(userA.close);
    addTearDown(userB.close);
    AppDatabase.setTestInstance(userA);

    await FileSystemService.instance.rebuildCardCache(
      userId,
      waitUntilIndexed: 1,
    );
    AppDatabase.setTestInstance(userB);
    await FileSystemService.instance.waitForCardCacheRebuild();

    expect(await userB.cardDao.getCards(), isEmpty);
  });

  test('the early page matches the full index order', () async {
    const userId = 'user-a';
    await _writeCards(userId, 100);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    AppDatabase.setTestInstance(db);

    await FileSystemService.instance.rebuildCardCache(
      userId,
      waitUntilIndexed: 1,
    );
    final early = await db.cardDao.getCards(limit: 1);
    await FileSystemService.instance.waitForCardCacheRebuild();
    final full = await db.cardDao.getCards(limit: 1);

    expect(early.single.factId, '2026/09/10.md#ts_99');
    expect(full.single.factId, early.single.factId);
  });
}

Future<void> _writeCards(String userId, int count) async {
  final files = FileSystemService.instance;
  for (var i = 1; i <= count; i++) {
    final factId = '2026/09/10.md#ts_$i';
    final cardPath = files.getCardPath(userId, factId);
    await Directory(cardPath).parent.create(recursive: true);
    await File(cardPath).writeAsString('''
fact_id: "$factId"
timestamp: 1781971200
created_at: 1781971200
status: completed
tags: []
ui_configs: []
''');
  }
}
