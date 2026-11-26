import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';

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

  test('a completed delete during rebuilding stays deleted from the index',
      () async {
    const user = 'review';
    await _writeCards(user, 100);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    addTearDown(db.close);
    final files = FileSystemService.instance;
    await files.rebuildCardCache(user, waitUntilIndexed: 1);
    const id = '2026/09/10.md#ts_1';
    expect(await files.deleteCard(user, id), isTrue);
    const edited = '2026/09/10.md#ts_10';
    await files.updateCardFile(
        user, edited, (card) => card.copyWith(tags: ['edited']));
    await files.waitForCardCacheRebuild();
    expect(await File(files.getCardPath(user, id)).exists(), isFalse);
    expect((await db.cardDao.getCards(tags: ['edited'])).single.factId, edited);
    expect((await db.cardDao.getCards(limit: 100)).map((row) => row.factId),
        isNot(contains(id)));
  });

  test('timeline repository returns the larger page during a rebuild',
      () async {
    const user = 'public-reader';
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveUser(user);
    await _writeCards(user, 100);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    addTearDown(db.close);
    final pages = await Future.wait(
        [getTimelineCards(limit: 20), getTimelineCards(limit: 1000)]);
    expect(pages.first, hasLength(20));
    final larger = pages.last;
    await FileSystemService.instance.waitForCardCacheRebuild();
    expect(await getTimelineCards(limit: 1000), hasLength(100));
    expect(larger.length, 100);
  });
  test('a small page can finish while an earlier full rebuild continues',
      () async {
    const user = 'large-first';
    await _writeCards(user, 100);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    addTearDown(db.close);
    final files = FileSystemService.instance;
    final full = files.rebuildCardCache(user);
    await files.rebuildCardCache(user, waitUntilIndexed: 2);
    expect(files.isCardCacheRebuilding, isTrue);
    expect(await db.cardDao.getCards(limit: 2), hasLength(2));
    await full;
    expect(await db.cardDao.getCards(limit: 100), hasLength(100));
  });

  test('the early page matches the full index order', () async {
    const userId = 'user-a';
    await _writeCards(userId, 100, body: 'x' * 32768);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    AppDatabase.setTestInstance(db);

    final outer = Zone.current;
    var fullBodyReads = 0;
    final early = await IOOverrides.runZoned(
        () async {
          await FileSystemService.instance
              .rebuildCardCache(userId, waitUntilIndexed: 1);
          final readsAtFirstPage = fullBodyReads;
          final page = await db.cardDao.getCards(limit: 1);
          await FileSystemService.instance.waitForCardCacheRebuild();
          expect(readsAtFirstPage, 1);
          expect(fullBodyReads, 100);
          return page;
        },
        fseGetType: (path, followLinks) => outer
            .run(() => FileSystemEntity.type(path, followLinks: followLinks)),
        stat: (path) => outer.run(() => FileStat.stat(path)),
        createFile: (path) {
          final file = outer.run(() => File(path));
          return path.endsWith('.yaml')
              ? _CountingFile(file, () => fullBodyReads++)
              : file;
        });
    final full = await db.cardDao.getCards(limit: 1);

    expect(early.single.factId, '2026/09/10.md#ts_99');
    expect(full.single.factId, early.single.factId);
  });
}

Future<void> _writeCards(String userId, int count,
    {String body = 'note'}) async {
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
fact: "$body"
tags: []
ui_configs: []
''');
  }
}

class _CountingFile extends Fake implements File {
  _CountingFile(this.file, this.onFullRead);
  final File file;
  final void Function() onFullRead;

  @override
  String get path => file.path;
  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) =>
      file.open(mode: mode);
  @override
  Future<bool> exists() => file.exists();
  @override
  Future<FileStat> stat() => file.stat();
  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    onFullRead();
    return file.readAsString(encoding: encoding);
  }
}
