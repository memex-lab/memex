import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/local_task_executor.dart';

enum AgentBackgroundRunState { idle, active, completed, failed }

class AgentBackgroundStatus {
  const AgentBackgroundStatus({
    required this.state,
    required this.pending,
    required this.processing,
    required this.retrying,
    required this.title,
    required this.stage,
    required this.detail,
    required this.agentName,
    required this.updatedAt,
    this.scene,
    this.sceneId,
  });

  factory AgentBackgroundStatus.fromActivity({
    required TaskActivitySnapshot taskSnapshot,
    AgentActivityMessageModel? latestMessage,
    DateTime? now,
  }) {
    final messageType = latestMessage?.type;
    final hasTasks = taskSnapshot.hasActiveTasks;
    final state = switch (messageType) {
      AgentActivityType.error when !hasTasks => AgentBackgroundRunState.failed,
      AgentActivityType.agent_stop when !hasTasks =>
        AgentBackgroundRunState.completed,
      _ when hasTasks => AgentBackgroundRunState.active,
      _ => AgentBackgroundRunState.idle,
    };

    final fallbackStage = switch (state) {
      AgentBackgroundRunState.failed => 'Needs attention',
      AgentBackgroundRunState.completed => 'Completed',
      AgentBackgroundRunState.active => 'Processing',
      AgentBackgroundRunState.idle => 'Idle',
    };

    final title = switch (state) {
      AgentBackgroundRunState.failed => 'Memex task needs attention',
      AgentBackgroundRunState.completed => 'Memex task complete',
      AgentBackgroundRunState.active => 'Memex is processing',
      AgentBackgroundRunState.idle => 'Memex is idle',
    };

    final stage =
        _firstNonBlank([latestMessage?.title, latestMessage?.agentName]) ??
            fallbackStage;

    final detail = _detailFor(
      taskSnapshot: taskSnapshot,
      latestMessage: latestMessage,
      state: state,
    );

    return AgentBackgroundStatus(
      state: state,
      pending: taskSnapshot.pending,
      processing: taskSnapshot.processing,
      retrying: taskSnapshot.retrying,
      title: title,
      stage: stage,
      detail: detail,
      agentName: latestMessage?.agentName ?? '',
      scene: latestMessage?.scene,
      sceneId: latestMessage?.sceneId,
      updatedAt: now ?? DateTime.now(),
    );
  }

  final AgentBackgroundRunState state;
  final int pending;
  final int processing;
  final int retrying;
  final String title;
  final String stage;
  final String detail;
  final String agentName;
  final String? scene;
  final String? sceneId;
  final DateTime updatedAt;

  int get remainingTasks => pending + processing + retrying;

  bool get hasActiveTasks => remainingTasks > 0;

  bool get shouldShowSystemSurface =>
      state == AgentBackgroundRunState.active ||
      state == AgentBackgroundRunState.completed ||
      state == AgentBackgroundRunState.failed;

  Map<String, dynamic> toPlatformMap() {
    return {
      'state': state.name,
      'pending': pending,
      'processing': processing,
      'retrying': retrying,
      'remainingTasks': remainingTasks,
      'title': title,
      'stage': stage,
      'detail': detail,
      'agentName': agentName,
      'scene': scene,
      'sceneId': sceneId,
      'updatedAtMs': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is AgentBackgroundStatus &&
        other.state == state &&
        other.pending == pending &&
        other.processing == processing &&
        other.retrying == retrying &&
        other.title == title &&
        other.stage == stage &&
        other.detail == detail &&
        other.agentName == agentName &&
        other.scene == scene &&
        other.sceneId == sceneId;
  }

  @override
  int get hashCode => Object.hash(
        state,
        pending,
        processing,
        retrying,
        title,
        stage,
        detail,
        agentName,
        scene,
        sceneId,
      );
}

String _detailFor({
  required TaskActivitySnapshot taskSnapshot,
  required AgentActivityMessageModel? latestMessage,
  required AgentBackgroundRunState state,
}) {
  final messageContent = _trimToSingleLine(latestMessage?.content);
  if (messageContent != null) return messageContent;

  if (taskSnapshot.hasActiveTasks) {
    final parts = <String>[];
    if (taskSnapshot.processing > 0) {
      parts.add('${taskSnapshot.processing} running');
    }
    if (taskSnapshot.pending > 0) {
      parts.add('${taskSnapshot.pending} waiting');
    }
    if (taskSnapshot.retrying > 0) {
      parts.add('${taskSnapshot.retrying} retrying');
    }
    return '${taskSnapshot.total} remaining: ${parts.join(', ')}';
  }

  return switch (state) {
    AgentBackgroundRunState.failed => 'Processing stopped with an error.',
    AgentBackgroundRunState.completed => 'All background tasks finished.',
    AgentBackgroundRunState.active => 'Processing is starting.',
    AgentBackgroundRunState.idle => 'No background tasks.',
  };
}

String? _firstNonBlank(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String? _trimToSingleLine(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final compact = trimmed.replaceAll(RegExp(r'\s+'), ' ');
  if (compact.length <= 140) return compact;
  return '${compact.substring(0, 137)}...';
}
