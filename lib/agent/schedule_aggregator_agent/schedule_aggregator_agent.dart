import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:intl/intl.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/schedule_aggregator_agent/prompt.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/event_bus_message.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleAggregatorAgent');

class ScheduleAggregatorAgent {
  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
  }) async {
    final fileService = FileSystemService.instance;

    final sessionId = "schedule_aggregator_$userId";

    // Load or create agent state
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'schedule_aggregation',
      'sceneId': sessionId,
    });

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final skills = [
      ScheduleAggregationSkill(forceActivate: true),
    ];

    // Ensure output directory exists
    final scheduleAggPath = fileService.getScheduleAggregationsPath(userId);
    final scheduleAggDir = Directory(scheduleAggPath);
    if (!scheduleAggDir.existsSync()) {
      scheduleAggDir.createSync(recursive: true);
    }

    final workingDirectory = fileService.getWorkspacePath(userId);

    // Configure File Permission Manager
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
          rootPath: fileService.getScheduleAggregationsPath(userId),
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
      sourceAgent: 'schedule_aggregator_agent',
    );
    final memoryManagementPrompt =
        await memoryManagement.buildMemoryManagementPrompt();
    final memoryManagementTools = memoryManagement.buildMemoryManagementTools();
    tools.addAll(memoryManagementTools);

    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    final agent = StatefulAgent(
      name: 'schedule_aggregator_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      compressor: LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 32000,
        keepRecentMessageSize: 10,
      ),
      tools: tools,
      skills: skills,
      systemPrompts: [
        scheduleAggregatorSystemPrompt,
        memoryManagementPrompt,
      ],
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
        'ScheduleAggregatorAgent created, userId: $userId, sessionId: $sessionId');
    return agent;
  }

  static Future<bool> updateScheduleAggregation() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot refresh schedule aggregation');
    }

    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.scheduleAggregatorAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;
    final modelConfig = resources.modelConfig;

    final sessionId = "schedule_aggregator_$userId";
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'schedule_aggregation',
      'sceneId': sessionId,
    });

    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
    );

    List<LLMMessage> result = [];
    try {
      if (state.isRunning) {
        _logger.info(
            "ScheduleAggregatorAgent resume, sessionId:${state.sessionId}");
        result = await agent.resume();
      } else {
        _logger.info(
            "ScheduleAggregatorAgent run, sessionId:${state.sessionId}");

        String inputMessage = "Please update schedule aggregation.";

        final messages = [
          UserMessage([
            TextPart(
                "<system-reminder>current time is ${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}.</system-reminder>"),
            TextPart(inputMessage),
          ])
        ];
        _logger.info("ScheduleAggregatorAgent start");

        // Log agent execution event
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: userId,
            eventType: 'agent_execution',
            description: 'Schedule Aggregator Agent started',
            metadata: {
              'agent_name': 'schedule_aggregator_agent',
              'session_id': sessionId,
              'input': inputMessage,
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }

        result = await agent.run(messages);

        // Post-processing: emit UI refresh event
        EventBusService.instance.emitEvent(ScheduleAggregationUpdatedMessage(
          aggregationId: sessionId,
        ));
      }
    } on AgentException catch (e) {
      if (e.code == AgentExceptionCode.loopDetection) {
        await deleteAgentState(userId, sessionId);
        _logger.info(
            "ScheduleAggregatorAgent loop detection, sessionId:${state.sessionId}, delete state");
      }
      rethrow;
    }

    _logger.info(
        "ScheduleAggregatorAgent done, sessionId:${state.sessionId}, result messages length:${result.length}");
    return true;
  }
}
