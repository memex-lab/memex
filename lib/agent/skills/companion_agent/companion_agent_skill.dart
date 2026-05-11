import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/skills/character_tools_factory.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/tavern_macro.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

class CompanionAgentSkill extends Skill {
  CompanionAgentSkill({
    required CharacterModel character,
    required String userId,
    required String userName,
    required String userProfile,
    required String characterMemories,
    super.forceActivate,
  }) : super(
          name: 'companion_chat',
          description:
              'Emotional companion chat skill. Stay in-character, warm, concise, and continuous.',
          systemPrompt: _buildSystemPrompt(
            character: character,
            userName: userName,
            userProfile: userProfile,
            characterMemories: characterMemories,
          ),
          tools: CharacterToolsFactory.buildCompanionTools(
            userId: userId,
            characterId: character.id,
          ),
        );

  static String _buildSystemPrompt({
    required CharacterModel character,
    required String userName,
    required String userProfile,
    required String characterMemories,
  }) {
    final now = formatLocalDateTimeWithZone(DateTime.now());
    final lang = UserStorage.l10n.commentLanguageInstruction;
    final b = StringBuffer();

    // Helper to resolve tavern macros in character card fields.
    String m(String text) =>
        TavernMacro.resolve(text, userName: userName, charName: character.name);

    // If character has a system prompt override, use it as the primary directive.
    if (character.systemPromptOverride != null &&
        character.systemPromptOverride!.trim().isNotEmpty) {
      b.writeln(m(character.systemPromptOverride!));
      b.writeln('');
    }

    b.writeln('# You Are ${character.name}');
    b.writeln('Current time: $now');
    b.writeln('');
    b.writeln('## Persona');
    b.writeln(m(character.persona));
    b.writeln('');
    b.writeln('## Behavior Rules');
    b.writeln('- Fully role-play this character.');
    b.writeln('- Keep replies natural and brief like real chat.');
    b.writeln('- Prefer empathy and continuity over exposition.');
    b.writeln('- Always send a visible chat reply to the user.');
    b.writeln('- For ordinary emotional chat, reply directly in text first.');
    b.writeln(
        '- Do not answer a normal chat turn with only tool calls or empty content.');
    b.writeln(
        '- If you see "CONTEXT SUMMARY — REFERENCE ONLY", treat it as background history, not a fresh user request.');
    b.writeln('- Always prioritize the latest real user message.');
    b.writeln(
        '- Use HistorySearch when memory or compressed history is too vague and exact past wording matters.');
    b.writeln('- Language: $lang');
    b.writeln('');

    if (userProfile.isNotEmpty) {
      b.writeln('## User Profile');
      b.writeln(userProfile);
      b.writeln('');
    }

    if (characterMemories.isNotEmpty) {
      b.writeln('## Character Memory Entries');
      b.writeln(characterMemories);
      b.writeln('');
    }

    if (character.mesExample != null &&
        character.mesExample!.trim().isNotEmpty) {
      b.writeln('## Style Examples');
      b.writeln(m(character.mesExample!));
      b.writeln('');
    }

    b.writeln('## Memory Update Guidance');
    b.writeln(
        '- Use `append_memories` to record durable USER-level facts (preferences, identity, habits) that apply across all characters.');
    b.writeln(
        '- Use MemoryWrite/MemoryEdit/MemoryRemove to manage CHARACTER-level memory (relationship dynamics, emotional bonds, interaction patterns specific to this character).');
    b.writeln(
        '- Do not use memory tools during a simple support reply unless the user states a durable preference or correction.');
    b.writeln(
        '- Memory tools are optional and must never replace the chat reply.');
    b.writeln('- Avoid storing ephemeral details or exact chat logs.');
    return b.toString();
  }
}
