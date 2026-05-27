import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:memex/domain/models/schedule_view_data.dart';
import 'package:memex/ui/schedule/models/schedule_day_label.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  group('resolveScheduleDayLabel', () {
    const labels = ScheduleDayLabelStrings(
      yesterday: 'Yesterday',
      today: 'Today',
      tomorrow: 'Tomorrow',
      thisWeek: 'This week',
      localeName: 'en',
    );

    test('recomputes stale relative labels from day dates', () {
      final reference = DateTime(2026, 5, 16, 22, 30);

      expect(
        resolveScheduleDayLabel(
          ScheduleViewTimelineDay(
              dayLabel: 'Tomorrow', dayDate: DateTime(2026, 5, 16, 8)),
          referenceDate: reference,
          labels: labels,
        ),
        'Today',
      );
      expect(
        resolveScheduleDayLabel(
          ScheduleViewTimelineDay(
            dayLabel: 'Today',
            dayDate: DateTime(2026, 5, 17, 23, 59),
          ),
          referenceDate: reference,
          labels: labels,
        ),
        'Tomorrow',
      );
      expect(
        resolveScheduleDayLabel(
          ScheduleViewTimelineDay(
              dayLabel: '明天', dayDate: DateTime(2026, 5, 15)),
          referenceDate: reference,
          labels: labels,
        ),
        'Yesterday',
      );
    });

    test('preserves custom non-relative labels for distant days', () {
      final label = resolveScheduleDayLabel(
        ScheduleViewTimelineDay(
            dayLabel: 'Launch day', dayDate: DateTime(2026, 5, 20)),
        referenceDate: DateTime(2026, 5, 16),
        labels: labels,
      );

      expect(label, 'Launch day');
    });

    test('formats distant days when stored label is relative or empty', () {
      final dayDate = DateTime(2026, 5, 20);
      final expected = DateFormat.MMMEd(labels.localeName).format(dayDate);

      expect(
        resolveScheduleDayLabel(
          ScheduleViewTimelineDay(dayLabel: 'tomorrow', dayDate: dayDate),
          referenceDate: DateTime(2026, 5, 16),
          labels: labels,
        ),
        expected,
      );
      expect(
        resolveScheduleDayLabel(
          ScheduleViewTimelineDay(dayLabel: '', dayDate: dayDate),
          referenceDate: DateTime(2026, 5, 16),
          labels: labels,
        ),
        expected,
      );
    });

    test('uses stored or fallback labels when day date is missing', () {
      expect(
        resolveScheduleDayLabel(
          const ScheduleViewTimelineDay(dayLabel: 'Unscheduled'),
          referenceDate: DateTime(2026, 5, 16),
          labels: labels,
        ),
        'Unscheduled',
      );
      expect(
        resolveScheduleDayLabel(
          const ScheduleViewTimelineDay(dayLabel: '   '),
          referenceDate: DateTime(2026, 5, 16),
          labels: labels,
        ),
        'This week',
      );
    });

    test('supports Chinese relative labels independently of UI locale', () {
      expect(isRelativeScheduleDayLabel(' 今天 '), isTrue);
      expect(isRelativeScheduleDayLabel('明天'), isTrue);
      expect(isRelativeScheduleDayLabel('昨天'), isTrue);
      expect(isRelativeScheduleDayLabel('Today'), isTrue);
      expect(isRelativeScheduleDayLabel('launch day'), isFalse);
    });
  });

  group('scheduleDayOffset', () {
    test('compares calendar dates and ignores time-of-day', () {
      expect(
        scheduleDayOffset(
          DateTime(2026, 5, 17, 0, 1),
          DateTime(2026, 5, 16, 23, 59),
        ),
        1,
      );
      expect(
        scheduleDayOffset(
          DateTime(2026, 5, 16, 23, 59),
          DateTime(2026, 5, 16, 0, 1),
        ),
        0,
      );
    });

    test('handles month and year boundaries', () {
      expect(
        scheduleDayOffset(DateTime(2027, 1, 1), DateTime(2026, 12, 31)),
        1,
      );
      expect(
        scheduleDayOffset(DateTime(2026, 12, 31), DateTime(2027, 1, 1)),
        -1,
      );
    });
  });
}
