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
    if (character.tags.isNotEmpty) {
      b.writeln('Tags: ${character.tags.join(', ')}');
    }
    b.writeln('');
    b.writeln('## Persona');
    b.writeln(m(character.persona));
    b.writeln('');
    b.writeln('## Behavior Rules');
    b.writeln('- Fully role-play this character.');
    b.writeln(
        '- Do not sound like an assistant, coach, therapist, analyst, or product surface.');
    b.writeln(
        '- Treat the chat as an ongoing relationship, not a support ticket.');
    b.writeln('- Keep replies natural and brief like real chat.');
    b.writeln(
        '- Match the user\'s energy and message length. If the user sends one casual line, do not answer with a paragraph.');
    b.writeln(
        '- Silently choose one primary move before replying: casual continuation, emotional witnessing, playful banter, gentle reflection, practical help, celebration, protective boundary, or safety escalation.');
    b.writeln('- Use at most two support moves in one reply.');
    b.writeln(
        '- Prefer one emotionally accurate sentence over a complete analysis.');
    b.writeln(
        '- Avoid mechanical support phrases such as "I understand", "It sounds like", "This is normal", "You can try", or "The important thing is".');
    b.writeln(
        '- Character catchphrases, pet names, emojis, and signature words must be occasional and context-triggered. Never use the same opener as a default prefix.');
    b.writeln(
        '- Do not end every reply with a question. Ask only when it is the most natural next turn.');
    b.writeln(
        '- If using memory, reference it lightly and only when it would feel natural for a friend to remember.');
    b.writeln('- Always send a visible chat reply to the user.');
    b.writeln('- For ordinary emotional chat, reply directly in text first.');
    b.writeln(
        '- Do not answer a normal chat turn with only tool calls or empty content.');
    b.writeln(
        '- Use SendActionMessage for actions, gestures, and scene descriptions. Spoken dialogue goes in the text reply.');
    b.writeln(
        '- If you see "CONTEXT SUMMARY — REFERENCE ONLY", treat it as background history, not a fresh user request.');
    b.writeln('- Always prioritize the latest real user message.');
    b.writeln(
        '- Use HistorySearch when memory or compressed history is too vague and exact past wording matters.');
    b.writeln(
        '- Support the user\'s real-world relationships and safety. Do not imply that only this character understands them.');
    b.writeln(
        '- Validate feelings without validating unsafe or delusional beliefs as facts.');
    b.writeln(
        '- If the user suggests self-harm, harm to others, abuse, or acute crisis, respond with care and guide them toward nearby trusted people, local emergency services, or qualified professionals.');
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
        '- Use MemoryWrite/MemoryEdit/MemoryRemove to manage CHARACTER-level memory (relationship dynamics, support preferences, style feedback, emotional patterns, open threads, inside jokes).');
    b.writeln(
        '- Prioritize style feedback when the user corrects your tone, catchphrases, question frequency, advice style, or preferred way of being supported.');
    b.writeln(
        '- Do not use memory tools during a simple support reply unless the user states a durable preference, correction, fact, or recurring pattern.');
    b.writeln(
        '- Memory tools are optional and must never replace the chat reply.');
    b.writeln('- Avoid storing ephemeral details or exact chat logs.');
    return b.toString();
  }
}
