import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';

void main() {
  group('renderEventLogSearchResultsForAgent', () {
    test('uses stored local time and unix seconds when available', () {
      final output = renderEventLogSearchResultsForAgent(
        [
          {
            'event_type': 'user_chat',
            'description': 'User sent message to agent',
            'event_time': '2026-04-28T12:00:46.000Z',
            'event_time_local': '2026-04-28 20:00:46 +08:00 (CST)',
            'event_time_unix_seconds': 1777387246,
            'metadata': {'session_id': 's1'},
          },
        ],
        effectiveLimit: 10,
        effectiveOffset: 0,
      );

      expect(output, contains('Local Time: 2026-04-28 20:00:46 +08:00 (CST)'));
      expect(output, contains('Unix Seconds: 1777387246'));
      expect(output, contains('Raw Time: 2026-04-28T12:00:46.000Z'));
      expect(output, contains('Metadata: {session_id: s1}'));
    });

    test('falls back to raw event_time for legacy events', () {
      final output = renderEventLogSearchResultsForAgent(
        [
          {
            'event_type': 'user_chat',
            'description': 'Legacy chat event',
            'event_time': '2026-04-28T20:00:46.000',
          },
        ],
        effectiveLimit: 10,
        effectiveOffset: 0,
      );

      expect(output, contains('Local Time: 2026-04-28 20:00:46'));
      expect(output, contains('Raw Time: 2026-04-28T20:00:46.000'));
    });

    test('keeps rendering useful output when legacy time is malformed', () {
      final output = renderEventLogSearchResultsForAgent(
        [
          {
            'event_type': 'user_chat',
            'description': 'Malformed timestamp event',
            'event_time': 'not-a-date',
          },
        ],
        effectiveLimit: 10,
        effectiveOffset: 0,
      );

      expect(output, contains('Local Time: Unknown'));
      expect(output, contains('Raw Time: not-a-date'));
      expect(output, contains('Malformed timestamp event'));
    });

    test('includes pagination hint only when the page is full', () {
      final fullPageOutput = renderEventLogSearchResultsForAgent(
        [
          {'event_type': 'user_chat', 'description': 'first'},
          {'event_type': 'user_chat', 'description': 'second'},
        ],
        effectiveLimit: 2,
        effectiveOffset: 4,
      );

      final partialPageOutput = renderEventLogSearchResultsForAgent(
        [
          {'event_type': 'user_chat', 'description': 'only'},
        ],
        effectiveLimit: 2,
        effectiveOffset: 0,
      );

      expect(fullPageOutput, contains('offset=6'));
      expect(partialPageOutput, contains('Showing all 1 events'));
      expect(partialPageOutput, isNot(contains('offset=')));
    });
  });
}
