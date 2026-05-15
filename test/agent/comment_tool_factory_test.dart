import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/agent/skills/comment_agent/tools/comment_tools.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('CommentToolFactory SaveComment reply routing', () {
    late Directory tempRoot;
    late AppDatabase db;
    late String userId;
    const cardId = '2026/05/15.md#ts_1';
    const characterId = 'char-a';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'comment_tool_${DateTime.now().microsecondsSinceEpoch}';
      await UserStorage.saveUser(userId);

      tempRoot = await Directory.systemTemp.createTemp('memex_comment_tool_');
      await FileSystemService.init(tempRoot.path);

      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      await db.searchDao.createFtsTables();

      await _writeCard(
        userId: userId,
        cardId: cardId,
        comments: const [
          CardComment(
            id: 'char-comment',
            content: 'I am the original character comment.',
            isAi: true,
            timestamp: 1000,
            characterId: characterId,
          ),
          CardComment(
            id: 'user-comment',
            content: 'User replied to the character.',
            isAi: false,
            timestamp: 1001,
            replyToId: 'char-comment',
          ),
        ],
      );
    });

    tearDown(() async {
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test(
        'forcedReplyToId pins AI reply to the user comment even when '
        'the model supplies the original character comment id', () async {
      final tool = CommentToolFactory(
        userId: userId,
        cardId: cardId,
        characterId: characterId,
        forcedReplyToId: 'user-comment',
      ).buildSaveCommentTool();

      await Function.apply(tool.executable!, [
        'Character answer to the user.',
        'char-comment',
      ]);

      final latest = await _latestComment(userId, cardId);
      expect(latest.isAi, isTrue);
      expect(latest.characterId, characterId);
      expect(latest.replyToId, 'user-comment');

      final timeline = await CharacterMemoryService.instance.loadTimelineLines(
        userId,
        characterId,
      );
      expect(timeline.join('\n'), contains('"reply_to_id":"user-comment"'));
      expect(
        timeline.join('\n'),
        isNot(contains('"reply_to_id":"char-comment"')),
      );
    });

    test(
        'forcedReplyToId still attaches to the user comment when '
        'the model leaves reply_to_id empty', () async {
      final tool = CommentToolFactory(
        userId: userId,
        cardId: cardId,
        characterId: characterId,
        forcedReplyToId: 'user-comment',
      ).buildSaveCommentTool();

      await Function.apply(tool.executable!, [
        'Character answer without explicit tool routing.',
        '',
      ]);

      final latest = await _latestComment(userId, cardId);
      expect(latest.replyToId, 'user-comment');
    });

    test(
      'without forcedReplyToId, SaveComment preserves a valid model-supplied '
      'reply target for character-to-character interactions',
      () async {
        final tool = CommentToolFactory(
          userId: userId,
          cardId: cardId,
          characterId: characterId,
        ).buildSaveCommentTool();

        await Function.apply(tool.executable!, [
          'Character builds on another character.',
          'char-comment',
        ]);

        final latest = await _latestComment(userId, cardId);
        expect(latest.replyToId, 'char-comment');
      },
    );

    test('empty reply_to_id is normalized to a top-level comment', () async {
      final tool = CommentToolFactory(
        userId: userId,
        cardId: cardId,
        characterId: characterId,
      ).buildSaveCommentTool();

      await Function.apply(tool.executable!, [
        'Top-level character comment.',
        '   ',
      ]);

      final latest = await _latestComment(userId, cardId);
      expect(latest.replyToId, isNull);
    });
  });
}

Future<void> _writeCard({
  required String userId,
  required String cardId,
  required List<CardComment> comments,
}) async {
  await FileSystemService.instance.safeWriteCardFile(
    userId,
    cardId,
    CardData(
      factId: cardId,
      timestamp: 1000,
      status: 'done',
      tags: const [],
      uiConfigs: const [],
      title: 'Reply routing fixture',
      comments: comments,
    ),
  );
}

Future<CardComment> _latestComment(String userId, String cardId) async {
  final card = await FileSystemService.instance.readCardFile(userId, cardId);
  expect(card, isNotNull);
  expect(card!.comments, isNotEmpty);
  return card.comments.last;
}
