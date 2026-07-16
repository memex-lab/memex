abstract final class PersonaChatMessageTypes {
  static const String text = 'chat';
  static const String emoji = 'emoji';
  static const String action = 'action';
}

enum CharacterOutgoingMessageType { text, emoji }

class CharacterOutgoingMessage {
  const CharacterOutgoingMessage._({
    required this.type,
    required this.content,
  });

  factory CharacterOutgoingMessage.text(String content) {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(content, 'content');
    }
    return CharacterOutgoingMessage._(
      type: CharacterOutgoingMessageType.text,
      content: normalized,
    );
  }

  factory CharacterOutgoingMessage.emoji(String content) {
    final normalized = content.trim();
    if (!isStandaloneEmoji(normalized)) {
      throw ArgumentError.value(
        content,
        'content',
        'Emoji messages must contain only one emoji sequence.',
      );
    }
    return CharacterOutgoingMessage._(
      type: CharacterOutgoingMessageType.emoji,
      content: normalized,
    );
  }

  factory CharacterOutgoingMessage.fromAgentJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final content = json['content'] as String? ?? '';
    return switch (type) {
      'text' => CharacterOutgoingMessage.text(content),
      'emoji' => CharacterOutgoingMessage.emoji(content),
      _ => throw ArgumentError.value(type, 'type'),
    };
  }

  final CharacterOutgoingMessageType type;
  final String content;

  String get storageType => switch (type) {
        CharacterOutgoingMessageType.text => PersonaChatMessageTypes.text,
        CharacterOutgoingMessageType.emoji => PersonaChatMessageTypes.emoji,
      };

  Map<String, dynamic> toAgentJson() => {
        'type': type.name,
        'content': content,
      };

  @override
  bool operator ==(Object other) =>
      other is CharacterOutgoingMessage &&
      other.type == type &&
      other.content == content;

  @override
  int get hashCode => Object.hash(type, content);
}

bool isStandaloneEmoji(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;
  final runes = normalized.runes.toList(growable: false);
  if (runes.length > 16) return false;

  var hasEmojiBase = false;
  var expectsJoinedBase = false;
  var regionalIndicatorCount = 0;
  final keycapCount = runes.where((rune) => rune == 0x20E3).length;
  if (keycapCount > 1) return false;
  final isKeycapSequence = keycapCount == 1;
  for (final rune in runes) {
    final isModifier = (rune >= 0x1F3FB && rune <= 0x1F3FF) ||
        (rune >= 0xE0020 && rune <= 0xE007F);
    if (isModifier) continue;
    if (rune == 0x200D) {
      if (!hasEmojiBase || expectsJoinedBase) return false;
      expectsJoinedBase = true;
      continue;
    }
    final isRegionalIndicator = rune >= 0x1F1E6 && rune <= 0x1F1FF;
    final isEmojiBase = (rune >= 0x1F000 && rune <= 0x1FAFF) ||
        (rune >= 0x2600 && rune <= 0x27BF) ||
        (rune >= 0x2300 && rune <= 0x23FF) ||
        rune == 0x00A9 ||
        rune == 0x00AE ||
        rune == 0x2122 ||
        rune == 0x3030 ||
        rune == 0x303D ||
        rune == 0x3297 ||
        rune == 0x3299;
    if (isEmojiBase) {
      if (isRegionalIndicator) {
        if ((hasEmojiBase && regionalIndicatorCount == 0) ||
            ++regionalIndicatorCount > 2) {
          return false;
        }
      } else {
        if (regionalIndicatorCount > 0 ||
            (hasEmojiBase && !expectsJoinedBase)) {
          return false;
        }
      }
      hasEmojiBase = true;
      expectsJoinedBase = false;
      continue;
    }
    final isEmojiJoiner = rune == 0xFE0E ||
        rune == 0xFE0F ||
        rune == 0x20E3 ||
        (isKeycapSequence &&
            (rune == 0x23 || rune == 0x2A || (rune >= 0x30 && rune <= 0x39)));
    if (!isEmojiJoiner) return false;
  }
  return !expectsJoinedBase && (hasEmojiBase || isKeycapSequence);
}

List<CharacterOutgoingMessage> parseCharacterOutgoingMessages(
  List<dynamic> values,
) {
  if (values.isEmpty) {
    throw ArgumentError('Speak requires at least one message.');
  }
  return values.map((value) {
    if (value is String) {
      return isStandaloneEmoji(value)
          ? CharacterOutgoingMessage.emoji(value)
          : CharacterOutgoingMessage.text(value);
    }
    if (value is! Map) {
      throw ArgumentError('Each message must be a typed object.');
    }
    return CharacterOutgoingMessage.fromAgentJson(
      Map<String, dynamic>.from(value),
    );
  }).toList(growable: false);
}

List<CharacterOutgoingMessage> normalizeCharacterOutgoingMessages(
  Iterable<Object> values,
) {
  final messages = values.map((value) {
    if (value is CharacterOutgoingMessage) return value;
    if (value is String) {
      return isStandaloneEmoji(value)
          ? CharacterOutgoingMessage.emoji(value)
          : CharacterOutgoingMessage.text(value);
    }
    throw ArgumentError.value(value, 'messages');
  }).toList(growable: false);
  if (messages.isEmpty) {
    throw ArgumentError('Speak requires at least one message.');
  }
  return messages;
}
