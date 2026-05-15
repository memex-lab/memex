int isoWeekNumber(DateTime date) {
  // Method from https://stackoverflow.com/questions/49393231/how-to-get-day-of-year-week-of-year-from-a-datetime-dart-object
  int weekOfYear(DateTime date) {
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    DateTime firstThursday = monday.add(const Duration(days: 3));
    int week =
        ((firstThursday.difference(DateTime(firstThursday.year, 1, 1)).inDays) /
                    7)
                .floor() +
            1;
    return week;
  }

  return weekOfYear(date);
}

DateTime? parseLocalDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is int) {
    final milliseconds = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
  }
  if (value is num) {
    final milliseconds = value > 100000000000 ? value.toInt() : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds.toInt(),
      isUtc: true,
    ).toLocal();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed)?.toLocal();
  }
  return null;
}
