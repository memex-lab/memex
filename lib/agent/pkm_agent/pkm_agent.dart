import 'dart:convert';
import 'dart:io';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/utils/user_storage.dart';

import 'package:path/path.dart' as p;

import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/pkm_agent/prompts.dart';
import 'package:memex/agent/pkm_agent/pkm_stats_service.dart';
import 'package:memex/agent/state_util.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/skills/manage_pkm/pkm_skill.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/agent/skills/ask_clarification/ask_clarification_skill.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/agent/agent_cache_helper.dart';

class PkmAgent {
  static final Logger _logger = getLogger('PkmAgent');

  static const Set<String> validSkipReasons = {
    'explicit_user_opt_out',
    'temporary_state',
    'low_signal_noise',
    'duplicate_existing_memory',
  };

  /// Detects raw inputs where the user explicitly opts out of persistent PKM
  /// organization before we invoke the LLM agent.
  static PkmSkipDecision detectNonPersistentInput(String rawInput) {
    final text = rawInput.trim();
    if (text.isEmpty) return const PkmSkipDecision.persist();

    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('長', '长')
        .replaceAll('記', '记')
        .replaceAll('憶', '忆');

    final explicitOptOutPatterns = [
      RegExp(
        r'(不要|别|不用|无需|不必).{0,8}(写成|写进|写入|存入|保存|沉淀|长期|长久|持久|记住|记忆|记录).{0,12}(长期记忆|长记忆|记忆|pkm|知识库|长期|memory)',
      ),
      RegExp(r'(不要|别|不用|无需|不必)(记住|记下来|记录下来|记录|保存|沉淀)'),
      RegExp(r'(不要记|别记|不用记|无需记|不必记)(这个|这条|这件事|本条|本次)?($|[，。！？,.!;；])'),
      RegExp(r'(别|不要)写进(长期)?记忆'),
      RegExp(r'(不要|别|不用|无需|不必).{0,8}(长期保存|长期沉淀|写长期记忆|写成长记忆)'),
      RegExp(
        r"(do\s*not|don't|dont|never).{0,30}(save|store|persist|remember|write).{0,30}(memory|pkm|knowledge|long[-\s]?term)",
      ),
    ];

    final hasExplicitOptOut = explicitOptOutPatterns.any(
      (pattern) => pattern.hasMatch(normalized),
    );
    if (hasExplicitOptOut) {
      return PkmSkipDecision.skip(
        reason: 'explicit_user_opt_out',
        temporalScope:
            _looksTemporary(normalized) ? 'temporary' : 'unspecified',
        evidence: _shortEvidence(text),
      );
    }

    final isTemporaryOnly = _looksTemporary(normalized) &&
        RegExp(r'(状态|心情|碎事|临时事|试一下|测试|temporary|test)').hasMatch(normalized);
    final hasPersistenceBoundary = RegExp(
      r'(不要|别|不用|无需|不必).{0,8}(影响|改动|修改|覆盖|更新).{0,18}(项目|规则|安排|提醒|偏好|知识|记忆)',
    ).hasMatch(normalized);
    if (isTemporaryOnly && hasPersistenceBoundary) {
      return PkmSkipDecision.skip(
        reason: 'temporary_state',
        temporalScope: 'temporary',
        evidence: _shortEvidence(text),
      );
    }

    return const PkmSkipDecision.persist();
  }

  static bool _looksTemporary(String normalized) {
    return RegExp(
      r'(只是|仅仅|就是|临时|暂时|今天状态|当下状态|试一下|测试|temporary|transient|justtesting)',
    ).hasMatch(normalized);
  }

  static String _shortEvidence(String text) {
    const maxLength = 120;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Future<StatefulAgent> createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
  }) async {
    final fileService = FileSystemService.instance;

    // Match backend task_id format: {user_id}_{fact_id_safe}
    final factIdSafe = fileService.makeFactIdSafe(factId);
    final sessionId = "pkm_${userId}_$factIdSafe";

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

    final stopAfterUpdateCardInsightRef = [true];
    final skills = [
      PkmSkill(
        forceActivate: true,
        stopAfterUpdateCardInsightRef: stopAfterUpdateCardInsightRef,
        workingDirectory: '/',
      ),
      SystemActionSkill(forceActivate: true),
      AskClarificationSkill(),
    ];

    final pkmPath = '${fileService.getWorkspacePath(userId)}/PKM';
    final pkmDir = Directory(pkmPath);
    if (!pkmDir.existsSync()) {
      pkmDir.createSync(recursive: true);
    }

    // Get working directory (Workspace Root)
    final workingDirectory = fileService.getPkmPath(userId);

    // Configure File Permission Manager
    // PkmAgent has access to:
    // - Write: /PKM (Primary workspace)
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(
          rootPath: fileService.getPkmPath(userId),
          access: FileAccessType.write),
    ]);

    final fileToolFactory = FileToolFactory(
      permissionManager: permissionManager,
      workingDirectory: workingDirectory,
    );

    final plainReadTool = fileToolFactory.buildReadTool();
    final readTool = Tool(
      name: plainReadTool.name,
      description: plainReadTool.description,
      parameters: plainReadTool.parameters,
      executable: (String filePath, int? offset, int? limit) async {
        // Resolve path only for permission check (needs absolute path)
        // FileOperationService methods will handle path resolution internally
        String resolvedPath;
        if (filePath.startsWith(workingDirectory)) {
          resolvedPath = filePath;
        } else if (filePath.startsWith('/')) {
          resolvedPath = filePath == '/'
              ? workingDirectory
              : p.join(workingDirectory, filePath.substring(1));
        } else {
          resolvedPath = p.join(workingDirectory, filePath);
        }

        // Check permission (requires absolute path)
        permissionManager.checkPermission(resolvedPath, FileAccessType.read);

        // Pass original filePath to readFile - it will resolve internally
        final result = await FileOperationService.instance.readFile(
          filePath: filePath,
          workingDirectory: workingDirectory,
          offset: offset ?? 1,
          limit: limit,
        );

        final reminders = <String>[];

        // 1. Line count check
        final lineCount = '\n'.allMatches(result).length + 1;
        if (lineCount >= 2000) {
          reminders.add(
              '<system-reminder>The file "$filePath" contains $lineCount lines, which exceeds the 2000-line limit. Please adjust this file to ensure it complies with the P.A.R.A. structure requirement after the input is processed.</system-reminder>');
        } else if (lineCount > 1000) {
          reminders.add(
              '<system-reminder>The file "$filePath" contains $lineCount lines. Please consider whether the P.A.R.A. structure is reasonable after the input is processed.</system-reminder>');
        }

        // 2. Directory fragmentation check
        try {
          // Use filePath's parent directory - grepFiles will resolve internally
          final parentDirDisplay = p.dirname(filePath);

          // Use grepFiles with r: false to get fact_id counts in current directory only
          // Pass parentDirDisplay (model's perspective path) - grepFiles will resolve internally
          final grepResult = await FileOperationService.instance.grepFiles(
            pattern: 'fact_id',
            searchPath: parentDirDisplay,
            workingDirectory: workingDirectory,
            outputMode: 'count',
            r: false, // Non-recursive: only search current directory
          );

          final matchCounts = <String, int>{};
          if (!grepResult.startsWith('No matches found')) {
            final lines = grepResult.split('\n');
            for (final line in lines) {
              // Filter truncated message if exists
              if (line.startsWith('(Output limited')) continue;

              final lastColon = line.lastIndexOf(':');
              if (lastColon != -1) {
                final fPath = line.substring(0, lastColon).trim();
                final countStr = line.substring(lastColon + 1).trim();
                try {
                  matchCounts[fPath] = int.parse(countStr);
                } catch (e) {
                  // ignore parse error
                }
              }
            }
          }

          // Count files with 2 or fewer fact_id references
          int fragmentedFilesCount = 0;
          final fragmentedFileInfos = <String>[];

          for (final entry in matchCounts.entries) {
            final count = entry.value;
            if (count <= 1) {
              fragmentedFilesCount++;
              fragmentedFileInfos.add('${p.basename(entry.key)} ($count)');
            }
          }

          if (fragmentedFilesCount > 5) {
            reminders.add(
                '<system-reminder>The directory "$parentDirDisplay" contains $fragmentedFilesCount files with only one fact_id reference each: ${fragmentedFileInfos.join(", ")}. Please consider adjusting the file structure to avoid excessive fragmentation after the input is processed.</system-reminder>');
          }
        } catch (e) {
          // Ignore directory errors (e.g., parent dir doesn't exist or access denied)
          // FileOperationService will handle path validation
        }

        // 3. Filename date check
        final filename = p.basename(filePath);
        // Strict date check: 20XX year, 01-12 month, 01-31 day
        if (RegExp(r'20\d{2}-?(?:0[1-9]|1[0-2])-?(?:0[1-9]|[12]\d|3[01])')
            .hasMatch(filename)) {
          reminders.add(
              '<system-reminder>The file "$filename" contains a date in its filename. Please determine if this filename is reasonable after the input is processed.</system-reminder>');
        }

        // 4. Frequent edit check
        try {
          final editCount = await PkmStatsService.instance
              .getRecentEditCount(userId, filePath);
          if (editCount >= 3) {
            final bool hasDatePattern = RegExp(r'(20\d{2})').hasMatch(filename);
            if (hasDatePattern) {
              reminders.add(
                  '<system-reminder>The file "${p.basename(filePath)}" has been modified in $editCount of the last 5 inputs and contains a date in its name. This frequent activity suggests it is being used as a time-based log (e.g., "YYYY_MM_Life"). Please consider renaming it to a topic-based name or splitting it to improve organization after the input is processed.</system-reminder>');
            } else {
              reminders.add(
                  '<system-reminder>The file "${p.basename(filePath)}" has been modified in $editCount of the last 5 inputs. This frequent activity suggests the filename is too generic (e.g., "Image Record", "Notes"). Please consider renaming it to be more specific or splitting it to improve organization after the input is processed.</system-reminder>');
            }
          }
        } catch (e) {
          // Ignore stats service errors
        }

        if (reminders.isNotEmpty) {
          stopAfterUpdateCardInsightRef[0] = false;
          return '$result\n\n${reminders.join('\n')}';
        }
        return result;
      },
    );

    final tools = [
      readTool,
      fileToolFactory.buildBatchReadTool(),
      fileToolFactory.buildWriteTool(),
      fileToolFactory.buildEditTool(),
      fileToolFactory.buildMoveTool(),
      fileToolFactory.buildRemoveTool(),
      fileToolFactory.buildLSTool(),
      fileToolFactory.buildGlobTool(),
      fileToolFactory.buildGrepTool(),
      // getPkmOverviewTool
    ];

    // Memory Management (Read-Only)
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'pkm_agent',
    );
    // REMOVED: buildMemoryManagementPrompt() - PkmAgent should not have the complex memory instructions
    // REMOVED: buildMemoryManagementTools() - PkmAgent cannot write to memory
    // tools.addAll(memoryManagementTools);

    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    final agent = StatefulAgent(
        name: 'pkm_agent',
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
        systemPrompts: [pkmAgentSystemPrompt],
        disableSubAgents: true,
        controller: controller,
        withGeneralPrinciples: true,
        planMode: PlanMode.none,
        autoSaveStateFunc: (state) async {
          await saveAgentState(state);
        },
        systemCallback: createSystemCallback(userId));

    _logger.info('PkmAgent created, userId: $userId, sessionId: $sessionId');
    return agent;
  }

  /// Static method to run the agent with user message
  /// This method handles responseId caching and agent initialization internally
  static Future<PkmRunCompletionEvidence> runWithContent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String instruction,
  }) async {
    // Ensure we have a valid cached responseId with matching hashCode
    final cachedResponseId = await AgentCacheHelper.ensureValidCachedResponseId(
      agentType: 'pkm',
      client: client,
      modelConfig: modelConfig,
      agentFactory: ({
        required LLMClient client,
        required ModelConfig modelConfig,
      }) =>
          createAgent(
        client: client,
        modelConfig: modelConfig,
        userId: "mocked_user_id",
        factId: "mocked_fact_id_${DateTime.now().millisecondsSinceEpoch}",
      ),
    );

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

    final agent = await createAgent(
      client: client,
      modelConfig: finalModelConfig,
      userId: userId,
      factId: factId,
    );

    final pkmOverview = await _getPkmOverview(userId);

    final input = [
      UserMessage([
        TextPart('''$pkmOverview
<system-reminder>
${UserStorage.l10n.userLanguageInstruction}
</system-reminder>.

$instruction
'''),
      ])
    ];

    // Run the agent (with retry when P.A.R.A write or insight update is missing)
    final wasRunning = agent.state.isRunning;
    const maxRetries = 3;
    var runCount = 0;
    List<LLMMessage> messagesToRun = input;

    while (true) {
      runCount++;
      final shouldResume = runCount == 1 && wasRunning;
      if (shouldResume) {
        _logger.info(
            "PkmAgent resume (attempt $runCount/${maxRetries + 1}), sessionId:${agent.state.sessionId}");
      } else {
        _logger.info(
            "PkmAgent run (attempt $runCount/${maxRetries + 1}), sessionId:${agent.state.sessionId}");
      }

      try {
        if (shouldResume) {
          await agent.resume(useStream: false);
        } else {
          await agent.run(messagesToRun, useStream: false);
        }
      } on AgentException catch (e) {
        if (e.code == AgentExceptionCode.loopDetection) {
          final factId = agent.state.metadata['factId'] as String?;
          if (factId != null) {
            final check = inspectPkmRunCompletion(
              messages: agent.state.history.messages,
              factId: factId,
            );
            if (check.isComplete) {
              _logger.info(
                'PKM agent hit loop detection after valid completion evidence for $factId: ${check.toJson()}',
              );
              break;
            }
          }
        }
        rethrow;
      }

      if (runCount == 1) {
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: userId,
            eventType: 'agent_execution',
            description: 'PKM Agent started',
            metadata: {
              'agent_name': 'pkm_agent',
              'session_id': agent.state.sessionId,
              'fact_id': agent.state.metadata['factId'],
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }
      }

      if (runCount > maxRetries) break;

      final factId = agent.state.metadata['factId'] as String?;
      if (factId == null) break;

      final check = inspectPkmRunCompletion(
        messages: agent.state.history.messages,
        factId: factId,
      );
      if (check.isComplete) break;

      final reminderParts = <String>[];
      if (!check.wrotePara) {
        reminderParts.add(
            'Write to P.A.R.A.: use the Write or Edit tool to organize the current raw input under / and record the current fact_id in the file (e.g. as a comment: <!-- fact_id: ... -->)');
      }
      if (!check.updatedInsight) {
        reminderParts.add(
            'Update the Timeline Card insight: use the update_timeline_card_insight tool to complete the New Raw Input Organization Task (this call is required to mark the workflow as complete)');
      }
      final reminderText = reminderParts.map((s) => '- $s').join('\n');
      messagesToRun = [
        UserMessage([
          TextPart(
            '<system-reminder>The PKM task is incomplete. Complete one valid path before finishing:\n'
            '1. Persistent organization path: complete all missing steps below.\n'
            '$reminderText\n'
            '2. Non-persistent skip path: if the user explicitly asked not to save, persist, write long-term memory, or modify existing knowledge, call skip_pkm_organization with the reason and evidence instead of writing P.A.R.A. files.\n'
            '3. Clarification path: if missing or conflicting details block a safe PKM update, create one deduped clarification request and then stop.</system-reminder>',
          ),
        ])
      ];
    }

    // Record edits for this session
    try {
      final editedFiles = <String>{};
      for (final msg in agent.state.history.messages) {
        if (msg is! FunctionExecutionResultMessage) continue;
        for (final r in msg.results) {
          if (r.isError) continue;
          if (r.name == 'Write' || r.name == 'Edit') {
            // arguments is a Map<String, dynamic> usually, or JSON string.
            // The tool definition says parameters are maps.
            // But DartAgentCore ToolResult.arguments is Map<String, dynamic>.
            // Let's verify how arguments are stored.
            // ToolResult arguments are Map<String, dynamic>.
            // The tools (Write, Edit) have 'target_file' or similar as first arg.
            // Wait, standard file tools usually use 'file_path' or 'path'.
            // Let's check FileToolFactory definitions or just infer from usage.
            // 'Write' tool usually has 'file_path' or 'target_file'.
            // 'Edit' tool usually has 'file_path' or 'target_file'.
            // Let's check the file_tools.dart if possible, or assume 'file_path' based on Read tool usage.

            // In FileTools:
            // Write: 'file_path'
            // Edit: 'file_path'

            try {
              final args = jsonDecode(r.arguments) as Map<String, dynamic>;
              if (args.containsKey('file_path')) {
                editedFiles.add(args['file_path'] as String);
              }
            } catch (e) {
              // Ignore JSON parse errors or invalid format
            }
          }
        }
      }
      await PkmStatsService.instance
          .recordSessionEdits(userId, editedFiles.toList());
    } catch (e) {
      _logger.warning('Failed to record session edits: $e');
    }

    return inspectPkmRunCompletion(
      messages: agent.state.history.messages,
      factId: factId,
    );
  }

  /// Returns whether history contains successful write/edit (with fact_id) and
  /// successful update_timeline_card_insight, or a successful explicit skip.
  static PkmRunCompletionEvidence inspectPkmRunCompletion({
    required List<LLMMessage> messages,
    required String factId,
  }) {
    bool wrotePara = false;
    bool updatedInsight = false;
    bool skippedPkm = false;
    bool clarificationRequested = false;
    bool successfulPkmMutation = false;
    String? skipReason;
    String? skipTemporalScope;
    String? skipEvidence;
    String? clarificationDedupeKey;

    for (final msg in messages) {
      if (msg is! FunctionExecutionResultMessage) continue;
      for (final r in msg.results) {
        if (r.isError) continue;
        if (r.name == 'Write' ||
            r.name == 'Edit' ||
            r.name == 'Move' ||
            r.name == 'Remove') {
          successfulPkmMutation = true;
        }
        if ((r.name == 'Write' || r.name == 'Edit') &&
            r.arguments.contains(factId)) {
          wrotePara = true;
        }
        if (r.name == 'update_timeline_card_insight') {
          updatedInsight = true;
        }
        if (r.name == 'skip_pkm_organization') {
          skippedPkm = true;
          final args = _decodeToolArguments(r.arguments);
          skipReason = args['reason'] as String?;
          skipTemporalScope = args['temporal_scope'] as String?;
          skipEvidence = args['evidence'] as String?;
        }
        if (r.name == 'create_clarification_request') {
          clarificationRequested = true;
          final args = _decodeToolArguments(r.arguments);
          clarificationDedupeKey = args['dedupe_key'] as String?;
        }
      }
    }

    return PkmRunCompletionEvidence(
      wrotePara: wrotePara,
      updatedInsight: updatedInsight,
      skippedPkm: skippedPkm,
      clarificationRequested: clarificationRequested,
      successfulPkmMutation: successfulPkmMutation,
      skipReason: skipReason,
      skipTemporalScope: skipTemporalScope,
      skipEvidence: skipEvidence,
      clarificationDedupeKey: clarificationDedupeKey,
    );
  }

  static Map<String, dynamic> _decodeToolArguments(String arguments) {
    try {
      final decoded = jsonDecode(arguments);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Some older tool histories may not store JSON arguments.
    }
    return const {};
  }

  static Future<String> _getPkmOverview(String userId) async {
    final fileService = FileSystemService.instance;
    final fileOpService = FileOperationService.instance;

    final workingDirectory = fileService.getPkmPath(userId);
    final pkmPath = fileService.getPkmPath(userId);
    final pkmDir = Directory(pkmPath);

    String pkmStructure = '';
    try {
      if (pkmDir.existsSync()) {
        pkmStructure = await fileOpService.listDirectory(
          dirPath: pkmPath,
          workingDirectory: workingDirectory,
        );
      } else {
        pkmStructure =
            '<system-reminder>${Prompts.pkmAgentDirectoryNotCreated}</system-reminder>';
      }
    } catch (e) {
      _logger.warning('Failed to get PKM structure: $e');
      pkmStructure =
          '<system-reminder>${Prompts.pkmAgentDirectoryStructureError(e.toString())}</system-reminder>';
    }

    final header = pkmStructure.contains('passing a specific path')
        ? Prompts.pkmAgentTruncatedOverviewHeader
        : Prompts.pkmAgentFullOverviewHeader;
    return '''<system-reminder>
$header
$pkmStructure
</system-reminder>''';
  }
}

class PkmSkipDecision {
  const PkmSkipDecision._({
    required this.shouldSkip,
    this.reason,
    this.temporalScope,
    this.evidence,
  });

  final bool shouldSkip;
  final String? reason;
  final String? temporalScope;
  final String? evidence;

  const PkmSkipDecision.persist() : this._(shouldSkip: false);

  const PkmSkipDecision.skip({
    required String reason,
    required String temporalScope,
    required String evidence,
  }) : this._(
          shouldSkip: true,
          reason: reason,
          temporalScope: temporalScope,
          evidence: evidence,
        );

  Map<String, dynamic> toJson() => {
        'should_skip': shouldSkip,
        if (reason != null) 'reason': reason,
        if (temporalScope != null) 'temporal_scope': temporalScope,
        if (evidence != null) 'evidence': evidence,
      };
}

class PkmRunCompletionEvidence {
  const PkmRunCompletionEvidence({
    required this.wrotePara,
    required this.updatedInsight,
    required this.skippedPkm,
    required this.clarificationRequested,
    required this.successfulPkmMutation,
    this.skipReason,
    this.skipTemporalScope,
    this.skipEvidence,
    this.clarificationDedupeKey,
  });

  final bool wrotePara;
  final bool updatedInsight;
  final bool skippedPkm;
  final bool clarificationRequested;
  final bool successfulPkmMutation;
  final String? skipReason;
  final String? skipTemporalScope;
  final String? skipEvidence;
  final String? clarificationDedupeKey;

  bool get isComplete =>
      (wrotePara && updatedInsight) ||
      (skippedPkm && !successfulPkmMutation) ||
      (clarificationRequested && !successfulPkmMutation);

  List<String> get missingRequirements {
    if (isComplete) return const [];
    if (skippedPkm && successfulPkmMutation) {
      return const ['skip_without_successful_pkm_mutation'];
    }
    if (clarificationRequested && successfulPkmMutation) {
      return const ['clarification_without_persistent_completion'];
    }

    final missing = <String>[];
    if (!wrotePara) missing.add('wrote_para_with_fact_id');
    if (!updatedInsight) missing.add('updated_timeline_card_insight');
    if (!skippedPkm) missing.add('skip_pkm_organization');
    if (!clarificationRequested) {
      missing.add('create_clarification_request');
    }
    return missing;
  }

  Map<String, dynamic> toJson() => {
        'is_complete': isComplete,
        'wrote_para': wrotePara,
        'updated_insight': updatedInsight,
        'skipped_pkm': skippedPkm,
        'clarification_requested': clarificationRequested,
        'successful_pkm_mutation': successfulPkmMutation,
        'missing_requirements': missingRequirements,
        if (skipReason != null) 'skip_reason': skipReason,
        if (skipTemporalScope != null) 'skip_temporal_scope': skipTemporalScope,
        if (skipEvidence != null) 'skip_evidence': skipEvidence,
        if (clarificationDedupeKey != null)
          'clarification_dedupe_key': clarificationDedupeKey,
      };
}
