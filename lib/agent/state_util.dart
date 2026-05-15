import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/file_system_service.dart';

Future<AgentState> loadOrCreateAgentState(
    String sessionId, Map<String, dynamic>? initialMetadata) async {
  final userId = initialMetadata?['userId'] ?? 'mock_user_id';
  final stateDirPath =
      await FileSystemService.instance.getAgentStateDirectory(userId);
  final stateDir = Directory(stateDirPath);
  final storage = FileStateStorage(stateDir);
  return await storage.loadOrCreate(sessionId, initialMetadata);
}

Future<void> saveAgentState(AgentState state) async {
  final userId = state.metadata['userId'] ?? 'mock_user_id';
  final stateDirPath =
      await FileSystemService.instance.getAgentStateDirectory(userId);
  final stateDir = Directory(stateDirPath);
  final storage = FileStateStorage(stateDir);
  await storage.save(state);
}

Future<void> deleteAgentState(String userId, String sessionId) async {
  final stateDirPath =
      await FileSystemService.instance.getAgentStateDirectory(userId);
  final stateDir = Directory(stateDirPath);
  final storage = FileStateStorage(stateDir);
  await storage.delete(sessionId);
}

/// Resolve the session ID for a character agent.
///
/// Strategy:
/// - Look for existing state files matching `prefix_N` pattern.
/// - If the latest one is still running (interrupted), return it for resume.
/// - Otherwise, return a new ID with incremented sequence number.
///
/// Returns `(sessionId, isExisting)` — if `isExisting` is true, the caller
/// should attempt resume; otherwise it's a fresh session.
Future<({String sessionId, bool isExisting})> resolveCharacterSessionId({
  required String prefix,
  required String userId,
}) async {
  final stateDirPath =
      await FileSystemService.instance.getAgentStateDirectory(userId);
  final stateDir = Directory(stateDirPath);
  if (!await stateDir.exists()) {
    return (sessionId: '${prefix}_1', isExisting: false);
  }

  // List state files matching the prefix pattern.
  final entities = await stateDir.list().toList();
  int maxSeq = 0;
  String? latestFile;
  for (final entity in entities) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last.replaceAll('.json', '');
    if (!name.startsWith('${prefix}_')) continue;
    final suffix = name.substring(prefix.length + 1);
    final seq = int.tryParse(suffix);
    if (seq != null && seq > maxSeq) {
      maxSeq = seq;
      latestFile = name;
    }
  }

  if (latestFile == null) {
    return (sessionId: '${prefix}_1', isExisting: false);
  }

  // Check if the latest session is still running (interrupted).
  final storage = FileStateStorage(stateDir);
  try {
    final state = await storage.loadOrCreate(latestFile, null);
    if (state.isRunning) {
      return (sessionId: latestFile, isExisting: true);
    }
  } catch (_) {
    // Corrupted state file — skip it.
  }

  // Latest session completed; create next one.
  return (sessionId: '${prefix}_${maxSeq + 1}', isExisting: false);
}
