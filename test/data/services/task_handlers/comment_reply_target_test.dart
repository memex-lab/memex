import 'package:memex/data/services/task_handlers/comment_agent_handler.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:test/test.dart';

void main() {
  group('resolveReplyTargetCharacterId', () {
    const comments = [
      CardComment(
        id: 'a1',
        content: 'Character A first',
        isAi: true,
        timestamp: 1,
        characterId: 'char-a',
      ),
      CardComment(
        id: 'b1',
        content: 'Character B later',
        isAi: true,
        timestamp: 2,
        characterId: 'char-b',
      ),
      CardComment(
        id: 'u1',
        content: 'User replied to A',
        isAi: false,
        timestamp: 3,
        replyToId: 'a1',
      ),
      CardComment(
        id: 'u2',
        content: 'User replied to their own reply',
        isAi: false,
        timestamp: 4,
        replyToId: 'u1',
      ),
    ];

    test('direct reply to an AI comment uses that character', () {
      expect(resolveReplyTargetCharacterId(comments, 'a1'), 'char-a');
      expect(resolveReplyTargetCharacterId(comments, 'b1'), 'char-b');
    });

    test('reply to a user comment walks the chain to the thread owner', () {
      expect(resolveReplyTargetCharacterId(comments, 'u1'), 'char-a');
      expect(resolveReplyTargetCharacterId(comments, 'u2'), 'char-a');
    });

    test('unknown or cyclic reply ids return null', () {
      expect(resolveReplyTargetCharacterId(comments, 'missing'), isNull);
      expect(
        resolveReplyTargetCharacterId(
          const [
            CardComment(
              id: 'loop-a',
              content: 'loop',
              isAi: false,
              timestamp: 1,
              replyToId: 'loop-b',
            ),
            CardComment(
              id: 'loop-b',
              content: 'loop',
              isAi: false,
              timestamp: 2,
              replyToId: 'loop-a',
            ),
          ],
          'loop-a',
        ),
        isNull,
      );
    });
  });
}
