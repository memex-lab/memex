import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:uuid/uuid.dart';

final _logger = Logger('SystemActionSkill');

/// Skill for managing Calendar Events and Reminders locally.
class SystemActionSkill extends Skill {
  SystemActionSkill({super.forceActivate})
      : super(
          name: "manage_calendar_and_reminders",
          description:
              "Extracts explicitly stated calendar events or reminders from the user's input "
              "and manages system actions (create, cancel) to be executed on the user's device. "
              "Only use this if there is a clear scheduling or reminder intent.",
          systemPrompt: _buildSystemPrompt(),
          tools: _buildTools(),
        );

  static String _buildSystemPrompt() {
    return """## Skill Name
`manage_calendar_and_reminders`

## Skill Description
Your capability includes extracting user intents for scheduling calendar events or setting reminders, and managing corresponding system actions (create, cancel) on the user's device.

## Execution Rules
1. **Explicit Consent**: ONLY perform actions when explicitly requested by the user. Do NOT hallucinate or guess intents that are not clearly expressed.
   Diagnostic or memo inputs about Memex/app behavior are not consent. If the user is reporting a bug, asking why something disappeared, or saying they will investigate later, do not create/cancel/modify calendar or reminder actions unless this turn explicitly asks for that action.
2. **Calendar Events Construction**: Extract a `title`, `start_time` (essential), and optional `end_time`, `location`, or `notes`.
3. **Reminders Construction**: Extract a `title` and an optional `due_date` or `notes`.
4. **Time Calculation**: Relative times (like "tomorrow 3 PM", "next Monday") MUST be calculated accurately based on the provided Current User Time context.
5. **Timezone Format**: Provide the local timezone date string in 'YYYY-MM-DD HH:MM:SS' format.
6. **Cancellation Protocol**: When cancelling (or modifying an existing action by cancelling and recreating), FIRST use `get_recent_actions` to find the correct `action_id`, then execute the cancellation.

## Current User Time Context
The current time is provided dynamically in your agent's state/reminders. Always refer to it to correctly parse words like 'today', 'tomorrow', 'next week'.
""";
  }

  static List<Tool> _buildTools() {
    return [
      Tool(
        name: 'create_calendar_event',
        description: "Creates a new scheduled calendar event with a duration.",
        parameters: {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "description": "The title or subject of the event."
            },
            "start_time": {
              "type": "string",
              "description":
                  "The start time of the event. Format: 'YYYY-MM-DD HH:MM:SS' in local time."
            },
            "end_time": {
              "type": "string",
              "description":
                  "The end time for the event. Format: 'YYYY-MM-DD HH:MM:SS' in local time."
            },
            "notes": {
              "type": "string",
              "description": "Optional details or description."
            },
            "location": {
              "type": "string",
              "description": "Optional location of the event."
            },
            "all_day": {
              "type": "boolean",
              "description": "True if the event is an all-day event."
            }
          },
          "required": ["title", "start_time"]
        },
        executable: (
          String title,
          String startTime,
          String? endTime,
          String? notes,
          String? location,
          bool? allDay,
        ) async {
          try {
            final context = AgentCallToolContext.current!;
            final factId = context.state.metadata['factId'];
            final actionId = const Uuid().v4();

            final actionData = {
              "title": title,
              "start_time": startTime,
              "end_time": endTime,
              "notes": notes,
              "location": location,
              "all_day": allDay ?? false,
            };

            await SystemActionService.instance.createAction(
              id: actionId,
              type: 'calendar',
              data: actionData,
              factId: factId,
            );

            return AgentToolResult(
              content: TextPart(
                  "Successfully created calendar event '$title' (Action ID: $actionId)."),
            );
          } catch (e, st) {
            _logger.severe("Failed to create_calendar_event", e, st);
            rethrow;
          }
        },
      ),
      Tool(
        name: 'create_reminder',
        description: "Creates a new reminder for simple tasks or to-dos.",
        parameters: {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "description": "The title or subject of the reminder."
            },
            "due_date": {
              "type": "string",
              "description":
                  "Optional trigger time for the reminder. Format: 'YYYY-MM-DD HH:MM:SS' in local time."
            },
            "notes": {
              "type": "string",
              "description": "Optional details or description."
            }
          },
          "required": ["title"]
        },
        executable: (
          String title,
          String? dueDate,
          String? notes,
        ) async {
          try {
            final context = AgentCallToolContext.current!;
            final factId = context.state.metadata['factId'];
            final actionId = const Uuid().v4();

            final actionData = {
              "title": title,
              "due_date": dueDate,
              "notes": notes,
            };

            await SystemActionService.instance.createAction(
              id: actionId,
              type: 'reminder',
              data: actionData,
              factId: factId,
            );

            return AgentToolResult(
              content: TextPart(
                  "Successfully created reminder '$title' (Action ID: $actionId)."),
            );
          } catch (e, st) {
            _logger.severe("Failed to create_reminder", e, st);
            rethrow;
          }
        },
      ),
      Tool(
        name: 'get_recent_actions',
        description:
            "Retrieves a list of the 20 most recent calendar events and reminders, regardless of their status (pending, completed, dismissed, rejected). Use this to find the action_id before cancelling an action.",
        parameters: {"type": "object", "properties": {}},
        executable: () async {
          try {
            final actions =
                await SystemActionService.instance.getRecentActions();

            if (actions.isEmpty) {
              return AgentToolResult(
                  content: TextPart("No recent actions found."));
            }

            final buffer = StringBuffer("Recent actions (last 20):\n");
            for (var a in actions) {
              buffer.writeln(
                  "- ID: ${a.id} | Type: ${a.actionType} | Status: ${a.status} | Data: ${a.actionData}");
            }
            return AgentToolResult(content: TextPart(buffer.toString()));
          } catch (e, st) {
            _logger.severe("Failed to get_recent_actions", e, st);
            rethrow;
          }
        },
      ),
      Tool(
        name: 'cancel_action',
        description: "Cancels an existing calendar event or reminder.",
        parameters: {
          "type": "object",
          "properties": {
            "action_id": {
              "type": "string",
              "description":
                  "The ID of the action to cancel (obtain via get_recent_actions)."
            }
          },
          "required": ["action_id"]
        },
        executable: (String actionId) async {
          try {
            final success =
                await SystemActionService.instance.cancelAction(actionId);

            if (success) {
              return AgentToolResult(
                content: TextPart(
                    "Successfully cancelled action with ID: $actionId"),
              );
            }
            throw StateError("Action with ID $actionId not found.");
          } catch (e, st) {
            _logger.severe("Failed to cancel_action", e, st);
            rethrow;
          }
        },
      ),
    ];
  }
}
