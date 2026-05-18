import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/memex_skill_host_agent/memex_skill_host_agent.dart';
import 'package:memex/agent/pure_skill_host_agent/pure_skill_host_agent.dart';
import 'package:memex/agent/super_agent/super_agent.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/location_context_service.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/token_usage_utils.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import 'package:memex/data/model/chat_events.dart';

export 'package:memex/data/model/chat_events.dart';

// --- Chat Service ---

class ChatService {
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;
  ChatService._internal();

  final Logger _logger = getLogger('ChatService');
  FileSystemService get _fileService => FileSystemService.instance;
  final Uuid _uuid = const Uuid();

  /// Send a message and get a stream of events.
  ///
  /// When [isQuickQuery] is true, the agent operates in read-only mode
  /// (filtered tools/skills), but the session is still persisted normally.
  Stream<ChatEvent> sendMessage(
    String message, {
    String? sessionId,
    String? agentName = 'memex_agent',
    String? scene = 'assistant',
    String? sceneId,
    List<Map<String, String>>? refs,
    bool isQuickQuery = false,
  }) async* {
    _logger.info(
      'sendMessage: sessionId=$sessionId, message=$message, refs=${refs?.length}',
    );

    final userId = await UserStorage.getUserId();
    if (userId == null) {
      yield ChatErrorEvent('User not logged in');
      return;
    }

    String finalSessionId = sessionId ?? '';
    final userMessageTime = DateTime.now();

    // 1. Session Management
    try {
      if (finalSessionId.isEmpty) {
        finalSessionId = await _createSession(
          userId,
          agentName,
          [
            {'type': 'text', 'text': message},
          ],
          isQuickQuery: isQuickQuery,
          createdAt: userMessageTime,
        );
      }

      // Notify UI of the active session ID immediately
      yield ChatSessionCreatedEvent(finalSessionId);

      // Save User Message
      await _addMessageToSession(
        userId,
        finalSessionId,
        'user',
        [
          {'type': 'text', 'text': message},
        ],
        refs: refs,
        isQuickQuery: isQuickQuery,
        timestamp: userMessageTime,
      );

      // Log chat event
      try {
        await _fileService.eventLogService.logEvent(
          userId: userId,
          eventType: 'user_chat',
          description: 'User sent message to agent',
          metadata: {
            'agent_name': agentName ?? 'memex_agent',
            'scene': scene ?? 'assistant',
            'scene_id': sceneId,
            'session_id': finalSessionId,
            'message': message,
            'message_local_time': formatLocalDateTimeWithZone(userMessageTime),
            'message_unix_seconds': unixSecondsFromDateTime(userMessageTime),
            'has_refs': refs != null && refs.isNotEmpty,
            'is_quick_query': isQuickQuery,
          },
        );
      } catch (e) {
        // Event logging failure should not break chat
      }
    } catch (e) {
      _logger.severe('Failed to manage session', e);
      yield ChatErrorEvent('Failed to initialize session: $e');
      return;
    }

    // 2. Initialize Agent
    StatefulAgent? agent;
    AgentController? controller;
    SkillSyncResult? skillSync;

    try {
      // Check if this session belongs to a custom agent by reading session metadata,
      // then load the latest config from CustomAgentConfigService.
      CustomAgentConfig? customAgentCfg;
      if (sessionId != null && sessionId.isNotEmpty) {
        final isCustom = await _isCustomAgentSession(userId, finalSessionId);
        if (isCustom && agentName != null && agentName.isNotEmpty) {
          final configs = await CustomAgentConfigService.instance.loadAll(
            userId,
          );
          customAgentCfg =
              configs.where((c) => c.agentName == agentName).firstOrNull;
        }
      }

      final agentIdForLLM =
          customAgentCfg?.llmConfigKey ?? AgentDefinitions.chatAgent;
      final resources = await UserStorage.getAgentLLMResources(
        agentIdForLLM,
        defaultClientKey:
            customAgentCfg?.llmConfigKey ?? LLMConfig.defaultClientKey,
      );
      final client = resources.client;
      final modelConfig = resources.modelConfig;

      // Load State
      final stateDirPath = await _fileService.getAgentStateDirectory(userId);
      final stateDir = Directory(stateDirPath);
      final storage = FileStateStorage(stateDir);
      final state = await storage.loadOrCreate(finalSessionId, {
        'userId': userId,
        'scene': scene,
        'sceneId': sceneId,
      });

      controller = AgentController();

      if (customAgentCfg != null) {
        // Recreate the same agent type used by custom_agent_task_handler.
        final skillDir = _fileService.resolveSkillPath(
          userId,
          customAgentCfg.skillDirectoryPath,
        );
        final workingDirAbs = await _fileService.resolveWorkingDirectory(
          userId,
          customAgentCfg.workingDirectory,
        );

        // Sync skill directory into workingDirectory if it's outside,
        // so file tools (Read, LS, etc.) can access skill files.
        skillSync = await _fileService.syncSkillsIfNeeded(
          skillAbsPath: skillDir,
          workingDirAbsPath: workingDirAbs,
        );

        switch (customAgentCfg.hostAgentType) {
          case HostAgentType.pure:
            agent = await PureSkillHostAgent.createAgent(
              client: client,
              modelConfig: modelConfig,
              userId: userId,
              name: agentName ?? 'custom_agent',
              state: state,
              skillDirectoryPath: skillSync.effectivePath,
              workingDirectory: workingDirAbs,
              controller: controller,
              additionalSystemPrompt: customAgentCfg.systemPrompt,
            );
            break;
          case HostAgentType.memex:
            agent = await MemexSkillHostAgent.createAgent(
              client: client,
              modelConfig: modelConfig,
              userId: userId,
              name: agentName ?? 'custom_agent',
              state: state,
              skillDirectoryPath: skillSync.effectivePath,
              workingDirectory: workingDirAbs,
              controller: controller,
              additionalSystemPrompt: customAgentCfg.systemPrompt,
            );
            break;
        }
      } else {
        // Default: use SuperAgent for normal chat sessions.
        var additionalSystemPrompt = """## Comprehensive Correction Principles
When the user disputes content you generated (such as Cards, PKM entries, or Asset Analysis Results) and provides correction suggestions, you must perform a **comprehensive** correction.
-   **Do not modify only a single dimension** (e.g., do not just modify the card body or just the asset analysis).
-   **You must check and synchronously correct all related content** to ensure overall consistency.
-   **Example**: If the user corrects the description of an image, you must not only update the image analysis result (`.analysis.txt`) but also check if the Card body (`Cards/...`) or related PKM entries that reference this image need to be updated synchronously.

## Interaction Guidelines
- **Ask Clarifying Questions**: You are engaging in a direct dialogue. If the user's request is unclear, explicitly ask for clarification instead of guessing.
- **Professional Tone**: You are communicating directly with the knowledge base owner. Maintain a formal, concise, and professional tone.
- **Know Your Limits**: If a task cannot be accomplished with your current skills and tools, explicitly decline the request with an explanation.

## Important
- **Language**: ${UserStorage.l10n.chatLanguageInstruction}
""";

        final forceActiveSkills = <String>[];
        if (scene == 'assistant_timeline_card_detail') {
          forceActiveSkills.add('manage_timeline_card');
          forceActiveSkills.add('manage_pkm');
        } else if (scene == 'insight_card_chat') {
          forceActiveSkills.add('update_knowledge_insight');
        }

        agent = await SuperAgent.createAgent(
          client: client,
          modelConfig: modelConfig,
          userId: userId,
          name: agentName ?? 'memex_agent',
          state: state,
          controller: controller,
          disableSubAgents: false,
          forceActiveSkills: forceActiveSkills,
          quickQuery: isQuickQuery,
          additionalSystemPrompt: additionalSystemPrompt,
        );
      }
    } catch (e) {
      _logger.severe('Failed to initialize agent', e);
      yield ChatErrorEvent('Failed to initialize agent: $e');
      return;
    }

    // 3. Setup Listeners & Run
    final streamController = StreamController<ChatEvent>();

    // Forward events from agent controller to stream
    _setupControllerListeners(
      controller,
      streamController,
      userId,
      finalSessionId,
    );

    // Build scene context reminder
    String sceneContext = "";
    switch (scene) {
      case 'assistant_timeline_card_detail':
        sceneContext =
            "The user is currently viewing a **Timeline Card Detail Page**. They may want to edit, analyze, or discuss this specific card.";
        break;
      case 'update_knowledge_insight':
      case 'insight_card_chat':
        sceneContext =
            "The user is currently on the **Knowledge Insights Page**. They may want to update insights, discuss existing insight cards, or generate new knowledge summaries.";
        break;
      default:
        sceneContext = "";
    }

    List<LLMMessage> userMessages = [];
    CurrentLocationContext? locationContext;
    String? locationContextReminder;
    try {
      locationContext =
          await LocationContextService.instance.getCurrentContext();
      locationContextReminder = locationContext.toAgentSystemReminderContent();
    } catch (e) {
      _logger.warning('Failed to decorate chat with location context: $e');
    }

    // Build combined system reminder content
    if (sceneContext.isNotEmpty ||
        locationContextReminder != null ||
        (refs != null && refs.isNotEmpty)) {
      final StringBuffer reminderContent = StringBuffer();
      reminderContent.write('<system-reminder>\n');

      // Add scene context if available
      if (sceneContext.isNotEmpty) {
        reminderContent.write(sceneContext);
        reminderContent.write('\n');
      }

      if (locationContextReminder != null) {
        if (sceneContext.isNotEmpty) {
          reminderContent.write('\n');
        }
        reminderContent.write(locationContextReminder);
        reminderContent.write('\n');
      }

      // Add refs context if available
      if (refs != null && refs.isNotEmpty) {
        if (sceneContext.isNotEmpty || locationContextReminder != null) {
          reminderContent.write('\n');
        }
        final refsString = refs
            .map(
              (r) =>
                  'Title: ${r['title']}\nType: ${r['type'] ?? 'unknown'}\nContent: ${r['content']}',
            )
            .join('\n\n');
        reminderContent.write(
          'The user has referenced the following content. Use this context to answer the user query:\n',
        );
        reminderContent.write(refsString);
        reminderContent.write('\n');
      }

      reminderContent.write('</system-reminder>');

      userMessages.addAll([
        UserMessage.text(reminderContent.toString()),
        ModelMessage(
          model: "mocked",
          textOutput: "Understood, I will keep this context in mind.",
        ),
      ]);
    }

    userMessages.add(
      UserMessage([
        TextPart(buildCurrentTimeReminder(userMessageTime)),
        TextPart(buildMessageTimePrefix(userMessageTime)),
        TextPart(message),
      ]),
    );

    // We don't await the result here, we rely on AgentStoppedEvent to handle completion
    agent.run(userMessages).whenComplete(() async {
      // Sync skill changes back to the original directory if we made a copy.
      if (skillSync != null) {
        try {
          await _fileService.syncSkillsBack(skillSync);
        } catch (e) {
          _logger.warning('Failed to sync skills back: $e');
        }
      }
    }).catchError((e) {
      // This catchError is for synchronous errors during startup or unhandled async errors
      // causing the run future to fail before AgentStoppedEvent might be emitted (though AgentStoppedEvent is in finally block)
      _logger.severe('Agent run failed (catchError)', e);
      if (!streamController.isClosed) {
        streamController.add(ChatErrorEvent(e.toString()));
        streamController.close();
      }
      return <LLMMessage>[];
    });

    yield* streamController.stream;
  }

  void _setupControllerListeners(
    AgentController controller,
    StreamController<ChatEvent> stream,
    String userId,
    String sessionId,
  ) {
    // 1. Lifecycle Events
    // 1. Lifecycle Events
    controller.on((AgentStartedEvent event) {
      _logger.info('Agent started');
      stream.add(ChatAgentStartedEvent());
    });

    controller.on((AgentStoppedEvent event) async {
      _logger.info('Agent stopped');

      // Calculate usage stats
      int totalPrompt = 0;
      int totalCompletion = 0;
      int totalCached = 0;
      int totalEffectivePrompt = 0;
      int totalCachedForRate = 0;
      int totalTokens = 0;
      double totalCost = 0.0;
      // Within a single agent turn all calls share the same client.
      bool? turnCacheSemantics;

      for (final msg in event.modelMessages) {
        final u = msg.usage;
        if (u == null) {
          continue;
        }

        final p = u.promptTokens;
        final c = u.completionTokens;
        final ca = u.cachedToken;
        final sem = TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: event.agent.client,
          originalUsage: u.originalUsage,
        );
        turnCacheSemantics ??= sem;
        final effP = TokenUsageUtils.effectivePromptTokensOrNull(
          promptTokens: p,
          cachedTokens: ca,
          cachedTokensIncludedInPrompt: sem,
        );

        totalPrompt += p;
        totalCompletion += c;
        totalCached += ca;
        if (effP != null) {
          totalEffectivePrompt += effP;
          totalCachedForRate += ca;
        }
        totalTokens += u.totalTokens;

        // Calculate cost
        final cost = TokenUsageUtils.calculateCost(
          model: msg.model,
          promptTokens: p,
          completionTokens: c,
          cachedTokens: ca,
          thoughtTokens: u.thoughtToken,
          cachedTokensIncludedInPrompt: sem,
        )['total']!;
        totalCost += cost;
      }

      if (event.error != null) {
        if (!stream.isClosed) {
          stream.add(ChatAgentStoppedEvent());
          stream.add(ChatErrorEvent(event.error.toString()));
          stream.close();
        }
        return;
      }

      // Handle success / final result
      String response = "Sorry, I couldn't generate a response.";
      if (event.modelMessages.isNotEmpty) {
        final lastMsg = event.modelMessages.last;
        if (lastMsg.textOutput != null) {
          response = lastMsg.textOutput!;
        }
      }

      // Save AI response with usage stats
      final responseTime = DateTime.now();
      final sessionTotalUsage = await _addMessageToSession(
        userId,
        sessionId,
        'ai',
        [
          {'type': 'text', 'text': response},
        ],
        usage: {
          'prompt_tokens': totalPrompt,
          'completion_tokens': totalCompletion,
          'cached_tokens': totalCached,
          if (turnCacheSemantics != null)
            'cache_tokens_included_in_prompt': turnCacheSemantics,
          'total_tokens': totalTokens,
          'total_cost': totalCost,
        },
        timestamp: responseTime,
      );

      // Emit Token Usage (Cumulative if available, else current turn)
      if (sessionTotalUsage != null) {
        stream.add(
          ChatTokenUsageEvent(
            promptTokens: sessionTotalUsage['prompt_tokens'] as int? ?? 0,
            completionTokens:
                sessionTotalUsage['completion_tokens'] as int? ?? 0,
            cachedTokens: sessionTotalUsage['cached_tokens'] as int? ?? 0,
            effectivePromptTokens: totalEffectivePrompt,
            cachedTokensForRate: totalCachedForRate,
            totalTokens: sessionTotalUsage['total_tokens'] as int? ?? 0,
            estimatedCost: sessionTotalUsage['total_cost'] as double? ?? 0.0,
          ),
        );
      } else if (totalTokens > 0) {
        // Fallback to single turn usage
        stream.add(
          ChatTokenUsageEvent(
            promptTokens: totalPrompt,
            completionTokens: totalCompletion,
            cachedTokens: totalCached,
            effectivePromptTokens: totalEffectivePrompt,
            cachedTokensForRate: totalCachedForRate,
            totalTokens: totalTokens,
            estimatedCost: totalCost,
          ),
        );
      }

      if (!stream.isClosed) {
        // Send a final empty chunk to mark isDone=true without duplicating text
        stream.add(ChatResponseChunkEvent('', isDone: true));
        stream.add(ChatAgentStoppedEvent());
        stream.close();
      }
    });

    // 2. Planning Events
    controller.on((PlanChangedEvent event) {
      String getStatusEmoji(String status) {
        switch (status.toLowerCase()) {
          case 'completed':
          case 'success':
          case 'done':
            return '✅';
          case 'active':
          case 'running':
          case 'inprogress':
            return '👉';
          case 'failed':
          case 'error':
            return '❌';
          case 'pending':
          default:
            return '⏳'; // Or ⬜
        }
      }

      final planText = event.plan.steps.map((t) {
        final emoji = getStatusEmoji(t.status.name);
        return '$emoji ${t.description}';
      }).join('\n\n');
      stream.add(ChatThoughtChunkEvent("Plan Updated:\n$planText"));
    });

    // 3. Thoughts & Chunks
    controller.on((LLMChunkEvent event) {
      if (event.response.thought != null &&
          event.response.thought!.isNotEmpty) {
        stream.add(ChatThoughtChunkEvent(event.response.thought!));
      }

      if (event.response.textOutput != null &&
          event.response.textOutput!.isNotEmpty) {
        stream.add(ChatResponseChunkEvent(event.response.textOutput!));
      }
    });

    // 4. Tool Call
    controller.on((BeforeToolCallEvent event) {
      stream.add(
        ChatToolCallEvent(
          event.functionCall.name,
          event.functionCall.arguments.toString(),
        ),
      );
    });

    // 5. Tool Result
    // 5. Tool Result
    controller.on((AfterToolCallEvent event) {
      // Format result for display
      final dynamic content = event.result.content;
      String resultPreview;

      if (content is List) {
        resultPreview = content.map((e) {
          if (e is TextPart) return e.text;
          return e.toString();
        }).join('\n');
      } else if (content is TextPart) {
        resultPreview = content.text;
      } else {
        resultPreview = content.toString();
      }

      if (resultPreview.length > 300) {
        resultPreview = '${resultPreview.substring(0, 300)}...';
      }
      stream.add(
        ChatToolResultEvent(
          event.result.name,
          resultPreview,
          isError: event.result.isError,
        ),
      );
    });
  }

  // --- Session Helpers (Recreated from chat.dart to be independent) ---

  /// Check whether a session file has `is_custom_agent: true`.
  Future<bool> _isCustomAgentSession(String userId, String sessionId) async {
    try {
      final sessionFile = _getSessionFilePath(userId, sessionId);
      if (!await sessionFile.exists()) return false;
      final content = await sessionFile.readAsString();
      final doc = loadYaml(content);
      final data = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
      return data['is_custom_agent'] == true;
    } catch (e) {
      _logger.warning('Failed to read session metadata: $e');
    }
    return false;
  }

  Future<String> _createSession(
    String userId,
    String? agentName,
    List<Map<String, dynamic>> initialContent, {
    bool isQuickQuery = false,
    DateTime? createdAt,
  }) async {
    final uuidStr = _uuid.v4();
    final sessionId = agentName != null && agentName.isNotEmpty
        ? '${agentName}_$uuidStr'
        : uuidStr;
    final now = createdAt ?? DateTime.now();

    String? title;
    for (final item in initialContent) {
      if (item['type'] == 'text' && item['text'] != null) {
        final text = item['text'] as String;
        title = text.length > 50 ? text.substring(0, 50) : text;
        break;
      }
    }

    final sessionData = {
      'session_id': sessionId,
      'agent_name': agentName,
      'title': title ?? 'New Chat',
      'created_at': now.toIso8601String(),
      'created_at_local': formatLocalDateTimeWithZone(now),
      'created_at_unix_seconds': unixSecondsFromDateTime(now),
      'updated_at': now.toIso8601String(),
      'updated_at_local': formatLocalDateTimeWithZone(now),
      'updated_at_unix_seconds': unixSecondsFromDateTime(now),
      'is_quick_query': isQuickQuery,
      'messages': <dynamic>[],
    };

    final sessionFile = _getSessionFilePath(userId, sessionId);
    final parentDir = sessionFile.parent;
    await parentDir.create(recursive: true);

    await _fileService.writeYamlFile(sessionFile.path, sessionData);
    return sessionId;
  }

  Future<Map<String, dynamic>?> _addMessageToSession(
    String userId,
    String sessionId,
    String role,
    List<Map<String, dynamic>> content, {
    Map<String, dynamic>? usage,
    List<Map<String, String>>? refs,
    bool? isQuickQuery,
    DateTime? timestamp,
  }) async {
    final sessionFile = _getSessionFilePath(userId, sessionId);
    if (!await sessionFile.exists()) return null;

    final fileContent = await sessionFile.readAsString();
    final doc = loadYaml(fileContent);
    final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;
    _backfillSessionTimeContext(sessionData);

    final messageTime = timestamp ?? DateTime.now();
    final messageDict = {
      'role': role,
      'content': content,
      if (usage != null) 'usage': usage,
      if (refs != null) 'refs': refs,
      'timestamp': messageTime.toIso8601String(),
      'local_time': formatLocalDateTimeWithZone(messageTime),
      'unix_seconds': unixSecondsFromDateTime(messageTime),
    };

    final messages = (sessionData['messages'] as List<dynamic>? ?? [])
        .map(_backfillMessageTimeContext)
        .toList()
      ..add(messageDict);
    sessionData['messages'] = messages;

    // Update cumulative session usage
    if (usage != null) {
      final currentTotal =
          sessionData['total_usage'] as Map<String, dynamic>? ??
              {
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'cached_tokens': 0,
                'total_tokens': 0,
                'total_cost': 0.0,
              };

      sessionData['total_usage'] = {
        'prompt_tokens': (currentTotal['prompt_tokens'] as int? ?? 0) +
            (usage['prompt_tokens'] as int? ?? 0),
        'completion_tokens': (currentTotal['completion_tokens'] as int? ?? 0) +
            (usage['completion_tokens'] as int? ?? 0),
        'cached_tokens': (currentTotal['cached_tokens'] as int? ?? 0) +
            (usage['cached_tokens'] as int? ?? 0),
        'total_tokens': (currentTotal['total_tokens'] as int? ?? 0) +
            (usage['total_tokens'] as int? ?? 0),
        'total_cost': (currentTotal['total_cost'] as double? ?? 0.0) +
            (usage['total_cost'] as double? ?? 0.0),
      };
    }

    // Update session-level mode flag so history can restore it
    if (isQuickQuery != null) {
      sessionData['is_quick_query'] = isQuickQuery;
    }

    final updatedAt = DateTime.now();
    sessionData['updated_at'] = updatedAt.toIso8601String();
    sessionData['updated_at_local'] = formatLocalDateTimeWithZone(updatedAt);
    sessionData['updated_at_unix_seconds'] = unixSecondsFromDateTime(updatedAt);

    await _fileService.writeYamlFile(sessionFile.path, sessionData);
    return sessionData['total_usage'] as Map<String, dynamic>?;
  }

  File _getSessionFilePath(String userId, String sessionId) {
    final sessionsPath = _fileService.getChatSessionsPath(userId);
    return File(p.join(sessionsPath, '$sessionId.yaml'));
  }

  void _backfillSessionTimeContext(Map<String, dynamic> sessionData) {
    final createdAt = tryParseDateTime(sessionData['created_at']);
    if (createdAt != null) {
      sessionData['created_at_local'] ??= formatLocalDateTimeWithZone(
        createdAt,
      );
      sessionData['created_at_unix_seconds'] ??= unixSecondsFromDateTime(
        createdAt,
      );
    }

    final updatedAt = tryParseDateTime(sessionData['updated_at']);
    if (updatedAt != null) {
      sessionData['updated_at_local'] ??= formatLocalDateTimeWithZone(
        updatedAt,
      );
      sessionData['updated_at_unix_seconds'] ??= unixSecondsFromDateTime(
        updatedAt,
      );
    }
  }

  dynamic _backfillMessageTimeContext(dynamic message) {
    if (message is! Map<String, dynamic>) {
      return message;
    }

    final parsed = tryParseDateTime(message['timestamp']);
    if (parsed == null) {
      return message;
    }

    return {
      ...message,
      'local_time':
          message['local_time'] ?? formatLocalDateTimeWithZone(parsed),
      'unix_seconds':
          message['unix_seconds'] ?? unixSecondsFromDateTime(parsed),
    };
  }
}
