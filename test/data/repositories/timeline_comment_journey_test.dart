import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/get_calendar_data.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/hydrated_card_cache.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/search_service.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('open a listed entry, post and reply, then reopen the correct thread',
      () async {
    const user = 'journal-reader';
    const older = '2026/11/25.md#ts_1';
    const newer = '2026/11/25.md#ts_2';
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveUser(user);
    final root = await Directory.systemTemp.createTemp('memex-comment');
    addTearDown(() => root.delete(recursive: true));
    await FileSystemService.init(root.path);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    addTearDown(db.close);

    for (final (id, time, text) in [
      (older, 1795564800, 'Morning walk'),
      (newer, 1795568400, 'Afternoon coffee'),
    ]) {
      final saved = await FileSystemService.instance.safeWriteCardFile(
          user,
          id,
          CardData(
              factId: id,
              timestamp: time,
              fact: text,
              tags: const [],
              status: 'completed',
              uiConfigs: const []));
      expect(saved, isTrue);
    }

    final list = await getTimelineCards();
    expect(
        list.map((card) => card.rawText), ['Afternoon coffee', 'Morning walk']);
    final id = list.first.id;
    final first = await postCommentEndpoint(id, user, 'Try the other roast');
    final firstId = first['comment_id'] as String;
    final reply =
        await postCommentEndpoint(id, user, 'Tomorrow', replyToId: firstId);

    final reopened = await getCardDetail(id);
    expect(reopened.rawContent, 'Afternoon coffee');
    final comments = reopened.insight.comments;
    expect(comments.map((c) => c.content), ['Try the other roast', 'Tomorrow']);
    expect(comments.map((c) => c.id), [firstId, reply['comment_id']]);
    expect(comments.last.replyToId, firstId);
    expect((await getCardDetail(older)).insight.comments, isEmpty);
  });
  test('find a photo note and its thread after reopening the database',
      () async {
    const user = 'photo-journal';
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveUser(user);
    final root = await Directory.systemTemp.createTemp('memex-photo-journal');
    addTearDown(() => root.delete(recursive: true));
    await FileSystemService.init(root.path);
    addTearDown(LocalAssetServer.stopServer);
    addTearDown(SearchService.instance.reset);
    final disk = File('${root.path}/journal.sqlite');
    var db = AppDatabase.forTesting(NativeDatabase(disk));
    AppDatabase.setTestInstance(db);
    addTearDown(() => db.close());

    final fs = FileSystemService.instance;
    final source = File('${root.path}/camera.png');
    await source.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    final (photo, _) = await fs.saveAssetFromFile(
        userId: user, sourcePath: source.path, assetType: 'img');
    await source.delete();
    final ids =
        await Future.wait(List.generate(2, (_) => fs.allocateCardFactId(user)));
    expect(ids.toSet(), hasLength(2));
    final id = ids.first;
    final neighbor = ids.last;
    await fs.updateCardFile(user, neighbor,
        (c) => c.copyWith(fact: 'Grocery list', status: 'completed'));
    final card = await fs.updateCardFile(
        user,
        id,
        (c) => c.copyWith(
            fact: 'Orchard blossoms',
            assets: ['![image](fs://$photo)'],
            tags: ['walk'],
            status: 'completed'));
    final listed = (await getTimelineCards(tags: ['walk'])).single;
    expect(listed.id, id);
    expect(listed.rawText, 'Orchard blossoms');
    expect(Uri.parse(listed.assets!.single.url).pathSegments.last, photo);
    final comment = await postCommentEndpoint(listed.id, user, 'Visit again');
    await postCommentEndpoint(listed.id, user, 'On Sunday',
        replyToId: comment['comment_id'] as String);

    await db.close();
    db = AppDatabase.forTesting(NativeDatabase(disk));
    AppDatabase.setTestInstance(db);
    HydratedCardCache.instance.clearAll();
    final search = SearchService.instance;
    await search.rebuildCardFtsIndex(user);
    final result = (await search.searchCards('orchard')).single;
    expect(result['fact_id'], id);
    final detail = await getCardDetail(result['fact_id'] as String);
    expect(detail.rawContent, 'Orchard blossoms');
    expect(detail.insight.comments.map((c) => c.content),
        ['Visit again', 'On Sunday']);
    expect(detail.insight.comments.last.replyToId,
        detail.insight.comments.first.id);
    final image = detail.assets.single;
    expect(image.isImage, isTrue);
    expect(Uri.parse(image.url).pathSegments.last, photo);
    final stream =
        LocalImage.provider(image.url).resolve(ImageConfiguration.empty);
    final loaded = Completer<ImageInfo>();
    final listener = ImageStreamListener((info, _) => loaded.complete(info),
        onError: loaded.completeError);
    stream.addListener(listener);
    try {
      final info = await loaded.future;
      addTearDown(info.dispose);
      expect((await info.image.toByteData())!.getUint8(3), 255);
    } finally {
      stream.removeListener(listener);
    }
    final day = card!.timestamp;
    final entries = (await getCalendarData(day, day)).single.cards;
    expect(entries.map((c) => c.id), unorderedEquals(ids));
    final other = await getCardDetail(neighbor);
    expect(other.assets, isEmpty);
    expect(other.insight.comments, isEmpty);

    await fs.updateCardFile(
        user, id, (c) => c.copyWith(fact: 'Magnolia blossoms'));
    await search.rebuildCardFtsIndex(user);
    expect(await search.searchCards('orchard'), isEmpty);
    expect((await search.searchCards('magnolia')).single['fact_id'], id);
    expect(await deleteCardEndpoint(id), isTrue);
    await search.rebuildCardFtsIndex(user);
    expect(await search.searchCards('magnolia'), isEmpty);
    expect((await getTimelineCards()).map((c) => c.id), [neighbor]);
    expect((await getCalendarData(day, day)).single.cards.map((c) => c.id),
        [neighbor]);
    expect((await search.searchCards('grocery')).single['fact_id'], neighbor);
  });
}
