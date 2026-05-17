import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/context/character_context_assembler.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/logger.dart';

class CharacterContextCompressor {
  CharacterContextCompressor._();

  static final CharacterContextCompressor instance =
      CharacterContextCompressor._();
  final _logger = getLogger('CharacterContextCompressor');

  /// Trigger compression based on real promptTokens from the last LLM call.
  /// Call this AFTER agent.run() completes, passing the actual token usage.
  Future<void> compressIfNeeded({
    required String userId,
    required String characterId,
    required int lastPromptTokens,
    int contextWindow = 64000,
    double softRatio = 0.80,
    double hardRatio = 0.95,
    Duration failureCooldown = const Duration(minutes: 10),
    int keepRecent = 20,
  }) async {
    final softThreshold = (contextWindow * softRatio).toInt();
    final hardThreshold = (contextWindow * hardRatio).toInt();
    if (lastPromptTokens <= softThreshold) return;

    final svc = CharacterMemoryService.instance;
    final lines = await svc.loadTimelineLines(userId, characterId);
    if (lines.isEmpty) return;

    // Cooldown: if previous compression failed recently, skip unless hard threshold.
    final indexes =
        await CharacterMemoryService.instance.loadIndexes(userId, characterId);
    final failedAt = indexes['last_compress_failed_at'] as String?;
    if (failedAt != null && lastPromptTokens < hardThreshold) {
      final t = DateTime.tryParse(failedAt);
      if (t != null && DateTime.now().difference(t) < failureCooldown) {
        return;
      }
    }

    final trimCount = lines.length - keepRecent;
    if (trimCount <= 0) return;
    final boundary = _findSafeBoundary(lines, trimCount);
    final oldLines = _preTrim(lines.sublist(0, boundary));
    final keptLines = lines.sublist(boundary);
    try {
      final summary = await _buildRollingSummary(
        userId: userId,
        characterId: characterId,
        newEvents: oldLines,
      );
      final checkpoint = <String, dynamic>{
        'created_at': DateTime.now().toIso8601String(),
        'summary': summary,
      };
      await svc.appendArchivedTimelineLines(userId, characterId, oldLines);
      await svc.replaceCheckpoint(userId, characterId, checkpoint);
      await svc.replaceTimelineLines(userId, characterId, keptLines);

      final updatedIndexes = await CharacterMemoryService.instance
          .loadIndexes(userId, characterId);
      updatedIndexes.remove('last_compress_failed_at');
      await CharacterMemoryService.instance
          .saveIndexes(userId, characterId, updatedIndexes);
      _logger.info(
          'Compressed timeline for $characterId, promptTokens=$lastPromptTokens, trimmed=${oldLines.length}, kept=${keptLines.length}');
    } catch (e) {
      final updatedIndexes = await CharacterMemoryService.instance
          .loadIndexes(userId, characterId);
      updatedIndexes['last_compress_failed_at'] =
          DateTime.now().toIso8601String();
      await CharacterMemoryService.instance
          .saveIndexes(userId, characterId, updatedIndexes);
      _logger.warning('Timeline compression failed for $characterId: $e');
    }
  }

  List<String> _preTrim(List<String> lines) {
    final seen = <String>{};
    final result = <String>[];
    for (final line in lines) {
      final key = line.length > 160 ? line.substring(0, 160) : line;
      if (!seen.add(key)) continue;
      var normalized = line;
      try {
        final obj = jsonDecode(line);
        if (obj is Map) {
          final m = Map<String, dynamic>.from(obj);
          final meta = m['metadata'];
          if (meta is Map && meta['arguments'] is String) {
            final args = meta['arguments'] as String;
            if (args.length > 600) {
              final updatedMeta = Map<String, dynamic>.from(meta);
              updatedMeta['arguments'] = '${args.substring(0, 600)}...';
              m['metadata'] = updatedMeta;
            }
          }
          normalized = jsonEncode(m);
        }
      } catch (_) {}
      if (normalized.length > 4000) {
        normalized = '${normalized.substring(0, 4000)}...';
      }
      result.add(normalized);
    }
    return result;
  }

  int _findSafeBoundary(List<String> lines, int targetBoundary) {
    var boundary = targetBoundary;
    for (var i = lines.length - 1; i >= targetBoundary; i--) {
      try {
        final obj = jsonDecode(lines[i]);
        if (obj is Map && obj['event_type'] is String) {
          final t = obj['event_type'] as String;
          if (t == CharacterMemoryEventType.userChatMessage.name ||
              t == CharacterMemoryEventType.postObserved.name ||
              t == CharacterMemoryEventType.userCommentReply.name) {
            boundary = i;
            break;
          }
        }
      } catch (_) {}
    }
    if (boundary <= 0) return targetBoundary;
    return boundary;
  }

  /// Maximum character count for the rolling summary.
  static const int _summaryCharBudget = 12000;

  /// Build a rolling summary by merging the existing summary with new events.
  /// Provides user memories and character memories as context so the model
  /// knows what's already captured and can focus on storyline progression.
  Future<String> _buildRollingSummary({
    required String userId,
    required String characterId,
    required List<String> newEvents,
  }) async {
    final svc = CharacterMemoryService.instance;

    // Load existing summary
    final existingSummary =
        await svc.loadCheckpointSummary(userId, characterId);

    // Load user-level memories
    String userMemories = '';
    try {
      final mm = await MemoryManagement.createDefault(
        userId: userId,
        sourceAgent: 'compressor',
      );
      userMemories = await mm.buildMemoryPrompt();
    } catch (_) {}

    // Load character-level memories
    final characterMemories = await svc.buildAllMemoriesText(
      userId: userId,
      characterId: characterId,
    );

    // Format events using the same renderer used for context injection
    final formattedEvents = CharacterContextAssembler.renderTimeline(newEvents);

    final prompt = StringBuffer();
    prompt.writeln(
        'You maintain a rolling storyline summary for a role-play character\'s interaction history with the user.');
    prompt.writeln('');
    prompt.writeln('## Task');
    prompt.writeln(
        'Merge the existing summary with the new events below into ONE updated summary.');
    prompt.writeln('Focus on **storyline and plot progression**:');
    prompt.writeln('- Ongoing narrative arcs and unresolved threads');
    prompt.writeln('- Emotional trajectory and relationship dynamics');
    prompt.writeln('- Promises, plans, or commitments made');
    prompt.writeln('- Context needed to continue conversations naturally');
    prompt.writeln('');
    prompt.writeln('## What NOT to include');
    prompt.writeln(
        'The following facts are already stored in structured memory. Do NOT repeat them in the summary:');

    if (userMemories.isNotEmpty) {
      prompt.writeln('');
      prompt.writeln('### User Memories (already stored)');
      prompt.writeln(userMemories);
    }
    if (characterMemories.isNotEmpty) {
      prompt.writeln('');
      prompt.writeln('### Character Memories (already stored)');
      prompt.writeln(characterMemories);
    }

    prompt.writeln('');
    prompt.writeln('## Requirements');
    prompt.writeln('- Output markdown only, no JSON, no preamble.');
    prompt
        .writeln('- MUST be under $_summaryCharBudget characters. Be concise.');
    prompt.writeln(
        '- Drop details already covered by the memories listed above.');
    prompt.writeln(
        '- When the existing summary grows stale or contradicts new events, update it rather than appending.');
    prompt.writeln(
        '- Preserve open threads and recent emotional context with higher priority than old resolved topics.');

    if (existingSummary.isNotEmpty) {
      prompt.writeln('');
      prompt.writeln('## Existing Summary');
      prompt.writeln(existingSummary);
    }

    prompt.writeln('');
    prompt.writeln('## New Events to Incorporate');
    prompt.writeln(formattedEvents);

    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.profileAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );
      final res = await resources.client.generate(
        [
          UserMessage([TextPart(prompt.toString())])
        ],
        modelConfig: resources.modelConfig,
      );
      var out = res.textOutput?.trim() ?? '';
      if (out.isEmpty) {
        return existingSummary.isNotEmpty
            ? existingSummary
            : _buildFallbackSummary(newEvents);
      }

      // If output exceeds budget, ask for a tighter version.
      if (out.length > _summaryCharBudget) {
        _logger.info(
            'Rolling summary too long (${out.length} chars), requesting condensed version');
        final condensePrompt =
            'The following summary is ${out.length} characters but must be under $_summaryCharBudget characters. '
            'Condense it aggressively. Keep open threads and recent emotional context. '
            'Drop resolved topics and facts already in structured memory. '
            'Output markdown only, no preamble.\n\n$out';
        try {
          final res2 = await resources.client.generate(
            [
              UserMessage([TextPart(condensePrompt)])
            ],
            modelConfig: resources.modelConfig,
          );
          final out2 = res2.textOutput?.trim() ?? '';
          if (out2.isNotEmpty && out2.length < out.length) {
            out = out2;
          }
        } catch (_) {
          // Use the original (over-budget) summary rather than failing.
        }
        // Hard truncate as last resort.
        if (out.length > _summaryCharBudget) {
          _logger.warning(
              'Summary still over budget after retry (${out.length} chars), truncating');
          out = '${out.substring(0, _summaryCharBudget)}...';
        }
      }
      return out;
    } catch (e) {
      _logger.warning('LLM summary generation failed: $e');
      return existingSummary.isNotEmpty
          ? existingSummary
          : _buildFallbackSummary(newEvents);
    }
  }

  String _buildFallbackSummary(List<String> events) {
    final rendered = CharacterContextAssembler.renderTimeline(events).trim();
    if (rendered.isEmpty) return 'Archived timeline events.';
    if (rendered.length <= _summaryCharBudget) return rendered;
    return '${rendered.substring(0, _summaryCharBudget)}...';
  }
}
