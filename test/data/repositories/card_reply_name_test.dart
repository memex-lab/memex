import 'package:memex/data/repositories/card.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:test/test.dart';

void main() {
  group('withResolvedReplyNames', () {
    test('resolves an AI reply to a user comment as the display name', () {
      const userDisplayName = 'You';
      final comments = [
        Comment(
          id: 'u1',
          content: 'User comment',
          isAi: false,
          timestamp: 1000,
        ),
        Comment(
          id: 'a1',
          content: 'AI reply',
          isAi: true,
          timestamp: 1001,
          character: CharacterInfo(
            id: 'char-yaoyao',
            name: 'YaoYao',
            tags: const [],
          ),
          replyToId: 'u1',
        ),
      ];

      final resolved = withResolvedReplyNames(
        comments,
        userDisplayName: userDisplayName,
      );

      expect(resolved[1].replyToName, userDisplayName);
      expect(resolved[1].replyToName, isNot('raw-user-id'));
      expect(
          commentReplyNameMap(comments, userDisplayName: userDisplayName)['u1'],
          userDisplayName);
    });

    test('resolves an AI reply to another character by character name', () {
      final comments = [
        Comment(
          id: 'a1',
          content: 'First character',
          isAi: true,
          timestamp: 1000,
          character: CharacterInfo(
            id: 'char-yaoyao',
            name: 'YaoYao',
            tags: const [],
          ),
        ),
        Comment(
          id: 'a2',
          content: 'Second character replies',
          isAi: true,
          timestamp: 1001,
          character: CharacterInfo(
            id: 'char-other',
            name: 'Other',
            tags: const [],
          ),
          replyToId: 'a1',
        ),
      ];

      final resolved = withResolvedReplyNames(
        comments,
        userDisplayName: 'You',
      );

      expect(resolved[1].replyToName, 'YaoYao');
    });

    test('does not use a raw userId as the user display name', () {
      const userDisplayName = 'You';
      const rawUserId = 'user_abc123';
      final comments = [
        Comment(
          id: 'u1',
          content: 'User comment',
          isAi: false,
          timestamp: 1000,
        ),
        Comment(
          id: 'a1',
          content: 'AI reply',
          isAi: true,
          timestamp: 1001,
          character: CharacterInfo(
            id: 'char-yaoyao',
            name: 'YaoYao',
            tags: const [],
          ),
          replyToId: 'u1',
        ),
      ];

      final resolved = withResolvedReplyNames(
        comments,
        userDisplayName: userDisplayName,
      );

      expect(resolved[1].replyToName, 'You');
      expect(resolved[1].replyToName, isNot(rawUserId));
      expect(
        replyDisplayNameFor(comments.first, userDisplayName),
        userDisplayName,
      );
    });
  });
}
