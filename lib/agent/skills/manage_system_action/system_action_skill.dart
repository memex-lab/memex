import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/logger.dart';
import 'package:uuid/uuid.dart';

final _logger = getLogger('SystemActionSkill');

/// Lets the SuperAgent prepare device calendar and reminder actions.
///
/// The skill deliberately stops at a local, pending [SystemAction]. The user
/// must still confirm the action in the UI before Memex requests OS permission
/// and writes to the device's native Calendar or Reminders store.
class SystemActionSkill extends Skill {
  SystemActionSkill({super.forceActivate})
      : super(
          name: 'manage_calendar_and_reminders',
          description:
              'Prepares a calendar event or reminder for the user to review '
              'and add with the device native Calendar or Reminders app. Use '
              'only when the user explicitly asks to schedule or be reminded.',
          systemPrompt: _systemPrompt,
          tools: _buildTools(),
        );

  static const _systemPrompt = '''
## Calendar and reminder actions

Use this skill only when the user explicitly asks you to create a calendar
event or reminder. A mention of a date, a plan, a historical event, or a bug
report is not permission to create one.

- Resolve relative dates from the Current Local Time supplied in context.
- Pass local date-times as `YYYY-MM-DD HH:MM:SS`.
- Use `create_calendar_event` for an event with a scheduled start.
- Use `create_reminder` for a task or prompt with a specific due time. If the
  user did not provide enough information to resolve that time, ask instead of
  guessing.
- Each tool creates a pending proposal. The user must review it and press the
  add button before Memex requests system permission and writes to the device.
- Never claim the event or reminder is already in the device app after this
  tool succeeds. Say it is ready for confirmation in the attached card.
- Do not create a Timeline record unless the user separately asks to capture
  the information as a record.
''';

  static List<Tool> _buildTools() {
    return [
      Tool(
        name: 'create_calendar_event',
        description:
            'Prepares a calendar event for user confirmation. It does not '
            'write to the device calendar until the user confirms in the UI.',
        parameters: {
          'type': 'object',
          'properties': {
            'title': {
              'type': 'string',
              'description': 'The event title.',
            },
            'start_time': {
              'type': 'string',
              'description':
                  "Local event start in 'YYYY-MM-DD HH:MM:SS' format.",
            },
            'end_time': {
              'type': 'string',
              'description':
                  "Optional local event end in 'YYYY-MM-DD HH:MM:SS' format.",
            },
            'notes': {
              'type': 'string',
              'description': 'Optional event details.',
            },
            'location': {
              'type': 'string',
              'description': 'Optional event location.',
            },
          },
          'required': ['title', 'start_time'],
        },
        executable: (
          String title,
          String startTime,
          String? endTime,
          String? notes,
          String? location,
        ) async {
          try {
            final normalizedTitle = _requiredText(title, field: 'title');
            final start = _requiredDateTime(
              startTime,
              field: 'start_time',
            );
            final end = _optionalDateTime(endTime, field: 'end_time');
            if (end != null && !end.isAfter(start)) {
              throw ArgumentError.value(
                endTime,
                'end_time',
                'must be later than start_time',
              );
            }

            final denied = await gateMutatingToolCall(
              toolName: 'create_calendar_event',
              summary: '$normalizedTitle · ${_wireDateTime(start)}',
            );
            if (denied != null) return denied;

            final actionId = const Uuid().v4();
            await SystemActionService.instance.createAction(
              id: actionId,
              type: 'calendar',
              data: {
                'title': normalizedTitle,
                'start_time': _wireDateTime(start),
                if (end != null) 'end_time': _wireDateTime(end),
                if (_optionalText(notes) case final value?) 'notes': value,
                if (_optionalText(location) case final value?)
                  'location': value,
              },
            );

            final artifact = ChatArtifact.systemAction(
              actionId: actionId,
              systemActionKind: 'calendar',
              title: normalizedTitle,
              summary: _wireDateTime(start),
              updated: false,
            );
            return AgentToolResult(
              content: TextPart(
                "Prepared calendar event '$normalizedTitle' for user "
                'confirmation (Action ID: $actionId). It has not been written '
                'to the device calendar yet.',
              ),
              metadata: {'artifact': artifact.toJson()},
            );
          } catch (error, stackTrace) {
            _logger.severe(
              'Failed to prepare calendar event',
              error,
              stackTrace,
            );
            rethrow;
          }
        },
      ),
      Tool(
        name: 'create_reminder',
        description:
            'Prepares a reminder for user confirmation. It does not write to '
            'the device until the user confirms in the UI.',
        parameters: {
          'type': 'object',
          'properties': {
            'title': {
              'type': 'string',
              'description': 'The reminder title.',
            },
            'due_date': {
              'type': 'string',
              'description':
                  "Required local due time in 'YYYY-MM-DD HH:MM:SS' format.",
            },
            'notes': {
              'type': 'string',
              'description': 'Optional reminder details.',
            },
          },
          'required': ['title', 'due_date'],
        },
        executable: (
          String title,
          String? dueDate,
          String? notes,
        ) async {
          try {
            final normalizedTitle = _requiredText(title, field: 'title');
            final due = _requiredDateTime(
              dueDate ?? '',
              field: 'due_date',
            );

            final denied = await gateMutatingToolCall(
              toolName: 'create_reminder',
              summary: '$normalizedTitle · ${_wireDateTime(due)}',
            );
            if (denied != null) return denied;

            final actionId = const Uuid().v4();
            await SystemActionService.instance.createAction(
              id: actionId,
              type: 'reminder',
              data: {
                'title': normalizedTitle,
                'due_date': _wireDateTime(due),
                if (_optionalText(notes) case final value?) 'notes': value,
              },
            );

            final artifact = ChatArtifact.systemAction(
              actionId: actionId,
              systemActionKind: 'reminder',
              title: normalizedTitle,
              summary: _wireDateTime(due),
              updated: false,
            );
            return AgentToolResult(
              content: TextPart(
                "Prepared reminder '$normalizedTitle' for user confirmation "
                '(Action ID: $actionId). It has not been written to the '
                'device yet.',
              ),
              metadata: {'artifact': artifact.toJson()},
            );
          } catch (error, stackTrace) {
            _logger.severe(
              'Failed to prepare reminder',
              error,
              stackTrace,
            );
            rethrow;
          }
        },
      ),
    ];
  }

  static String _requiredText(String value, {required String field}) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
    return normalized;
  }

  static String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static DateTime _requiredDateTime(
    String value, {
    required String field,
  }) {
    final parsed = parseLocalDateTime(value);
    if (parsed == null) {
      throw ArgumentError.value(value, field, 'must be a valid local date');
    }
    return parsed;
  }

  static DateTime? _optionalDateTime(
    String? value, {
    required String field,
  }) {
    if (_optionalText(value) == null) return null;
    return _requiredDateTime(value!, field: field);
  }

  static String _wireDateTime(DateTime value) => value.toIso8601String();
}
