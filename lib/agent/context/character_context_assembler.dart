import 'dart:convert';
import 'dart:io';

import 'package:memex/agent/context/user_knowledge_context_service.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/time_context.dart';
import 'package:path/path.dart' as p;

class CharacterContextSnapshot {
  final String userProfile;
  final String characterMemories;
  final String characterWorld;
  final String recentTimeline;
  final String checkpoints;
  final String knowledgeCards;

  const CharacterContextSnapshot({
    required this.userProfile,
    required this.characterMemories,
    required this.characterWorld,
    required this.recentTimeline,
    required this.checkpoints,
    required this.knowledgeCards,
  });
}

class CharacterContextAssembler {
  CharacterContextAssembler._();

  static Future<CharacterContextSnapshot> build({
    required String userId,
    required CharacterModel character,
    required String sourceAgent,
    int timelineTailCount = 20,
    String queryHint = '',
    String? excludeTimelineThreadId,
    bool excludeTrailingUserMessage = false,
  }) async {
    final memoryService = CharacterMemoryService.instance;
    await memoryService.ensureMigrated(userId, character.id);

    final characterMemoriesRaw = await memoryService.buildAllMemoriesText(
      userId: userId,
      characterId: character.id,
    );
    final characterWorldRaw =
        await memoryService.buildTriggeredWorldEntriesText(
      userId: userId,
      characterId: character.id,
      queryHint: queryHint,
    );
    final userProfileRaw = await _loadUserProfile(userId, sourceAgent);
    final recentTimelineRaw = await _loadRecentTimeline(
      userId,
      character.id,
      limit: timelineTailCount,
      excludeThreadId: excludeTimelineThreadId,
      excludeTrailingUserMessage: excludeTrailingUserMessage,
    );
    final checkpointsRaw = await memoryService.loadRecentCheckpointsAsText(
      userId,
      character.id,
      limit: 3,
    );
    final knowledgeCardsRaw =
        await UserKnowledgeContextService.instance.buildKnowledgeCards(
      userId: userId,
      queryHint: queryHint,
    );

    // Only knowledge and world entries get hard-capped here.
    // userProfile, characterMemories, checkpoints, and timeline pass through
    // unclipped — their size is controlled at write time (memory add) or
    // compression time (checkpoints/timeline).
    const characterWorldCap = 2000;
    const knowledgeCap = 2000;

    final characterWorld = _clipByTokens(characterWorldRaw, characterWorldCap);
    final knowledgeCards = _clipByTokens(knowledgeCardsRaw, knowledgeCap);

    return CharacterContextSnapshot(
      userProfile: userProfileRaw,
      characterMemories: characterMemoriesRaw,
      characterWorld: characterWorld,
      recentTimeline: recentTimelineRaw,
      checkpoints: checkpointsRaw,
      knowledgeCards: knowledgeCards,
    );
  }

  static String _clipByTokens(String input, int maxTokens) {
    if (input.isEmpty) return input;
    final maxChars = maxTokens * 4;
    if (input.length <= maxChars) return input;
    return '${input.substring(0, maxChars)}...';
  }

  static Future<String> _loadUserProfile(
      String userId, String sourceAgent) async {
    try {
      final mm = await MemoryManagement.createDefault(
        userId: userId,
        sourceAgent: sourceAgent,
      );
      return mm.buildMemoryPrompt();
    } catch (_) {
      return '';
    }
  }

  static Future<String> _loadRecentTimeline(
    String userId,
    String characterId, {
    required int limit,
    String? excludeThreadId,
    bool excludeTrailingUserMessage = false,
  }) async {
    final path = p.join(
      FileSystemService.instance.getSystemPath(userId),
      'character_memory',
      characterId,
      'timeline.jsonl',
    );
    final file = File(path);
    if (!await file.exists()) return '';
    var lines = await file.readAsLines();
    if (lines.isEmpty) return '';

    // Drop the trailing userChatMessage to avoid duplication with the current
    // user input that will be passed separately to the agent.
    if (excludeTrailingUserMessage && lines.isNotEmpty) {
      try {
        final lastObj = jsonDecode(lines.last);
        if (lastObj is Map && lastObj['event_type'] == 'userChatMessage') {
          lines = lines.sublist(0, lines.length - 1);
        }
      } catch (_) {}
    }

    if (lines.isEmpty) return '';
    final start = lines.length > limit ? lines.length - limit : 0;
    final tail = lines.sublist(start);
    return _renderTimeline(tail, excludeThreadId: excludeThreadId);
  }

  static String _renderTimeline(
    List<String> lines, {
    String? excludeThreadId,
  }) {
    final events = <Map<String, dynamic>>[];
    for (final line in lines) {
      try {
        final obj = jsonDecode(line);
        if (obj is Map) {
          final event = Map<String, dynamic>.from(obj);
          final threadId = event['thread_id'] as String? ?? '';
          if (excludeThreadId != null &&
              excludeThreadId.isNotEmpty &&
              threadId == excludeThreadId) {
            continue;
          }
          events.add(event);
        }
      } catch (_) {}
    }
    if (events.isEmpty) return '';

    final b = StringBuffer();
    String? currentThread;
    for (final event in events) {
      final scene = event['scene'] as String? ?? '';
      final eventType = event['event_type'] as String? ?? '';
      final threadId = event['thread_id'] as String? ?? '';
      final rawTs = event['ts'] as String? ?? '';
      final content = (event['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) continue;

      // Format timestamp with timezone for readability
      final ts = _formatEventTimestamp(rawTs);

      final groupKey = scene == CharacterMemoryScene.comment.name
          ? 'comment:$threadId'
          : 'chat:${threadId.isEmpty ? 'direct' : threadId}';
      if (groupKey != currentThread) {
        if (b.isNotEmpty) b.writeln('');
        if (scene == CharacterMemoryScene.comment.name) {
          b.writeln(
              '### Post Comment Thread · $ts · ${threadId.isEmpty ? 'unknown thread' : threadId}');
        } else {
          b.writeln('### Direct Chat · $ts');
        }
        currentThread = groupKey;
      }

      switch (eventType) {
        case 'postObserved':
          b.writeln('[$ts] Post:');
          b.writeln(content);
          break;
        case 'characterComment':
          final replyTo = event['reply_to_id'] as String?;
          b.writeln(
              '[$ts] Character commented${replyTo == null ? '' : ' (reply to $replyTo)'}:');
          b.writeln(content);
          break;
        case 'userCommentReply':
          final replyTo = event['reply_to_id'] as String?;
          b.writeln(
              '[$ts] User replied${replyTo == null ? '' : ' (reply to $replyTo)'}:');
          b.writeln(content);
          break;
        case 'userChatMessage':
          b.writeln('[$ts] User: $content');
          break;
        case 'characterChatMessage':
          b.writeln('[$ts] Character: $content');
          break;
        default:
          b.writeln('[$ts] $eventType: $content');
      }
    }
    return b.toString().trim();
  }

  /// Parse an ISO 8601 timestamp and format it with timezone for LLM readability.
  static String _formatEventTimestamp(String rawTs) {
    if (rawTs.isEmpty) return 'unknown time';
    final dt = DateTime.tryParse(rawTs);
    if (dt == null) return rawTs;
    return formatLocalDateTimeWithZone(dt);
  }
}
