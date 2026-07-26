import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_workspace.dart';

/// Progressive read access and semantic memory writes shared by every scene
/// in which a character thinks or speaks.
class CharacterWorkspaceMemoryTools {
  CharacterWorkspaceMemoryTools({
    required this.userId,
    required this.characterId,
    CharacterWorkspaceService? workspaceService,
  }) : _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance;

  final String userId;
  final String characterId;
  final CharacterWorkspaceService _workspaceService;

  List<Tool> build() {
    final fileSystem = FileSystemService.instance;
    final workspace = fileSystem.getCharacterWorkspacePath(userId, characterId);
    final permissions = FilePermissionManager(
      userId,
      [
        PermissionRule(rootPath: workspace, access: FileAccessType.none),
        PermissionRule(
          rootPath: fileSystem.getCharacterIdentityPath(userId, characterId),
          access: FileAccessType.read,
        ),
        PermissionRule(
          rootPath: fileSystem.getCharacterWorldPath(userId, characterId),
          access: FileAccessType.read,
        ),
        PermissionRule(
          rootPath: fileSystem.getCharacterPkmPath(userId, characterId),
          access: FileAccessType.read,
        ),
        PermissionRule(
          rootPath: fileSystem.getCharacterJournalPath(userId, characterId),
          access: FileAccessType.read,
        ),
      ],
      withDefaultRules: false,
    );
    final fileTools = FileToolFactory(
      permissionManager: permissions,
      workingDirectory: workspace,
    );

    return [
      fileTools.buildLSTool(),
      fileTools.buildGlobTool(),
      fileTools.buildGrepTool(),
      fileTools.buildReadTool(),
      fileTools.buildBatchReadTool(),
      _buildRememberTool(),
    ];
  }

  Tool _buildRememberTool() {
    return Tool(
      name: 'Remember',
      description: 'Create or replace one durable Markdown note in your own '
          'PKM. Use a stable, descriptive relative path such as '
          '`people/user-and-66.md` or `open_threads/childhood.md`. Read an '
          'existing note before replacing it.',
      parameters: {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description': 'Relative path under PKM/. Must end in .md.',
          },
          'content': {
            'type': 'string',
            'description': 'The complete new Markdown content of the note.',
          },
        },
        'required': ['path', 'content'],
      },
      executable: (String path, String content) async {
        final declined = await gateMutatingToolCall(
          toolName: 'Remember',
          summary: 'Update character memory at PKM/$path',
          details: {'path': 'PKM/$path'},
        );
        if (declined != null) return declined;
        await _workspaceService.writePkmNote(
          userId: userId,
          characterId: characterId,
          relativePath: path,
          content: content,
        );
        return 'Remembered in PKM/$path.';
      },
    );
  }
}

class CharacterWorkspaceTools {
  CharacterWorkspaceTools({
    required this.userId,
    required this.characterId,
    required this.observation,
    CharacterWorkspaceService? workspaceService,
  }) : _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance;

  final String userId;
  final String characterId;
  final CharacterObservation observation;
  final CharacterWorkspaceService _workspaceService;

  List<Tool> build() {
    return [
      ...CharacterWorkspaceMemoryTools(
        userId: userId,
        characterId: characterId,
        workspaceService: _workspaceService,
      ).build(),
      _buildAppendJournalTool(),
      _buildFinishObservationTool(),
    ];
  }

  Tool _buildAppendJournalTool() {
    return Tool(
      name: 'AppendJournal',
      description: 'Write or revise your private, immediate reflection for '
          'this observation. This is subjective continuity, not a transcript '
          'or objective summary.',
      parameters: {
        'type': 'object',
        'properties': {
          'content': {
            'type': 'string',
            'description': 'A brief private reflection in your own voice.',
          },
        },
        'required': ['content'],
      },
      executable: (String content) async {
        final declined = await gateMutatingToolCall(
          toolName: 'AppendJournal',
          summary: 'Update the character journal for this observation',
        );
        if (declined != null) return declined;
        await _workspaceService.writeJournalEntry(
          userId: userId,
          characterId: characterId,
          observation: observation,
          content: content,
        );
        return 'Journal updated.';
      },
    );
  }

  Tool _buildFinishObservationTool() {
    return Tool(
      name: 'FinishObservation',
      description: 'Finish digesting the current observation. Call this '
          'exactly once, after any memory or journal updates. The raw '
          'observation will then leave your inbox.',
      parameters: const {
        'type': 'object',
        'properties': <String, dynamic>{},
      },
      executable: () async {
        final declined = await gateMutatingToolCall(
          toolName: 'FinishObservation',
          summary: 'Finish the current character observation',
        );
        if (declined != null) return declined;
        await _workspaceService.completeObservation(
          userId: userId,
          characterId: characterId,
          observationId: observation.id,
        );
        return AgentToolResult(
          content: TextPart('Observation digested.'),
          stopFlag: true,
        );
      },
    );
  }
}
