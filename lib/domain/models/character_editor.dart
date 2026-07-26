class CharacterEditorData {
  const CharacterEditorData({
    required this.worldEntries,
    required this.memoryEntries,
  });

  final List<Map<String, dynamic>> worldEntries;
  final List<Map<String, dynamic>> memoryEntries;
}

class CharacterDraft {
  CharacterDraft({
    required this.name,
    required List<String> tags,
    required this.persona,
    required this.enabled,
    required List<Map<String, dynamic>> worldEntries,
    required List<Map<String, dynamic>> memoryEntries,
    this.characterId,
    this.avatar,
    this.firstMessage,
    this.systemPromptOverride,
    this.postHistoryInstructions,
    this.mesExample,
    this.chatBackground,
  })  : tags = List.unmodifiable(tags),
        worldEntries = List.unmodifiable(
          worldEntries.map((entry) => Map<String, dynamic>.unmodifiable(entry)),
        ),
        memoryEntries = List.unmodifiable(
          memoryEntries
              .map((entry) => Map<String, dynamic>.unmodifiable(entry)),
        );

  final String? characterId;
  final String name;
  final List<String> tags;
  final String persona;
  final bool enabled;
  final String? avatar;
  final String? firstMessage;
  final String? systemPromptOverride;
  final String? postHistoryInstructions;
  final String? mesExample;
  final String? chatBackground;
  final List<Map<String, dynamic>> worldEntries;
  final List<Map<String, dynamic>> memoryEntries;

  Map<String, dynamic> toCharacterData() {
    return {
      'name': name.trim(),
      'tags': tags,
      'persona': persona.trim(),
      'enabled': enabled,
      'avatar': avatar,
      'first_message': _nullableText(firstMessage),
      'system_prompt_override': _nullableText(systemPromptOverride),
      'post_history_instructions': _nullableText(postHistoryInstructions),
      'mes_example': _nullableText(mesExample),
      'chat_background': chatBackground,
    };
  }

  static String? _nullableText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}

class CharacterEditorMedia {
  const CharacterEditorMedia({
    required this.relativePath,
    required this.absolutePath,
  });

  final String relativePath;
  final String absolutePath;
}
