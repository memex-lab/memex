import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/time_context.dart';

void main() {
  group('time context helpers', () {
    test('parses Unix seconds without losing precision', () {
      final parsed = tryParseUnixSeconds(1777377646);

      expect(parsed, isNotNull);
      expect(parsed!.millisecondsSinceEpoch, 1777377646000);
    });

    test('formats timezone offsets with sign and minutes', () {
      expect(formatTimeZoneOffset(const Duration(hours: 8)), '+08:00');
      expect(
        formatTimeZoneOffset(const Duration(hours: -5, minutes: -30)),
        '-05:30',
      );
    });

    test('formats local date time with explicit timezone context', () {
      final formatted = formatLocalDateTimeWithZone(
        DateTime(2026, 4, 28, 20, 0, 46),
      );

      expect(formatted, contains('2026-04-28 20:00:46'));
      expect(formatted, matches(RegExp(r'[+-]\d{2}:\d{2}')));
    });
  });
}
