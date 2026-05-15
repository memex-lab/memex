import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/persona_chat_service.dart';

/// Factory for the SendActionMessage tool used by the companion agent.
///
/// An "action message" is a narrative / stage-direction style message
/// (e.g. *leans closer and whispers*) that is rendered differently in the
/// chat UI — no speech bubble, italic text, centred.
class ActionMessageToolFactory {
  final String characterId;

  ActionMessageToolFactory({required this.characterId});

  Tool buildSendActionMessageTool() {
    return Tool(
      name: 'SendActionMessage',
      description: '''Send a narrative / action description message to the user.

Use this for actions, gestures, scene descriptions, or atmosphere — anything
that is *shown* rather than *said*.

This sends a SEPARATE message rendered as a centred italic line between chat
bubbles. Your spoken reply goes in the final text output of the turn.
Do NOT put dialogue or spoken words in this tool.''',
      parameters: {
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'description': 'The narrative / action text to send.',
          },
        },
        'required': ['action'],
      },
      executable: (String action) async {
        final trimmed = action.trim();
        if (trimmed.isEmpty) {
          return 'Error: action text cannot be empty.';
        }
        // Wrap in asterisks if not already wrapped.
        final wrapped = (trimmed.startsWith('*') && trimmed.endsWith('*'))
            ? trimmed
            : '*$trimmed*';
        try {
          await PersonaChatService.instance.addActionMessage(
            characterId,
            wrapped,
            isRead: true,
          );
          // Notify the chat screen to reload immediately so the action message
          // appears before the spoken reply arrives.
          EventBusService.instance.emitEvent(
            PersonaChatMessageAddedMessage(characterId: characterId),
          );
          return 'Action message sent.';
        } catch (e) {
          return 'Error sending action message: $e';
        }
      },
    );
  }
}
