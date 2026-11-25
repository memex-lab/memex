import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/file_system_service.dart';
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
}
