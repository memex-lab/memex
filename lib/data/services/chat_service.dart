import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:memex/agent/memex_skill_host_agent/memex_skill_host_agent.dart';
import 'package:memex/agent/pure_skill_host_agent/pure_skill_host_agent.dart';
import 'package:memex/agent/super_agent/super_agent.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
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
  final FileSystemService _fileService = FileSystemService.instance;
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
        'sendMessage: sessionId=$sessionId, message=$message, refs=${refs?.length}');

    final userId = await UserStorage.getUserId();
    if (userId == null) {
      yield ChatErrorEvent('User not logged in');
      return;
    }

    String finalSessionId = sessionId ?? '';

    // 1. Session Management
    try {
      if (finalSessionId.isEmpty) {
        finalSessionId = await _createSession(
            userId,
            agentName,
            [
              {'type': 'text', 'text': message}
            ],
            isQuickQuery: isQuickQuery);
      }

      // Notify UI of the active session ID immediately
      yield ChatSessionCreatedEvent(finalSessionId);

      // Save User Message
      await _addMessageToSession(
          userId,
          finalSessionId,
          'user',
          [
            {'type': 'text', 'text': message}
          ],
          refs: refs,
          isQuickQuery: isQuickQuery);

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
          final configs =
              await CustomAgentConfigService.instance.loadAll(userId);
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
            userId, customAgentCfg.skillDirectoryPath);
        final workingDirAbs = await _fileService.resolveWorkingDirectory(
            userId, customAgentCfg.workingDirectory);

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
        controller, streamController, userId, finalSessionId);

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

    // Build combined system reminder content
    if (sceneContext.isNotEmpty || (refs != null && refs.isNotEmpty)) {
      final StringBuffer reminderContent = StringBuffer();
      reminderContent.write('<system-reminder>\n');

      // Add scene context if available
      if (sceneContext.isNotEmpty) {
        reminderContent.write(sceneContext);
        reminderContent.write('\n');
      }

      // Add refs context if available
      if (refs != null && refs.isNotEmpty) {
        if (sceneContext.isNotEmpty) {
          reminderContent.write('\n');
        }
        final refsString = refs
            .map((r) =>
                'Title: ${r['title']}\nType: ${r['type'] ?? 'unknown'}\nContent: ${r['content']}')
            .join('\n\n');
        reminderContent.write(
            'The user has referenced the following content. Use this context to answer the user query:\n');
        reminderContent.write(refsString);
        reminderContent.write('\n');
      }

      reminderContent.write('</system-reminder>');

      userMessages.addAll([
        UserMessage.text(reminderContent.toString()),
        ModelMessage(
            model: "mocked",
            textOutput: "Understood, I will keep this context in mind.")
      ]);
    }

    userMessages.add(UserMessage([
      TextPart(
          "<system-reminder>current time is ${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}</system-reminder>."),
      TextPart(message),
    ]));

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
      int totalCacheBase = 0;
      int totalTokens = 0;
      double totalCost = 0.0;

      for (final msg in event.modelMessages) {
        final u = msg.usage;
        if (u == null) {
          continue; // Just in case, but lint says it's not null. Actually if lint says it CANT be null, then I don't need check.
        }
        // Wait, if lint says "Left operand cant be null", it means msg.usage is NOT null.
        // So I can just use it.

        final p = u.promptTokens;
        final c = u.completionTokens;
        final ca = u.cachedToken;
        final cachedTokensIncludedInPrompt =
            TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: event.agent.client,
          originalUsage: u.originalUsage,
        );
        final cacheBase = TokenUsageUtils.effectivePromptTokensOrNull(
            promptTokens: p,
            cachedTokens: ca,
            cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt);

        totalPrompt += p;
        totalCompletion += c;
        totalCached += ca;
        totalCacheBase += cacheBase ?? 0;
        totalTokens += u.totalTokens;

        // Calculate cost
        final cost = _calculateCost(
            msg.model, p, c, ca, u.thoughtToken, cachedTokensIncludedInPrompt);
        totalCost += cost['total']!;
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
      final sessionTotalUsage =
          await _addMessageToSession(userId, sessionId, 'ai', [
        {'type': 'text', 'text': response}
      ], usage: {
        'prompt_tokens': totalPrompt,
        'completion_tokens': totalCompletion,
        'cached_tokens': totalCached,
        'cache_base_tokens': totalCacheBase,
        'total_tokens': totalTokens,
        'total_cost': totalCost
      });

      // Emit Token Usage (Cumulative if available, else current turn)
      if (sessionTotalUsage != null) {
        stream.add(ChatTokenUsageEvent(
          promptTokens: sessionTotalUsage['prompt_tokens'] as int? ?? 0,
          completionTokens: sessionTotalUsage['completion_tokens'] as int? ?? 0,
          cachedTokens: sessionTotalUsage['cached_tokens'] as int? ?? 0,
          cacheBaseTokens: sessionTotalUsage['cache_base_tokens'] as int? ?? 0,
          totalTokens: sessionTotalUsage['total_tokens'] as int? ?? 0,
          estimatedCost: sessionTotalUsage['total_cost'] as double? ?? 0.0,
        ));
      } else if (totalTokens > 0) {
        // Fallback to single turn usage
        stream.add(ChatTokenUsageEvent(
          promptTokens: totalPrompt,
          completionTokens: totalCompletion,
          cachedTokens: totalCached,
          cacheBaseTokens: totalCacheBase,
          totalTokens: totalTokens,
          estimatedCost: totalCost,
        ));
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
      stream.add(ChatToolCallEvent(
          event.functionCall.name, event.functionCall.arguments.toString()));
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
      stream.add(ChatToolResultEvent(event.result.name, resultPreview,
          isError: event.result.isError));
    });
  }

  static const _pricing = {
    'gemini-3-flash-preview': {
      'input': 0.0000005,
      'cached': 0.00000005,
      'output': 0.000003,
    },
    'gemini-2.5-flash': {
      'input': 0.0000003,
      'cached': 0.00000003,
      'output': 0.0000025,
    },
    'gemini-3.1-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gemini-3-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gpt-4o': {
      'input': 0.0000025,
      'cached': 0.00000125,
      'output': 0.00001,
    },
  };

  Map<String, double> _calculateCost(String model, int prompt, int completion,
      int cached, int thought, bool? cachedTokensIncludedInPrompt) {
    // Default to gemini-1.5-flash pricing if unknown
    final prices = _pricing[model] ?? _pricing['gemini-3-flash-preview']!;

    final effectivePrompt = TokenUsageUtils.nonCachedPromptTokensOrNull(
            promptTokens: prompt,
            cachedTokens: cached,
            cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt) ??
        prompt;

    final inputCost =
        (effectivePrompt * prices['input']!) + (cached * prices['cached']!);
    final outputCost = model.startsWith(
            'ep-') // todo: responses API completion includes thought
        ? completion * prices['output']!
        : (completion + thought) * prices['output']!;

    return {
      'input': inputCost,
      'output': outputCost,
      'total': inputCost + outputCost,
    };
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
  }) async {
    final uuidStr = _uuid.v4();
    final sessionId = agentName != null && agentName.isNotEmpty
        ? '${agentName}_$uuidStr'
        : uuidStr;
    final now = DateTime.now();

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
      'updated_at': now.toIso8601String(),
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
  }) async {
    final sessionFile = _getSessionFilePath(userId, sessionId);
    if (!await sessionFile.exists()) return null;

    final fileContent = await sessionFile.readAsString();
    final doc = loadYaml(fileContent);
    final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

    final messageDict = {
      'role': role,
      'content': content,
      if (usage != null) 'usage': usage,
      if (refs != null) 'refs': refs,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final messages = (sessionData['messages'] as List<dynamic>? ?? [])
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
                'cache_base_tokens': 0,
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
        'cache_base_tokens': (currentTotal['cache_base_tokens'] as int? ?? 0) +
            (usage['cache_base_tokens'] as int? ?? 0),
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

    sessionData['updated_at'] = DateTime.now().toIso8601String();

    await _fileService.writeYamlFile(sessionFile.path, sessionData);
    return sessionData['total_usage'] as Map<String, dynamic>?;
  }

  File _getSessionFilePath(String userId, String sessionId) {
    final sessionsPath = _fileService.getChatSessionsPath(userId);
    return File(p.join(sessionsPath, '$sessionId.yaml'));
  }
}
