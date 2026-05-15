import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/comment_agent/tools/comment_tools.dart';
import 'package:memex/agent/skills/comment_agent/tools/memory_tools.dart';
import 'package:memex/agent/skills/companion_agent/tools/action_message_tools.dart';

class CharacterToolsFactory {
  CharacterToolsFactory._();

  static List<Tool> buildCompanionTools({
    required String userId,
    required String characterId,
  }) {
    final memoryFactory = MemoryToolFactory(
      userId: userId,
      defaultCharacterId: characterId,
    );
    final actionFactory = ActionMessageToolFactory(characterId: characterId);
    return [
      memoryFactory.buildMemoryReadTool(),
      memoryFactory.buildMemoryWriteTool(),
      memoryFactory.buildMemoryEditTool(),
      memoryFactory.buildMemoryRemoveTool(),
      memoryFactory.buildHistorySearchTool(),
      actionFactory.buildSendActionMessageTool(),
    ];
  }

  static List<Tool> buildCommentTools({
    required String userId,
    required String workingDirectory,
    required String factId,
    String? characterId,
    String? forcedReplyToId,
    bool includeSaveCommentTool = true,
    bool includeFileTools = true,
  }) {
    final tools = <Tool>[];

    if (includeFileTools) {
      final permissionManager = FilePermissionManager(userId, [
        PermissionRule(rootPath: workingDirectory, access: FileAccessType.read),
      ]);
      final fileFactory = FileToolFactory(
        permissionManager: permissionManager,
        workingDirectory: workingDirectory,
      );
      tools.add(fileFactory.buildReadTool());
      tools.add(fileFactory.buildGrepTool());
    }

    if (includeSaveCommentTool) {
      final commentFactory = CommentToolFactory(
        userId: userId,
        cardId: factId,
        characterId: characterId,
        forcedReplyToId: forcedReplyToId,
      );
      tools.add(commentFactory.buildSaveCommentTool());
    }

    if (characterId != null) {
      final memoryFactory = MemoryToolFactory(
        userId: userId,
        defaultCharacterId: characterId,
      );
      tools.add(memoryFactory.buildMemoryReadTool());
      tools.add(memoryFactory.buildMemoryWriteTool());
      tools.add(memoryFactory.buildMemoryEditTool());
      tools.add(memoryFactory.buildMemoryRemoveTool());
      tools.add(memoryFactory.buildHistorySearchTool());
    }

    return tools;
  }
}
