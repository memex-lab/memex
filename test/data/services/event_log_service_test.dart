import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_log_service.dart';

void main() {
  group('EventLogService', () {
    test('stores agent-readable local time with explicit timezone', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_event_log_service_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = EventLogService(dataRoot: tempDir.path);
      final fromTime =
          DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String();

      await service.logEvent(
        userId: 'test-user',
        eventType: 'user_chat',
        description: 'User sent message to agent',
      );

      final events = await service.searchEvents(
        userId: 'test-user',
        fromTime: fromTime,
        offset: 0,
        limit: 10,
      );

      expect(events, hasLength(1));
      expect(
        events.single['event_time_local'],
        matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{2}:\d{2}')),
      );
      expect(events.single['event_time_unix_seconds'], isA<int>());
    });

    test('searches legacy log lines without local-time fields', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_event_log_service_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = EventLogService(dataRoot: tempDir.path);
      final logFile = File(
        service.getEventLogPath('test-user', DateTime(2026, 4, 28)),
      );
      await logFile.parent.create(recursive: true);
      await logFile.writeAsString(
        '${jsonEncode({
              'event_type': 'user_chat',
              'description': 'legacy chat event',
              'event_time': '2026-04-28T20:00:46.000',
              'user_id': 'test-user',
            })}\n',
      );

      final events = await service.searchEvents(
        userId: 'test-user',
        fromTime: '2026-04-28T00:00:00.000',
        offset: 0,
        limit: 10,
        toTime: '2026-04-28T23:59:59.000',
      );

      expect(events, hasLength(1));
      expect(events.single['description'], 'legacy chat event');
      expect(events.single.containsKey('event_time_local'), isFalse);
    });

    test('applies event type, time range, and pagination filters', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_event_log_service_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = EventLogService(dataRoot: tempDir.path);
      final logFile = File(
        service.getEventLogPath('test-user', DateTime(2026, 4, 28)),
      );
      await logFile.parent.create(recursive: true);
      await logFile.writeAsString(
        [
          {
            'event_type': 'user_chat',
            'description': 'older chat',
            'event_time': '2026-04-28T08:00:00.000',
            'user_id': 'test-user',
          },
          {
            'event_type': 'file_modified',
            'description': 'not a chat',
            'event_time': '2026-04-28T12:00:00.000',
            'user_id': 'test-user',
          },
          {
            'event_type': 'user_chat',
            'description': 'newer chat',
            'event_time': '2026-04-28T20:00:00.000',
            'user_id': 'test-user',
          },
          {
            'event_type': 'user_chat',
            'description': 'outside range',
            'event_time': '2026-04-29T09:00:00.000',
            'user_id': 'test-user',
          },
        ].map(jsonEncode).join('\n'),
      );

      final events = await service.searchEvents(
        userId: 'test-user',
        fromTime: '2026-04-28T00:00:00.000',
        offset: 1,
        limit: 1,
        toTime: '2026-04-28T23:59:59.000',
        eventType: 'user_chat',
      );

      expect(events, hasLength(1));
      expect(events.single['description'], 'older chat');
    });

    test('ignores malformed json lines while keeping valid events', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_event_log_service_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = EventLogService(dataRoot: tempDir.path);
      final logFile = File(
        service.getEventLogPath('test-user', DateTime(2026, 4, 28)),
      );
      await logFile.parent.create(recursive: true);
      await logFile.writeAsString(
        'not-json\n'
        '${jsonEncode({
              'event_type': 'user_chat',
              'description': 'valid event',
              'event_time': '2026-04-28T20:00:46.000',
              'user_id': 'test-user',
            })}\n',
      );

      final events = await service.searchEvents(
        userId: 'test-user',
        fromTime: '2026-04-28T00:00:00.000',
        offset: 0,
        limit: 10,
      );

      expect(events, hasLength(1));
      expect(events.single['description'], 'valid event');
    });
  });
}
