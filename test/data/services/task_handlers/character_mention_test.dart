import 'package:test/test.dart';
import 'package:memex/data/services/task_handlers/character_mention.dart';

void main() {
  group('indexOfStandaloneMention', () {
    test('matches a mention surrounded by whitespace', () {
      expect(indexOfStandaloneMention('hello @Bob there', '@Bob'), 6);
    });

    test('matches a mention at the start or end of the string', () {
      expect(indexOfStandaloneMention('@Bob', '@Bob'), 0);
      expect(indexOfStandaloneMention('ping @Bob', '@Bob'), 5);
    });

    test('matches when the mention is followed by punctuation', () {
      expect(indexOfStandaloneMention('see @Bob.', '@Bob'), 4);
    });

    test('does not match a longer token that shares a prefix', () {
      expect(indexOfStandaloneMention('hello @Bobby', '@Bob'), -1);
      expect(indexOfStandaloneMention('@Anne hi', '@Ann'), -1);
    });

    test('does not match an email-style prefix', () {
      expect(indexOfStandaloneMention('mail@Bob.com', '@Bob'), -1);
    });

    test('returns the first standalone mention when a prefix also appears', () {
      expect(
        indexOfStandaloneMention('@Bobby and @Bob later', '@Bob'),
        11,
      );
    });
  });
}
