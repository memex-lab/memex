import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/file_system_service.dart';

Future<AgentState> loadOrCreateAgentState(
  String sessionId,
  Map<String, dynamic>? initialMetadata,
) async {
  final userId = initialMetadata?['userId'] ?? 'mock_user_id';
  final stateDirPath = await FileSystemService.instance.getAgentStateDirectory(
    userId,
  );
  final stateDir = Directory(stateDirPath);
  final storage = FileStateStorage(stateDir);
  final state = await storage.loadOrCreate(sessionId, initialMetadata);
  if (_repairLegacyAssistantContentBlocks(state)) {
    await storage.save(state);
  }
  return state;
}

Future<void> saveAgentState(AgentState state) async {
  final userId = state.metadata['userId'] ?? 'mock_user_id';
  final stateDirPath = await FileSystemService.instance.getAgentStateDirectory(
    userId,
  );
  final stateDir = Directory(stateDirPath);
  final storage = FileStateStorage(stateDir);
  await storage.save(state);
}

bool _repairLegacyAssistantContentBlocks(AgentState state) {
  var changed = false;
  final repairedMessages = <LLMMessage>[];

  for (final message in state.history.messages) {
    if (message is! ModelMessage) {
      repairedMessages.add(message);
      continue;
    }

    var repaired = message;
    if (repaired.contentBlocks.isEmpty &&
        repaired.thought != null &&
        repaired.thought!.isNotEmpty) {
      repaired = _withSynthesizedContentBlocks(repaired);
      changed = true;
    }

    if (_needsLegacyReasoningContentPlaceholder(repaired)) {
      repaired = _withReasoningContentPlaceholder(repaired);
      changed = true;
    }

    repairedMessages.add(repaired);
  }

  if (changed) {
    state.history.messages = repairedMessages;
  }
  return changed;
}

bool _needsLegacyReasoningContentPlaceholder(ModelMessage message) {
  if (message.thought != null) return false;
  if (message.functionCalls.isEmpty) return false;

  final model = message.model.toLowerCase();
  return model.contains('deepseek-v4');
}

ModelMessage _withReasoningContentPlaceholder(ModelMessage message) {
  // Old interrupted DeepSeek V4 tool-call turns may have lost
  // reasoning_content. We cannot reconstruct it, but a present field unblocks
  // the next API call; fresh turns keep the real reasoning_content.
  return _copyModelMessage(message, thought: ' ');
}

ModelMessage _withSynthesizedContentBlocks(ModelMessage message) {
  final contentBlocks = <Map<String, dynamic>>[
    {
      'type': 'thinking',
      'thinking': message.thought,
      if (message.thoughtSignature != null)
        'signature': message.thoughtSignature,
    },
  ];

  if (message.textOutput != null && message.textOutput!.isNotEmpty) {
    contentBlocks.add({'type': 'text', 'text': message.textOutput});
  }

  for (final call in message.functionCalls) {
    if (call.id.isEmpty) continue;
    contentBlocks.add({
      'type': 'tool_use',
      'id': call.id,
      'name': call.name,
      'input': _decodeToolInput(call.arguments),
    });
  }

  return _copyModelMessage(message, contentBlocks: contentBlocks);
}

ModelMessage _copyModelMessage(
  ModelMessage message, {
  String? thought,
  List<Map<String, dynamic>>? contentBlocks,
}) {
  return ModelMessage(
    thought: thought ?? message.thought,
    thoughtSignature: message.thoughtSignature,
    contentBlocks: contentBlocks ?? message.contentBlocks,
    functionCalls: message.functionCalls,
    textOutput: message.textOutput,
    imageOutputs: message.imageOutputs,
    videoOutputs: message.videoOutputs,
    audioOutputs: message.audioOutputs,
    usage: message.usage,
    metadata: message.metadata,
    stopReason: message.stopReason,
    model: message.model,
    responseId: message.responseId,
    timestamp: message.timestamp,
  );
}

dynamic _decodeToolInput(String arguments) {
  if (arguments.isEmpty) {
    return {};
  }
  try {
    return jsonDecode(arguments);
  } catch (_) {
    return {};
  }
}

Future<void> deleteAgentState(String userId, String sessionId) async {
  final stateDirPath = await FileSystemService.instance.getAgentStateDirectory(
    userId,
  );
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
  final stateDirPath = await FileSystemService.instance.getAgentStateDirectory(
    userId,
  );
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
