import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/built_in_tools/search_event_logs_tool.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/skills/manage_pkm/pkm_skill.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/agent/skills/knowledge_insight/knowledge_insight_skill.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/super_agent/prompts.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// Read-only tool names available in Quick Query mode.
const _readOnlyToolNames = {
  'LS', 'Glob', 'Grep', 'Read', 'BatchRead',
  'search_event_logs', 'getCurrentTime', 'get_pkm_overview',
};

/// Skills excluded in Quick Query mode (those that create/modify data).
const _quickQueryExcludedSkills = {
  'manage_timeline_card',
};

class SuperAgent {
  static final Logger _logger = getLogger('SuperAgent');

  /// Whether this agent operates in read-only Quick Query mode.
  static Future<StatefulAgent> createAgent(
      {required LLMClient client,
      required ModelConfig modelConfig,
      required String userId,
      required String name,
      required AgentState state,
      AgentController? controller,
      List<String>? forceActiveSkills,
      bool disableSubAgents = false,
      bool quickQuery = false,
      String? additionalSystemPrompt}) async {
    final fileService = FileSystemService.instance;

    controller = controller ?? AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final workingDirectory = fileService.getWorkspacePath(userId);

    // SuperAgent has full access to the workspace (read-only in Quick Query)
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(
          rootPath: fileService.getWorkspacePath(userId),
          access: quickQuery ? FileAccessType.read : FileAccessType.write),
    ]);

    final fileToolFactory = FileToolFactory(
      permissionManager: permissionManager,
      workingDirectory: workingDirectory,
    );

    final allTools = [
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
      getPkmOverviewTool
    ];

    // Filter tools in Quick Query mode — only keep read-only tools
    final tools = quickQuery
        ? allTools.where((t) => _readOnlyToolNames.contains(t.name)).toList()
        : allTools;

    // Memory Management (skip write tools in Quick Query mode)
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: name,
    );
    final memoryManagementPrompt =
        await memoryManagement.buildMemoryManagementPrompt();
    if (!quickQuery) {
      final memoryManagementTools = memoryManagement.buildMemoryManagementTools();
      tools.addAll(memoryManagementTools);
    }

    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    var skills = [
      KnowledgeInsightSkill(),
      TimelineCardSkill(),
      PkmSkill(workingDirectory: '/PKM'),
      SystemActionSkill(),
    ];
    if (quickQuery) {
      skills = skills
          .where((s) => !_quickQueryExcludedSkills.contains(s.name))
          .toList();
    }
    if (forceActiveSkills != null) {
      for (var skill in skills) {
        if (forceActiveSkills.contains(skill.name)) {
          skill.forceActivate = true;
        }
      }
    }

    final systemPrompts = [superAgentSystemPrompt, memoryManagementPrompt];
    if (quickQuery) {
      systemPrompts.add(
        '## Quick Query Mode\n'
        'You are in **Quick Query** (read-only) mode. You can ONLY read and search existing data.\n'
        'You MUST NOT create, modify, or delete any records, cards, knowledge entries, or files.\n'
        'If the user asks you to create or change something, explain that this is a read-only mode '
        'and suggest they use the full Chat mode instead.',
      );
    }
    if (additionalSystemPrompt != null) {
      systemPrompts.add(additionalSystemPrompt);
    }

    final agent = StatefulAgent(
        name: name,
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
        systemPrompts: systemPrompts,
        disableSubAgents: true,
        controller: controller,
        withGeneralPrinciples: true,
        planMode: PlanMode.auto,
        autoSaveStateFunc: (state) async {
          await saveAgentState(state);
        },
        systemCallback: createSystemCallback(userId));

    _logger.info(
        'SuperAgent created, userId: $userId, sessionId: ${state.sessionId}');
    return agent;
  }
}
