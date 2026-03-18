import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/flutter_js_runtime.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

const pureSkillHostAgentSystemPrompt = '''
You are a personal assistant running on the user's mobile phone.
Always be concise, helpful, and friendly.
''';

/// A lightweight skill-host agent with a simple system prompt.
/// Supports file-based skills (SKILL.md + RunJavaScript) and file operations.
/// Does NOT include memory management or PKM overview tools.
class PureSkillHostAgent {
  static final Logger _logger = getLogger('PureSkillHostAgent');

  static Future<StatefulAgent> createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String name,
    required AgentState state,
    required String skillDirectoryPath,
    String? workingDirectory,
    AgentController? controller,
    bool disableSubAgents = true,
    String? additionalSystemPrompt,
  }) async {
    final fileService = FileSystemService.instance;

    controller = controller ?? AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    workingDirectory ??= fileService.getWorkspacePath(userId);

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

    final systemPrompts = <String>[pureSkillHostAgentSystemPrompt];
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
        'PureSkillHostAgent created, userId: $userId, sessionId: ${state.sessionId}');
    return agent;
  }
}
