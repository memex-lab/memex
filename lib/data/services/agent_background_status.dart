import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/l10n/app_localizations.dart';

enum AgentBackgroundRunState { idle, active, paused, completed, failed }

class AgentBackgroundStatus {
  const AgentBackgroundStatus({
    required this.state,
    required this.pending,
    required this.processing,
    required this.retrying,
    required this.title,
    required this.stage,
    required this.detail,
    required this.summary,
    required this.agentName,
    required this.updatedAt,
    this.taskSummary = '',
    this.statusText = '',
    this.progressCompleted = 0,
    this.progressTotal = 0,
    this.scene,
    this.sceneId,
  });

  factory AgentBackgroundStatus.fromActivity({
    required TaskActivitySnapshot taskSnapshot,
    AgentActivityMessageModel? latestMessage,
    AgentForegroundTaskSnapshot foregroundSnapshot =
        const AgentForegroundTaskSnapshot.empty(),
    DateTime? now,
    AgentBackgroundStatusLabels labels = const AgentBackgroundStatusLabels(),
  }) {
    final effectiveTaskSnapshot =
        foregroundSnapshot.hasActiveTasks || foregroundSnapshot.hasAttention
            ? foregroundSnapshot.taskSnapshot
            : taskSnapshot;
    final messageType = latestMessage?.type;
    final hasTasks = effectiveTaskSnapshot.hasActiveTasks;
    final state = foregroundSnapshot.hasAttention
        ? AgentBackgroundRunState.failed
        : foregroundSnapshot.paused && hasTasks
            ? AgentBackgroundRunState.paused
            : switch (messageType) {
                AgentActivityType.agent_stop when !hasTasks =>
                  AgentBackgroundRunState.completed,
                _ when hasTasks => AgentBackgroundRunState.active,
                _ => AgentBackgroundRunState.idle,
              };

    final fallbackStage = _stageForState(state, labels);
    final title = _titleForState(state, labels);
    final stage = state == AgentBackgroundRunState.failed ||
            state == AgentBackgroundRunState.paused
        ? fallbackStage
        : _localizeKnownStatusText(
              _firstNonBlank([latestMessage?.title, latestMessage?.agentName]),
              labels,
            ) ??
            fallbackStage;
    final attentionDetail = foregroundSnapshot.latestAttentionDetail;
    final pausedDetail = _localizeKnownStatusText(
          foregroundSnapshot.pausedMessage,
          labels,
        ) ??
        foregroundSnapshot.pausedMessage;
    final detail = state == AgentBackgroundRunState.failed
        ? _trimToSingleLine(attentionDetail) ?? labels.failedDetail
        : state == AgentBackgroundRunState.paused
            ? _trimToSingleLine(pausedDetail) ?? labels.pausedDetail
            : _detailFor(
                taskSnapshot: effectiveTaskSnapshot,
                latestMessage: latestMessage,
                state: state,
                labels: labels,
              );
    final summary = _summaryFor(
      taskSnapshot: effectiveTaskSnapshot,
      latestMessage: state == AgentBackgroundRunState.failed ||
              state == AgentBackgroundRunState.paused
          ? null
          : latestMessage,
      fallbackStage: fallbackStage,
      detail: detail,
      labels: labels,
    );
    final taskSummary = formatAgentTaskSummary(
      pending: effectiveTaskSnapshot.pending,
      processing: effectiveTaskSnapshot.processing,
      retrying: effectiveTaskSnapshot.retrying,
      labels: labels,
    );

    return AgentBackgroundStatus(
      state: state,
      pending: effectiveTaskSnapshot.pending,
      processing: effectiveTaskSnapshot.processing,
      retrying: effectiveTaskSnapshot.retrying,
      title: title,
      stage: stage,
      detail: detail,
      summary: summary,
      taskSummary: taskSummary,
      statusText: _statusTextFor(
        state: state,
        remainingTasks: effectiveTaskSnapshot.total,
        taskSummary: taskSummary,
        labels: labels,
      ),
      agentName: latestMessage?.agentName ?? '',
      scene: latestMessage?.scene,
      sceneId: latestMessage?.sceneId,
      updatedAt: now ?? foregroundSnapshot.updatedAt ?? DateTime.now(),
    );
  }

  final AgentBackgroundRunState state;
  final int pending;
  final int processing;
  final int retrying;
  final String title;
  final String stage;
  final String detail;
  final String summary;
  final String taskSummary;
  final String statusText;
  final String agentName;
  final String? scene;
  final String? sceneId;
  final DateTime updatedAt;
  final int progressCompleted;
  final int progressTotal;

  int get remainingTasks => pending + processing + retrying;

  bool get hasActiveTasks => remainingTasks > 0;

  bool get shouldShowSystemSurface =>
      state == AgentBackgroundRunState.active ||
      state == AgentBackgroundRunState.paused ||
      state == AgentBackgroundRunState.failed;

  Map<String, dynamic> toPlatformMap({bool isInBackground = false}) {
    return {
      'state': state.name,
      'pending': pending,
      'processing': processing,
      'retrying': retrying,
      'remainingTasks': remainingTasks,
      'taskSummary': taskSummary,
      'statusText': statusText,
      'title': title,
      'stage': stage,
      'detail': detail,
      'summary': summary,
      'agentName': agentName,
      'scene': scene,
      'sceneId': sceneId,
      'progressCompleted': progressCompleted,
      'progressTotal': progressTotal,
      'updatedAtMs': updatedAt.millisecondsSinceEpoch,
      'isInBackground': isInBackground,
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
        other.summary == summary &&
        other.taskSummary == taskSummary &&
        other.statusText == statusText &&
        other.agentName == agentName &&
        other.scene == scene &&
        other.sceneId == sceneId &&
        other.progressCompleted == progressCompleted &&
        other.progressTotal == progressTotal;
  }

  @override
  int get hashCode => Object.hashAll([
        state,
        pending,
        processing,
        retrying,
        title,
        stage,
        detail,
        summary,
        taskSummary,
        statusText,
        agentName,
        scene,
        sceneId,
        progressCompleted,
        progressTotal,
      ]);
}

class AgentBackgroundStatusLabels {
  const AgentBackgroundStatusLabels({
    this.title = 'Memex Agent',
    this.pausedTitle = 'Memex Agent paused',
    this.needsAttentionTitle = 'Memex Agent needs attention',
    this.stageIdle = 'Idle',
    this.stageProcessing = 'Processing',
    this.stageQueued = 'Queued',
    this.stageRetrying = 'Waiting to retry',
    this.stagePaused = 'Paused',
    this.stageCompleted = 'Completed',
    this.stageNeedsAttention = 'Needs attention',
    this.stageAnalyzingMedia = 'Analyzing media',
    this.stageGeneratingCard = 'Generating card',
    this.stageUpdatingKnowledge = 'Updating knowledge',
    this.stagePreparingComment = 'Preparing comment',
    this.stageRoutingFollowUps = 'Routing follow-ups',
    this.taskSummary = _defaultTaskSummary,
    this.taskDetail = _defaultTaskDetail,
    this.noTasks = 'No background tasks.',
    this.starting = 'Processing is starting.',
    this.completedDetail = 'All background tasks finished.',
    this.failedDetail = 'Processing stopped with an error.',
    this.pausedDetail = 'Processing is paused and will continue later.',
    this.queuedDetail = 'Waiting for the next processing step.',
    this.retryingDetail = 'The current step will retry automatically.',
    this.analyzeMediaDetail = 'Reading attachments and local context.',
    this.generatingCardDetail = 'Turning the record into a timeline card.',
    this.updatingKnowledgeDetail = 'Updating local knowledge and memory.',
    this.preparingCommentDetail = 'Preparing an assistant follow-up.',
    this.routingFollowUpsDetail = 'Checking follow-up actions for this card.',
    this.pausedStatus = _defaultPausedStatus,
    this.needsAttentionStatus = _defaultNeedsAttentionStatus,
  });

  factory AgentBackgroundStatusLabels.fromL10n(AppLocalizations l10n) {
    return AgentBackgroundStatusLabels(
      title: l10n.agentBackgroundTitle,
      pausedTitle: l10n.agentBackgroundPausedTitle,
      needsAttentionTitle: l10n.agentBackgroundNeedsAttentionTitle,
      stageIdle: l10n.agentBackgroundStageIdle,
      stageProcessing: l10n.agentBackgroundStageProcessing,
      stageQueued: l10n.agentBackgroundStageQueued,
      stageRetrying: l10n.agentBackgroundStageRetrying,
      stagePaused: l10n.agentBackgroundStagePaused,
      stageCompleted: l10n.agentBackgroundStageCompleted,
      stageNeedsAttention: l10n.agentBackgroundStageNeedsAttention,
      stageAnalyzingMedia: l10n.agentBackgroundStageAnalyzingMedia,
      stageGeneratingCard: l10n.agentBackgroundStageGeneratingCard,
      stageUpdatingKnowledge: l10n.agentBackgroundStageUpdatingKnowledge,
      stagePreparingComment: l10n.agentBackgroundStagePreparingComment,
      stageRoutingFollowUps: l10n.agentBackgroundStageRoutingFollowUps,
      taskSummary: l10n.agentBackgroundTaskSummary,
      taskDetail: l10n.agentBackgroundTaskDetail,
      noTasks: l10n.agentBackgroundNoTasks,
      starting: l10n.agentBackgroundStarting,
      completedDetail: l10n.agentBackgroundCompletedDetail,
      failedDetail: l10n.agentBackgroundFailedDetail,
      pausedDetail: l10n.agentBackgroundPausedDetail,
      queuedDetail: l10n.agentBackgroundQueuedDetail,
      retryingDetail: l10n.agentBackgroundRetryingDetail,
      analyzeMediaDetail: l10n.agentBackgroundAnalyzeMediaDetail,
      generatingCardDetail: l10n.agentBackgroundGeneratingCardDetail,
      updatingKnowledgeDetail: l10n.agentBackgroundUpdatingKnowledgeDetail,
      preparingCommentDetail: l10n.agentBackgroundPreparingCommentDetail,
      routingFollowUpsDetail: l10n.agentBackgroundRoutingFollowUpsDetail,
      pausedStatus: l10n.agentBackgroundPausedStatus,
      needsAttentionStatus: l10n.agentBackgroundNeedsAttentionStatus,
    );
  }

  final String title;
  final String pausedTitle;
  final String needsAttentionTitle;
  final String stageIdle;
  final String stageProcessing;
  final String stageQueued;
  final String stageRetrying;
  final String stagePaused;
  final String stageCompleted;
  final String stageNeedsAttention;
  final String stageAnalyzingMedia;
  final String stageGeneratingCard;
  final String stageUpdatingKnowledge;
  final String stagePreparingComment;
  final String stageRoutingFollowUps;
  final String Function(Object running, Object pending, Object retrying)
      taskSummary;
  final String Function(Object count) taskDetail;
  final String noTasks;
  final String starting;
  final String completedDetail;
  final String failedDetail;
  final String pausedDetail;
  final String queuedDetail;
  final String retryingDetail;
  final String analyzeMediaDetail;
  final String generatingCardDetail;
  final String updatingKnowledgeDetail;
  final String preparingCommentDetail;
  final String routingFollowUpsDetail;
  final String Function(Object summary) pausedStatus;
  final String Function(Object summary) needsAttentionStatus;
}

String _detailFor({
  required TaskActivitySnapshot taskSnapshot,
  required AgentActivityMessageModel? latestMessage,
  required AgentBackgroundRunState state,
  required AgentBackgroundStatusLabels labels,
}) {
  final messageContent = _trimToSingleLine(latestMessage?.content);
  if (messageContent != null) return messageContent;

  if (taskSnapshot.hasActiveTasks) {
    return labels.taskDetail(taskSnapshot.total);
  }

  return switch (state) {
    AgentBackgroundRunState.failed => labels.failedDetail,
    AgentBackgroundRunState.completed => labels.completedDetail,
    AgentBackgroundRunState.paused => labels.pausedDetail,
    AgentBackgroundRunState.active => labels.starting,
    AgentBackgroundRunState.idle => labels.noTasks,
  };
}

String _summaryFor({
  required TaskActivitySnapshot taskSnapshot,
  required AgentActivityMessageModel? latestMessage,
  required String fallbackStage,
  required String detail,
  required AgentBackgroundStatusLabels labels,
}) {
  final messageTitle = _firstNonBlank([
    latestMessage?.title,
    latestMessage?.agentName,
  ]);
  final messageContent = _trimToSingleLine(latestMessage?.content);
  if (messageContent != null) return messageContent;
  if (messageTitle != null) return messageTitle;
  if (taskSnapshot.hasActiveTasks) return labels.taskDetail(taskSnapshot.total);
  if (detail.isNotBlank) return detail;
  return fallbackStage;
}

String formatAgentTaskSummary({
  required int pending,
  required int processing,
  required int retrying,
  AgentBackgroundStatusLabels labels = const AgentBackgroundStatusLabels(),
}) {
  return labels.taskSummary(processing, pending, retrying);
}

String _statusTextFor({
  required AgentBackgroundRunState state,
  required int remainingTasks,
  required String taskSummary,
  required AgentBackgroundStatusLabels labels,
}) {
  return switch (state) {
    AgentBackgroundRunState.failed => remainingTasks > 0
        ? labels.needsAttentionStatus(taskSummary)
        : labels.stageNeedsAttention,
    AgentBackgroundRunState.paused => remainingTasks > 0
        ? labels.pausedStatus(taskSummary)
        : labels.pausedDetail,
    AgentBackgroundRunState.active =>
      remainingTasks > 0 ? taskSummary : labels.stageProcessing,
    AgentBackgroundRunState.completed => labels.stageCompleted,
    AgentBackgroundRunState.idle => labels.stageIdle,
  };
}

String _titleForState(
  AgentBackgroundRunState state,
  AgentBackgroundStatusLabels labels,
) {
  return switch (state) {
    AgentBackgroundRunState.failed => labels.needsAttentionTitle,
    AgentBackgroundRunState.paused => labels.pausedTitle,
    AgentBackgroundRunState.completed ||
    AgentBackgroundRunState.active ||
    AgentBackgroundRunState.idle =>
      labels.title,
  };
}

String _stageForState(
  AgentBackgroundRunState state,
  AgentBackgroundStatusLabels labels,
) {
  return switch (state) {
    AgentBackgroundRunState.failed => labels.stageNeedsAttention,
    AgentBackgroundRunState.completed => labels.stageCompleted,
    AgentBackgroundRunState.paused => labels.stagePaused,
    AgentBackgroundRunState.active => labels.stageProcessing,
    AgentBackgroundRunState.idle => labels.stageIdle,
  };
}

String? _localizeKnownStatusText(
  String? value,
  AgentBackgroundStatusLabels labels,
) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return switch (trimmed) {
    'Idle' => labels.stageIdle,
    'Processing' => labels.stageProcessing,
    'Queued' => labels.stageQueued,
    'Waiting to retry' => labels.stageRetrying,
    'Paused' => labels.stagePaused,
    'Completed' => labels.stageCompleted,
    'Needs attention' => labels.stageNeedsAttention,
    'Analyzing media' => labels.stageAnalyzingMedia,
    'Generating card' => labels.stageGeneratingCard,
    'Updating knowledge' => labels.stageUpdatingKnowledge,
    'Preparing comment' => labels.stagePreparingComment,
    'Routing follow-ups' => labels.stageRoutingFollowUps,
    'No background tasks.' => labels.noTasks,
    'Processing is starting.' => labels.starting,
    'All background tasks finished.' => labels.completedDetail,
    'Processing stopped with an error.' => labels.failedDetail,
    'Processing is paused and will continue later.' => labels.pausedDetail,
    'Background time expired. Memex will continue later.' ||
    'iOS paused background processing. Memex will continue later.' =>
      labels.pausedDetail,
    'Waiting for the next processing step.' ||
    'Waiting for background processing to start.' ||
    'Waiting for the next background window.' =>
      labels.queuedDetail,
    'The current step will retry automatically.' => labels.retryingDetail,
    'Reading attachments and local context.' => labels.analyzeMediaDetail,
    'Turning the record into a timeline card.' => labels.generatingCardDetail,
    'Updating local knowledge and memory.' => labels.updatingKnowledgeDetail,
    'Preparing an assistant follow-up.' => labels.preparingCommentDetail,
    'Checking follow-up actions for this card.' =>
      labels.routingFollowUpsDetail,
    _ => trimmed,
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

String _defaultTaskSummary(Object running, Object pending, Object retrying) {
  return 'Running $running, Pending $pending, Retry $retrying';
}

String _defaultTaskDetail(Object count) {
  return 'Processing $count queued task(s).';
}

String _defaultPausedStatus(Object summary) {
  return 'Paused - $summary';
}

String _defaultNeedsAttentionStatus(Object summary) {
  return 'Needs attention - $summary';
}

extension on String {
  bool get isNotBlank => trim().isNotEmpty;
}
