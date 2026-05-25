import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:intl/intl.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/system_action_agent/prompt.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('SystemActionAgent');

/// Lightweight stateful agent that decides whether the user's raw input
/// expresses a calendar event or a reminder, and creates the corresponding
/// system action on the device. Runs independently of PkmAgent.
class SystemActionAgent {
  static Future<void> run({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String combinedText,
    DateTime? now,
  }) async {
    final effectiveNow = now ?? DateTime.now();

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final sessionId = 'system_action_${userId}_${_safeSessionPart(factId)}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'factId': factId,
      'scene': 'system_action',
      'sceneId': factId,
      'agentName': 'system_action_agent',
    });

    final agent = StatefulAgent(
      name: 'system_action_agent',
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
      skills: [SystemActionSkill(forceActivate: true)],
      systemPrompts: [systemActionAgentSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    final formattedNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(effectiveNow);
    final messages = [
      UserMessage([
        TextPart(
          '<system-reminder>Current User Time: $formattedNow.</system-reminder>',
        ),
        TextPart(
          'Decide whether this raw input contains a calendar event or '
          'reminder intent. If it does, create the matching action(s); '
          'otherwise stop without writing anything.\n\n'
          'Raw Input ID (fact_id): $factId\n\n'
          'Raw Input Content:\n$combinedText',
        ),
      ]),
    ];

    try {
      await agent.run(messages, useStream: false);
      _logger.info('SystemActionAgent run completed, sessionId:$sessionId');
    } on AgentException catch (e) {
      _logger.warning(
        'SystemActionAgent finished with agent exception (${e.code}) for '
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
