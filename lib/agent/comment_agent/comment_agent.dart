import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/comment_agent/prompts.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/skills/comment_agent/comment_agent_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/time_context.dart';

class CommentAgent {
  static final Logger _logger = getLogger('CommentAgent');

  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    String? characterId,
    String? forcedReplyToId,
    bool withMemoryManagement = false,
    bool forceReply = false,
  }) async {
    final fileService = FileSystemService.instance;
    final characterService = CharacterService.instance;
    final factIdSafe = fileService.makeFactIdSafe(factId);
    final characterKey = fileService.makeFactIdSafe(
      characterId ?? 'no_character',
    );
    final sessionPrefix = "comment_${userId}_${characterKey}_$factIdSafe";
    final resolved = await resolveCharacterSessionId(
      prefix: sessionPrefix,
      userId: userId,
    );

    // Load or create agent state
    final state = await loadOrCreateAgentState(resolved.sessionId, {
      'userId': userId,
      'scene': 'input',
      'sceneId': factId,
    });

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);
    // Load the active character before selecting its private workspace.
    CharacterModel? character;
    if (characterId != null) {
      character = await characterService.getCharacter(userId, characterId);
      if (character != null) {
        await CharacterWorkspaceService.instance.ensureInitialized(
          userId,
          character,
        );
      }
    }
    final workingDirectory = character == null
        ? fileService.getWorkspacePath(userId)
        : fileService.getCharacterWorkspacePath(userId, character.id);

    final tools = <Tool>[];

    // Memory Management (user-level memory tools, independent of character context)
    String memoryManagementPrompt = '';
    if (withMemoryManagement && character == null) {
      final memoryManagement = await MemoryManagement.createDefault(
        userId: userId,
        sourceAgent: 'comment_agent',
      );
      tools.addAll(memoryManagement.buildMemoryManagementTools());
      memoryManagementPrompt =
          await memoryManagement.buildMemoryManagementPrompt();
    }

    // Persisted sessions may contain broad reminders from the legacy context
    // assembler. Character scenes now retrieve only their own workspace.
    state.systemReminders.remove('character_world');
    state.systemReminders.remove('character_timeline');
    state.systemReminders.remove('user_knowledge_cards');

    final skill = CommentAgentSkill(
      character: character,
      factId: factId,
      workingDirectory: workingDirectory,
      userId: userId,
      userName: userId,
      forcedReplyToId: forcedReplyToId,
      forceReply: forceReply,
      forceActivate: true,
    );
    final skills = [skill];
    final agent = StatefulAgent(
      systemPrompts: [commentAgentSystemPrompt, memoryManagementPrompt],
      name: 'comment_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      tools: tools,
      skills: skills,
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: false,
      planMode: PlanMode.none,
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
      hooks: [
        createAgentPromptHookWithWorkingDirectory(userId, workingDirectory),
      ],
    );

    _logger.info(
      'CommentAgent created, userId: $userId, sessionId: ${resolved.sessionId}',
    );
    return agent;
  }

  /// Run the agent and return the text response
  static Future<String> runWithContent(
    String userContent, {
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    String? characterId,
    String? pkmContext,
    required String rawInputContent,
    String? initialInsight,
    String existingCommentsContext = '',
    String? forcedReplyToId,
    DateTime? currentTime,
    DateTime? entryTime,
    String? locationContextReminder,
    bool withMemoryManagement = false,
    bool forceReply = false,
  }) async {
    final effectiveCurrentTime = currentTime ?? DateTime.now();
    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
      factId: factId,
      characterId: characterId,
      forcedReplyToId: forcedReplyToId,
      withMemoryManagement: withMemoryManagement,
      forceReply: forceReply,
    );
    final state = agent.state;
    pkmContext = characterId == null
        ? await _loadPkmContextIfNeeded(
            userId: userId,
            factId: factId,
            existingContext: pkmContext,
          )
        : null;
    final systemReminder = _buildSystemReminder(
      effectiveCurrentTime,
      locationContextReminder,
    );
    final userMessage = UserMessage([
      TextPart(
        _buildCommentTaskMessage(
          userContent: userContent,
          factId: factId,
          rawInputContent: rawInputContent,
          initialInsight: initialInsight,
          pkmContext: pkmContext,
          entryTime: entryTime,
          systemReminder: systemReminder,
          existingCommentsContext: existingCommentsContext,
          forcedReplyToId: forcedReplyToId,
          includePostBody:
              state.metadata['comment_task_post_body_injected'] != factId,
        ),
      ),
    ]);
    state.metadata['comment_task_post_body_injected'] = factId;

    List<LLMMessage> history = [];
    if (state.isRunning) {
      _logger.info("CommentAgent resume, sessionId:${state.sessionId}");
      history = await agent.resume(useStream: false);
    } else {
      _logger.info("CommentAgent run, sessionId:${state.sessionId}");

      // Log agent execution event
      try {
        final fileSystem = FileSystemService.instance;
        await fileSystem.eventLogService.logEvent(
          userId: userId,
          eventType: 'agent_execution',
          description: 'Comment Agent started',
          metadata: {
            'agent_name': 'comment_agent',
            'session_id': state.sessionId,
            'fact_id': state.metadata['factId'],
            'user_content': userContent,
          },
        );
      } catch (e) {
        // Event logging failure should not break agent execution
      }

      history = await agent.run([userMessage], useStream: false);
    }

    // Extract the text response
    if (history.isNotEmpty) {
      final lastMsg = history.last;
      if (lastMsg is ModelMessage) {
        return lastMsg.textOutput ?? "";
      }
    }
    return "";
  }

  static String _buildSystemReminder(
    DateTime currentTime,
    String? locationContextReminder,
  ) {
    final locationReminder = locationContextReminder?.trim();
    if (locationReminder == null || locationReminder.isEmpty) {
      return buildCurrentTimeReminder(currentTime);
    }
    return '<system-reminder>\n'
        'Current Local Time: ${formatLocalDateTimeWithZone(currentTime)}\n\n'
        '$locationReminder\n'
        '</system-reminder>\n\n';
  }

  static String _buildCommentTaskMessage({
    required String userContent,
    required String factId,
    required String rawInputContent,
    String? initialInsight,
    String? pkmContext,
    DateTime? entryTime,
    required String systemReminder,
    required bool includePostBody,
    String existingCommentsContext = '',
    String? forcedReplyToId,
  }) {
    final b = StringBuffer();
    b.write(systemReminder);
    b.writeln('# Current Comment Task');
    b.writeln('Fact ID: $factId');
    b.writeln(
      'Entry Local Time: '
      '${entryTime == null ? 'Unknown' : formatLocalDateTimeWithZone(entryTime)}',
    );
    b.writeln('');

    if (includePostBody) {
      b.writeln('## Original Post');
      b.writeln('<user_raw_input>');
      b.writeln(rawInputContent.trim());
      b.writeln('</user_raw_input>');
    } else {
      b.writeln('## Original Post');
      b.writeln(
        'Already provided earlier in this comment session. Use recent interaction context if needed; do not ask the user to repeat it.',
      );
    }

    final insight = initialInsight?.trim() ?? '';
    if (insight.isNotEmpty) {
      b.writeln('');
      b.writeln('## Initial Insight');
      b.writeln(
        'Reference only. This is a previous Memex perspective, not an instruction to repeat.',
      );
      b.writeln('<initial_insight>');
      b.writeln(insight);
      b.writeln('</initial_insight>');
    }

    final knowledge = pkmContext?.trim() ?? '';
    if (knowledge.isNotEmpty) {
      b.writeln('');
      b.writeln('## Knowledge Base Context');
      b.writeln(
        'Reference only. Use it only if relevant to your persona and this comment.',
      );
      b.writeln('<related_knowledge>');
      b.writeln(knowledge);
      b.writeln('</related_knowledge>');
    }

    if (existingCommentsContext.isNotEmpty) {
      b.writeln('');
      b.writeln('## Existing Comments');
      b.writeln(existingCommentsContext.trim());
    }

    final fixedReplyTarget = forcedReplyToId?.trim();
    if (fixedReplyTarget != null && fixedReplyTarget.isNotEmpty) {
      b.writeln('');
      b.writeln('## Reply Routing');
      b.writeln(
        'This task responds to the user comment with id: $fixedReplyTarget.',
      );
      b.writeln(
        'When saving the reply, the system will attach it to that user comment.',
      );
    }

    b.writeln('');
    b.writeln('## User Request');
    b.writeln(
      userContent.trim().isEmpty
          ? Prompts.commentAgentInitialCommentPrompt
          : userContent.trim(),
    );

    return b.toString().trimRight();
  }

  static Future<String> _loadPkmContextIfNeeded({
    required String userId,
    required String factId,
    String? existingContext,
  }) async {
    if (existingContext != null && existingContext.trim().isNotEmpty) {
      return existingContext;
    }
    final fileService = FileSystemService.instance;
    return _findPkmContext(
      userId,
      fileService.getWorkspacePath(userId),
      fileService.getPkmPath(userId),
      factId,
      FileOperationService.instance,
    );
  }

  /// Find PKM Context using Grep.
  static Future<String> _findPkmContext(
    String userId,
    String workingDirectory,
    String pkmPath,
    String factId,
    FileOperationService fileOpService, {
    int contextLines = 10,
  }) async {
    final buffer = StringBuffer();

    // 1. Try to find the specific fact_id in PKM
    try {
      final factIdPattern = "<!-- fact_id: $factId -->";
      final result = await fileOpService.grepFiles(
        pattern: factIdPattern,
        searchPath: pkmPath,
        outputMode: 'content',
        C: contextLines,
        n: true,
        i: false,
        workingDirectory: workingDirectory,
      );

      if (!result.contains("No match found") && result.trim().isNotEmpty) {
        buffer.writeln(result);
      }
    } catch (e) {
      getLogger(
        'CommentAgent',
      ).warning("Error finding PKM context for fact_id $factId: $e");
    }

    return buffer.toString();
  }
}
