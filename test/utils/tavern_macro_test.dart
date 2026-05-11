import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/tavern_macro.dart';

void main() {
  group('TavernMacro.resolve', () {
    test('replaces {{user}} case-insensitively', () {
      expect(
        TavernMacro.resolve(
          'Hello {{user}}! And {{User}} again.',
          userName: 'Alice',
          charName: 'Bob',
        ),
        'Hello Alice! And Alice again.',
      );
    });

    test('replaces {{char}} case-insensitively', () {
      expect(
        TavernMacro.resolve(
          '{{char}} says hi. {{CHAR}} too.',
          userName: 'Alice',
          charName: 'Bob',
        ),
        'Bob says hi. Bob too.',
      );
    });

    test('replaces {{time}} with HH:mm and timezone offset', () {
      final result = TavernMacro.resolve(
        'Now is {{time}}',
        userName: 'Alice',
        charName: 'Bob',
      );
      // Should match HH:mm +/-HH:MM pattern
      expect(RegExp(r'Now is \d{2}:\d{2} [+-]\d{2}:\d{2}').hasMatch(result),
          isTrue);
    });

    test('replaces {{date}} with yyyy-MM-dd format', () {
      final result = TavernMacro.resolve(
        'Today is {{date}}',
        userName: 'Alice',
        charName: 'Bob',
      );
      expect(RegExp(r'Today is \d{4}-\d{2}-\d{2}').hasMatch(result), isTrue);
    });

    test('leaves unknown macros untouched', () {
      expect(
        TavernMacro.resolve(
          '{{unknown}} stays',
          userName: 'Alice',
          charName: 'Bob',
        ),
        '{{unknown}} stays',
      );
    });

    test('returns text unchanged when no macros present', () {
      const text = 'No macros here at all.';
      expect(
        TavernMacro.resolve(text, userName: 'Alice', charName: 'Bob'),
        text,
      );
    });

    test('handles multiple macros in one string', () {
      final result = TavernMacro.resolve(
        '{{char}} shouldn\'t refrain from using explicit words for body parts. {{char}} is a destroyer.',
        userName: 'Alice',
        charName: 'Error',
      );
      expect(
        result,
        'Error shouldn\'t refrain from using explicit words for body parts. Error is a destroyer.',
      );
    });
  });
}
