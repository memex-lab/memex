// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/character_emoji.dart';
import 'package:memex/domain/models/character_message.dart';

abstract final class CharacterContactActionTools {
  static List<Tool> build({
    required DateTime now,
    required void Function(List<CharacterOutgoingMessage> messages) onSpeak,
    required void Function(DateTime wakeAt, String reason) onThinkLater,
    required void Function(String reason) onStayQuiet,
  }) {
    return [
      _speak(onSpeak),
      _thinkLater(now, onThinkLater),
      _stayQuiet(onStayQuiet),
    ];
  }

  static Tool _speak(
    void Function(List<CharacterOutgoingMessage>) onSpeak,
  ) {
    return Tool(
      name: 'Speak',
      description:
          'Send one natural private-chat burst as one or more bubbles.',
      parameters: {
        'type': 'object',
        'properties': {
          'messages': {
            'type': 'array',
            'items': {'type': 'string'},
            'minItems': 1,
            'description': 'Optional exact text bubbles in send order. Keep '
                'standalone emoji out of this field.',
          },
          'emoji': {
            'type': 'string',
            'enum': CharacterEmoji.agentIds,
            'description': 'Optional standalone Fluent emoji gesture, sent '
                'after the text bubbles. Omit it when no gesture is natural.',
          },
        },
      },
      executable: (List<dynamic>? messages, String? emoji) {
        final normalized = parseCharacterOutgoingMessages(
          messages,
          emojiId: emoji,
        );
        onSpeak(normalized);
        return AgentToolResult(
          content: TextPart('Private messages selected.'),
          stopFlag: true,
        );
      },
    );
  }

  static Tool _thinkLater(
    DateTime now,
    void Function(DateTime, String) onThinkLater,
  ) {
    return Tool(
      name: 'ThinkLater',
      description:
          'Choose a future time to reconsider this private conversation.',
      parameters: {
        'type': 'object',
        'properties': {
          'wake_at': {
            'type': 'string',
            'format': 'date-time',
            'description': 'A future ISO 8601 timestamp with timezone.',
          },
          'reason': {
            'type': 'string',
            'description': 'A brief private reason. Never shown to the user.',
          },
        },
        'required': ['wake_at', 'reason'],
      },
      executable: (String wake_at, String reason) {
        final wakeAt = DateTime.tryParse(wake_at);
        if (wakeAt == null || !wakeAt.isAfter(now)) {
          throw ArgumentError('wake_at must be a valid future timestamp.');
        }
        final normalizedReason = reason.trim();
        if (normalizedReason.isEmpty) {
          throw ArgumentError('reason must describe what you want to revisit.');
        }
        onThinkLater(wakeAt, normalizedReason);
        return AgentToolResult(
          content: TextPart('Future reflection scheduled.'),
          stopFlag: true,
        );
      },
    );
  }

  static Tool _stayQuiet(void Function(String) onStayQuiet) {
    return Tool(
      name: 'StayQuiet',
      description: 'Finish this moment without sending a private message.',
      parameters: {
        'type': 'object',
        'properties': {
          'reason': {
            'type': 'string',
            'description': 'A brief private reason. Never shown to the user.',
          },
        },
        'required': ['reason'],
      },
      executable: (String reason) {
        final normalizedReason = reason.trim();
        if (normalizedReason.isEmpty) {
          throw ArgumentError('reason must not be empty.');
        }
        onStayQuiet(normalizedReason);
        return AgentToolResult(
          content: TextPart('Stayed quiet.'),
          stopFlag: true,
        );
      },
    );
  }
}
