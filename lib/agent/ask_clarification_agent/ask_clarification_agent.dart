import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/ask_clarification_agent/prompt.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/skills/ask_clarification/ask_clarification_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/clarification_request_service.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('AskClarificationAgent');

/// Independent agent that decides whether the current raw input is worth a
/// clarification question. Runs in parallel with PkmAgent.
class AskClarificationAgent {
  static Future<void> run({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String combinedText,
  }) async {
    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final sessionId = 'ask_clarification_${userId}_${_safeSessionPart(factId)}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'factId': factId,
      'scene': 'ask_clarification',
      'sceneId': factId,
      'agentName': 'ask_clarification_agent',
    });

    // Memory is read-only; clarification agent never writes long-term memory
    // itself. ClarificationResolutionAgent handles that after the user answers.
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'ask_clarification_agent',
    );
    final existingMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders['user_memory'] = existingMemory;

    final agent = StatefulAgent(
      name: 'ask_clarification_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      compressor: LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 12000,
        keepRecentMessageSize: 4,
      ),
      tools: const [],
      skills: [AskClarificationSkill(forceActivate: true)],
      systemPrompts: [askClarificationAgentSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    final recentRequests =
        await ClarificationRequestService.instance.getRecentRequests(limit: 30);
    final recentSummary = recentRequests.isEmpty
        ? 'No recent clarification requests.'
        : recentRequests
            .map(
              (r) => '- ID: ${r.id} | Status: ${r.status} | Entity: '
                  '${r.entityLabel ?? '-'} | Dedupe: ${r.dedupeKey ?? '-'} | '
                  'Question: ${r.question}',
            )
            .join('\n');

    final messages = [
      UserMessage([
        TextPart(
          'Decide whether this new raw input warrants exactly one '
          'high-impact clarification question. If it does, call '
          '`create_clarification_request` once. Otherwise, stop without '
          'creating anything.\n\n'
          'Raw Input ID (fact_id): $factId\n\n'
          'Raw Input Content:\n$combinedText\n\n'
          '<recent_clarification_requests>\n$recentSummary\n'
          '</recent_clarification_requests>',
        ),
      ]),
    ];

    try {
      await agent.run(messages, useStream: false);
      _logger.info(
        'AskClarificationAgent run completed, sessionId:$sessionId',
      );
    } on AgentException catch (e) {
      _logger.warning(
        'AskClarificationAgent finished with agent exception (${e.code}) for '
        'fact_id=$factId, sessionId=$sessionId',
        e,
      );
      rethrow;
    } finally {
      try {
        await deleteAgentState(userId, sessionId);
      } catch (_) {
        // best effort cleanup
      }
    }
  }
}

String _safeSessionPart(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
}
