import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/agent/skills/comment_agent/tools/comment_tools.dart';
import 'package:memex/agent/skills/comment_agent/tools/memory_tools.dart';
import 'package:memex/utils/user_storage.dart';

/// Skill for Comment Agent - generates warm, empathetic comments for user's private tree hole entries
class CommentAgentSkill extends Skill {
  CommentAgentSkill({
    CharacterModel? character,
    required String factId,
    required String rawInputContent,
    String? initialInsight,
    String? pkmContext,
    required String workingDirectory,
    required String pkmStructure,
    required String userId,
    super.forceActivate,
  }) : super(
          name: "persona_comment",
          description: Prompts.commentAgentSkillDescription,
          systemPrompt: _buildSystemPrompt(
            factId: factId,
            userId: userId,
            character: character,
            rawInputContent: rawInputContent,
            initialInsight: initialInsight,
            pkmContext: pkmContext,
          ),
          tools: _buildTools(
            userId: userId,
            workingDirectory: workingDirectory,
            factId: factId,
            characterId: character?.id,
          ),
        );

  static String _buildSystemPrompt({
    required String factId,
    required String userId,
    CharacterModel? character,
    required String rawInputContent,
    String? initialInsight,
    String? pkmContext,
  }) {
    StringBuffer personaBuffer = StringBuffer();
    if (character != null) {
      personaBuffer.writeln("Name: ${character.name}");
      personaBuffer.writeln("Tags: ${character.tags.join(', ')}");
      personaBuffer.writeln("### Persona: \n${character.persona}");

      // Inject character memory as relationship context
      if (character.memory.isNotEmpty) {
        personaBuffer.writeln("\n### Your Memory of This User:");
        personaBuffer.writeln(
            "The following is what you remember from past interactions. "
            "Use this to make your response feel continuous and personal. "
            "Reference specific things you remember when natural.");
        for (final block in character.memory) {
          if (block.value.isNotEmpty) {
            personaBuffer.writeln("- [${block.label}]: ${block.value}");
          }
        }
      }
    }
    String persona = personaBuffer.toString();

    final systemPrompt = Prompts.commentSkillSystemPrompt(
      factId,
      persona,
      rawInputContent,
      initialInsight ?? '',
      pkmContext ?? '',
      UserStorage.l10n.commentLanguageInstruction,
    );

    return systemPrompt;
  }

  static List<Tool> _buildTools({
    required String userId,
    required String workingDirectory,
    required String factId,
    String? characterId,
  }) {
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(rootPath: workingDirectory, access: FileAccessType.read),
    ]);
    final fileFactory = FileToolFactory(
        permissionManager: permissionManager,
        workingDirectory: workingDirectory);

    final commentFactory = CommentToolFactory(
      userId: userId,
      cardId: factId,
      characterId: characterId,
    );

    final tools = <Tool>[
      fileFactory.buildReadTool(),
      fileFactory.buildGrepTool(),
      commentFactory.buildSaveCommentTool(),
    ];

    // Add memory tools so the character can remember things about the user
    if (characterId != null) {
      final memoryFactory = MemoryToolFactory(
        userId: userId,
        defaultCharacterId: characterId,
      );
      tools.add(memoryFactory.buildMemoryReadTool());
      tools.add(memoryFactory.buildMemoryWriteTool());
    }

    return tools;
  }
}
