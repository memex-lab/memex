import 'dart:io';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;

/// Manages the companion character's memory files:
/// - relationship.md  (what the character remembers about the relationship)
/// - emotional_state.md (current emotional snapshot of the user)
class CompanionMemory {
  static final Logger _logger = getLogger('CompanionMemory');

  static String _charsPath(String userId) =>
      CharacterService.instance.getCharactersPath(userId);

  static String _relationshipPath(String userId, String characterId) =>
      p.join(_charsPath(userId), '${characterId}_relationship.md');

  static String _emotionalStatePath(String userId, String characterId) =>
      p.join(_charsPath(userId), '${characterId}_emotional_state.md');

  /// Load the relationship memory for a character.
  static Future<String> loadRelationship(
      String userId, String characterId) async {
    final file = File(_relationshipPath(userId, characterId));
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  /// Load the emotional state snapshot for a character.
  static Future<String> loadEmotionalState(
      String userId, String characterId) async {
    final file = File(_emotionalStatePath(userId, characterId));
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  /// Load the global user profile (archived_memory from MemoryManagement).
  static Future<String> loadUserProfile(String userId) async {
    try {
      final mm = await MemoryManagement.createDefault(
        userId: userId,
        sourceAgent: 'companion_agent',
      );
      return mm.buildMemoryPrompt();
    } catch (e) {
      _logger.warning('Failed to load user profile: $e');
      return '';
    }
  }

  /// Load the character's memory blocks (written by CommentAgent via MemoryWrite).
  /// These contain observations the character has made about the user.
  static Future<String> loadCharacterMemory(
      String userId, String characterId) async {
    try {
      final character =
          await CharacterService.instance.getCharacter(userId, characterId);
      if (character == null || character.memory.isEmpty) return '';

      final buffer = StringBuffer();
      for (final block in character.memory) {
        if (block.value.isNotEmpty) {
          buffer.writeln('- [${block.label}]: ${block.value}');
        }
      }
      return buffer.toString();
    } catch (e) {
      _logger.warning('Failed to load character memory blocks: $e');
      return '';
    }
  }

  /// Load recent daily facts (last 2-3 days) for life context.
  static Future<String> loadRecentFacts(String userId,
      {int days = 3, int maxChars = 3000}) async {
    final fs = FileSystemService.instance;
    final now = DateTime.now();
    final buffer = StringBuffer();
    var totalChars = 0;

    for (var i = 0; i < days && totalChars < maxChars; i++) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final factFile =
          File(p.join(fs.getWorkspacePath(userId), 'Facts', '$y', m, '$d.md'));

      try {
        if (!await factFile.exists()) continue;
        final content = await factFile.readAsString();
        if (content.trim().isEmpty) continue;

        final remaining = maxChars - totalChars;
        final truncated = content.length > remaining
            ? '${content.substring(0, remaining)}...'
            : content;
        buffer.writeln('### $y-$m-$d');
        buffer.writeln(truncated);
        totalChars += truncated.length;
      } catch (_) {}
    }

    return buffer.toString();
  }

  /// Update memory after a conversation ends.
  /// Uses a single LLM call to produce both relationship + emotional state.
  static Future<void> updateAfterConversation({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required String conversationSummary,
  }) async {
    final oldRelationship = await loadRelationship(userId, characterId);
    final oldEmotional = await loadEmotionalState(userId, characterId);

    final prompt = '''You are a memory manager for an AI companion character.
Given a conversation between the character and the user, update two memory files.

## Current Relationship Memory
${oldRelationship.isEmpty ? '(empty - first conversation)' : oldRelationship}

## Current Emotional State
${oldEmotional.isEmpty ? '(unknown)' : oldEmotional}

## Recent Conversation
$conversationSummary

## Instructions
Output exactly two sections separated by "---SPLIT---":

**Section 1: Updated Relationship Memory** (max 2000 chars)
- Merge new observations into existing memory
- Track: ongoing topics, key moments, user preferences, things to remember
- Remove outdated info that's been superseded
- Keep it concise and structured with markdown headers

**Section 2: Updated Emotional State** (max 200 chars)
- Current emotional state of the user based on this conversation
- What they need right now (listening, encouragement, humor, etc.)
- Overwrite completely, only keep the latest state

Output the two sections now, separated by ---SPLIT---:''';

    try {
      final response = await client.generate(
        [
          UserMessage([TextPart(prompt)])
        ],
        modelConfig: modelConfig,
      );

      final output = response.textOutput?.trim() ?? '';
      if (output.isEmpty) return;

      final parts = output.split('---SPLIT---');
      if (parts.length >= 2) {
        final newRelationship = parts[0].trim();
        final newEmotional = parts[1].trim();

        if (newRelationship.isNotEmpty) {
          final file = File(_relationshipPath(userId, characterId));
          await file.parent.create(recursive: true);
          await file.writeAsString(newRelationship);
          _logger
              .info('Updated relationship memory for character $characterId');
        }

        if (newEmotional.isNotEmpty) {
          final file = File(_emotionalStatePath(userId, characterId));
          await file.parent.create(recursive: true);
          await file.writeAsString(newEmotional);
          _logger.info('Updated emotional state for character $characterId');
        }
      }
    } catch (e) {
      _logger.warning('Failed to update companion memory: $e');
    }
  }
}
