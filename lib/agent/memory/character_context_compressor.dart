import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/agent/memory/character_memory_updater.dart';
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
    int keepRecent = 40,
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
      final summary = await _buildSummaryWithLlm(userId, oldLines);
      final checkpoint = <String, dynamic>{
        'created_at': DateTime.now().toIso8601String(),
        'covered_events': oldLines.length,
        'summary': summary,
      };
      await svc.appendArchivedTimelineLines(userId, characterId, oldLines);
      await svc.appendCheckpoint(userId, characterId, checkpoint);
      await svc.replaceTimelineLines(userId, characterId, keptLines);

      // Extract durable memories from the raw events being compressed.
      // try {
      //   await CharacterMemoryUpdater.instance.updateFromCompressedEvents(
      //     userId: userId,
      //     characterId: characterId,
      //     rawEventLines: oldLines,
      //   );
      // } catch (e) {
      //   _logger.warning('Memory extraction after compression failed: $e');
      // }

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
      // De-duplicate near-identical lines by hash key.
      final key = line.length > 160 ? line.substring(0, 160) : line;
      if (!seen.add(key)) {
        continue;
      }
      var normalized = line;
      // Truncate overlong JSON snippets while preserving valid JSON if possible.
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
    // Keep at least one most-recent user turn in raw tail.
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

  String _buildHeuristicSummary(List<String> oldLines) {
    var userChat = 0;
    var characterChat = 0;
    var posts = 0;
    var characterComments = 0;
    var userReplies = 0;
    final highlights = <String>[];

    for (final line in oldLines) {
      try {
        final obj = jsonDecode(line);
        if (obj is! Map) continue;
        final m = Map<String, dynamic>.from(obj);
        final type = (m['event_type'] as String?) ?? '';
        final content = (m['content'] as String?)?.trim() ?? '';
        switch (type) {
          case 'userChatMessage':
            userChat++;
            break;
          case 'characterChatMessage':
            characterChat++;
            break;
          case 'postObserved':
            posts++;
            break;
          case 'characterComment':
            characterComments++;
            break;
          case 'userCommentReply':
            userReplies++;
            break;
        }
        if (content.isNotEmpty && highlights.length < 8) {
          final clipped = content.length > 120
              ? '${content.substring(0, 120)}...'
              : content;
          final thread = (m['thread_id'] as String?) ?? '';
          highlights
              .add('- [$type${thread.isEmpty ? '' : ' · $thread'}] $clipped');
        }
      } catch (_) {}
    }

    final b = StringBuffer();
    b.writeln('Event counts:');
    b.writeln('- user chat messages: $userChat');
    b.writeln('- character chat messages: $characterChat');
    b.writeln('- observed posts: $posts');
    b.writeln('- character comments: $characterComments');
    b.writeln('- user comment replies: $userReplies');
    if (highlights.isNotEmpty) {
      b.writeln('');
      b.writeln('Representative highlights:');
      for (final h in highlights) {
        b.writeln(h);
      }
    }
    return b.toString().trim();
  }

  /// Maximum recommended character count for a single checkpoint summary.
  /// ~3000 tokens ≈ 12000 characters for mixed CJK/English content.
  static const int _checkpointCharBudget = 12000;

  Future<String> _buildSummaryWithLlm(
      String userId, List<String> oldLines) async {
    final fallback = _buildHeuristicSummary(oldLines);
    if (oldLines.isEmpty) return fallback;
    final raw = oldLines.join('\n');
    final prompt =
        '''You summarize cross-scene relationship history for a role-play character.

Summarize the following events into concise markdown with sections:
- Topic Continuity
- Stable Facts about the user
- Relationship Changes
- Emotional Trajectory
- Open Threads

Requirements:
- Keep it factual and compact.
- Preserve important names/preferences.
- No JSON, markdown only.
- CRITICAL: Output MUST be under $_checkpointCharBudget characters total. Be ruthlessly concise. Drop low-value details to stay within budget.

Events:
$raw
''';
    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.chatAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );
      final res = await resources.client.generate(
        [
          UserMessage([TextPart(prompt)])
        ],
        modelConfig: resources.modelConfig,
      );
      var out = res.textOutput?.trim() ?? '';
      if (out.isEmpty) return fallback;

      // If output exceeds budget, ask for a tighter version.
      if (out.length > _checkpointCharBudget) {
        _logger.info(
            'Checkpoint summary too long (${out.length} chars), requesting condensed version');
        final condensePrompt =
            'The following summary is ${out.length} characters but must be under $_checkpointCharBudget characters. '
            'Condense it aggressively while preserving the most important facts and open threads. '
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
        // If still over budget after retry, hard truncate.
        if (out.length > _checkpointCharBudget) {
          _logger.warning(
              'Checkpoint still over budget after retry (${out.length} chars), truncating');
          out = '${out.substring(0, _checkpointCharBudget)}...';
        }
      }
      return out;
    } catch (_) {
      return fallback;
    }
  }
}
