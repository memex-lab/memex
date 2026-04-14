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
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

class CommentAgent {
  static final Logger _logger = getLogger('CommentAgent');

  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    String? characterId,
    String? pkmContext,
    required String rawInputContent,
    String? initialInsight,
    bool withMemoryManagement = false,
  }) async {
    final fileService = FileSystemService.instance;
    final characterService = CharacterService.instance;
    final fileOpService = FileOperationService.instance;

    final factIdSafe = fileService.makeFactIdSafe(factId);
    final sessionId = "comment_${userId}_$factIdSafe";

    // Load or create agent state
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'input',
      'sceneId': factId,
    });

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);
    // 1. Prepare Workspace
    final workingDirectory = fileService.getWorkspacePath(userId);
    final pkmPath = fileService.getPkmPath(userId);

    // 2. Load Character
    CharacterModel? character;
    if (characterId != null) {
      character = await characterService.getCharacter(userId, characterId);
    }

    // 3. Find PKM Context if not provided
    if (pkmContext == null || pkmContext.isEmpty) {
      pkmContext = await _findPkmContext(
          userId, workingDirectory, pkmPath, factId, fileOpService);
    }

    // 4. Create Skill
    String pkmStructure = '';
    try {
      pkmStructure = await fileOpService.listDirectory(
          dirPath: pkmPath, workingDirectory: workingDirectory);
    } catch (e) {
      pkmStructure = Prompts.commentAgentPkmErrorReadingDirectory;
      getLogger('CommentAgent').warning('Failed to get PKM structure: $e');
    }

    final tools = <Tool>[];

    // Memory Management
    String memoryManagementPrompt = '';
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'knowledge_insight_agent',
    );
    if (withMemoryManagement) {
      tools.addAll(memoryManagement.buildMemoryManagementTools());
      memoryManagementPrompt =
          await memoryManagement.buildMemoryManagementPrompt();
    }
    final userMemory = await memoryManagement.buildMemoryPrompt();
    state.systemReminders["user_memory"] = userMemory;

    final skill = CommentAgentSkill(
      character: character,
      factId: factId,
      rawInputContent: rawInputContent,
      initialInsight: initialInsight,
      pkmContext: pkmContext,
      workingDirectory: workingDirectory,
      pkmStructure: pkmStructure,
      userId: userId,
      forceActivate: true,
    );
    final skills = [skill];
    final agent = StatefulAgent(
        systemPrompts: [commentAgentSystemPrompt, memoryManagementPrompt],
        name: 'comment_agent',
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
    DateTime? currentTime,
    bool withMemoryManagement = false,
  }) async {
    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
      factId: factId,
      characterId: characterId,
      pkmContext: pkmContext,
      rawInputContent: rawInputContent,
      initialInsight: initialInsight,
      withMemoryManagement: withMemoryManagement,
    );
    final state = agent.state;
    final timeStr =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(currentTime ?? DateTime.now());
    final systemReminder =
        "<system-reminder>\nCurrent Time: $timeStr\n</system-reminder>\n\n";
    final fullUserContent = "$systemReminder$userContent";
    final userMessage = UserMessage([TextPart(fullUserContent)]);

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

  /// Find PKM Context using Grep.
  /// Falls back to recent daily facts if the specific fact_id isn't in PKM yet.
  static Future<String> _findPkmContext(String userId, String workingDirectory,
      String pkmPath, String factId, FileOperationService fileOpService,
      {int contextLines = 10}) async {
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
      getLogger('CommentAgent')
          .warning("Error finding PKM context for fact_id $factId: $e");
    }

    // 2. Always try to include recent daily facts for life context
    // This gives the character awareness of what the user has been up to lately
    try {
      final recentContext = await _getRecentFactsContext(
          userId, workingDirectory, fileOpService);
      if (recentContext.isNotEmpty) {
        buffer.writeln("\n## Recent User Activity (last few days):");
        buffer.writeln(recentContext);
      }
    } catch (e) {
      getLogger('CommentAgent')
          .warning("Error getting recent facts context: $e");
    }

    return buffer.toString();
  }

  /// Read the most recent daily fact files to give the character
  /// awareness of the user's recent life context.
  static Future<String> _getRecentFactsContext(String userId,
      String workingDirectory, FileOperationService fileOpService) async {
    final fileSystem = FileSystemService.instance;
    final now = DateTime.now();
    final buffer = StringBuffer();
    var totalChars = 0;
    const maxChars = 3000; // Keep it concise

    // Try the last 3 days of facts
    for (var i = 0; i < 3 && totalChars < maxChars; i++) {
      final date = now.subtract(Duration(days: i));
      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final factRelPath = 'Facts/$year/$month/$day.md';
      final factFullPath =
          '${fileSystem.getWorkspacePath(userId)}/$factRelPath';

      try {
        final content = await fileOpService.readFile(
          filePath: factFullPath,
          workingDirectory: workingDirectory,
        );

        if (content.isNotEmpty && !content.contains('Error')) {
          // Truncate if needed
          final remaining = maxChars - totalChars;
          final truncated = content.length > remaining
              ? '${content.substring(0, remaining)}...(truncated)'
              : content;
          buffer.writeln("### $year-$month-$day");
          buffer.writeln(truncated);
          totalChars += truncated.length;
        }
      } catch (_) {
        // File doesn't exist for this day, skip
      }
    }

    return buffer.toString();
  }
}
