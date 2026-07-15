// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';

abstract final class CharacterInitiativeActionTools {
  static List<Tool> build({
    required DateTime now,
    required void Function(
      List<String> messages,
      DateTime wakeAt,
      String reason,
    ) onSpeak,
    required void Function(DateTime wakeAt, String reason) onSleepUntil,
  }) {
    return [
      _speak(now, onSpeak),
      _sleepUntil(now, onSleepUntil),
    ];
  }

  static Tool _speak(
    DateTime now,
    void Function(List<String>, DateTime, String) onSpeak,
  ) {
    return Tool(
      name: 'Speak',
      description: 'Send one natural private-chat burst now and choose when '
          'you next want a chance to reconsider contact.',
      parameters: {
        'type': 'object',
        'properties': {
          'messages': {
            'type': 'array',
            'items': {'type': 'string'},
            'minItems': 1,
            'description': 'Exact user-facing chat bubbles in send order.',
          },
          'next_wake_at': {
            'type': 'string',
            'format': 'date-time',
            'description': 'A future ISO 8601 timestamp with timezone.',
          },
          'next_wake_reason': {
            'type': 'string',
            'description': 'Why your future self may want to reconsider '
                'contact then. Never shown to the user.',
          },
        },
        'required': ['messages', 'next_wake_at', 'next_wake_reason'],
      },
      executable: (
        List<dynamic> messages,
        String next_wake_at,
        String next_wake_reason,
      ) {
        final normalized = messages
            .whereType<String>()
            .map((message) => message.trim())
            .where((message) => message.isNotEmpty)
            .toList(growable: false);
        if (normalized.isEmpty || normalized.length != messages.length) {
          throw ArgumentError('Speak requires non-empty string messages.');
        }
        final wake = _parseWake(
          now: now,
          wakeAtText: next_wake_at,
          reason: next_wake_reason,
        );
        onSpeak(normalized, wake.wakeAt, wake.reason);
        return AgentToolResult(
          content: TextPart('Private messages and next wake selected.'),
          stopFlag: true,
        );
      },
    );
  }

  static Tool _sleepUntil(
    DateTime now,
    void Function(DateTime, String) onSleepUntil,
  ) {
    return Tool(
      name: 'SleepUntil',
      description: 'Send nothing now and choose when you next want a chance '
          'to reconsider contact.',
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
            'description': 'Why your future self may want to reconsider '
                'contact then. Never shown to the user.',
          },
        },
        'required': ['wake_at', 'reason'],
      },
      executable: (String wake_at, String reason) {
        final wake = _parseWake(
          now: now,
          wakeAtText: wake_at,
          reason: reason,
        );
        onSleepUntil(wake.wakeAt, wake.reason);
        return AgentToolResult(
          content: TextPart('Next wake selected.'),
          stopFlag: true,
        );
      },
    );
  }

  static ({DateTime wakeAt, String reason}) _parseWake({
    required DateTime now,
    required String wakeAtText,
    required String reason,
  }) {
    final wakeAt = DateTime.tryParse(wakeAtText);
    if (wakeAt == null || !wakeAt.isAfter(now)) {
      throw ArgumentError('wake_at must be a valid future timestamp.');
    }
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError('reason must describe what you want to revisit.');
    }
    return (wakeAt: wakeAt, reason: normalizedReason);
  }
}
