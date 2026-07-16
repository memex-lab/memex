import 'package:memex/domain/models/character_message.dart';
import 'package:test/test.dart';

void main() {
  test('recognizes standalone emoji sequences without treating text as emoji',
      () {
    expect(isStandaloneEmoji('🙂'), isTrue);
    expect(isStandaloneEmoji('❤️'), isTrue);
    expect(isStandaloneEmoji('👨‍👩‍👧'), isTrue);
    expect(isStandaloneEmoji('1️⃣'), isTrue);
    expect(isStandaloneEmoji('🙂🙂'), isFalse);
    expect(isStandaloneEmoji('[smile]'), isFalse);
    expect(isStandaloneEmoji('晚安🙂'), isFalse);
  });

  test('parses typed messages and preserves legacy text messages', () {
    final messages = parseCharacterOutgoingMessages([
      {'type': 'text', 'content': '早点睡。'},
      {'type': 'emoji', 'content': '🌙'},
      '明天见。',
      '🙂',
    ]);

    expect(messages[0], CharacterOutgoingMessage.text('早点睡。'));
    expect(messages[1], CharacterOutgoingMessage.emoji('🌙'));
    expect(messages[2], CharacterOutgoingMessage.text('明天见。'));
    expect(messages[3], CharacterOutgoingMessage.emoji('🙂'));
    expect(messages.map((message) => message.storageType), [
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.emoji,
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.emoji,
    ]);
  });
}
