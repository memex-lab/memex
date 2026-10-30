/// Calendar dates, not 24-hour spans.
///
/// [DateTime.add] of one day stays on the same civil date when clocks fall
/// back, and a subtracted span can land on the previous evening when clocks
/// spring forward. Constructing `DateTime(year, month, day + 1)` follows the
/// calendar instead.
DateTime civilDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime nextCivilDay(DateTime date) =>
    DateTime(date.year, date.month, date.day + 1);

/// Inclusive civil dates from [start] through [end]. Empty when [end] is
/// before [start].
List<DateTime> civilDaysInclusive(DateTime start, DateTime end) {
  final first = civilDay(start);
  final last = civilDay(end);
  if (last.isBefore(first)) return const [];
  final days = <DateTime>[];
  var cursor = first;
  while (!cursor.isAfter(last)) {
    days.add(cursor);
    cursor = nextCivilDay(cursor);
  }
  return days;
}
