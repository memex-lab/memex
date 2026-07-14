import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:memex/utils/time_context.dart';

final _logger = getLogger('ChatEndpoint');
ChatSessionStorage get _chatStorage => ChatSessionStorage.instance;

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

    final sessions = <Map<String, dynamic>>[];
    final sessionRows = await _chatStorage.listSessionMetadata(userId);
    for (final sessionData in sessionRows) {
      try {
        final sessionAgentName = sessionData['agent_name'] as String?;
        final sessionId = sessionData['session_id'] as String?;
        if (sessionId == null || sessionId.isEmpty) continue;

        if (agentName != null &&
            agentName.isNotEmpty &&
            sessionAgentName != agentName) {
          continue;
        }

        sessions.add({
          'session_id': sessionId,
          'agent_name': sessionAgentName,
          'scene': sessionData['scene'] as String?,
          'scene_id': sessionData['scene_id'] as String?,
          'title': sessionData['title'] as String? ?? 'New chat',
          'created_at': sessionData['created_at'] as String? ??
              DateTime.now().toIso8601String(),
          'created_at_local': sessionData['created_at_local'] as String? ??
              formatLocalDateTimeWithZoneOrNull(sessionData['created_at']),
          'created_at_unix_seconds': sessionData['created_at_unix_seconds'] ??
              unixSecondsFromDateTimeOrNull(sessionData['created_at']),
          'updated_at': sessionData['updated_at'] as String? ??
              DateTime.now().toIso8601String(),
          'updated_at_local': sessionData['updated_at_local'] as String? ??
              formatLocalDateTimeWithZoneOrNull(sessionData['updated_at']),
          'updated_at_unix_seconds': sessionData['updated_at_unix_seconds'] ??
              unixSecondsFromDateTimeOrNull(sessionData['updated_at']),
          'last_message_preview':
              sessionData['last_message_preview'] as String?,
          'is_quick_query': sessionData['is_quick_query'] == true,
        });
      } catch (e) {
        _logger.warning('Failed to load chat session row: $e');
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

/// Check one chat session path without scanning or reading session content.
Future<bool> chatSessionExistsEndpoint(String sessionId) async {
  final userId = await UserStorage.getUserId();
  if (userId == null) {
    throw ApiException('User not logged in, cannot check session');
  }
  if (sessionId.isEmpty) {
    throw ApiException('Session ID cannot be empty');
  }
  return _chatStorage.sessionExists(userId, sessionId);
}

/// Get session detail
///
/// Args:
///   sessionId: session ID
///
/// Returns:
///   Map<String, dynamic>: session detail (session_id, agent_name, title, created_at, updated_at, messages)
Future<Map<String, dynamic>> fetchChatSessionDetailEndpoint(
  String sessionId, {
  int? messageLimit,
  String? messageBeforeCursor,
}) async {
  _logger.info('fetchChatSessionDetail called: sessionId=$sessionId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw ApiException('User not logged in, cannot get session detail');
    }

    if (sessionId.isEmpty) {
      throw ApiException('Session ID cannot be empty');
    }

    if (!await _chatStorage.sessionExists(userId, sessionId)) {
      throw ApiException('Session not found: $sessionId');
    }

    final sessionData = await _chatStorage.loadMetadata(userId, sessionId);
    final page = await _chatStorage.loadMessagePage(
      userId,
      sessionId,
      limit: messageLimit,
      beforeCursor: messageBeforeCursor,
    );

    return {
      'session_id': sessionId,
      'agent_name': sessionData['agent_name'],
      'scene': sessionData['scene'] as String?,
      'scene_id': sessionData['scene_id'] as String?,
      'title': sessionData['title'] as String? ?? 'New chat',
      'created_at': sessionData['created_at'] as String? ??
          DateTime.now().toIso8601String(),
      'created_at_local': sessionData['created_at_local'] as String? ??
          formatLocalDateTimeWithZoneOrNull(sessionData['created_at']),
      'created_at_unix_seconds': sessionData['created_at_unix_seconds'] ??
          unixSecondsFromDateTimeOrNull(sessionData['created_at']),
      'updated_at': sessionData['updated_at'] as String? ??
          DateTime.now().toIso8601String(),
      'updated_at_local': sessionData['updated_at_local'] as String? ??
          formatLocalDateTimeWithZoneOrNull(sessionData['updated_at']),
      'updated_at_unix_seconds': sessionData['updated_at_unix_seconds'] ??
          unixSecondsFromDateTimeOrNull(sessionData['updated_at']),
      'messages': page.messages.map(_withLocalTimestampFallback).toList(),
      'message_limit': messageLimit,
      'message_before_cursor': messageBeforeCursor,
      'older_cursor': page.olderCursor,
      'has_more_messages': page.hasMoreMessages,
      if (sessionData['total_usage'] != null)
        'total_usage': sessionData['total_usage'],
      'is_quick_query': sessionData['is_quick_query'] == true,
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

    if (!await _chatStorage.sessionExists(userId, sessionId)) {
      _logger.warning('Session file not found: $sessionId');
      return false;
    }

    await _chatStorage.deleteSession(userId, sessionId);
    _logger.info('Session physically deleted: $sessionId');
    return true;
  } catch (e) {
    _logger.severe('Failed to delete chat session $sessionId: $e');
    return false;
  }
}

// Helper functions

Map<String, dynamic> _withLocalTimestampFallback(Map<String, dynamic> msg) {
  final result = Map<String, dynamic>.from(msg);
  if (result['local_time'] == null) {
    final parsed = tryParseDateTime(result['timestamp']);
    if (parsed != null) {
      result['local_time'] = formatLocalDateTimeWithZone(parsed);
      result['unix_seconds'] ??= unixSecondsFromDateTime(parsed);
    }
  }
  return result;
}
