import 'dart:convert';

import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/card_agent/prompts.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/state_util.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/agent_cache_helper.dart';
import 'package:memex/utils/user_storage.dart';

class CardRunCompletionEvidence {
  final String factId;
  final bool requireSaveToolCall;
  final bool hasMatchingSuccessfulSaveToolCall;
  final bool cardExists;
  final String? cardPath;
  final String? persistedFactId;
  final String? status;
  final bool hasTitle;
  final bool hasUiConfigs;
  final String? failureReason;

  const CardRunCompletionEvidence({
    required this.factId,
    required this.requireSaveToolCall,
    required this.hasMatchingSuccessfulSaveToolCall,
    required this.cardExists,
    this.cardPath,
    this.persistedFactId,
    this.status,
    required this.hasTitle,
    required this.hasUiConfigs,
    this.failureReason,
  });

  bool get isComplete {
    final saveToolSatisfied =
        !requireSaveToolCall || hasMatchingSuccessfulSaveToolCall;
    return saveToolSatisfied &&
        cardExists &&
        persistedFactId == factId &&
        status == 'completed' &&
        hasTitle &&
        hasUiConfigs;
  }

  List<String> get missingRequirements {
    final missing = <String>[];
    if (requireSaveToolCall && !hasMatchingSuccessfulSaveToolCall) {
      missing.add('matching_successful_save_timeline_card_tool_call');
    }
    if (!cardExists) missing.add('card_file_exists');
    if (persistedFactId != factId) missing.add('persisted_fact_id_matches');
    if (status != 'completed') missing.add('status_completed');
    if (!hasTitle) missing.add('title_present');
    if (!hasUiConfigs) missing.add('ui_configs_present');
    return missing;
  }

  Map<String, dynamic> toJson() {
    return {
      'fact_id': factId,
      'require_save_tool_call': requireSaveToolCall,
      'has_matching_successful_save_tool_call':
          hasMatchingSuccessfulSaveToolCall,
      'card_exists': cardExists,
      'card_path': cardPath,
      'persisted_fact_id': persistedFactId,
      'status': status,
      'has_title': hasTitle,
      'has_ui_configs': hasUiConfigs,
      'failure_reason': failureReason,
      'is_complete': isComplete,
      'missing_requirements': missingRequirements,
    };
  }
}

class CardAgent {
  static final Logger _logger = Logger('CardAgent');

  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
  }) async {
    final fileService = FileSystemService.instance;

    // Match backend task_id format: {user_id}_{fact_id_safe}
    final factIdSafe = fileService.makeFactIdSafe(factId);
    final sessionId = "card_${userId}_$factIdSafe";

    // Load or create agent state
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'factId': factId,
      'scene': 'input',
      'sceneId': factId,
    });

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'card_agent',
    );
    final memoryPrompt = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = memoryPrompt;

    final agent = StatefulAgent(
        name: 'card_agent',
        client: client,
        modelConfig: modelConfig,
        state: state,
        planMode: PlanMode.none,
        compressor: LLMBasedContextCompressor(
          client: client,
          modelConfig: modelConfig,
          totalTokenThreshold: 64000,
          keepRecentMessageSize: 10,
        ),
        tools: [],
        skills: [
          TimelineCardSkill(stopAfterSuccessSaveCard: true, forceActivate: true)
        ],
        systemPrompts: [cardAgentSystemPrompt],
        disableSubAgents: true,
        controller: controller,
        withGeneralPrinciples: true,
        autoSaveStateFunc: (state) async {
          await saveAgentState(state);
        },
        systemCallback: createSystemCallback(userId));

    _logger.info('CardAgent created, userId: $userId, sessionId: $sessionId');
    return agent;
  }

  /// Static method to run the agent with user message
  /// This method handles responseId caching and agent initialization internally
  static Future<CardRunCompletionEvidence> runWithContent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String instruction,
  }) async {
    // Ensure we have a valid cached responseId with matching hashCode
    final cachedResponseId = await AgentCacheHelper.ensureValidCachedResponseId(
        agentType: 'card',
        client: client,
        modelConfig: modelConfig,
        agentFactory: ({
          required LLMClient client,
          required ModelConfig modelConfig,
        }) async {
          return (await _createAgent(
            client: client,
            modelConfig: modelConfig,
            userId: "mocked_user_id",
            factId: "mocked_fact_id_${DateTime.now().millisecondsSinceEpoch}",
          ));
        });

    // Prepare modelConfig for actual run (with reasoning only, and previous_response_id if available)
    final extra = Map<String, dynamic>.from(modelConfig.extra ?? {});
    if (cachedResponseId != null) {
      extra['previous_response_id'] = cachedResponseId;
    }

    final finalModelConfig = ModelConfig(
      model: modelConfig.model,
      extra: extra,
      temperature: modelConfig.temperature,
      maxTokens: modelConfig.maxTokens,
      topP: modelConfig.topP,
      topK: modelConfig.topK,
      generationConfig: modelConfig.generationConfig,
    );

    // Create agent instance with updated modelConfig
    final agent = await _createAgent(
      client: client,
      modelConfig: finalModelConfig,
      userId: userId,
      factId: factId,
    );

    final timelineCardMetadata =
        await TimelineCardSkill.getTimelineCardMetadata(userId);

    final input = [
      UserMessage([
        TextPart('''<system-reminder>
${UserStorage.l10n.userLanguageInstruction}
Latest `get_card_metadata` tool executed result (Do not execute `get_card_metadata` again):
$timelineCardMetadata
</system-reminder>

$instruction
''')
      ])
    ];

    // Run the agent (with retry when save_timeline_card is not successfully called)
    final wasRunning = agent.state.isRunning;
    const maxRetries = 3;
    var runCount = 0;
    List<LLMMessage> messagesToRun = input;

    while (true) {
      runCount++;
      if (runCount == 1 && wasRunning) {
        _logger.info(
            "CardAgent resume (attempt $runCount/${maxRetries + 1}), sessionId:${agent.state.sessionId}");
        await agent.resume(useStream: false);
      } else {
        _logger.info(
            "CardAgent run (attempt $runCount/${maxRetries + 1}), sessionId:${agent.state.sessionId}");
        await agent.run(messagesToRun, useStream: false);
      }

      if (runCount == 1) {
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: userId,
            eventType: 'agent_execution',
            description: 'Card Agent started',
            metadata: {
              'agent_name': 'card_agent',
              'session_id': agent.state.sessionId,
              'fact_id': agent.state.metadata['factId'],
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }
      }

      if (runCount > maxRetries) break;

      final completionEvidence = await inspectCardRunCompletion(
        userId: userId,
        factId: factId,
        messages: agent.state.history.messages,
      );
      if (completionEvidence.isComplete) {
        _logger.info(
            'Card Agent completed for $factId: ${completionEvidence.toJson()}');
        return completionEvidence;
      }

      final reminderText =
          '- Call save_timeline_card to save the Timeline Card (this call is required to complete the task)\n'
          '- Current persisted card check failed: ${completionEvidence.missingRequirements.join(', ')}';
      messagesToRun = [
        UserMessage([
          TextPart(
              '<system-reminder>The following required step is still incomplete. You must complete it before finishing:\n$reminderText</system-reminder>'),
        ])
      ];
    }

    final completionEvidence = await inspectCardRunCompletion(
      userId: userId,
      factId: factId,
      messages: agent.state.history.messages,
    );
    if (completionEvidence.isComplete) {
      _logger.info(
          'Card Agent completed for $factId: ${completionEvidence.toJson()}');
      return completionEvidence;
    }
    throw StateError(
      'Card Agent did not produce a completed card for $factId. '
      'Evidence: ${jsonEncode(completionEvidence.toJson())}',
    );
  }

  /// Inspect both tool history and the persisted card file before considering
  /// the Card Agent task complete.
  static Future<CardRunCompletionEvidence> inspectCardRunCompletion({
    required String userId,
    required String factId,
    List<LLMMessage> messages = const [],
    bool requireSaveToolCall = true,
  }) async {
    final fileSystem = FileSystemService.instance;
    final card = await fileSystem.readCardFile(userId, factId);
    final cardPath = fileSystem.getCardPath(userId, factId);
    return CardRunCompletionEvidence(
      factId: factId,
      requireSaveToolCall: requireSaveToolCall,
      hasMatchingSuccessfulSaveToolCall:
          _hasMatchingSuccessfulSaveToolCall(messages, factId),
      cardExists: card != null,
      cardPath: cardPath,
      persistedFactId: card?.factId,
      status: card?.status,
      hasTitle: (card?.title?.trim().isNotEmpty ?? false),
      hasUiConfigs: card?.uiConfigs.isNotEmpty ?? false,
      failureReason: card?.failureReason,
    );
  }

  static bool _hasMatchingSuccessfulSaveToolCall(
    List<LLMMessage> messages,
    String factId,
  ) {
    for (final msg in messages) {
      if (msg is! FunctionExecutionResultMessage) continue;
      for (final r in msg.results) {
        if (r.isError || r.name != 'save_timeline_card') continue;
        try {
          final arguments = jsonDecode(r.arguments) as Map<String, dynamic>;
          if (arguments['fact_id'] == factId) return true;
        } catch (_) {
          // Ignore malformed historical arguments.
        }
      }
    }
    return false;
  }
}
