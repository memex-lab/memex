import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/memory/super_agent_context_compressor.dart';
import 'package:memex/agent/skills/manage_pkm/pkm_skill.dart';
import 'package:memex/agent/skills/manage_memory/memory_management_skill.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/dynamic_timeline_ui/dynamic_timeline_ui_skill.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/skills/knowledge_insight/knowledge_insight_skill.dart';
import 'package:memex/agent/skills/timeline_diagnostics/timeline_diagnostics_skill.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/super_agent/prompts.dart';
import 'package:memex/agent/super_agent/subagent/delegate_subagent_tool.dart';
import 'package:memex/agent/super_agent/super_agent_harness.dart';
import 'package:memex/agent/super_agent/super_agent_loop_detector.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

export 'package:memex/agent/super_agent/super_agent_pre_minted_record_hook.dart';

/// Read-only tool names available in Quick Query mode.
const _readOnlyToolNames = {
  'LS',
  'Glob',
  'Grep',
  'Read',
  'BatchRead',
  'view_image',
};

/// Skills excluded in Quick Query mode (those that create/modify data).
///
/// The `_readOnlyToolNames` whitelist only filters the base `allTools`; a
/// skill's own tools are injected when the model activates it and bypass that
/// whitelist. So EVERY skill that can write must be excluded here, or
/// read-only mode leaks a write path (e.g. activating `manage_pkm` exposes
/// `update_timeline_card_insight`). Read access stays available via base read
/// tools; use `LS` with `path: "/PKM"` to inspect PKM structure.
const _quickQueryExcludedSkills = {
  'manage_timeline_card',
  'dynamic_timeline_ui',
  'timeline_diagnostics',
  'manage_pkm',
  'update_schedule_aggregation',
  'update_knowledge_insight',
};

const _cloneSubAgentPromptLine =
    '- **clone**: A standard copy of yourself. Use this for general-purpose parallel tasks, reducing your context window usage, or when you need a fresh perspective on a specific sub-problem without the clutter of the current conversation history.';

class SuperAgent {
  static final Logger _logger = getLogger('SuperAgent');

  @visibleForTesting
  static const int rootMaxTurns = 80;

  @visibleForTesting
  static bool isQuickQueryToolAllowed(String toolName) {
    return _readOnlyToolNames.contains(toolName);
  }

  /// File-tool permission rules for the SuperAgent workspace.
  ///
  /// The whole workspace is writable (read-only in Quick Query), with one
  /// carve-out: generic file tools cannot write non-asset files under `Facts/`.
  /// `Facts/assets/` stays writable in normal mode because attached media files
  /// live there and may be referenced by `fs://...` ids.
  @visibleForTesting
  static List<PermissionRule> buildPermissionRules({
    required String workspacePath,
    required String factsPath,
    required String factsAssetsPath,
    required bool quickQuery,
  }) {
    return [
      PermissionRule(
          rootPath: workspacePath,
          access: quickQuery ? FileAccessType.read : FileAccessType.write),
      PermissionRule(rootPath: factsPath, access: FileAccessType.read),
      PermissionRule(
          rootPath: factsAssetsPath,
          access: quickQuery ? FileAccessType.read : FileAccessType.write),
    ];
  }

  /// Whether this agent operates in read-only Quick Query mode.
  static Future<StatefulAgent> createAgent(
      {required LLMClient client,
      required ModelConfig modelConfig,
      required String userId,
      required String name,
      required AgentState state,
      AgentController? controller,
      List<AgentHook> extraHooks = const [],
      List<String>? forceActiveSkills,
      bool quickQuery = false,
      String? additionalSystemPrompt,
      int compressionTokenThreshold = 64000}) async {
    final fileService = FileSystemService.instance;

    controller = controller ?? AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final workingDirectory = fileService.getWorkspacePath(userId);

    final permissionManager = FilePermissionManager(
      userId,
      buildPermissionRules(
        workspacePath: fileService.getWorkspacePath(userId),
        factsPath: fileService.getFactsPath(userId),
        factsAssetsPath: fileService.getAssetsPath(userId),
        quickQuery: quickQuery,
      ),
    );

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
      fileToolFactory.buildViewImageTool(),
      fileToolFactory.buildWriteTool(),
      fileToolFactory.buildMoveTool(),
      fileToolFactory.buildRemoveTool(),
      fileToolFactory.buildEditTool(),
      // Mint a fact_id without activating any skill, so capture is a clean
      // "mint, then delegate" flow. Writes a placeholder card, so it is NOT in
      // _readOnlyToolNames and the Quick Query filter below drops it.
      mintRecordFactIdTool,
      // Generic sub-agent delegation: spawn ONE child worker per call, shaped
      // by a fixed agent_type preset. The model runs several in parallel by
      // emitting multiple calls in one turn. Not in
      // _readOnlyToolNames, so the Quick Query whitelist filter below drops it.
      buildDelegateToSubagentTool(),
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

    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    // Memory WRITE capability is exposed as an on-demand skill (manage_memory)
    // instead of always-on tools + system prompt, so the agent only writes
    // long-term profile memory when the user explicitly asks. READ access is
    // unconditional via the user_memory reminder above. Quick Query stays
    // read-only: a read-only note in the system prompt, and no write skill.
    final readOnlyMemoryPrompt =
        quickQuery ? await memoryManagement.buildMemoryReadOnlyPrompt() : null;
    final memorySkill = quickQuery
        ? null
        : MemoryManagementSkill(
            systemPrompt:
                await memoryManagement.buildSuperAgentMemoryManagementPrompt(),
            tools: memoryManagement.buildMemoryManagementTools(),
          );

    var skills = [
      KnowledgeInsightSkill(),
      TimelineCardSkill(),
      DynamicTimelineUiSkill(),
      TimelineDiagnosticsSkill(),
      PkmSkill(workingDirectory: '/PKM'),
      ScheduleAggregationSkill(),
    ];
    if (quickQuery) {
      skills = skills
          .where((s) => !_quickQueryExcludedSkills.contains(s.name))
          .toList();
    }
    if (memorySkill != null) {
      skills.add(memorySkill);
    }
    if (forceActiveSkills != null) {
      for (var skill in skills) {
        if (forceActiveSkills.contains(skill.name)) {
          skill.forceActivate = true;
        }
      }
    }
    final prunedActiveSkills = pruneUnavailableActiveSkills(
      state,
      skills.map((skill) => skill.name).toSet(),
    );
    if (prunedActiveSkills) {
      await saveAgentState(state);
    }

    final systemPrompts = [superAgentSystemPrompt];
    if (readOnlyMemoryPrompt != null) {
      systemPrompts.add(readOnlyMemoryPrompt);
    }
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
        // Claude Code-style fixed-quota compaction. Quota defaults to the core
        // default (64k); `compressionTokenThreshold` lets evals lower it to
        // deterministically exercise compression without a giant session.
        compressor: SuperAgentContextCompressor(
          client: client,
          modelConfig: modelConfig,
          totalTokenThreshold: compressionTokenThreshold,
          keepRecentMessageSize: 10,
        ),
        tools: tools,
        skills: skills,
        systemPrompts: systemPrompts,
        disableSubAgents: true,
        controller: controller,
        loopDetector: SuperAgentLoopDetector(),
        maxTurns: rootMaxTurns,
        withGeneralPrinciples: true,
        planMode: PlanMode.none,
        autoSaveStateFunc: (state) async {
          await saveAgentState(state);
        },
        hooks: [
          createAgentPromptHook(userId),
          _SuperAgentPromptHook(),
          ...extraHooks,
          SuperAgentHarness.buildParentHook(userId),
        ]);

    _logger.info(
        'SuperAgent created, userId: $userId, sessionId: ${state.sessionId}');
    return agent;
  }

  @visibleForTesting
  static bool pruneUnavailableActiveSkills(
    AgentState state,
    Set<String> availableSkillNames,
  ) {
    final activeSkills = state.activeSkills;
    if (activeSkills == null || activeSkills.isEmpty) return false;

    final retained = activeSkills
        .where((skillName) => availableSkillNames.contains(skillName))
        .toList();
    if (retained.length == activeSkills.length) return false;

    final removed = activeSkills
        .where((skillName) => !availableSkillNames.contains(skillName))
        .toList();
    state.activeSkills = retained;
    _logger.warning(
      'Pruned unavailable active skill(s) from SuperAgent state '
      '${state.sessionId}: $removed',
    );
    return true;
  }
}

class _SuperAgentPromptHook extends AgentHook {
  @override
  ModelCallHookResult beforeModelCall(ModelCallHookContext context) {
    try {
      var nextSystemMessage = context.request.systemMessage;

      if (nextSystemMessage != null && nextSystemMessage.content.isNotEmpty) {
        final systemLines = nextSystemMessage.content.split('\n');
        final sanitizedLines = <String>[];
        for (final line in systemLines) {
          if (line.trim() == _cloneSubAgentPromptLine) continue;
          sanitizedLines.add(line);
        }
        final sanitizedContent = sanitizedLines.join('\n').trimRight();
        if (sanitizedContent != nextSystemMessage.content) {
          nextSystemMessage = SystemMessage(sanitizedContent);
        }
      }

      return ModelCallHookResult.proceed(
        request: context.request.copyWith(
          systemMessage: nextSystemMessage,
          clearSystemMessage: nextSystemMessage == null,
        ),
      );
    } catch (e, st) {
      SuperAgent._logger.warning(
        '[${context.agent.name}] super agent prompt hook failed; using original model request.',
        e,
        st,
      );
      return ModelCallHookResult.proceed(request: context.request);
    }
  }
}
