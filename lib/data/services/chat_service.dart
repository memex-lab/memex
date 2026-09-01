import 'dart:async';
import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/memex_skill_host_agent/memex_skill_host_agent.dart';
import 'package:memex/agent/run_mode/agent_run_mode.dart';
import 'package:memex/agent/pure_skill_host_agent/pure_skill_host_agent.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/super_agent/super_agent.dart';
import 'package:memex/agent/super_agent/subagent/delegate_progress.dart';
import 'package:memex/data/services/agent_image_attachment.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/chat_run_registry.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/location_context_service.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/token_usage_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:memex/data/model/chat_events.dart';

export 'package:memex/data/model/chat_events.dart';

@visibleForTesting
String chatErrorUserNotLoggedIn() => UserStorage.l10n.userIdNotFound;

@visibleForTesting
String chatErrorEmptyMessage() => UserStorage.l10n.unknownError;

@visibleForTesting
String chatErrorOperationFailed(Object error) =>
    UserStorage.l10n.operationFailed('$error');

// --- Chat Service ---

class _ChatDelegateProgressSink implements DelegateProgressSink {
  _ChatDelegateProgressSink(
    this._run,
    this._artifactCollector,
    this._onArtifactsProduced,
  );

  final ActiveChatRun _run;
  final ChatTurnArtifactCollector _artifactCollector;
  final void Function(List<ChatArtifact> artifacts) _onArtifactsProduced;
  final Map<String, List<String>> _pendingDelegateCallIdsByBrief = {};
  final Map<String, String> _delegateParentIds = {};
  final Map<String, int> _childTraceCounters = {};
  final Map<String, List<String>> _pendingChildTraceIdsByTool = {};

  void registerDelegateToolCall({
    required String callId,
    required String arguments,
  }) {
    final taskBrief = _taskBriefFromArguments(arguments);
    if (taskBrief == null || taskBrief.isEmpty) return;
    (_pendingDelegateCallIdsByBrief[taskBrief] ??= <String>[]).add(callId);
  }

  @override
  void delegateStarted(DelegateProgress progress) {
    final parentCallId = _takePendingDelegateCallId(progress.taskBrief);
    if (parentCallId == null) return;
    _delegateParentIds[progress.delegateRunId] = parentCallId;
    final event = ChatTraceStartedEvent(
      id: parentCallId,
      kind: ChatTraceKind.delegate,
      name: 'delegate_to_subagent',
      args: progress.taskBrief,
      label: progress.childName,
    );
    _run.add(event);
  }

  @override
  void childToolStarted({
    required DelegateProgress progress,
    required String toolName,
    required String arguments,
  }) {
    final parentId = _delegateParentIds[progress.delegateRunId];
    if (parentId == null) return;
    final childTraceId = _nextChildTraceId(progress.delegateRunId, toolName);
    final event = ChatTraceStartedEvent(
      id: childTraceId,
      parentId: parentId,
      kind: ChatTraceKind.tool,
      name: toolName,
      args: arguments,
      label: progress.childName,
    );
    _run.add(event);
  }

  @override
  void childToolFinished({
    required DelegateProgress progress,
    required FunctionExecutionResult result,
  }) {
    final parentId = _delegateParentIds[progress.delegateRunId];
    final childTraceId = _takeChildTraceId(progress.delegateRunId, result.name);
    if (parentId == null || childTraceId == null) return;
    final resultText = _toolResultText(result);
    final artifacts = result.isError
        ? const <ChatArtifact>[]
        : _artifactCollector.addFromToolResult(
            metadata: result.metadata,
            sourceToolCallId: result.id,
          );
    _run.add(ChatTraceCompletedEvent(
      id: childTraceId,
      result: _preview(resultText, 300),
      isError: result.isError,
      metadata: result.metadata,
    ));
    _onArtifactsProduced(artifacts);
  }

  @override
  void delegateFinished({
    required DelegateProgress progress,
    required String status,
    required String summary,
  }) {
    final parentId = _delegateParentIds.remove(progress.delegateRunId);
    if (parentId == null) return;
    _childTraceCounters.remove(progress.delegateRunId);
    _pendingChildTraceIdsByTool
        .removeWhere((key, _) => key.startsWith('${progress.delegateRunId}:'));
    final event = ChatTraceCompletedEvent(
      id: parentId,
      status: status,
      result: summary,
      isError: status == 'failed',
    );
    _run.add(event);
  }

  String _toolResultText(FunctionExecutionResult result) {
    final dynamic content = result.content;
    if (content is List) {
      return content.map((e) {
        if (e is TextPart) return e.text;
        return e.toString();
      }).join('\n');
    } else if (content is TextPart) {
      return content.text;
    } else {
      return content.toString();
    }
  }

  String? _taskBriefFromArguments(String arguments) {
    try {
      final decoded = jsonDecode(arguments);
      if (decoded is! Map) return null;
      final taskContent = decoded['task_content'];
      if (taskContent is! List || taskContent.isEmpty) return null;
      final parts = <String>[];
      for (final rawItem in taskContent) {
        if (rawItem is! Map) continue;
        final type = rawItem['type']?.toString();
        if (type == 'text') {
          final text = rawItem['text']?.toString().trim();
          if (text != null && text.isNotEmpty) {
            parts.add(text);
          }
        } else if (type == 'asset') {
          final ref = rawItem['ref']?.toString().trim();
          if (ref != null && ref.isNotEmpty) {
            parts.add('Attachment: $ref');
          }
        }
      }
      final brief = parts.join('\n\n').trim();
      return brief.isEmpty ? null : brief;
    } catch (_) {
      return null;
    }
  }

  String? _takePendingDelegateCallId(String taskBrief) {
    final calls = _pendingDelegateCallIdsByBrief[taskBrief];
    if (calls == null || calls.isEmpty) return null;
    final callId = calls.removeAt(0);
    if (calls.isEmpty) {
      _pendingDelegateCallIdsByBrief.remove(taskBrief);
    }
    return callId;
  }

  String _nextChildTraceId(String delegateRunId, String toolName) {
    final next = (_childTraceCounters[delegateRunId] ?? 0) + 1;
    _childTraceCounters[delegateRunId] = next;
    final id = '$delegateRunId/tool/$next';
    (_pendingChildTraceIdsByTool[_childTraceKey(delegateRunId, toolName)] ??=
            <String>[])
        .add(id);
    return id;
  }

  String? _takeChildTraceId(String delegateRunId, String toolName) {
    final key = _childTraceKey(delegateRunId, toolName);
    final ids = _pendingChildTraceIdsByTool[key];
    if (ids == null || ids.isEmpty) return null;
    final id = ids.removeAt(0);
    if (ids.isEmpty) {
      _pendingChildTraceIdsByTool.remove(key);
    }
    return id;
  }

  String _childTraceKey(String delegateRunId, String toolName) =>
      '$delegateRunId:$toolName';
}

String _preview(String text, int maxChars) {
  if (text.length <= maxChars) return text;
  return '${text.substring(0, maxChars)}...';
}

bool isActiveChatTurnTaskForSession({
  required String sessionId,
  required String taskType,
  required String expectedTaskType,
  required String status,
  required String? payloadJson,
}) {
  if (sessionId.isEmpty) return false;
  if (taskType != expectedTaskType) return false;
  if (!const {'pending', 'processing', 'retrying'}.contains(status)) {
    return false;
  }

  try {
    final payload = payloadJson == null || payloadJson.isEmpty
        ? null
        : jsonDecode(payloadJson);
    if (payload is! Map) return false;
    return payload['session_id'] == sessionId;
  } catch (_) {
    return false;
  }
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;
  ChatService._internal();

  final Logger _logger = getLogger('ChatService');
  FileSystemService get _fileService => FileSystemService.instance;
  ChatSessionStorage get _chatStorage => ChatSessionStorage.instance;
  final Uuid _uuid = const Uuid();
  static const String _superAgentChatTurnTaskType =
      'super_agent_chat_turn_task';
  static const String _activeAgentStateSessionIdKey =
      'active_agent_state_session_id';
  static const String _runningChatTurnIdKey = 'running_chat_turn_id';

  /// In-flight runs keyed by session id. Runs are owned by the service so a
  /// closed chat dialog does not interrupt them; a reopened dialog can
  /// re-attach and replay what it missed.
  final ChatRunRegistry _runRegistry = ChatRunRegistry();

  /// Whether [sessionId] has an in-memory run, or a persisted chat turn waiting
  /// to resume after app restart.
  Future<bool> hasActiveRun(String? sessionId) async {
    if (sessionId == null || sessionId.isEmpty) return false;
    if (_runRegistry.isActive(sessionId)) return true;
    return _hasQueuedChatTurn(sessionId);
  }

  /// Replays everything the in-flight run emitted so far, then continues
  /// live. If the app restarted while this session had a persisted queued
  /// turn, creates a placeholder run so the task handler can publish into the
  /// same stream once it resumes.
  Stream<ChatEvent> attachToActiveRun(String sessionId) async* {
    final activeRun = _runRegistry[sessionId];
    if (activeRun != null) {
      yield* activeRun.attach();
      return;
    }

    if (!await _hasQueuedChatTurn(sessionId)) return;
    yield* _runRegistry.getOrStart(sessionId).attach();
  }

  Future<bool> _hasQueuedChatTurn(String sessionId) async {
    try {
      final tasks = await LocalTaskExecutor.instance.getTasks(limit: 200);
      return tasks.any(
        (task) => isActiveChatTurnTaskForSession(
          sessionId: sessionId,
          taskType: task.type,
          expectedTaskType: _superAgentChatTurnTaskType,
          status: task.status,
          payloadJson: task.payload,
        ),
      );
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to query queued chat turn for session $sessionId',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<String> refreshAgentStateForSession(String sessionId) async {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw StateError('User not logged in');
    }
    if (sessionId.isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'must not be empty');
    }
    if (await hasActiveRun(sessionId)) {
      throw StateError(
          'Cannot refresh agent state while a chat turn is active');
    }

    final sessionData = await _chatStorage.loadMetadata(userId, sessionId);
    final now = DateTime.now();
    final newStateSessionId = '${sessionId}_state_${_uuid.v4()}';
    final state = await loadOrCreateAgentState(newStateSessionId, {
      'userId': userId,
      'scene': sessionData['scene'],
      'sceneId': sessionData['scene_id'],
      'chat_session_id': sessionId,
      'refreshed_from_chat_session': sessionId,
      'refreshed_at': now.toIso8601String(),
      'refreshed_at_local': formatLocalDateTimeWithZone(now),
      'refreshed_at_unix_seconds': unixSecondsFromDateTime(now),
    });
    await saveAgentState(state);

    await _chatStorage.updateMetadata(userId, sessionId, (metadata) {
      metadata[_activeAgentStateSessionIdKey] = newStateSessionId;
      metadata['agent_state_refreshed_at'] = now.toIso8601String();
      metadata['agent_state_refreshed_at_local'] =
          formatLocalDateTimeWithZone(now);
      metadata['agent_state_refreshed_at_unix_seconds'] =
          unixSecondsFromDateTime(now);
      metadata.remove('total_usage');
      return metadata;
    });
    return newStateSessionId;
  }

  /// Send a message and get a stream of events.
  ///
  /// When [isQuickQuery] is true, the agent operates in read-only mode
  /// (filtered tools/skills), but the session is still persisted normally.
  Stream<ChatEvent> sendMessage(
    String message, {
    String? sessionId,
    String? agentName = 'memex_agent',
    String? scene = 'assistant',
    String? sceneId,
    List<Map<String, String>>? refs,
    List<XFile> images = const [],
    Map<String, String>? imageOriginalFilenames,
    bool isQuickQuery = false,
    String runMode = 'auto',
  }) async* {
    _logger.info(
      'sendMessage: sessionId=$sessionId, message=$message, refs=${refs?.length}',
    );

    final turnId = _uuid.v4();
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      yield ChatErrorEvent(turnId, chatErrorUserNotLoggedIn());
      return;
    }

    String finalSessionId = sessionId ?? '';
    final userMessageTime = DateTime.now();
    final trimmedMessage = message.trim();
    final preparedImages = <AgentImageAttachment>[];
    String agentStateSessionId = '';

    try {
      for (final image in images) {
        preparedImages.add(
          await _prepareChatImage(
            userId: userId,
            image: image,
            originalName: imageOriginalFilenames?[image.path],
          ),
        );
      }
    } catch (e) {
      _logger.severe('Failed to prepare chat image attachment', e);
      yield ChatErrorEvent(turnId, chatErrorOperationFailed(e));
      return;
    }

    if (trimmedMessage.isEmpty && preparedImages.isEmpty) {
      yield ChatErrorEvent(turnId, chatErrorEmptyMessage());
      return;
    }

    final sessionContent = _buildSessionUserContent(
      trimmedMessage,
      preparedImages,
    );

    // 1. Session Management
    try {
      final sessionExists = finalSessionId.isNotEmpty &&
          await _chatStorage.sessionExists(userId, finalSessionId);
      if (!sessionExists) {
        if (finalSessionId.isNotEmpty) {
          _logger.warning(
            'Chat session $finalSessionId no longer exists; creating a new '
            'session so this turn remains persistent',
          );
        }
        finalSessionId = await _createSession(
          userId,
          agentName,
          sessionContent,
          isQuickQuery: isQuickQuery,
          scene: scene,
          sceneId: sceneId,
          createdAt: userMessageTime,
        );
      }

      // Notify UI of the active session ID immediately
      yield ChatSessionCreatedEvent(finalSessionId);
      agentStateSessionId =
          await _resolveAgentStateSessionId(userId, finalSessionId);

      // Save User Message
      await _addMessageToSession(
        userId,
        finalSessionId,
        'user',
        sessionContent,
        refs: refs,
        isQuickQuery: isQuickQuery,
        timestamp: userMessageTime,
        turnId: turnId,
      );

      // Log chat event
      try {
        await _fileService.eventLogService.logEvent(
          userId: userId,
          eventType: 'user_chat',
          description: 'User sent message to agent',
          metadata: {
            'agent_name': agentName ?? 'memex_agent',
            'scene': scene ?? 'assistant',
            'scene_id': sceneId,
            'session_id': finalSessionId,
            'message': trimmedMessage,
            'message_local_time': formatLocalDateTimeWithZone(userMessageTime),
            'message_unix_seconds': unixSecondsFromDateTime(userMessageTime),
            'has_refs': refs != null && refs.isNotEmpty,
            'has_images': preparedImages.isNotEmpty,
            'is_quick_query': isQuickQuery,
            'run_mode': runMode,
          },
        );
      } catch (e) {
        // Event logging failure should not break chat
      }
    } catch (e) {
      _logger.severe('Failed to manage session', e);
      yield ChatErrorEvent(turnId, chatErrorOperationFailed(e));
      return;
    }

    final runAlreadyActive = _runRegistry.isActive(finalSessionId);
    final run = _runRegistry.getOrStart(finalSessionId);

    try {
      final previousTaskId = await LocalTaskExecutor.instance.getLastTaskByType(
        _superAgentChatTurnTaskType,
      );
      final taskId = await LocalTaskExecutor.instance.enqueueTask(
        userId: userId,
        taskType: _superAgentChatTurnTaskType,
        payload: {
          'turn_id': turnId,
          'session_id': finalSessionId,
          'message': trimmedMessage,
          'agent_name': agentName ?? 'memex_agent',
          'scene': scene ?? 'assistant',
          'scene_id': sceneId,
          'refs': refs,
          'images': preparedImages.map((image) => image.toTaskJson()).toList(),
          'is_quick_query': isQuickQuery,
          'run_mode': runMode,
          'user_message_time': userMessageTime.toIso8601String(),
          'agent_state_session_id': agentStateSessionId,
        },
        // A chat turn is user-visible and should start promptly, but keep it
        // below system maintenance work that may use higher explicit priority.
        priority: 10,
        bizId: 'chat_turn:$finalSessionId:$turnId',
        // Super Agent turns form one global sequence. This is an ordering
        // barrier, not a hard dependency: a failed turn must not poison every
        // later user message.
        waitFor: previousTaskId == null ? null : [previousTaskId],
      );
      try {
        await AgentForegroundTaskTracker.instance.trackTask(taskId);
      } catch (trackingError, trackingStack) {
        _logger.warning(
          'Failed to track Super Agent chat turn for foreground updates',
          trackingError,
          trackingStack,
        );
      }
    } catch (e, st) {
      _logger.severe('Failed to enqueue chat turn', e, st);
      run.add(ChatErrorEvent(turnId, chatErrorOperationFailed(e)));
      run.close();
    }

    if (runAlreadyActive) {
      // The dialog already has a live subscription for this session. This call
      // only persists/enqueues the next turn; returning live events here would
      // create a second UI subscription and duplicate or steal stream handling.
      return;
    }

    yield* run.attach();
  }

  Future<void> handleSuperAgentChatTurnTask(
    String userId,
    Map<String, dynamic> payload,
    TaskContext taskContext,
  ) async {
    final sessionId = payload['session_id'] as String;
    final turnId = payload['turn_id'] as String;
    final message = payload['message'] as String? ?? '';
    final agentName = payload['agent_name'] as String? ?? 'memex_agent';
    final scene = payload['scene'] as String? ?? 'assistant';
    final sceneId = payload['scene_id'] as String?;
    final refs = _decodeRefs(payload['refs']);
    final preparedImages = _decodePreparedImages(payload['images']);
    final isQuickQuery = payload['is_quick_query'] as bool? ?? false;
    final runMode = payload['run_mode'] as String? ?? 'auto';
    final userMessageTime =
        tryParseDateTime(payload['user_message_time']) ?? DateTime.now();
    final agentStateSessionId =
        (payload['agent_state_session_id'] as String?)?.trim().isNotEmpty ==
                true
            ? (payload['agent_state_session_id'] as String).trim()
            : await _resolveAgentStateSessionId(userId, sessionId);

    if (await _sessionHasAssistantForTurn(userId, sessionId, turnId)) {
      _logger.info(
        'Skipping already-completed chat turn $turnId for session $sessionId',
      );
      if (await _shouldCloseRunAfterTask(taskContext.taskId)) {
        _runRegistry[sessionId]?.close();
      }
      return;
    }

    final run = _runRegistry.getOrStart(sessionId);

    await _runSuperAgentChatTurn(
      userId: userId,
      sessionId: sessionId,
      turnId: turnId,
      taskId: taskContext.taskId,
      message: message,
      agentName: agentName,
      scene: scene,
      sceneId: sceneId,
      refs: refs,
      preparedImages: preparedImages,
      isQuickQuery: isQuickQuery,
      runMode: runMode,
      userMessageTime: userMessageTime,
      agentStateSessionId: agentStateSessionId,
      run: run,
    );
  }

  Future<void> _runSuperAgentChatTurn({
    required String userId,
    required String sessionId,
    required String turnId,
    required String taskId,
    required String message,
    required String agentName,
    required String scene,
    required String? sceneId,
    required List<Map<String, String>>? refs,
    required List<AgentImageAttachment> preparedImages,
    required bool isQuickQuery,
    required String runMode,
    required DateTime userMessageTime,
    required String agentStateSessionId,
    required ActiveChatRun run,
  }) async {
    // 2. Initialize Agent
    StatefulAgent? agent;
    AgentController? controller;
    SkillSyncResult? skillSync;
    SuperAgentPreMintedRecordHook? preMintedRecordHook;

    try {
      // Check if this session belongs to a custom agent by reading session metadata,
      // then load the latest config from CustomAgentConfigService.
      CustomAgentConfig? customAgentCfg;
      if (sessionId.isNotEmpty) {
        final isCustom = await _isCustomAgentSession(userId, sessionId);
        if (isCustom && agentName.isNotEmpty) {
          final configs = await CustomAgentConfigService.instance.loadAll(
            userId,
          );
          customAgentCfg =
              configs.where((c) => c.agentName == agentName).firstOrNull;
        }
      }

      final agentIdForLLM =
          customAgentCfg?.llmConfigKey ?? AgentDefinitions.chatAgent;
      final resources = await UserStorage.getAgentLLMResources(
        agentIdForLLM,
        defaultClientKey:
            customAgentCfg?.llmConfigKey ?? LLMConfig.defaultClientKey,
      );
      final client = resources.client;
      final modelConfig = resources.modelConfig;
      // Load State
      final state = await loadOrCreateAgentState(agentStateSessionId, {
        'userId': userId,
        'scene': scene,
        'sceneId': sceneId,
        'chat_session_id': sessionId,
      });
      state.metadata['userId'] = userId;
      state.metadata['scene'] = scene;
      state.metadata['sceneId'] = sceneId;
      state.metadata['chat_session_id'] = sessionId;
      // Refresh per-turn: the user can switch run modes between messages.
      state.metadata[AgentRunMode.metadataKey] = runMode;

      controller = AgentController();

      if (customAgentCfg != null) {
        // Recreate the same agent type used by custom_agent_task_handler.
        final skillDir = _fileService.resolveSkillPath(
          userId,
          customAgentCfg.skillDirectoryPath,
        );
        final workingDirAbs = await _fileService.resolveWorkingDirectory(
          userId,
          customAgentCfg.workingDirectory,
        );

        // Sync skill directory into workingDirectory if it's outside,
        // so file tools (Read, LS, etc.) can access skill files.
        skillSync = await _fileService.syncSkillsIfNeeded(
          skillAbsPath: skillDir,
          workingDirAbsPath: workingDirAbs,
        );

        switch (customAgentCfg.hostAgentType) {
          case HostAgentType.pure:
            agent = await PureSkillHostAgent.createAgent(
              client: client,
              modelConfig: modelConfig,
              userId: userId,
              name: agentName,
              state: state,
              skillDirectoryPath: skillSync.effectivePath,
              workingDirectory: workingDirAbs,
              controller: controller,
              additionalSystemPrompt: customAgentCfg.systemPrompt,
            );
            break;
          case HostAgentType.memex:
            agent = await MemexSkillHostAgent.createAgent(
              client: client,
              modelConfig: modelConfig,
              userId: userId,
              name: agentName,
              state: state,
              skillDirectoryPath: skillSync.effectivePath,
              workingDirectory: workingDirAbs,
              controller: controller,
              additionalSystemPrompt: customAgentCfg.systemPrompt,
            );
            break;
        }
      } else {
        preMintedRecordHook = isQuickQuery
            ? null
            : SuperAgentPreMintedRecordHook(
                userId: userId,
                turnId: turnId,
              );
        // Default: use SuperAgent for normal chat sessions. Behavioral
        // guidance (orchestration, truthfulness, comprehensive correction,
        // tone, judgment) lives in superAgentSystemPrompt; only the dynamic
        // language instruction is appended per session here.
        var additionalSystemPrompt =
            """## Language\n${UserStorage.l10n.chatLanguageInstruction}""";

        final forceActiveSkills = <String>[];
        if (scene == 'assistant_timeline_card_detail') {
          forceActiveSkills.add('manage_timeline_card');
          forceActiveSkills.add('manage_pkm');
        } else if (scene == 'insight_card_chat') {
          forceActiveSkills.add('update_knowledge_insight');
        }

        agent = await SuperAgent.createAgent(
          client: client,
          modelConfig: modelConfig,
          userId: userId,
          name: agentName,
          state: state,
          controller: controller,
          extraHooks: [
            if (preMintedRecordHook != null) preMintedRecordHook,
          ],
          forceActiveSkills: forceActiveSkills,
          quickQuery: isQuickQuery,
          additionalSystemPrompt: additionalSystemPrompt,
        );
      }
    } catch (e) {
      _logger.severe('Failed to initialize agent', e);
      run.add(ChatErrorEvent(turnId, chatErrorOperationFailed(e)));
      if (await _shouldCloseRunAfterTask(taskId)) {
        run.close();
      }
      rethrow;
    }

    // 3. Setup Listeners & Run
    var persistedArtifacts = const <ChatArtifact>[];
    try {
      persistedArtifacts = await _chatStorage.loadArtifactsForTurn(
        userId,
        sessionId,
        turnId,
      );
    } catch (e, st) {
      _logger.warning(
        'Failed to restore artifacts for turn $turnId in session $sessionId',
        e,
        st,
      );
    }
    final artifactCollector = ChatTurnArtifactCollector(
      sourceRunId: turnId,
      initialArtifacts: persistedArtifacts,
    );
    var artifactWriteQueue = Future<void>.value();

    void persistAndEmitArtifacts(List<ChatArtifact> artifacts) {
      if (artifacts.isEmpty) return;

      artifactWriteQueue = artifactWriteQueue.then((_) async {
        await _addMessageToSession(
          userId,
          sessionId,
          'artifact',
          const [],
          artifacts: artifacts.map((artifact) => artifact.toJson()).toList(),
          timestamp: artifacts.first.createdAt,
          turnId: turnId,
        );
        if (!run.isClosed) {
          // Artifact messages are already persisted. Live listeners should see
          // them immediately after the append, but reattached dialogs rebuild
          // them from JSONL history instead of replaying this event.
          run.add(ChatArtifactsEvent(turnId, artifacts), replay: false);
        }
      }).catchError((Object e, StackTrace st) {
        _logger.warning(
          'Failed to persist chat artifact message for session $sessionId',
          e,
          st,
        );
      });
    }

    Future<void> waitForArtifactWrites() => artifactWriteQueue;

    final progressSink = _ChatDelegateProgressSink(
      run,
      artifactCollector,
      persistAndEmitArtifacts,
    );

    // Forward events from agent controller to the run channel
    _setupControllerListeners(
      controller,
      run,
      userId,
      sessionId,
      turnId,
      taskId,
      progressSink,
      artifactCollector,
      persistAndEmitArtifacts,
      waitForArtifactWrites,
    );

    // Build scene context reminder
    String sceneContext = "";
    switch (scene) {
      case 'super_agent_home':
        sceneContext = "";
        break;
      case 'assistant_timeline_card_detail':
        sceneContext =
            "The user is currently viewing a **Timeline Card Detail Page**. They may want to edit, analyze, or discuss this specific card.";
        break;
      case 'update_knowledge_insight':
      case 'insight_card_chat':
        sceneContext =
            "The user is currently on the **Knowledge Insights Page**. They may want to update insights, discuss existing insight cards, or generate new knowledge summaries.";
        break;
      default:
        sceneContext = "";
    }

    if (runMode == AgentRunMode.confirm.wireName) {
      const modeContext =
          "Run mode: ASK-FIRST. Every mutating tool call (records, cards, "
          "PKM/file writes, reminders, deletions) pauses for explicit in-app "
          "user approval before executing. Propose actions normally and do "
          "NOT additionally ask for permission in text — the approval card is "
          "the confirmation. If a tool result says the user declined, do not "
          "retry the same call; acknowledge and adjust.";
      sceneContext =
          sceneContext.isEmpty ? modeContext : "$sceneContext\n\n$modeContext";
    }

    final activeAgent = agent;
    final runningTurnId =
        activeAgent.state.metadata[_runningChatTurnIdKey] as String?;
    final resumeExistingRun =
        activeAgent.state.isRunning && runningTurnId == turnId;
    if (activeAgent.state.isRunning && !resumeExistingRun) {
      _logger.warning(
        'Ignoring stale SuperAgent running state, chatSessionId:$sessionId, '
        'stateSessionId:${activeAgent.state.sessionId}, '
        'stateTurnId:$runningTurnId, payloadTurnId:$turnId',
      );
      activeAgent.state.isRunning = false;
      activeAgent.state.metadata.remove(_runningChatTurnIdKey);
      await saveAgentState(activeAgent.state);
    }
    if (resumeExistingRun) {
      _logger.info(
        'SuperAgent resume, chatSessionId:$sessionId, '
        'stateSessionId:${activeAgent.state.sessionId}, turnId:$turnId',
      );
    } else {
      activeAgent.state.metadata[_runningChatTurnIdKey] = turnId;
      await saveAgentState(activeAgent.state);
    }

    List<LLMMessage> userMessages = const [];
    if (!resumeExistingRun) {
      CurrentLocationContext? locationContext;
      String? locationContextReminder;
      try {
        locationContext =
            await LocationContextService.instance.getCurrentContext();
        locationContextReminder =
            locationContext.toAgentSystemReminderContent();
      } catch (e) {
        _logger.warning('Failed to decorate chat with location context: $e');
      }

      // Per-turn context (message time, scene, location, refs) is
      // folded into a SINGLE <system-reminder> block at the head of this turn's
      // user message — rather than scattered across separate systemReminders
      // entries (which the agent loop would each wrap in its own
      // <system-reminder> tag).
      final referencedContent = (refs != null && refs.isNotEmpty)
          ? 'The user opened this chat from the following in-app reference. '
              'Treat it as the current page context for understanding words like '
              '"this", "this card", or "this insight", and use the target IDs if '
              'the user asks to update or organize the referenced content:\n${refs.map(
                    (r) =>
                        'Title: ${r['title']}\nType: ${r['type'] ?? 'unknown'}\nContent: ${r['content']}',
                  ).join('\n\n')}'
          : null;

      final reminderSections = <String>[
        // Two distinct facts: when the message was sent (stays fixed on
        // reprocessing) vs the current processing moment (becomes "now" on
        // reprocessing). They coincide for a live turn.
        'User Message Time: ${formatLocalDateTimeWithZone(userMessageTime)}',
        'Current Local Time: ${formatLocalDateTimeWithZone(DateTime.now())}',
        if (locationContextReminder != null &&
            locationContextReminder.isNotEmpty)
          locationContextReminder.trim(),
        if (sceneContext.isNotEmpty) sceneContext.trim(),
        if (referencedContent != null) referencedContent,
      ];
      final combinedReminder =
          '<system-reminder>\n${reminderSections.join('\n\n')}\n</system-reminder>';

      final userContentParts = <UserContentPart>[
        TextPart(combinedReminder),
        TextPart(
          message.isEmpty
              ? 'User sent ${preparedImages.length} image attachment(s).'
              : message,
        ),
      ];
      final inlinedImageFileNames = <String>[];
      for (var i = 0; i < preparedImages.length; i++) {
        final image = preparedImages[i];
        final inline = await _inlinePreparedImage(image);
        userContentParts.add(TextPart(
          buildAgentImageAttachmentReminder(
            i,
            image,
            imageLoaded: inline != null && inline.base64Data.isNotEmpty,
          ),
        ));
        if (inline != null && inline.base64Data.isNotEmpty) {
          userContentParts.add(ImagePart(inline.base64Data, inline.mimeType));
          inlinedImageFileNames.add(image.fsFilename);
        }
      }

      final userMessage = UserMessage(
        userContentParts,
        metadata: {
          // Lets the context compressor replace archived image bytes with
          // fs:// filename placeholders (see SuperAgentContextCompressor).
          if (inlinedImageFileNames.isNotEmpty)
            'image_fs_paths': inlinedImageFileNames,
        },
      );
      try {
        await preMintedRecordHook?.preallocate(activeAgent.state);
        if (preMintedRecordHook != null) {
          await saveAgentState(activeAgent.state);
        }
      } catch (e) {
        _logger.warning('Failed to pre-mint record fact_id: $e');
      }
      userMessages = [userMessage];
    }

    await DelegateProgressContext.run(progressSink, () async {
      try {
        final cancelToken = CancelToken();
        final agentFuture = resumeExistingRun
            ? activeAgent.resume(
                cancelToken: cancelToken,
              )
            : activeAgent.run(
                userMessages,
                cancelToken: cancelToken,
              );
        await agentFuture.whenComplete(() async {
          if (!activeAgent.state.isRunning &&
              activeAgent.state.metadata[_runningChatTurnIdKey] == turnId) {
            activeAgent.state.metadata.remove(_runningChatTurnIdKey);
            await saveAgentState(activeAgent.state);
          }
          // Sync skill changes back to the original directory if we made a copy.
          if (skillSync != null) {
            try {
              await _fileService.syncSkillsBack(skillSync);
            } catch (e) {
              _logger.warning('Failed to sync skills back: $e');
            }
          }
        });
      } catch (e) {
        _logger.severe('Agent run failed', e);
        if (!run.isClosed) {
          run.add(ChatErrorEvent(turnId, e.toString()));
          if (await _shouldCloseRunAfterTask(taskId)) {
            run.close();
          }
        }
        rethrow;
      }
    });
  }

  Future<AgentImageAttachment> _prepareChatImage({
    required String userId,
    required XFile image,
    required String? originalName,
  }) {
    return prepareChatImageAttachment(
      userId: userId,
      sourcePath: image.path,
      originalName: originalName,
    );
  }

  List<Map<String, dynamic>> _buildSessionUserContent(
    String message,
    List<AgentImageAttachment> images,
  ) {
    return [
      if (message.isNotEmpty) {'type': 'text', 'text': message},
      for (final image in images)
        {
          'type': 'image_url',
          'image_url': {'filePath': image.relativePath},
          'mime_type': image.mimeType,
          if (image.originalName != null && image.originalName!.isNotEmpty)
            'name': image.originalName,
        },
    ];
  }

  List<Map<String, String>>? _decodeRefs(dynamic raw) {
    if (raw is! List) return null;
    final refs = <Map<String, String>>[];
    for (final item in raw) {
      if (item is! Map) continue;
      refs.add({
        for (final entry in item.entries)
          if (entry.key != null && entry.value != null)
            entry.key.toString(): entry.value.toString(),
      });
    }
    return refs.isEmpty ? null : refs;
  }

  List<AgentImageAttachment> _decodePreparedImages(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => AgentImageAttachment.fromTaskJson(item))
        .whereType<AgentImageAttachment>()
        .toList();
  }

  Future<InlineAgentImage?> _inlinePreparedImage(
    AgentImageAttachment image,
  ) async {
    final absolutePath = _fileService.toAbsolutePath(image.relativePath);
    return inlineImageForLlm(
      absolutePath: absolutePath,
      fallbackMimeType: image.mimeType,
      logLabel: image.relativePath,
    );
  }

  void _setupControllerListeners(
    AgentController controller,
    ActiveChatRun stream,
    String userId,
    String sessionId,
    String turnId,
    String taskId,
    _ChatDelegateProgressSink progressSink,
    ChatTurnArtifactCollector artifactCollector,
    void Function(List<ChatArtifact> artifacts) onArtifactsProduced,
    Future<void> Function() waitForArtifactWrites,
  ) {
    // 1. Lifecycle Events
    controller.on((AgentStartedEvent event) {
      _logger.info('Agent started');
      stream.add(ChatAgentStartedEvent(turnId));
    });

    controller.on((AgentStoppedEvent event) async {
      _logger.info('Agent stopped');

      // Calculate usage stats
      int totalPrompt = 0;
      int totalCompletion = 0;
      int totalCached = 0;
      int totalEffectivePrompt = 0;
      int totalCachedForRate = 0;
      int totalTokens = 0;
      double totalCost = 0.0;
      // Within a single agent turn all calls share the same client.
      bool? turnCacheSemantics;

      for (final msg in event.modelMessages) {
        final u = msg.usage;
        if (u == null) {
          continue;
        }

        final p = u.promptTokens;
        final c = u.completionTokens;
        final ca = u.cachedToken;
        final sem = TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: event.agent.client,
          originalUsage: u.originalUsage,
        );
        turnCacheSemantics ??= sem;
        final effP = TokenUsageUtils.effectivePromptTokensOrNull(
          promptTokens: p,
          cachedTokens: ca,
          cachedTokensIncludedInPrompt: sem,
        );

        totalPrompt += p;
        totalCompletion += c;
        totalCached += ca;
        if (effP != null) {
          totalEffectivePrompt += effP;
          totalCachedForRate += ca;
        }
        totalTokens += u.totalTokens;

        // Calculate cost
        final cost = TokenUsageUtils.calculateCost(
          model: msg.model,
          promptTokens: p,
          completionTokens: c,
          cachedTokens: ca,
          thoughtTokens: u.thoughtToken,
          cachedTokensIncludedInPrompt: sem,
        )['total']!;
        totalCost += cost;
      }

      if (event.error != null) {
        if (!stream.isClosed) {
          stream.add(ChatAgentStoppedEvent(turnId));
          stream.add(ChatErrorEvent(turnId, event.error.toString()));
          if (await _shouldCloseRunAfterTask(taskId)) {
            stream.close();
          }
        }
        return;
      }

      // Handle success / final result
      String response = "Sorry, I couldn't generate a response.";
      if (event.modelMessages.isNotEmpty) {
        final lastMsg = event.modelMessages.last;
        if (lastMsg.textOutput != null) {
          response = lastMsg.textOutput!;
        }
      }

      final usage = {
        'prompt_tokens': totalPrompt,
        'completion_tokens': totalCompletion,
        'cached_tokens': totalCached,
        if (turnCacheSemantics != null)
          'cache_tokens_included_in_prompt': turnCacheSemantics,
        'total_tokens': totalTokens,
        'total_cost': totalCost,
      };

      // Save AI response with usage stats
      await waitForArtifactWrites();
      final responseTime = DateTime.now();
      final sessionTotalUsage =
          await _sessionHasAssistantForTurn(userId, sessionId, turnId)
              ? null
              : await _addMessageToSession(
                  userId,
                  sessionId,
                  'ai',
                  [
                    {'type': 'text', 'text': response},
                  ],
                  usage: usage,
                  timestamp: responseTime,
                  turnId: turnId,
                );

      // Emit Token Usage (Cumulative if available, else current turn)
      if (sessionTotalUsage != null) {
        stream.add(
          ChatTokenUsageEvent(
            promptTokens: sessionTotalUsage['prompt_tokens'] as int? ?? 0,
            completionTokens:
                sessionTotalUsage['completion_tokens'] as int? ?? 0,
            cachedTokens: sessionTotalUsage['cached_tokens'] as int? ?? 0,
            effectivePromptTokens: totalEffectivePrompt,
            cachedTokensForRate: totalCachedForRate,
            totalTokens: sessionTotalUsage['total_tokens'] as int? ?? 0,
            estimatedCost: sessionTotalUsage['total_cost'] as double? ?? 0.0,
          ),
        );
      } else if (totalTokens > 0) {
        // Fallback to single turn usage
        stream.add(
          ChatTokenUsageEvent(
            promptTokens: totalPrompt,
            completionTokens: totalCompletion,
            cachedTokens: totalCached,
            effectivePromptTokens: totalEffectivePrompt,
            cachedTokensForRate: totalCachedForRate,
            totalTokens: totalTokens,
            estimatedCost: totalCost,
          ),
        );
      }

      if (!stream.isClosed) {
        // Send a final empty chunk to mark isDone=true without duplicating text
        stream.add(ChatResponseChunkEvent(turnId, '', isDone: true));
        stream.add(ChatAgentStoppedEvent(turnId));
        if (await _shouldCloseRunAfterTask(taskId)) {
          stream.close();
        }
      }
    });

    // 2. Planning Events
    controller.on((PlanChangedEvent event) {
      String getStatusEmoji(String status) {
        switch (status.toLowerCase()) {
          case 'completed':
          case 'success':
          case 'done':
            return '✅';
          case 'active':
          case 'running':
          case 'inprogress':
            return '👉';
          case 'failed':
          case 'error':
            return '❌';
          case 'pending':
          default:
            return '⏳'; // Or ⬜
        }
      }

      final planText = event.plan.steps.map((t) {
        final emoji = getStatusEmoji(t.status.name);
        return '$emoji ${t.description}';
      }).join('\n\n');
      stream.add(ChatThoughtChunkEvent("Plan Updated:\n$planText"));
    });

    // 3. Thoughts & Chunks
    controller.on((LLMChunkEvent event) {
      if (event.response.thought != null &&
          event.response.thought!.isNotEmpty) {
        stream.add(ChatThoughtChunkEvent(event.response.thought!));
      }

      if (event.response.textOutput != null &&
          event.response.textOutput!.isNotEmpty) {
        stream.add(ChatResponseChunkEvent(turnId, event.response.textOutput!));
      }
    });

    // 4. Tool Call
    controller.on((BeforeToolCallEvent event) {
      if (event.functionCall.name == 'delegate_to_subagent') {
        progressSink.registerDelegateToolCall(
          callId: event.functionCall.id,
          arguments: event.functionCall.arguments,
        );
      }
      final traceEvent = ChatTraceStartedEvent(
        id: event.functionCall.id,
        kind: event.functionCall.name == 'delegate_to_subagent'
            ? ChatTraceKind.delegate
            : ChatTraceKind.tool,
        name: event.functionCall.name,
        args: event.functionCall.arguments.toString(),
      );
      stream.add(traceEvent);
    });

    // 5. Tool Result
    controller.on((AfterToolCallEvent event) {
      final dynamic content = event.result.content;
      String resultText;

      if (content is List) {
        resultText = content.map((e) {
          if (e is TextPart) return e.text;
          return e.toString();
        }).join('\n');
      } else if (content is TextPart) {
        resultText = content.text;
      } else {
        resultText = content.toString();
      }

      final resultPreview = _preview(resultText, 300);
      final artifacts = event.result.isError
          ? const <ChatArtifact>[]
          : artifactCollector.addFromToolResult(
              metadata: event.result.metadata,
              sourceToolCallId: event.result.id,
            );
      stream.add(
        ChatTraceCompletedEvent(
          id: event.result.id,
          result: resultPreview,
          isError: event.result.isError,
          metadata: event.result.metadata,
        ),
      );
      onArtifactsProduced(artifacts);
    });
  }

  Future<bool> _shouldCloseRunAfterTask(String taskId) async {
    final latestTaskId = await LocalTaskExecutor.instance.getLastTaskByType(
      _superAgentChatTurnTaskType,
    );
    return latestTaskId == taskId;
  }

  // --- Session Helpers (Recreated from chat.dart to be independent) ---

  Future<String> _resolveAgentStateSessionId(
    String userId,
    String sessionId,
  ) async {
    try {
      final sessionData = await _chatStorage.loadMetadata(userId, sessionId);
      final activeStateId =
          sessionData[_activeAgentStateSessionIdKey]?.toString().trim();
      if (activeStateId != null && activeStateId.isNotEmpty) {
        return activeStateId;
      }
    } catch (e, st) {
      _logger.warning(
        'Failed to resolve agent state session for chat session $sessionId',
        e,
        st,
      );
    }
    return sessionId;
  }

  /// Check whether a session file has `is_custom_agent: true`.
  Future<bool> _isCustomAgentSession(String userId, String sessionId) async {
    try {
      final data = await _chatStorage.loadMetadata(userId, sessionId);
      return data['is_custom_agent'] == true;
    } catch (e) {
      _logger.warning('Failed to read session metadata: $e');
    }
    return false;
  }

  Future<String> _createSession(
    String userId,
    String? agentName,
    List<Map<String, dynamic>> initialContent, {
    bool isQuickQuery = false,
    String? scene,
    String? sceneId,
    DateTime? createdAt,
  }) async {
    final uuidStr = _uuid.v4();
    final sessionId = agentName != null && agentName.isNotEmpty
        ? '${agentName}_$uuidStr'
        : uuidStr;
    final now = createdAt ?? DateTime.now();

    String? title;
    var imageCount = 0;
    for (final item in initialContent) {
      if (item['type'] == 'text' && item['text'] != null) {
        final text = item['text'] as String;
        title = text.length > 50 ? text.substring(0, 50) : text;
        break;
      } else if (item['type'] == 'image_url') {
        imageCount += 1;
      }
    }
    title ??= imageCount > 0 ? 'Image conversation ($imageCount)' : null;

    final sessionData = {
      'session_id': sessionId,
      'agent_name': agentName,
      'scene': scene,
      'scene_id': sceneId,
      'title': title ?? 'New Chat',
      'created_at': now.toIso8601String(),
      'created_at_local': formatLocalDateTimeWithZone(now),
      'created_at_unix_seconds': unixSecondsFromDateTime(now),
      'updated_at': now.toIso8601String(),
      'updated_at_local': formatLocalDateTimeWithZone(now),
      'updated_at_unix_seconds': unixSecondsFromDateTime(now),
      'is_quick_query': isQuickQuery,
      ChatArtifactSessionMigration.schemaVersionKey: ChatArtifact.schemaVersion,
    };

    await _chatStorage.createSession(
      userId: userId,
      sessionId: sessionId,
      metadata: sessionData,
    );
    return sessionId;
  }

  Future<Map<String, dynamic>?> _addMessageToSession(
    String userId,
    String sessionId,
    String role,
    List<Map<String, dynamic>> content, {
    Map<String, dynamic>? usage,
    List<Map<String, dynamic>> artifacts = const [],
    List<Map<String, String>>? refs,
    bool? isQuickQuery,
    DateTime? timestamp,
    String? turnId,
  }) async {
    if (!await _chatStorage.sessionExists(userId, sessionId)) return null;

    final messageTime = timestamp ?? DateTime.now();
    final messageDict = {
      'role': role,
      'content': content,
      if (usage != null) 'usage': usage,
      if (artifacts.isNotEmpty) 'artifacts': artifacts,
      if (refs != null) 'refs': refs,
      if (turnId != null) 'turn_id': turnId,
      'timestamp': messageTime.toIso8601String(),
      'local_time': formatLocalDateTimeWithZone(messageTime),
      'unix_seconds': unixSecondsFromDateTime(messageTime),
    };

    return _chatStorage.appendMessage(
      userId: userId,
      sessionId: sessionId,
      message: messageDict,
      usage: usage,
      isQuickQuery: isQuickQuery,
    );
  }

  Future<bool> _sessionHasAssistantForTurn(
    String userId,
    String sessionId,
    String turnId,
  ) async {
    if (!await _chatStorage.sessionExists(userId, sessionId)) return false;
    return _chatStorage.hasAssistantMessageForTurn(userId, sessionId, turnId);
  }
}
