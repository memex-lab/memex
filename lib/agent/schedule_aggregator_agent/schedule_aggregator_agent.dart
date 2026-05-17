import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregation_run_context.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregation_run_lifecycle.dart';
import 'package:memex/agent/schedule_aggregator_agent/prompt.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleAggregatorAgent');

class ScheduleAggregatorAgent {
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

    final skills = [ScheduleAggregationSkill(forceActivate: true)];

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
        rootPath: fileService.getScheduleAggregationsPath(userId),
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

    // Memory is read-only for this batch agent. Durable memory can inform the
    // summary, but schedule aggregation should not write long-term memory.
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'schedule_aggregator_agent',
    );
    final memoryReadOnlyPrompt =
        await memoryManagement.buildMemoryReadOnlyPrompt();

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
      systemPrompts: [scheduleAggregatorSystemPrompt, memoryReadOnlyPrompt],
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
      'ScheduleAggregatorAgent created, userId: $userId, sessionId: $sessionId',
    );
    return agent;
  }

  static Future<bool> updateScheduleAggregation({
    String? userId,
    String? runId,
    Duration resumeTtl = defaultScheduleAggregationResumeTtl,
  }) async {
    final effectiveUserId = userId ?? await UserStorage.getUserId();
    if (effectiveUserId == null) {
      throw Exception(
        'User not logged in, cannot refresh schedule aggregation',
      );
    }

    final now = DateTime.now();
    final effectiveRunId = normalizeScheduleAggregationRunId(runId, now);
    final sessionId = buildScheduleAggregatorSessionId(
      effectiveUserId,
      effectiveRunId,
    );

    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.scheduleAggregatorAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;
    final modelConfig = resources.modelConfig;

    var state = await loadOrCreateScheduleAggregatorRunState(
      userId: effectiveUserId,
      runId: effectiveRunId,
      sessionId: sessionId,
      now: now,
    );

    if (!state.isRunning && state.history.messages.isNotEmpty) {
      _logger.info(
        'ScheduleAggregatorAgent completed state residue, sessionId:$sessionId, delete state and restart',
      );
      await deleteAgentState(effectiveUserId, sessionId);
      state = await loadOrCreateScheduleAggregatorRunState(
        userId: effectiveUserId,
        runId: effectiveRunId,
        sessionId: sessionId,
        now: now,
      );
    } else if (state.isRunning &&
        !shouldResumeScheduleAggregatorRun(state, now, resumeTtl)) {
      _logger.info(
        'ScheduleAggregatorAgent stale interrupted run, sessionId:$sessionId, delete state and restart',
      );
      await deleteAgentState(effectiveUserId, sessionId);
      state = await loadOrCreateScheduleAggregatorRunState(
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
          "ScheduleAggregatorAgent resume, sessionId:${state.sessionId}",
        );
        result = await agent.resume();
      } else {
        _logger.info(
          "ScheduleAggregatorAgent run, sessionId:${state.sessionId}",
        );

        String inputMessage = "Please update schedule aggregation.";
        final runContext = await buildScheduleAggregationRunContext(
          userId: effectiveUserId,
          runId: effectiveRunId,
          now: now,
        );

        final messages = [
          UserMessage([
            TextPart(buildCurrentTimeReminder(now)),
            TextPart(runContext),
            TextPart(inputMessage),
          ]),
        ];
        _logger.info("ScheduleAggregatorAgent start");

        // Log agent execution event
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: effectiveUserId,
            eventType: 'agent_execution',
            description: 'Schedule Aggregator Agent started',
            metadata: {
              'agent_name': 'schedule_aggregator_agent',
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

      // Post-processing: emit UI refresh event for both fresh runs and resume.
      EventBusService.instance.emitEvent(
        ScheduleAggregationUpdatedMessage(aggregationId: sessionId),
      );
      await deleteAgentState(effectiveUserId, sessionId);
    } on AgentException catch (e) {
      if (e.code == AgentExceptionCode.loopDetection) {
        await deleteAgentState(effectiveUserId, sessionId);
        _logger.info(
          "ScheduleAggregatorAgent loop detection, sessionId:${state.sessionId}, delete state",
        );
      }
      rethrow;
    }

    _logger.info(
      "ScheduleAggregatorAgent done, sessionId:${state.sessionId}, result messages length:${result.length}",
    );
    return true;
  }
}
