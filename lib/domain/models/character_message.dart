import 'package:memex/domain/models/character_emoji.dart';

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

  factory CharacterOutgoingMessage.fromContent(String content) {
    return isEmojiOnlyMessage(content)
        ? CharacterOutgoingMessage.emoji(content)
        : CharacterOutgoingMessage.text(content);
  }

  factory CharacterOutgoingMessage.emoji(String content) {
    final normalized = content.trim();
    if (!isEmojiOnlyMessage(normalized)) {
      throw ArgumentError.value(
        content,
        'content',
        'Emoji messages must contain only Unicode emoji.',
      );
    }
    return CharacterOutgoingMessage._(
      type: CharacterOutgoingMessageType.emoji,
      content: normalized,
    );
  }

  final CharacterOutgoingMessageType type;
  final String content;

  String get storageType => switch (type) {
        CharacterOutgoingMessageType.text => PersonaChatMessageTypes.text,
        CharacterOutgoingMessageType.emoji => PersonaChatMessageTypes.emoji,
      };

  @override
  bool operator ==(Object other) =>
      other is CharacterOutgoingMessage &&
      other.type == type &&
      other.content == content;

  @override
  int get hashCode => Object.hash(type, content);
}

bool isEmojiOnlyMessage(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;
  final runes = normalized.runes.toList(growable: false);
  if (runes.length > 64) return false;

  var hasEmojiBase = false;
  var expectsJoinedBase = false;
  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    final isKeycapBase =
        rune == 0x23 || rune == 0x2A || (rune >= 0x30 && rune <= 0x39);
    if (isKeycapBase) {
      var next = index + 1;
      if (next < runes.length && runes[next] == 0xFE0F) next++;
      if (next >= runes.length || runes[next] != 0x20E3) return false;
      hasEmojiBase = true;
      expectsJoinedBase = false;
      index = next;
      continue;
    }
    final isModifier = (rune >= 0x1F3FB && rune <= 0x1F3FF) ||
        (rune >= 0xE0020 && rune <= 0xE007F);
    if (isModifier) continue;
    if (rune == 0x200D) {
      if (!hasEmojiBase || expectsJoinedBase) return false;
      expectsJoinedBase = true;
      continue;
    }
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
      hasEmojiBase = true;
      expectsJoinedBase = false;
      continue;
    }
    final isEmojiJoiner = rune == 0xFE0E || rune == 0xFE0F;
    if (!isEmojiJoiner) return false;
  }
  return !expectsJoinedBase && hasEmojiBase;
}

List<CharacterOutgoingMessage> parseCharacterOutgoingMessages(
  List<dynamic>? values, {
  String? emojiId,
}) {
  final messages = <CharacterOutgoingMessage>[];
  for (final value in values ?? const <dynamic>[]) {
    String? content;
    if (value is String) {
      content = value;
    } else if (value is Map && value['content'] is String) {
      // Compatibility with turns saved while the Agent-facing contract used
      // `{type, content}`. The declared type is intentionally ignored.
      content = value['content'] as String;
    }
    if (content?.trim().isNotEmpty == true) {
      messages.add(CharacterOutgoingMessage.fromContent(content!));
    }
  }
  final normalizedEmojiId = emojiId?.trim();
  if (normalizedEmojiId?.isNotEmpty == true) {
    final emoji = CharacterEmoji.fromAgentId(normalizedEmojiId!);
    if (emoji == null) {
      throw ArgumentError.value(emojiId, 'emojiId', 'Unsupported emoji.');
    }
    messages.add(CharacterOutgoingMessage.emoji(emoji.glyph));
  }
  if (messages.isEmpty) {
    throw ArgumentError('Speak requires text messages or one emoji.');
  }
  return List.unmodifiable(messages);
}

List<CharacterOutgoingMessage> normalizeCharacterOutgoingMessages(
  Iterable<Object> values,
) {
  final messages = values.map((value) {
    if (value is CharacterOutgoingMessage) return value;
    if (value is String) {
      return CharacterOutgoingMessage.fromContent(value);
    }
    throw ArgumentError.value(value, 'messages');
  }).toList(growable: false);
  if (messages.isEmpty) {
    throw ArgumentError('Speak requires at least one message.');
  }
  return messages;
}
