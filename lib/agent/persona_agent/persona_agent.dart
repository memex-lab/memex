import 'dart:io';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';

class PersonaAgent {
  final Logger _logger = getLogger('PersonaAgent');
  final GeminiClient client;
  final ModelConfig modelConfig;
  FileSystemService get _fileService => FileSystemService.instance;
  final CharacterService _characterService = CharacterService.instance;

  PersonaAgent({
    required this.client,
    required this.modelConfig,
  });

  Future<String> run({
    required String userId,
    required String message,
    required String sessionId, // task_id used as session_id
  }) async {
    _logger.info("Running PersonaAgent for user: $userId, session: $sessionId");

    try {
      // 1. Prepare Workspace
      final pkmPath = _fileService.getPkmPath(userId);
      final knowledgePath = Directory(pkmPath);
      if (!await knowledgePath.exists()) {
        await knowledgePath.create(recursive: true);
      }

      // 2. Get user profile (if available)
      // Note: ProfileService might not exist in client yet, skip for now
      const profileContent = ''; // TODO: Get from ProfileService when available

      // 3. Get all characters
      final characters = await _characterService.getAllCharacters(userId);
      final charactersInfo = characters
          .map((char) => {
                'id': char.id,
                'name': char.name,
                'tags': char.tags,
                'enabled': char.enabled,
              })
          .toList();

      // 4. Build System Prompt
      final systemPrompt = _buildSystemPrompt(
        knowledgePath: pkmPath,
        profileContent: profileContent,
        charactersInfo: charactersInfo,
      );

      // 5. Initialize State Storage and Agent
      final stateDirPath = await _fileService.getAgentStateDirectory(userId);
      final stateDir = Directory(stateDirPath);
      final storage = FileStateStorage(stateDir);

      // Use sessionId as task_id to maintain conversation history
      final state = await storage.loadOrCreate(sessionId, {
        'userId': userId,
        'scene': 'persona',
        'sceneId': sessionId,
        'workingDirectory': pkmPath,
      });

      // @see context auto-compress config
      final compressor = LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 128000,
        keepRecentMessageSize: 10,
      );

      final agent = StatefulAgent(
        name: 'persona_agent',
        client: client,
        modelConfig: modelConfig,
        tools: _buildTools(userId),
        systemPrompts: [systemPrompt],
        state: state,
        autoSaveStateFunc: (state) async {
          await storage.save(state);
        },
        compressor: compressor,
        systemCallback: createSystemCallback(userId),
      );

      // 6. Run Agent
      final userMessage = UserMessage([TextPart(message)]);

      // Log agent execution event
      try {
        await _fileService.eventLogService.logEvent(
          userId: userId,
          eventType: 'agent_execution',
          description: 'Persona Agent started',
          metadata: {
            'agent_name': 'persona_agent',
            'session_id': sessionId,
            'user_message': message,
          },
        );
      } catch (e) {
        // Event logging failure should not break agent execution
      }

      final history = await agent.run([userMessage]);

      // Save state after running
      await storage.save(state);

      // Extract the text response
      if (history.isNotEmpty) {
        final lastMsg = history.last;
        if (lastMsg is ModelMessage) {
          return lastMsg.textOutput ?? "Sorry, I did not generate a reply.";
        }
      }
      return "Sorry, I did not generate a reply.";
    } catch (e, stack) {
      _logger.severe("PersonaAgent failed: $e", e, stack);
      return "Sorry, I cannot reply at the moment.";
    }
  }

  String _buildSystemPrompt({
    required String knowledgePath,
    required String profileContent,
    required List<Map<String, dynamic>> charactersInfo,
  }) {
    var prompt =
        '''You are the character designer for Memex (private life-logging app). In this private space where users store voice, photos and text, you design virtual characters that provide deep emotional support.

Core design principles:

1. Language and culture alignment: Understand the current user profile and explore the user's personal knowledge base.
2. Human-like short text: Real users typically don't write long posts. Character replies must be short, life-like, like a real person. No "AI-style" lecturing or long essays; keep it natural like chat/SMS.

Workflow:

1. Understand current user profile and explore user's personal knowledge base:
- Understand the user profile and explore the user's knowledge base under /.
2. Generate character card (use the user's native language):
- Based on the user profile and knowledge base, consider: as a specific virtual character the user wants to build, what traits to care about, what emotional pain points to address, how to resonate with the user. If information is insufficient, keep exploring the knowledge base. Output a prompt ready for LLM to role-play.
- Do not include concrete dialogue examples in the persona.

''';

    prompt +=
        "\n\n## Current user profile\n${profileContent.isEmpty ? '(No user profile yet; explore the knowledge base first)' : profileContent}\n\n";

    prompt += "## Existing characters\n";
    if (charactersInfo.isNotEmpty) {
      for (final char in charactersInfo) {
        final tags = char['tags'] as List<dynamic>? ?? [];
        final tagsStr = tags.map((t) => t.toString()).join(', ');
        prompt +=
            "- ID: ${char['id']}, Name: ${char['name']}, Tags: ${tagsStr.isEmpty ? 'none' : tagsStr}\n";
      }
    } else {
      prompt += "(No characters yet)\n";
    }
    prompt +=
        "\nTip: Use GetCharacterPersona to view a character's current persona, and CreateOrUpdateCharacterPersona to create or update a character's persona.\n";

    return prompt;
  }

  List<Tool> _buildTools(String userId) {
    final pkmPath = _fileService.getPkmPath(userId);
    final permissionManager = FilePermissionManager(userId, [
      PermissionRule(rootPath: pkmPath, access: FileAccessType.read),
    ]);

    final fileToolFactory = FileToolFactory(
      permissionManager: permissionManager,
      workingDirectory: pkmPath,
    );

    return [
      fileToolFactory.buildLSTool(),
      fileToolFactory.buildGlobTool(),
      fileToolFactory.buildGrepTool(),
      fileToolFactory.buildReadTool(),
      Tool(
        name: 'GetCharacterPersona',
        description: '''View the current persona of a character.

Parameters:
- character_id: Character ID (required)
''',
        parameters: {
          'type': 'object',
          'properties': {
            'character_id': {
              'type': 'string',
              'description': 'Character ID',
            },
          },
          'required': ['character_id'],
        },
        executable: (String characterId) async {
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                'GetCharacterPersona must be called within an agent execution context.');
          }

          final userId = context.state.metadata['userId'] as String?;
          if (userId == null) {
            return 'Error: missing user ID';
          }

          try {
            final character =
                await _characterService.getCharacter(userId, characterId);
            if (character == null) {
              return 'Error: character $characterId not found';
            }

            final tagsStr =
                character.tags.isEmpty ? 'none' : character.tags.join(', ');
            var result = 'Character ID: ${character.id}\n';
            result += 'Name: ${character.name}\n';
            result += 'Tags: $tagsStr\n';
            result += 'Enabled: ${character.enabled ? "yes" : "no"}\n';
            result +=
                '\nCurrent Persona:\n${character.persona.isEmpty ? "(no persona yet)" : character.persona}';

            return result;
          } catch (e) {
            return 'Error: failed to get character persona - $e';
          }
        },
      ),
      Tool(
        name: 'CreateOrUpdateCharacterPersona',
        description: '''Create or update a character's persona.

Parameters:
- character_id: Character ID (required). If the character does not exist, a new one will be created (character_name required). If it exists, the persona will be updated.
- character_name: Character name (optional, required when creating a new character)
- persona: Persona content (required). Full prompt for the LLM to role-play. Design based on user profile and knowledge base.
- tags: Character tags (optional)

Note:
- If the character exists, persona, name and tags will be updated.
- If the character does not exist, a new character will be created (character_name required).
''',
        parameters: {
          'type': 'object',
          'properties': {
            'character_id': {
              'type': 'string',
              'description': 'Character ID',
            },
            'character_name': {
              'type': 'string',
              'description': 'Character name (required only when creating a new character)',
            },
            'persona': {
              'type': 'string',
              'description': 'Persona content, full prompt',
            },
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Character tags list',
            },
          },
          'required': ['character_id', 'persona'],
        },
        executable: (String characterId, String? characterName,
            String persona, List? tags) async {
          _logger.info(
              "CreateOrUpdateCharacterPersona called: character_id=$characterId, persona=$persona, character_name=$characterName, tags=$tags");
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                'CreateOrUpdateCharacterPersona must be called within an agent execution context.');
          }

          final userId = context.state.metadata['userId'] as String?;
          if (userId == null) {
            return 'Error: missing user ID';
          }

          final tagsList =
              tags?.map((t) => t.toString()).toList() ?? <String>[];

          try {
            // Check if character exists
            final existingCharacter = await _characterService
                .getCharacter(userId, characterId, returnPlaceholder: false);

            if (existingCharacter == null) {
              // Create new character
              if (characterName == null || characterName.isEmpty) {
                return 'Error: character_name is required when creating a new character';
              }

              // Create character with specified ID
              final charsPath = _characterService.getCharactersPath(userId);
              final charDir = Directory(charsPath);
              if (!await charDir.exists()) {
                await charDir.create(recursive: true);
              }

              final charFile = File('${charDir.path}/$characterId.yaml');
              if (await charFile.exists()) {
                return 'Error: character file $characterId.yaml already exists, use update instead';
              }

              final charData = {
                'name': characterName,
                'tags': tagsList,
                'persona': persona,
                'avatar': null,
                'enabled': true,
              };

              await _fileService.writeYamlFile(charFile.path, charData);

              return 'Created character $characterId (name: $characterName) and set persona';
            } else {
              // Update existing character
              final updates = <String, dynamic>{'persona': persona};
              if (characterName != null && characterName.isNotEmpty) {
                updates['name'] = characterName;
              }
              if (tagsList.isNotEmpty) {
                updates['tags'] = tagsList;
              }

              await _characterService.updateCharacter(
                userId: userId,
                characterId: characterId,
                updates: updates,
              );

              return 'Updated persona for character $characterId (name: ${existingCharacter.name})';
            }
          } catch (e) {
            return 'Error: failed to create or update character persona - $e';
          }
        },
      ),
    ];
  }
}
