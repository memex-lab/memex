import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/skills/character_tools_factory.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/tavern_macro.dart';
import 'package:memex/utils/user_storage.dart';

/// Skill for Comment Agent - generates warm, empathetic comments for user's private tree hole entries
class CommentAgentSkill extends Skill {
  CommentAgentSkill({
    CharacterModel? character,
    required String factId,
    required String workingDirectory,
    required String userId,
    String userName = '',
    String userProfile = '',
    String characterMemories = '',
    String? forcedReplyToId,
    super.forceActivate,
  }) : super(
          name: "persona_comment",
          description: Prompts.commentAgentSkillDescription,
          systemPrompt: _buildSystemPrompt(
            character: character,
            userName: userName,
            userProfile: userProfile,
            characterMemories: characterMemories,
          ),
          tools: _buildTools(
            userId: userId,
            workingDirectory: workingDirectory,
            factId: factId,
            characterId: character?.id,
            forcedReplyToId: forcedReplyToId,
          ),
        );

  static String _buildSystemPrompt({
    CharacterModel? character,
    required String userName,
    required String userProfile,
    required String characterMemories,
  }) {
    StringBuffer personaBuffer = StringBuffer();
    if (character != null) {
      final charName = character.name;
      String m(String text) =>
          TavernMacro.resolve(text, userName: userName, charName: charName);
      personaBuffer.writeln("Name: $charName");
      personaBuffer.writeln("Tags: ${character.tags.join(', ')}");
      personaBuffer.writeln("### Persona: \n${m(character.persona)}");
    }
    String persona = personaBuffer.toString();

    final systemPrompt = Prompts.commentSkillSystemPrompt(
      persona,
      UserStorage.l10n.commentLanguageInstruction,
    );

    final b = StringBuffer();

    // systemPromptOverride takes highest priority — prepend before skill prompt.
    if (character != null &&
        character.systemPromptOverride != null &&
        character.systemPromptOverride!.trim().isNotEmpty) {
      final charName = character.name;
      b.writeln(
        TavernMacro.resolve(
          character.systemPromptOverride!,
          userName: userName,
          charName: charName,
        ),
      );
      b.writeln('');
    }

    b.write(systemPrompt);

    if (userProfile.isNotEmpty) {
      b.writeln('');
      b.writeln('## User Profile');
      b.writeln(userProfile);
    }

    if (characterMemories.isNotEmpty) {
      b.writeln('');
      b.writeln('## Character Memory Entries');
      b.writeln(characterMemories);
    }

    if (character != null &&
        character.mesExample != null &&
        character.mesExample!.trim().isNotEmpty) {
      final charName = character.name;
      b.writeln('');
      b.writeln('## Style Examples');
      b.writeln(
        TavernMacro.resolve(
          character.mesExample!,
          userName: userName,
          charName: charName,
        ),
      );
    }

    return b.toString();
  }

  static List<Tool> _buildTools({
    required String userId,
    required String workingDirectory,
    required String factId,
    String? characterId,
    String? forcedReplyToId,
  }) {
    return CharacterToolsFactory.buildCommentTools(
      userId: userId,
      workingDirectory: workingDirectory,
      factId: factId,
      characterId: characterId,
      forcedReplyToId: forcedReplyToId,
    );
  }
}
