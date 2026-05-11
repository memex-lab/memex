import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/logger.dart';

/// Extracts durable memory entries from raw timeline events during compression.
class CharacterMemoryUpdater {
  CharacterMemoryUpdater._();

  static final CharacterMemoryUpdater instance = CharacterMemoryUpdater._();
  final _logger = getLogger('CharacterMemoryUpdater');

  /// Called during timeline compression. Extracts durable memories from the
  /// raw events being compressed (not the summary, to avoid information loss).
  Future<void> updateFromCompressedEvents({
    required String userId,
    required String characterId,
    required List<String> rawEventLines,
  }) async {
    if (rawEventLines.isEmpty) return;

    // Build a readable text from raw events for the LLM.
    final sourceText = _renderRawEvents(rawEventLines);
    if (sourceText.trim().isEmpty) return;

    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.chatAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );
      await _extractAndSaveMemories(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        characterId: characterId,
        sourceText: sourceText,
      );
    } catch (e) {
      _logger.warning('Failed to get LLM resources for memory extraction: $e');
    }
  }

  String _renderRawEvents(List<String> lines) {
    final b = StringBuffer();
    for (final line in lines) {
      try {
        final obj = jsonDecode(line);
        if (obj is! Map) continue;
        final ts = obj['ts'] ?? '';
        final scene = obj['scene'] ?? '';
        final type = obj['event_type'] ?? '';
        final content = (obj['content'] as String?)?.trim() ?? '';
        if (content.isEmpty) continue;
        b.writeln('[$ts] $scene/$type: $content');
      } catch (_) {
        // Skip malformed lines.
      }
    }
    return b.toString();
  }

  Future<void> _extractAndSaveMemories({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required String sourceText,
  }) async {
    final svc = CharacterMemoryService.instance;
    final existing = await svc.buildAllMemoriesText(
      userId: userId,
      characterId: characterId,
    );

    final prompt =
        '''Extract durable character memory entries from the following raw interaction history.

Existing memories (do not duplicate these):
${existing.isEmpty ? '(none)' : existing}

Raw interaction history:
$sourceText

Return JSON array only. Each item:
{
  "label": "short unique label (used as key)",
  "content": "one declarative durable memory, not an instruction",
  "salience": 0.0-1.0
}

Rules:
- Save only stable facts, explicit preferences/corrections, recurring patterns, or important open threads.
- Do not save ephemeral mood, exact chat logs, or temporary task progress.
- Do not duplicate or rephrase existing memories listed above.
- If an existing memory should be updated, use the same label to overwrite it.
- Return [] if nothing new and durable should be saved.
''';
    try {
      final res = await client.generate(
        [
          UserMessage([TextPart(prompt)])
        ],
        modelConfig: modelConfig,
      );
      final text = res.textOutput?.trim() ?? '';
      if (text.isEmpty) return;
      final decoded = jsonDecode(text);
      if (decoded is! List) return;
      for (final item in decoded) {
        if (item is! Map) continue;
        final content = item['content'] as String? ?? '';
        final label = item['label'] as String? ?? '';
        if (content.trim().isEmpty || label.trim().isEmpty) continue;
        await svc.writeMemoryEntry(
          userId: userId,
          characterId: characterId,
          label: label,
          content: content,
          salience: (item['salience'] as num?)?.toDouble() ?? 0.5,
        );
      }
    } catch (e) {
      _logger.warning('Failed to extract memories: $e');
    }
  }
}
