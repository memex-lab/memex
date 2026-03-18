import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/flutter_js_runtime.dart';
import 'package:memex/agent/memex_skill_host_agent/prompts.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/state_util.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// A full-featured skill-host agent that reuses the SuperAgent system prompt.
/// Supports file-based skills (SKILL.md + RunJavaScript) and file operations.
/// Does NOT include memory management or PKM overview tools.
class MemexSkillHostAgent {
  static final Logger _logger = getLogger('MemexSkillHostAgent');

  static Future<StatefulAgent> createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String name,
    required AgentState state,
    required String skillDirectoryPath,
    required String workingDirectory,
    AgentController? controller,
    bool disableSubAgents = true,
    String? additionalSystemPrompt,
  }) async {
    controller = controller ?? AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(rootPath: workingDirectory, access: FileAccessType.write),
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
      fileToolFactory.buildWriteTool(),
      fileToolFactory.buildMoveTool(),
      fileToolFactory.buildRemoveTool(),
      fileToolFactory.buildEditTool(),
      buildSearchEventLogsTool(),
      getCurrentTimeTool,
    ];

    final systemPrompts = <String>[memexSkillHostAgentSystemPrompt];
    if (additionalSystemPrompt != null) {
      systemPrompts.add(additionalSystemPrompt);
    }

    final agent = StatefulAgent(
      name: name,
      client: client,
      modelConfig: modelConfig,
      state: state,
      tools: tools,
      skillDirectoryPath: skillDirectoryPath,
      javaScriptRuntime: FlutterJavaScriptRuntime(),
      skills: null,
      systemPrompts: systemPrompts,
      disableSubAgents: disableSubAgents,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.auto,
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
      systemCallback:
          createSystemCallbackWithWorkingDirectory(userId, workingDirectory),
    );

    _logger.info(
        'MemexSkillHostAgent created, userId: $userId, sessionId: ${state.sessionId}');
    return agent;
  }
}
