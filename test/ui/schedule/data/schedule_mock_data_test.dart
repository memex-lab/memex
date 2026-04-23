import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/schedule/data/schedule_mock_data.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';

void main() {
  group('ScheduleMockData', () {
    test('dailyFocusData returns non-empty list', () {
      final data = ScheduleMockData.dailyFocusData;
      expect(data, isNotEmpty);
      expect(data.length, greaterThanOrEqualTo(3));
    });

    test('dailyFocusData contains both events and todos', () {
      final data = ScheduleMockData.dailyFocusData;
      final events = data.where((i) => i.type == ScheduleItemType.event);
      final todos = data.where((i) => i.type == ScheduleItemType.todo);

      expect(events, isNotEmpty);
      expect(todos, isNotEmpty);
    });

    test('weeklyOverviewData contains items across multiple days', () {
      final data = ScheduleMockData.weeklyOverviewData;
      expect(data, isNotEmpty);

      // Should have items with different start times
      final startTimes = data
          .where((i) => i.startTime != null)
          .map((i) => i.startTime!.day)
          .toSet();
      expect(startTimes.length, greaterThanOrEqualTo(2));
    });

    test('smartAgendaData has priority-based ordering', () {
      final data = ScheduleMockData.smartAgendaData;
      expect(data, isNotEmpty);

      final withPriority = data.where((i) => i.priority != null);
      expect(withPriority, isNotEmpty);
    });

    test('adaptiveCardData has diverse items for testing card styles', () {
      final data = ScheduleMockData.adaptiveCardData;
      expect(data, isNotEmpty);

      // Should have items with different priorities for different card styles
      final highPriority = data.where((i) => i.priority == 3);
      final withDescription = data.where((i) =>
          i.description != null && i.description!.length > 30);

      expect(highPriority, isNotEmpty);
      expect(withDescription, isNotEmpty);
    });

    test('conversationalData has mixed statuses', () {
      final data = ScheduleMockData.conversationalData;
      expect(data, isNotEmpty);

      final completed = data.where((i) =>
          i.status == ScheduleItemStatus.completed);
      final pending = data.where((i) =>
          i.status == ScheduleItemStatus.pending);

      expect(completed, isNotEmpty);
      expect(pending, isNotEmpty);
    });

    test('magazineData has a hero-worthy item (priority 3 event)', () {
      final data = ScheduleMockData.magazineData;
      expect(data, isNotEmpty);

      final heroCandidates = data.where((i) =>
          i.type == ScheduleItemType.event &&
          i.priority == 3 &&
          i.status != ScheduleItemStatus.completed);
      expect(heroCandidates, isNotEmpty);
    });

    test('all mock datasets have unique IDs', () {
      final allData = [
        ...ScheduleMockData.dailyFocusData,
        ...ScheduleMockData.weeklyOverviewData,
        ...ScheduleMockData.smartAgendaData,
        ...ScheduleMockData.adaptiveCardData,
        ...ScheduleMockData.conversationalData,
        ...ScheduleMockData.magazineData,
      ];

      final ids = allData.map((i) => i.id).toList();
      final uniqueIds = ids.toSet();

      expect(uniqueIds.length, ids.length,
          reason: 'All mock items should have unique IDs');
    });
  });
}
