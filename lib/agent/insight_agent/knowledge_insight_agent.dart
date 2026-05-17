import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:intl/intl.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/insight_agent/prompt.dart';
import 'package:memex/agent/insight_agent/knowledge_insight_run_context.dart';
import 'package:memex/agent/skills/knowledge_insight/knowledge_insight_skill.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('KnowledgeInsightAgent');

class KnowledgeInsightAgent {
  static const Duration interruptedRunResumeTtl = Duration(hours: 6);

  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required AgentState state,
  }) async {
    final fileService = FileSystemService.instance;
    final sessionId = state.sessionId;

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final skills = [KnowledgeInsightSkill(forceActivate: true)];

    final pkmPath = '${fileService.getWorkspacePath(userId)}/PKM';
    final pkmDir = Directory(pkmPath);
    if (!pkmDir.existsSync()) {
      pkmDir.createSync(recursive: true);
    }

    // Get working directory (Workspace Root)
    final workingDirectory = fileService.getWorkspacePath(userId);

    // KnowledgeInsightAgent reads durable workspace data and only writes
    // generated insight cards through the insight skill.
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(
        rootPath: fileService.getWorkspacePath(userId),
        access: FileAccessType.read,
      ),
      PermissionRule(
        rootPath: fileService.getCardsPath(userId),
        access: FileAccessType.read,
      ),
      PermissionRule(
        rootPath: fileService.getFactsPath(userId),
        access: FileAccessType.read,
      ),
      PermissionRule(
        rootPath: fileService.getPkmPath(userId),
        access: FileAccessType.read,
      ),
      PermissionRule(
        rootPath: fileService.getKnowledgeInsightsPath(userId),
        access: FileAccessType.write,
      ),
    ]);

    final fileToolFactory = FileToolFactory(
      permissionManager: permissionManager,
      workingDirectory: workingDirectory,
    );

    final tools = [
      fileToolFactory.buildLSTool(),
      fileToolFactory.buildGlobTool(),
      fileToolFactory.buildGrepTool(),
      fileToolFactory.buildReadTool(),
      fileToolFactory.buildBatchReadTool(),
      buildSearchEventLogsTool(),
      getCurrentTimeTool,
    ];

    // Memory Management
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'knowledge_insight_agent',
    );
    final memoryReadOnlyPrompt =
        await memoryManagement.buildMemoryReadOnlyPrompt();

    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    final agent = StatefulAgent(
      name: 'knowledge_insight_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      compressor: LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 64000,
        keepRecentMessageSize: 10,
      ),
      tools: tools,
      skills: skills,
      systemPrompts: [knowledgeInsightAgentSystemPrompt, memoryReadOnlyPrompt],
      disableSubAgents: false,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.auto,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    _logger.info(
      'KnowledgeInsightAgent created, userId: $userId, sessionId: $sessionId',
    );
    return agent;
  }

  static Future<bool> updateKnowledgeInsight({
    String? userId,
    String? runId,
    Duration resumeTtl = interruptedRunResumeTtl,
  }) async {
    final effectiveUserId = userId ?? await UserStorage.getUserId();
    if (effectiveUserId == null) {
      throw Exception('User not logged in, cannot refresh knowledge insight');
    }

    final now = DateTime.now();
    final effectiveRunId = _normalizeRunId(runId, now);
    final sessionId = _buildSessionId(effectiveUserId, effectiveRunId);

    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.knowledgeInsightAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;
    final modelConfig = resources.modelConfig;

    var state = await _loadOrCreateRunState(
      userId: effectiveUserId,
      runId: effectiveRunId,
      sessionId: sessionId,
      now: now,
    );

    if (!state.isRunning && state.history.messages.isNotEmpty) {
      _logger.info(
        'KnowledgeInsightAgent completed state residue, sessionId:$sessionId, delete state and restart',
      );
      await deleteAgentState(effectiveUserId, sessionId);
      state = await _loadOrCreateRunState(
        userId: effectiveUserId,
        runId: effectiveRunId,
        sessionId: sessionId,
        now: now,
      );
    } else if (state.isRunning &&
        !_shouldResumeInterruptedRun(state, now, resumeTtl)) {
      _logger.info(
        'KnowledgeInsightAgent stale interrupted run, sessionId:$sessionId, delete state and restart',
      );
      await deleteAgentState(effectiveUserId, sessionId);
      state = await _loadOrCreateRunState(
        userId: effectiveUserId,
        runId: effectiveRunId,
        sessionId: sessionId,
        now: now,
      );
    }

    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: effectiveUserId,
      state: state,
    );
    List<LLMMessage> result = [];
    try {
      if (state.isRunning) {
        _logger.info(
          "KnowledgeInsightAgent resume, sessionId:${state.sessionId}",
        );
        result = await agent.resume();
      } else {
        _logger.info("KnowledgeInsightAgent run, sessionId:${state.sessionId}");

        // Check if there are existing cards to determine if this is the first run
        final fileSystem = FileSystemService.instance;
        final existingCards = await fileSystem.listKnowledgeInsightCards(
          effectiveUserId,
        );

        final runContext = await buildKnowledgeInsightRunContext(
          userId: effectiveUserId,
          runId: effectiveRunId,
          now: now,
        );

        String inputMessage = "Please update knowledge insights.";

        if (existingCards.isEmpty) {
          inputMessage +=
              " This is your first time generating insights. Please analyze the user's ENTIRE knowledge base (PKM) and ALL facts comprehensively. Do NOT limit yourself to this week's data. You MUST first formulate a comprehensive analysis PLAN, then execute it to generate high-value, global insight cards.";
        }

        final messages = [
          UserMessage([
            TextPart(buildCurrentTimeReminder(now)),
            TextPart(runContext),
            TextPart(inputMessage),
          ]),
        ];
        _logger.info("KnowledgeInsightAgent start");

        // Log agent execution event
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: effectiveUserId,
            eventType: 'agent_execution',
            description: 'Knowledge Insight Agent started',
            metadata: {
              'agent_name': 'knowledge_insight_agent',
              'session_id': sessionId,
              'run_id': effectiveRunId,
              'input': inputMessage,
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }

        result = await agent.run(messages);
      }

      await _createInsightSummaryCardIfNeeded(agent.state, effectiveUserId);
      await deleteAgentState(effectiveUserId, sessionId);
    } on AgentException catch (e) {
      if (e.code == AgentExceptionCode.loopDetection) {
        await deleteAgentState(effectiveUserId, sessionId);
        _logger.info(
          "KnowledgeInsightAgent loop detection, sessionId:${state.sessionId}, delete state",
        );
      }
      rethrow;
    }
    _logger.info(
      "KnowledgeInsightAgent done, sessionId:${state.sessionId}, result messages length:${result.length}",
    );
    return true;
  }

  static Future<AgentState> _loadOrCreateRunState({
    required String userId,
    required String runId,
    required String sessionId,
    required DateTime now,
  }) async {
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'insight',
      'sceneId': runId,
      'run_id': runId,
      'run_started_at': now.toIso8601String(),
    });
    _ensureRunMetadata(state: state, userId: userId, runId: runId, now: now);
    return state;
  }

  static void _ensureRunMetadata({
    required AgentState state,
    required String userId,
    required String runId,
    required DateTime now,
  }) {
    state.metadata['userId'] = userId;
    state.metadata['scene'] = 'insight';
    state.metadata['sceneId'] = runId;
    state.metadata['run_id'] = runId;
    state.metadata.putIfAbsent('run_started_at', () => now.toIso8601String());
  }

  static bool _shouldResumeInterruptedRun(
    AgentState state,
    DateTime now,
    Duration ttl,
  ) {
    if (!state.isRunning) return false;
    final startedAtValue = state.metadata['run_started_at']?.toString();
    final startedAt =
        startedAtValue == null ? null : DateTime.tryParse(startedAtValue);
    if (startedAt == null) {
      return true;
    }
    final age = now.difference(startedAt);
    return age.isNegative || age <= ttl;
  }

  static String _normalizeRunId(String? runId, DateTime now) {
    final normalized = runId?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return 'manual_${now.microsecondsSinceEpoch}';
  }

  static String _buildSessionId(String userId, String runId) {
    return 'knowledge_insight_${_safeSessionPart(userId)}_${_safeSessionPart(runId)}';
  }

  static String _safeSessionPart(String value) {
    final safe = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (safe.isEmpty) {
      return 'unknown';
    }
    if (safe.length <= 96) {
      return safe;
    }
    return safe.substring(safe.length - 96);
  }

  static Future<void> _createInsightSummaryCardIfNeeded(
    AgentState state,
    String userId,
  ) async {
    final updatesTracker =
        state.metadata['insight_updates'] as Map<String, dynamic>?;
    if (updatesTracker == null) {
      return;
    }

    final addedCards = List<Map<String, dynamic>>.from(
      updatesTracker['added'] ?? [],
    );
    final updatedCards = List<Map<String, dynamic>>.from(
      updatesTracker['updated'] ?? [],
    );

    if (addedCards.isEmpty && updatedCards.isEmpty) {
      return;
    }

    try {
      final now = DateTime.now();
      final timestampSec = now.millisecondsSinceEpoch ~/ 1000;
      final dateStr = DateFormat('yyyy/MM/dd').format(now);
      final factId = '$dateStr.md#ts_${now.millisecondsSinceEpoch}';

      final cardData = CardData(
        factId: factId,
        title: UserStorage.l10n.knowledgeNewDiscovery,
        timestamp: timestampSec,
        status: 'completed',
        tags: ['insight'],
        uiConfigs: [
          UiConfig(
            templateId: 'insight_summary',
            data: {
              'added_insight_cards': addedCards,
              'updated_insight_cards': updatedCards,
            },
          ),
        ],
      );

      final fileService = FileSystemService.instance;
      await fileService.safeWriteCardFile(userId, factId, cardData);
      _logger.info(
        'Created insight summary card: ${addedCards.length} added, ${updatedCards.length} updated',
      );
    } catch (e) {
      _logger.warning('Failed to create insight summary card: $e');
    }
  }
}
