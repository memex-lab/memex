import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/time_context.dart';

/// Build a tool for searching event logs
///
/// Allows agents to query historical events to understand context
Tool buildSearchEventLogsTool() {
  return Tool(
    name: 'search_workspace_event_logs',
    description:
        '''Search event logs to understand what has happened in the workspace.

**⚠️ IMPORTANT LIMITATION**: Event logging started on **January 23, 2026**. Events before this date are NOT recorded. For historical data before Jan 23, 2026, you MUST search the workspace files directly instead of relying on event logs.

**IMPORTANT: Use this tool FIRST before blindly searching through files or making decisions.**

This tool provides a chronological view of workspace activities:
- User inputs and submissions
- File operations (create, modify, delete)
- Agent executions and their outcomes
- User-agent conversations

**Best Practice**:
When a user asks about recent activities or when you need context to complete a task:
1. **Start with event logs**: Query with an appropriate time range (e.g., last 24 hours, last week)
2. **Understand the timeline**: Review what happened chronologically to get the full picture
3. **Make informed decisions**: Use this context to provide accurate answers or take appropriate actions

**Example Use Cases**:
- "What did the user do today?" → Query events from today's 00:00
- "What files changed recently?" → Check latest file operations
- "What did previous agents do?" → Review agent executions
- "Show me user's recent conversations" → Review chat history

This approach is far more efficient than randomly searching files and ensures you have proper context.

Returns:
A list of events sorted by time (newest first), each containing:
- event_type: Type of event
- description: Human-readable description
- local_time: When the event occurred in the user's local timezone, including explicit UTC offset
- raw_event_time: Original stored timestamp
- file_path: File path (for file operations)
- metadata: Additional context
''',
    parameters: {
      'type': 'object',
      'properties': {
        'from_time': {
          'type': 'string',
          'description':
              'Start time in ISO 8601 format (e.g., "2026-01-21T00:00:00+08:00")',
        },
        'limit': {
          'type': 'integer',
          'description':
              'Maximum number of events to return (default: 50, max: 200)',
        },
        'offset': {
          'type': 'integer',
          'description': 'Number of events to skip for pagination (default: 0)',
        },
        'to_time': {
          'type': 'string',
          'description': 'Optional end time in ISO 8601 format (default: now)',
        },
      },
      'required': ['from_time'],
    },
    executable:
        (String fromTime, int? limit, int? offset, String? toTime) async {
      final effectiveLimit = (limit ?? 50).clamp(1, 200);
      final effectiveOffset = (offset ?? 0).clamp(0, 10000);

      try {
        final fileService = FileSystemService.instance;
        final userId = AgentCallToolContext.current!.state.metadata['userId'];
        final events = await fileService.eventLogService.searchEvents(
          userId: userId,
          fromTime: fromTime,
          offset: effectiveOffset,
          limit: effectiveLimit,
          toTime: toTime,
        );

        if (events.isEmpty) {
          return 'No events found matching the criteria.';
        }

        return renderEventLogSearchResultsForAgent(
          events,
          effectiveLimit: effectiveLimit,
          effectiveOffset: effectiveOffset,
        );
      } catch (e) {
        throw StateError('Error searching event logs: $e');
      }
    },
  );
}

String renderEventLogSearchResultsForAgent(
  List<Map<String, dynamic>> events, {
  required int effectiveLimit,
  required int effectiveOffset,
}) {
  final buffer = StringBuffer();
  buffer.writeln('Found ${events.length} events:');
  buffer.writeln();

  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    final localTime = event['event_time_local'] as String? ??
        formatLocalDateTimeWithZoneOrNull(event['event_time']) ??
        'Unknown';
    buffer.writeln('--- Event ${i + 1} ---');
    buffer.writeln('Local Time: $localTime');
    if (event['event_time_unix_seconds'] != null) {
      buffer.writeln('Unix Seconds: ${event['event_time_unix_seconds']}');
    }
    if (event['event_time'] != null) {
      buffer.writeln('Raw Time: ${event['event_time']}');
    }
    buffer.writeln('Type: ${event['event_type']}');
    buffer.writeln('Description: ${event['description']}');

    if (event['file_path'] != null) {
      buffer.writeln('File: ${event['file_path']}');
    }

    if (event['metadata'] != null) {
      buffer.writeln('Metadata: ${event['metadata']}');
    }

    buffer.writeln();
  }

  if (events.length == effectiveLimit) {
    buffer.writeln(
      '⚠️ Returned exactly $effectiveLimit events (the limit).',
    );
    buffer.writeln('There might be more events available. To see more:');
    buffer.writeln(
      '- Use offset=${effectiveOffset + effectiveLimit} to see next page',
    );
    buffer.writeln('- Or increase limit (max: 200) to see more at once');
  } else {
    buffer.writeln(
      'Showing all ${events.length} events matching the criteria.',
    );
  }

  return buffer.toString();
}
