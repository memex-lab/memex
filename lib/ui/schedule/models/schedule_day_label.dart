import 'package:intl/intl.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';

class ScheduleDayLabelStrings {
  const ScheduleDayLabelStrings({
    required this.yesterday,
    required this.today,
    required this.tomorrow,
    required this.thisWeek,
    required this.localeName,
  });

  final String yesterday;
  final String today;
  final String tomorrow;
  final String thisWeek;
  final String localeName;
}

String resolveScheduleDayLabel(
  TimelineDay day, {
  required DateTime referenceDate,
  required ScheduleDayLabelStrings labels,
}) {
  final storedLabel = day.dayLabel.trim();
  final dayDate = day.dayDate;
  if (dayDate == null) {
    return storedLabel.isNotEmpty ? storedLabel : labels.thisWeek;
  }

  return switch (scheduleDayOffset(dayDate, referenceDate)) {
    -1 => labels.yesterday,
    0 => labels.today,
    1 => labels.tomorrow,
    _ =>
      storedLabel.isNotEmpty && !isRelativeScheduleDayLabel(storedLabel)
          ? storedLabel
          : DateFormat.MMMEd(labels.localeName).format(dayDate),
  };
}

int scheduleDayOffset(DateTime dayDate, DateTime referenceDate) {
  final target = DateTime.utc(dayDate.year, dayDate.month, dayDate.day);
  final reference = DateTime.utc(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  return target.difference(reference).inDays;
}

bool isRelativeScheduleDayLabel(String label) {
  const relativeLabels = {'today', 'tomorrow', 'yesterday', '今天', '明天', '昨天'};
  return relativeLabels.contains(label.trim().toLowerCase());
}
