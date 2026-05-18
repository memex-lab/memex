import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';

import 'package:synchronized/synchronized.dart';

/// Event logging service for tracking workspace changes
/// Logs events to daily JSONL files in EventLogs directory
class EventLogService {
  final Logger _logger = getLogger('EventLogService');
  final String dataRoot;

  // Static map to hold locks for each log file path to prevent race conditions
  // even across multiple service instances
  static final Map<String, Lock> _fileLocks = {};

  EventLogService({required this.dataRoot});

  /// Get the event log file path for a user and date
  /// Returns path like: workspace/_userId/_System/EventLogs/YYYY-MM-DD.jsonl
  String getEventLogPath(String userId, DateTime date) {
    final workspaceName = '_$userId';
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final dateStr = '$year-$month-$day';

    return path.join(
      dataRoot,
      'workspace',
      workspaceName,
      '_System',
      'EventLogs',
      '$dateStr.jsonl',
    );
  }

  /// Log an event to the event log
  ///
  /// Args:
  ///   userId: User ID
  ///   eventType: Type of event (user_input, file_created, file_modified, file_deleted, agent_execution, user_chat)
  ///   description: Human-readable description
  ///   filePath: Optional relative file path for file operations
  ///   metadata: Optional additional context
  Future<void> logEvent({
    required String userId,
    required String eventType,
    required String description,
    String? filePath,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();
      final logPath = getEventLogPath(userId, now);

      // Get or create a lock for this specific file
      // This ensures strict serialization of writes to the same file
      final lock = _fileLocks.putIfAbsent(logPath, () => Lock());

      await lock.synchronized(() async {
        // Ensure parent directory exists
        final logFile = File(logPath);
        if (!await logFile.exists()) {
          await logFile.parent.create(recursive: true);
        }

        // Create event record
        final event = {
          'event_type': eventType,
          'description': description,
          'event_time': now.toIso8601String(),
          'event_time_local': formatLocalDateTimeWithZone(now),
          'event_time_unix_seconds': unixSecondsFromDateTime(now),
          'user_id': userId,
          if (filePath != null) 'file_path': filePath,
          if (metadata != null) 'metadata': metadata,
        };

        // Append as JSONL (one line per event)
        final eventLine = '${jsonEncode(event)}\n';
        await logFile.writeAsString(
          eventLine,
          mode: FileMode.append,
          encoding: utf8,
          flush: true, // Ensure data is flushed to disk immediately
        );
      });

      _logger.fine('Event logged: $eventType - $description');
    } catch (e) {
      // Best-effort logging - don't break main operations
      _logger.warning('Failed to log event: $e');
    }
  }

  /// Search events with filtering and pagination
  ///
  /// Args:
  ///   userId: User ID
  ///   fromTime: Start time (ISO 8601 format)
  ///   offset: Skip this many events
  ///   limit: Return at most this many events
  ///   toTime: Optional end time (ISO 8601 format)
  ///   eventType: Optional filter by event type
  ///
  /// Returns:
  ///   List of event maps matching the criteria
  Future<List<Map<String, dynamic>>> searchEvents({
    required String userId,
    required String fromTime,
    required int offset,
    required int limit,
    String? toTime,
    String? eventType,
  }) async {
    try {
      final fromDate = DateTime.parse(fromTime);
      final toDate = toTime != null ? DateTime.parse(toTime) : DateTime.now();

      final workspaceName = '_$userId';
      final eventLogsDir = path.join(
        dataRoot,
        'workspace',
        workspaceName,
        '_System',
        'EventLogs',
      );

      final dir = Directory(eventLogsDir);
      if (!await dir.exists()) {
        return [];
      }

      // Collect all relevant daily log files
      final allEvents = <Map<String, dynamic>>[];

      // Iterate through dates from fromDate to toDate
      var currentDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final endDate = DateTime(toDate.year, toDate.month, toDate.day);

      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        final logPath = getEventLogPath(userId, currentDate);
        final logFile = File(logPath);

        if (await logFile.exists()) {
          final lines = await logFile.readAsLines();
          for (final line in lines) {
            if (line.trim().isEmpty) continue;

            try {
              final event = jsonDecode(line) as Map<String, dynamic>;
              final eventTime = DateTime.parse(event['event_time']);

              // Filter by time range
              if (eventTime.isBefore(fromDate) || eventTime.isAfter(toDate)) {
                continue;
              }

              // Filter by event type if specified
              if (eventType != null && event['event_type'] != eventType) {
                continue;
              }

              allEvents.add(event);
            } catch (e) {
              _logger.warning('Failed to parse event line: $e');
            }
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      // Sort by time descending (newest first)
      allEvents.sort((a, b) {
        final timeA = DateTime.parse(a['event_time']);
        final timeB = DateTime.parse(b['event_time']);
        return timeB.compareTo(timeA);
      });

      // Apply pagination
      final startIndex = offset.clamp(0, allEvents.length);
      final endIndex = (offset + limit).clamp(0, allEvents.length);

      return allEvents.sublist(startIndex, endIndex);
    } catch (e) {
      _logger.severe('Failed to search events: $e');
      return [];
    }
  }

  /// Log a user input event
  Future<void> logUserInput({
    required String userId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      userId: userId,
      eventType: 'user_input',
      description: description,
      metadata: metadata,
    );
  }

  /// Log a file created event
  Future<void> logFileCreated({
    required String userId,
    required String filePath,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      userId: userId,
      eventType: 'file_created',
      description: description ?? 'Created file: $filePath',
      filePath: filePath,
      metadata: metadata,
    );
  }

  /// Log a file modified event
  Future<void> logFileModified({
    required String userId,
    required String filePath,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      userId: userId,
      eventType: 'file_modified',
      description: description ?? 'Modified file: $filePath',
      filePath: filePath,
      metadata: metadata,
    );
  }

  /// Log a file deleted event
  Future<void> logFileDeleted({
    required String userId,
    required String filePath,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      userId: userId,
      eventType: 'file_deleted',
      description: description ?? 'Deleted file: $filePath',
      filePath: filePath,
      metadata: metadata,
    );
  }
}
