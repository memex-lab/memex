import 'package:memex/domain/models/character_emoji.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:test/test.dart';

void main() {
  test('recognizes emoji-only bubbles without treating mixed text as emoji',
      () {
    expect(isEmojiOnlyMessage('🙂'), isTrue);
    expect(isEmojiOnlyMessage('❤️'), isTrue);
    expect(isEmojiOnlyMessage('👨‍👩‍👧'), isTrue);
    expect(isEmojiOnlyMessage('1️⃣'), isTrue);
    expect(isEmojiOnlyMessage('🙂🙂'), isTrue);
    expect(isEmojiOnlyMessage('🇨🇳🇯🇵'), isTrue);
    expect(isEmojiOnlyMessage('[smile]'), isFalse);
    expect(isEmojiOnlyMessage('晚安🙂'), isFalse);
    expect(isEmojiOnlyMessage('1️⃣2'), isFalse);
  });

  test('maps stable agent emoji ids to Unicode and Fluent assets', () {
    expect(CharacterEmoji.fromAgentId('warm_smile'), CharacterEmoji.warmSmile);
    expect(CharacterEmoji.fromGlyph('😊'), CharacterEmoji.warmSmile);
    expect(CharacterEmoji.fromGlyph('❤'), CharacterEmoji.heart);
    expect(CharacterEmoji.fromAgentId('unknown'), isNull);
    expect(
      CharacterEmoji.warmSmile.assetFileName,
      'smiling_face_with_smiling_eyes_3d.png',
    );
  });

  test('classifies text and appends the selected Fluent emoji gesture', () {
    final messages = parseCharacterOutgoingMessages(
      [
        '早点睡。',
        '明天见。',
        {'type': 'emoji', 'content': '[smile]'},
        {'type': 'text', 'content': '🙂'},
        {'unexpected': true},
      ],
      emojiId: 'moon',
    );

    expect(messages[0], CharacterOutgoingMessage.text('早点睡。'));
    expect(messages[1], CharacterOutgoingMessage.text('明天见。'));
    expect(messages[2], CharacterOutgoingMessage.text('[smile]'));
    expect(messages[3], CharacterOutgoingMessage.emoji('🙂'));
    expect(messages[4], CharacterOutgoingMessage.emoji('🌙'));
    expect(messages.map((message) => message.storageType), [
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.emoji,
      PersonaChatMessageTypes.emoji,
    ]);
  });

  test('supports an emoji-only reply and rejects an unknown emoji id', () {
    expect(
      parseCharacterOutgoingMessages(null, emojiId: 'wave'),
      [CharacterOutgoingMessage.emoji('👋')],
    );
    expect(
      () => parseCharacterOutgoingMessages(null, emojiId: 'not_supported'),
      throwsArgumentError,
    );
  });

  test('fails when Speak contains neither text nor an emoji gesture', () {
    expect(
      () => parseCharacterOutgoingMessages([
        {'type': 'emoji'},
        null,
        '',
      ]),
      throwsArgumentError,
    );
  });
}
