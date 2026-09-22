import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/run_mode/agent_run_mode.dart';
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
  SystemActionSkill({String? userId, super.forceActivate})
      : super(
          name: 'manage_calendar_and_reminders',
          description:
              'Prepares a calendar event or reminder for the user to review '
              'and add with the device native Calendar or Reminders app. Use '
              'for explicit requests or a clear future commitment in a saved record.',
          systemPrompt: _systemPrompt,
          tools: _buildTools(userId),
        );

  static const _systemPrompt = '''
## Calendar and reminder actions

Use this skill for explicit scheduling requests, or to offer a pending proposal
for a clear future personal commitment in a saved record. A proposal is not
permission to write to the device. Historical events, quotations, cancelled or
hypothetical plans, bug reports and vague wishes do not warrant proposals.
For record-derived proposals, wait for verified card completion and provide the
exact fact_id. Never invent an ID or a date/time. Respect rejected proposals.

- Resolve relative dates from the Current Local Time supplied in context.
- Pass local date-times as `YYYY-MM-DD HH:MM:SS`.
- Use `create_calendar_event` for an event with a scheduled start.
- Use `create_reminder` for a task or prompt with a specific due time. If the
  user did not provide enough information to resolve that time, ask instead of
  guessing.
- For iOS calendar events, the card opens the prefilled system calendar editor.
  The user can edit and save there, or cancel without adding anything.
- Each tool creates a pending proposal. The user must review it and press the
  add button before Memex requests system permission and writes to the device.
- Never claim the event or reminder is already in the device app after this
  tool succeeds. Say it is ready for confirmation in the attached card.
- Do not create a Timeline record unless the user separately asks to capture
  the information as a record.
''';

  static List<Tool> _buildTools(String? userId) {
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
            'fact_id': {
              'type': 'string',
              'description':
                  'Optional verified saved record ID. Required when offering help derived from a record; omit for scheduling-only requests.',
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
          String? factId,
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

            _checkWritableMode();

            final actionId = await _prepare(
              userId: userId,
              factId: factId,
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

            final existing =
                await SystemActionService.instance.getAction(actionId);
            if (existing != null && existing.status != 'pending') {
              return AgentToolResult(
                  content: TextPart(
                'Existing device proposal $actionId has status ${existing.status}. '
                'Do not create a duplicate or ask again. No new device write occurred.',
              ));
            }
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
            'fact_id': {
              'type': 'string',
              'description':
                  'Optional verified saved record ID. Required when offering help derived from a record; omit for scheduling-only requests.',
            },
          },
          'required': ['title', 'due_date'],
        },
        executable: (
          String title,
          String? dueDate,
          String? notes,
          String? factId,
        ) async {
          try {
            final normalizedTitle = _requiredText(title, field: 'title');
            final due = _requiredDateTime(
              dueDate ?? '',
              field: 'due_date',
            );

            _checkWritableMode();

            final actionId = await _prepare(
              userId: userId,
              factId: factId,
              type: 'reminder',
              data: {
                'title': normalizedTitle,
                'due_date': _wireDateTime(due),
                if (_optionalText(notes) case final value?) 'notes': value,
              },
            );

            final existing =
                await SystemActionService.instance.getAction(actionId);
            if (existing != null && existing.status != 'pending') {
              return AgentToolResult(
                  content: TextPart(
                'Existing device proposal $actionId has status ${existing.status}. '
                'Do not create a duplicate or ask again. No new device write occurred.',
              ));
            }
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

  // Proposals already have persistent review UI. Do not pause once to prepare
  // and a second time to execute; read-only remains enforced at execution too.
  static void _checkWritableMode() {
    final metadata = AgentCallToolContext.current?.state.metadata;
    if (AgentRunMode.fromWire(metadata?[AgentRunMode.metadataKey] as String?) ==
        AgentRunMode.readOnly) {
      throw StateError('Device proposals are unavailable in read-only mode.');
    }
  }

  static Future<String> _prepare({
    required String? userId,
    required String? factId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final sourceId = _optionalText(factId);
    if (sourceId != null) {
      final owner = userId ??
          AgentCallToolContext.current?.state.metadata['userId'] as String?;
      if (owner == null || owner.isEmpty) {
        throw StateError('A user context is required for a record proposal.');
      }
      return SystemActionService.instance.prepareForRecord(
        userId: owner,
        factId: sourceId,
        type: type,
        data: data,
      );
    }
    return SystemActionService.instance.createAction(
      id: const Uuid().v4(),
      type: type,
      data: data,
    );
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
