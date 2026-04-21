import 'dart:io';
import 'dart:convert';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/agent/persona_agent/persona_agent.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:uuid/uuid.dart';

final _logger = getLogger('ChatEndpoint');
final _fileSystemService = FileSystemService.instance;
const _uuid = Uuid();

/// Get chat session list
///
/// Args:
///   agentName: optional, filter by agent
///   limit: optional, max count
///
/// Returns:
///   List<Map<String, dynamic>>: session list
Future<List<Map<String, dynamic>>> fetchChatSessionsEndpoint({
  String? agentName,
  int? limit,
}) async {
  _logger.info('fetchChatSessions called: agentName=$agentName, limit=$limit');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw ApiException('User not logged in, cannot get session list');
    }

    final sessionsPath = _fileSystemService.getChatSessionsPath(userId);
    final sessionsDir = Directory(sessionsPath);

    if (!await sessionsDir.exists()) {
      return [];
    }

    final sessions = <Map<String, dynamic>>[];
    final sessionFiles = <File>[];

    await for (final entity in sessionsDir.list()) {
      if (entity is File && entity.path.endsWith('.yaml')) {
        final fileName = p.basenameWithoutExtension(entity.path);

        // If agentName set, filter by filename prefix (no need to read file)
        if (agentName != null && agentName.isNotEmpty) {
          if (!fileName.startsWith('${agentName}_')) {
            continue;
          }
        }

        sessionFiles.add(entity);
      }
    }

    // Sort by mtime (newest first)
    sessionFiles.sort((a, b) {
      try {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      } catch (_) {
        return 0;
      }
    });

    for (final sessionFile in sessionFiles) {
      try {
        final content = await sessionFile.readAsString();
        final doc = loadYaml(content);
        final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

        final sessionAgentName = sessionData['agent_name'] as String?;

        // Double check agent_name in file (should match filename prefix, but verify for safety)
        if (agentName != null &&
            agentName.isNotEmpty &&
            sessionAgentName != agentName) {
          continue;
        }

        final sessionId = sessionData['session_id'] as String? ??
            p.basenameWithoutExtension(sessionFile.path);
        final messages = sessionData['messages'] as List<dynamic>? ?? [];

        // Get last message preview
        String? lastMessagePreview;
        if (messages.isNotEmpty) {
          final lastMsg = messages.last as Map<String, dynamic>;
          final contentList = lastMsg['content'] as List<dynamic>? ?? [];
          final textParts = <String>[];
          for (final item in contentList) {
            if (item is Map<String, dynamic> &&
                item['type'] == 'text' &&
                item['text'] != null) {
              textParts.add(item['text'] as String);
            }
          }
          if (textParts.isNotEmpty) {
            final preview = textParts.join(' ');
            lastMessagePreview =
                preview.length > 100 ? preview.substring(0, 100) : preview;
          }
        }

        sessions.add({
          'session_id': sessionId,
          'agent_name': sessionAgentName,
          'title': sessionData['title'] as String? ?? 'New chat',
          'created_at': sessionData['created_at'] as String? ??
              DateTime.now().toIso8601String(),
          'updated_at': sessionData['updated_at'] as String? ??
              DateTime.now().toIso8601String(),
          'message_count': messages.length,
          'last_message_preview': lastMessagePreview,
          'is_quick_query': sessionData['is_quick_query'] == true,
        });
      } catch (e) {
        _logger.warning('Failed to load session from ${sessionFile.path}: $e');
        continue;
      }
    }

    // Apply limit
    if (limit != null && limit > 0) {
      return sessions.take(limit).toList();
    }

    return sessions;
  } catch (e) {
    _logger.severe('Failed to fetch chat sessions: $e');
    rethrow;
  }
}

/// Get session detail
///
/// Args:
///   sessionId: session ID
///
/// Returns:
///   Map<String, dynamic>: session detail (session_id, agent_name, title, created_at, updated_at, messages)
Future<Map<String, dynamic>> fetchChatSessionDetailEndpoint(
    String sessionId) async {
  _logger.info('fetchChatSessionDetail called: sessionId=$sessionId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw ApiException('User not logged in, cannot get session detail');
    }

    if (sessionId.isEmpty) {
      throw ApiException('Session ID cannot be empty');
    }

    final sessionFile = _getSessionFilePath(userId, sessionId);
    if (!await sessionFile.exists()) {
      throw ApiException('Session not found: $sessionId');
    }

    final content = await sessionFile.readAsString();
    final doc = loadYaml(content);
    final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

    final messages = await _getSessionMessages(userId, sessionId);

    return {
      'session_id': sessionId,
      'agent_name': sessionData['agent_name'],
      'title': sessionData['title'] as String? ?? 'New chat',
      'created_at': sessionData['created_at'] as String? ??
          DateTime.now().toIso8601String(),
      'updated_at': sessionData['updated_at'] as String? ??
          DateTime.now().toIso8601String(),
      'messages': messages,
      if (sessionData['total_usage'] != null)
        'total_usage': sessionData['total_usage'],
    };
  } catch (e) {
    _logger.severe('Failed to fetch chat session detail: $e');
    rethrow;
  }
}

/// Delete session (physical delete)
///
/// Args:
///   sessionId: session ID
///
/// Returns:
///   bool: success
///
/// Note:
///   Client uses physical delete; session file is removed
Future<bool> deleteChatSessionEndpoint(String sessionId) async {
  _logger.info('deleteChatSession called: sessionId=$sessionId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw ApiException('User not logged in, cannot delete session');
    }

    if (sessionId.isEmpty) {
      throw ApiException('Session ID cannot be empty');
    }

    final sessionFile = _getSessionFilePath(userId, sessionId);
    if (!await sessionFile.exists()) {
      _logger.warning('Session file not found: $sessionId');
      return false;
    }

    await sessionFile.delete();
    _logger.info('Session file physically deleted: $sessionId');
    return true;
  } catch (e) {
    _logger.severe('Failed to delete chat session $sessionId: $e');
    return false;
  }
}

// Helper functions

File _getSessionFilePath(String userId, String sessionId) {
  final sessionsPath = _fileSystemService.getChatSessionsPath(userId);
  return File(p.join(sessionsPath, '$sessionId.yaml'));
}

Future<String> _createSession(
  String userId,
  String? agentName,
  List<Map<String, dynamic>> initialContent,
) async {
  // Generate sessionId as agentName_uuid format
  final uuidStr = _uuid.v4();
  final sessionId = agentName != null && agentName.isNotEmpty
      ? '${agentName}_$uuidStr'
      : uuidStr;
  final now = DateTime.now();

  // Generate title from first message text
  String? title;
  for (final item in initialContent) {
    if (item['type'] == 'text' && item['text'] != null) {
      final text = item['text'] as String;
      title = text.length > 50 ? text.substring(0, 50) : text;
      break;
    }
  }

  final sessionData = {
    'session_id': sessionId,
    'agent_name': agentName,
    'title': title ?? 'New chat',
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
    'messages': <dynamic>[],
  };

  final sessionFile = _getSessionFilePath(userId, sessionId);
  final parentDir = sessionFile.parent;
  await parentDir.create(recursive: true);

  await _fileSystemService.writeYamlFile(sessionFile.path, sessionData);
  _logger.info('Created chat session $sessionId for user $userId');

  return sessionId;
}

Future<void> _addMessageToSession(
  String userId,
  String sessionId,
  String role,
  List<Map<String, dynamic>> content,
) async {
  final sessionFile = _getSessionFilePath(userId, sessionId);
  if (!await sessionFile.exists()) {
    throw ApiException('Session not found: $sessionId');
  }

  final fileContent = await sessionFile.readAsString();
  final doc = loadYaml(fileContent);
  final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

  final messageDict = {
    'role': role,
    'content': content,
    'timestamp': DateTime.now().toIso8601String(),
  };

  final messages = (sessionData['messages'] as List<dynamic>? ?? [])
    ..add(messageDict);
  sessionData['messages'] = messages;
  sessionData['updated_at'] = DateTime.now().toIso8601String();

  // If this is the first user message, update title
  if ((sessionData['title'] as String? ?? '') == 'New chat' && role == 'user') {
    for (final item in content) {
      if (item['type'] == 'text' && item['text'] != null) {
        final text = item['text'] as String;
        final title = text.length > 50 ? text.substring(0, 50) : text;
        sessionData['title'] = title;
        break;
      }
    }
  }

  await _fileSystemService.writeYamlFile(sessionFile.path, sessionData);
  _logger.info('Added message to session $sessionId');
}

Future<List<Map<String, dynamic>>> _getSessionMessages(
  String userId,
  String sessionId,
) async {
  final sessionFile = _getSessionFilePath(userId, sessionId);
  if (!await sessionFile.exists()) {
    return [];
  }

  final content = await sessionFile.readAsString();
  final doc = loadYaml(content);
  final sessionData = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

  final messages = sessionData['messages'] as List<dynamic>? ?? [];
  return messages.map((msg) {
    if (msg is Map<String, dynamic>) {
      return msg;
    }
    return <String, dynamic>{};
  }).toList();
}
