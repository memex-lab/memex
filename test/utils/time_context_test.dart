import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/time_context.dart';

void main() {
  group('time context helpers', () {
    test('parses Unix seconds without losing precision', () {
      final parsed = tryParseUnixSeconds(1777377646);

      expect(parsed, isNotNull);
      expect(parsed!.millisecondsSinceEpoch, 1777377646000);
    });

    test('rounds fractional Unix seconds to milliseconds', () {
      final parsed = tryParseUnixSeconds(1.234);

      expect(parsed, isNotNull);
      expect(parsed!.millisecondsSinceEpoch, 1234);
    });

    test('rejects non numeric Unix seconds', () {
      expect(tryParseUnixSeconds('1777377646'), isNull);
      expect(tryParseUnixSeconds(null), isNull);
    });

    test('parses ISO date strings for local context decoration', () {
      final parsed = tryParseDateTime('2026-04-28T20:00:46.000');

      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 4);
      expect(parsed.day, 28);
    });

    test('rejects blank and malformed ISO date strings', () {
      expect(tryParseDateTime(''), isNull);
      expect(tryParseDateTime('not-a-date'), isNull);
      expect(formatLocalDateTimeWithZoneOrNull('not-a-date'), isNull);
    });

    test('converts date time to truncated Unix seconds', () {
      final seconds = unixSecondsFromDateTime(
        DateTime.fromMillisecondsSinceEpoch(1777377646999),
      );

      expect(seconds, 1777377646);
    });

    test('converts parseable date time values to Unix seconds', () {
      expect(
        unixSecondsFromDateTimeOrNull('2026-04-28T20:00:46.999'),
        unixSecondsFromDateTime(DateTime(2026, 4, 28, 20, 0, 46, 999)),
      );
      expect(unixSecondsFromDateTimeOrNull('not-a-date'), isNull);
    });

    test('formats timezone offsets with sign and minutes', () {
      expect(formatTimeZoneOffset(const Duration(hours: 8)), '+08:00');
      expect(
        formatTimeZoneOffset(const Duration(hours: -5, minutes: -30)),
        '-05:30',
      );
      expect(formatTimeZoneOffset(Duration.zero), '+00:00');
    });

    test('formats local date time with explicit timezone context', () {
      final formatted = formatLocalDateTimeWithZone(
        DateTime(2026, 4, 28, 20, 0, 46),
      );

      expect(formatted, contains('2026-04-28 20:00:46'));
      expect(formatted, matches(RegExp(r'[+-]\d{2}:\d{2}')));
    });

    test('builds message time prefix with explicit timezone context', () {
      final prefix = buildMessageTimePrefix(DateTime(2026, 4, 28, 20, 0, 46));

      expect(prefix, startsWith('<message_time>'));
      expect(prefix, contains('2026-04-28 20:00:46'));
      expect(prefix, matches(RegExp(r'[+-]\d{2}:\d{2}')));
    });

    test('builds current time reminder with local-time label', () {
      final reminder = buildCurrentTimeReminder(
        DateTime(2026, 4, 28, 20, 0, 46),
      );

      expect(reminder, startsWith('<system-reminder>'));
      expect(reminder, contains('Current Local Time:'));
      expect(reminder, contains('2026-04-28 20:00:46'));
      expect(reminder, endsWith('</system-reminder>\n\n'));
    });
  });
}
