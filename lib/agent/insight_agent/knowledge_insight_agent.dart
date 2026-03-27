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
import 'package:memex/agent/skills/knowledge_insight/knowledge_insight_skill.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('KnowledgeInsightAgent');

class KnowledgeInsightAgent {
  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
  }) async {
    final fileService = FileSystemService.instance;

    final sessionId = "knowledge_insight_$userId";

    // Load or create agent state
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'insight',
      'sceneId': sessionId,
    });

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final skills = [
      KnowledgeInsightSkill(forceActivate: true),
    ];

    final pkmPath = '${fileService.getWorkspacePath(userId)}/PKM';
    final pkmDir = Directory(pkmPath);
    if (!pkmDir.existsSync()) {
      pkmDir.createSync(recursive: true);
    }

    // Get working directory (Workspace Root)
    final workingDirectory = fileService.getWorkspacePath(userId);

    // Configure File Permission Manager
    // KnowledgeInsightAgent has access to:
    // - Read: / (Global context for analysis)
    // - Write: /Cards (Generate insight cards)
    // - Write: /Facts (Update/Link facts)
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(
          rootPath: fileService.getWorkspacePath(userId),
          access: FileAccessType.read),
      PermissionRule(
          rootPath: fileService.getCardsPath(userId),
          access: FileAccessType.read),
      PermissionRule(
          rootPath: fileService.getFactsPath(userId),
          access: FileAccessType.read),
      PermissionRule(
          rootPath: fileService.getPkmPath(userId),
          access: FileAccessType.read),
      PermissionRule(
          rootPath: fileService.getKnowledgeInsightsPath(userId),
          access: FileAccessType.write),
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
    final memoryManagementPrompt =
        await memoryManagement.buildMemoryManagementPrompt();
    final memoryManagementTools = memoryManagement.buildMemoryManagementTools();
    tools.addAll(memoryManagementTools);

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
        systemPrompts: [
          knowledgeInsightAgentSystemPrompt,
          memoryManagementPrompt
        ],
        disableSubAgents: false,
        controller: controller,
        withGeneralPrinciples: true,
        planMode: PlanMode.auto,
        systemCallback: createSystemCallback(userId),
        autoSaveStateFunc: (state) async {
          await saveAgentState(state);
        });

    _logger.info(
        'KnowledgeInsightAgent created, userId: $userId, sessionId: $sessionId');
    return agent;
  }

  static Future<bool> updateKnowledgeInsight() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot refresh knowledge insight');
    }
    final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.knowledgeInsightAgent,
        defaultClientKey: LLMConfig.defaultClientKey);
    final client = resources.client;
    final modelConfig = resources.modelConfig;
    final sessionId = "knowledge_insight_$userId";
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'insight',
      'sceneId': userId,
    });
    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
    );
    List<LLMMessage> result = [];
    try {
      if (state.isRunning) {
        _logger
            .info("KnowledgeInsightAgent resume, sessionId:${state.sessionId}");
        result = await agent.resume();
      } else {
        _logger.info("KnowledgeInsightAgent run, sessionId:${state.sessionId}");

        // Check if there are existing cards to determine if this is the first run
        final fileSystem = FileSystemService.instance;
        final existingCards =
            await fileSystem.listKnowledgeInsightCards(userId);

        String inputMessage = "Please update knowledge insights.";

        if (existingCards.isEmpty) {
          inputMessage +=
              " This is your first time generating insights. Please analyze the user's ENTIRE knowledge base (PKM) and ALL facts comprehensively. Do NOT limit yourself to this week's data. You MUST first formulate a comprehensive analysis PLAN, then execute it to generate high-value, global insight cards.";
        }

        final messages = [
          UserMessage([
            TextPart(
                "<system-reminder>current time is ${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}.</system-reminder>"),
            TextPart(inputMessage),
          ])
        ];
        _logger.info("KnowledgeInsightAgent start");

        // Log agent execution event
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: userId,
            eventType: 'agent_execution',
            description: 'Knowledge Insight Agent started',
            metadata: {
              'agent_name': 'knowledge_insight_agent',
              'session_id': sessionId,
              'input': inputMessage,
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }

        result = await agent.run(messages);

        // After agent run, check for insight updates and create summary timeline card
        final updatesTracker =
            agent.state.metadata['insight_updates'] as Map<String, dynamic>?;
        if (updatesTracker != null) {
          final addedCards =
              List<Map<String, dynamic>>.from(updatesTracker['added'] ?? []);
          final updatedCards =
              List<Map<String, dynamic>>.from(updatesTracker['updated'] ?? []);

          if (addedCards.isNotEmpty || updatedCards.isNotEmpty) {
            try {
              final timestampSec =
                  DateTime.now().millisecondsSinceEpoch ~/ 1000;
              final dateStr = DateFormat('yyyy/MM/dd').format(DateTime.now());
              final factId =
                  '$dateStr.md#ts_${DateTime.now().millisecondsSinceEpoch}';

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
                  'Created insight summary card: ${addedCards.length} added, ${updatedCards.length} updated');
            } catch (e) {
              _logger.warning('Failed to create insight summary card: $e');
            }

            // Clear tracker to avoid regenerating on resume
            agent.state.metadata['insight_updates'] = {
              'added': [],
              'updated': []
            };
            await saveAgentState(agent.state);
          }
        }
      }
    } on AgentException catch (e) {
      if (e.code == AgentExceptionCode.loopDetection) {
        await deleteAgentState(userId, sessionId);
        _logger.info(
            "KnowledgeInsightAgent loop detection, sessionId:${state.sessionId}, delete state");
      }
      rethrow;
    }
    _logger.info(
        "KnowledgeInsightAgent done, sessionId:${state.sessionId}, result messages length:${result.length}");
    return true;
  }
}
