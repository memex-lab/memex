import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/state_util.dart';

const Duration defaultScheduleAggregationResumeTtl = Duration(hours: 6);

String normalizeScheduleAggregationRunId(String? runId, DateTime now) {
  final normalized = runId?.trim();
  if (normalized != null && normalized.isNotEmpty) {
    return normalized;
  }
  return 'manual_${now.microsecondsSinceEpoch}';
}

String buildScheduleAggregatorSessionId(String userId, String runId) {
  return 'schedule_aggregator_${safeScheduleAggregatorSessionPart(userId)}_${safeScheduleAggregatorSessionPart(runId)}';
}

String safeScheduleAggregatorSessionPart(String value) {
  final safe = value
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
  if (safe.isEmpty) {
    return 'unknown';
  }
  if (safe.length <= 96) {
    return safe;
  }
  return safe.substring(safe.length - 96);
}

Future<AgentState> loadOrCreateScheduleAggregatorRunState({
  required String userId,
  required String runId,
  required String sessionId,
  required DateTime now,
}) async {
  final state = await loadOrCreateAgentState(sessionId, {
    'userId': userId,
    'scene': 'schedule_aggregation',
    'sceneId': runId,
    'run_id': runId,
  });
  ensureScheduleAggregatorRunMetadata(
    state: state,
    userId: userId,
    runId: runId,
    now: now,
  );
  return state;
}

void ensureScheduleAggregatorRunMetadata({
  required AgentState state,
  required String userId,
  required String runId,
  required DateTime now,
}) {
  state.metadata['userId'] = userId;
  state.metadata['scene'] = 'schedule_aggregation';
  state.metadata['sceneId'] = runId;
  state.metadata['run_id'] = runId;
  state.metadata.putIfAbsent('run_started_at', () => now.toIso8601String());
}

bool shouldResumeScheduleAggregatorRun(
  AgentState state,
  DateTime now,
  Duration ttl,
) {
  if (!state.isRunning) return false;
  final startedAtValue = state.metadata['run_started_at']?.toString();
  final startedAt =
      startedAtValue == null ? null : DateTime.tryParse(startedAtValue);
  if (startedAt == null) {
    return true;
  }
  final age = now.difference(startedAt);
  return age.isNegative || age <= ttl;
}
