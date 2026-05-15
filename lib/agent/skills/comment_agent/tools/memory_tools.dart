// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/memory/character_memory_service.dart';

class MemoryToolFactory {
  final String userId;
  final String? defaultCharacterId;

  MemoryToolFactory({
    required this.userId,
    this.defaultCharacterId,
  });

  String? get _targetId => defaultCharacterId;

  Tool buildMemoryReadTool() {
    return Tool(
      name: 'MemoryRead',
      description:
          '''Reads memory blocks from the current character's memory storage.

Usage:
- The `labels` parameter is optional; if provided, only memory blocks with matching labels are returned.
- If `labels` is omitted or empty, all memory blocks are returned.
- Use this before editing memory so you can see existing content and avoid duplicates.''',
      parameters: {
        'type': 'object',
        'properties': {
          'labels': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Optional list of memory block labels to filter by.'
          }
        },
        'required': []
      },
      executable: (List<dynamic>? labels) async {
        final characterId = _targetId;
        if (characterId == null) return 'Error: No default character set.';
        return CharacterMemoryService.instance.readMemoryEntries(
          userId: userId,
          characterId: characterId,
          labels: labels?.map((e) => e.toString()).toList(),
        );
      },
    );
  }

  Tool buildMemoryEditTool() {
    return Tool(
      name: 'MemoryEdit',
      description: '''Performs precise string replacement in a memory block.

Usage:
- Specify the `label` of the memory block to edit.
- `old_string` must uniquely match text within the block's content.
- If `old_string` matches multiple times, the edit will fail unless `replace_all` is true.
- If the target memory block doesn't exist and old_string is empty, a new block is created with new_string as content.''',
      parameters: {
        'type': 'object',
        'properties': {
          'label': {
            'type': 'string',
            'description': 'The label of the memory block to edit.'
          },
          'old_string': {
            'type': 'string',
            'description':
                'The exact text to find and replace in the memory block content.'
          },
          'new_string': {
            'type': 'string',
            'description': 'The new text to replace old_string with.'
          },
          'replace_all': {
            'type': 'boolean',
            'description':
                'Whether to replace all occurrences of old_string. Defaults to false.'
          }
        },
        'required': ['label', 'old_string', 'new_string']
      },
      executable: (
        String label,
        String old_string,
        String new_string, [
        bool? replace_all,
      ]) async {
        final characterId = _targetId;
        if (characterId == null) return 'Error: No default character set.';
        return CharacterMemoryService.instance.editMemoryEntry(
          userId: userId,
          characterId: characterId,
          label: label,
          oldString: old_string,
          newString: new_string,
          replaceAll: replace_all ?? false,
        );
      },
    );
  }

  Tool buildMemoryWriteTool() {
    return Tool(
      name: 'MemoryWrite',
      description: '''Writes (creates or overwrites) a memory block.

Usage:
- If a memory block with the given label exists, it will be overwritten entirely.
- If it doesn't exist, a new block is created.
- Always prioritize MemoryEdit for partial changes to preserve existing content.''',
      parameters: {
        'type': 'object',
        'properties': {
          'label': {
            'type': 'string',
            'description': 'The label of the memory block to write.'
          },
          'content': {
            'type': 'string',
            'description': 'The content to write to the memory block.'
          },
          'salience': {
            'type': 'number',
            'description': 'Importance from 0.0 to 1.0. Defaults to 0.5.'
          }
        },
        'required': ['label', 'content']
      },
      executable: (
        String label,
        String content, [
        num? salience,
      ]) async {
        final characterId = _targetId;
        if (characterId == null) return 'Error: No default character set.';
        return CharacterMemoryService.instance.writeMemoryEntry(
          userId: userId,
          characterId: characterId,
          label: label,
          content: content,
          salience: salience?.toDouble() ?? 0.5,
        );
      },
    );
  }

  Tool buildMemoryRemoveTool() {
    return Tool(
      name: 'MemoryRemove',
      description: 'Removes a memory block by label.',
      parameters: {
        'type': 'object',
        'properties': {
          'label': {
            'type': 'string',
            'description': 'The label of the memory block to remove.'
          }
        },
        'required': ['label']
      },
      executable: (String label) async {
        final characterId = _targetId;
        if (characterId == null) return 'Error: No default character set.';
        return CharacterMemoryService.instance.removeMemoryEntry(
          userId: userId,
          characterId: characterId,
          label: label,
        );
      },
    );
  }

  Tool buildHistorySearchTool() {
    return Tool(
      name: 'HistorySearch',
      description: '''Searches this character's archived interaction history.
Use this when compressed checkpoints or memory entries are too vague and you need exact prior chat/comment/post wording from before compression.''',
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description':
                'Keywords to search for in previous chats, posts, comments, or replies.'
          },
          'limit': {
            'type': 'integer',
            'description': 'Maximum number of matches to return. Defaults to 8.'
          },
          'scene': {
            'type': 'string',
            'enum': ['chat', 'comment'],
            'description': 'Optional scene filter.'
          },
          'thread_id': {
            'type': 'string',
            'description':
                'Optional comment thread/fact id filter, for example a factId.'
          },
        },
        'required': ['query']
      },
      executable: (
        String query, [
        int? limit,
        String? scene,
        String? thread_id,
      ]) async {
        final characterId = _targetId;
        if (characterId == null) return 'Error: No default character set.';
        CharacterMemoryScene? sceneFilter;
        if (scene != null && scene.trim().isNotEmpty) {
          for (final candidate in CharacterMemoryScene.values) {
            if (candidate.name == scene.trim()) {
              sceneFilter = candidate;
              break;
            }
          }
          if (sceneFilter == null) {
            return 'Error: scene must be "chat" or "comment".';
          }
        }
        return CharacterMemoryService.instance.searchTimelineEvents(
          userId: userId,
          characterId: characterId,
          query: query,
          limit: limit ?? 8,
          includeArchived: true,
          scene: sceneFilter,
          threadId: thread_id,
        );
      },
    );
  }
}
