import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/date_util.dart';

void main() {
  group('parseLocalDateTime', () {
    test('keeps offset timestamps as the same local instant', () {
      final parsed = parseLocalDateTime('2026-05-15T15:00:00+08:00');

      expect(parsed, DateTime.parse('2026-05-15T15:00:00+08:00').toLocal());
      expect(parsed?.toUtc(), DateTime.utc(2026, 5, 15, 7));
    });

    test('keeps timezone-less timestamps in local time', () {
      final parsed = parseLocalDateTime('2026-05-15 15:00:00');

      expect(parsed, DateTime(2026, 5, 15, 15));
    });

    test('parses unix seconds and milliseconds as UTC instants', () {
      final instant = DateTime.utc(2026, 5, 15, 7);

      expect(
        parseLocalDateTime(instant.millisecondsSinceEpoch)?.toUtc(),
        instant,
      );
      expect(
        parseLocalDateTime(instant.millisecondsSinceEpoch ~/ 1000)?.toUtc(),
        instant,
      );
    });

    test('returns null for blank or invalid values', () {
      expect(parseLocalDateTime(' '), isNull);
      expect(parseLocalDateTime('not a date'), isNull);
      expect(parseLocalDateTime(null), isNull);
    });
  });
}
