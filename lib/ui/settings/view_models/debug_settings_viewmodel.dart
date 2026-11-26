import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/sandbox_user_clone_service.dart';
import 'package:memex/ui/settings/widgets/reprocess_cards_dialog.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

abstract interface class DebugSettingsDataController {
  Future<void> enqueueTask({
    required String taskType,
    required Map<String, dynamic> payload,
    String? bizId,
  });

  Future<void> startSuperAgentReprocess({
    required ReprocessCardsDebugOptions options,
  });

  Future<void> clearData();

  Future<int> clearFailedAgentConversationContexts();

  Future<SandboxUserCloneResult> cloneToTestUser({
    required String targetUserId,
    required bool overwriteTarget,
  });

  Future<void> rebuildAllFtsIndexes();

  Future<void> changeLocalUser(String? userId);
}

class MemexRouterDebugSettingsDataController
    implements DebugSettingsDataController {
  MemexRouterDebugSettingsDataController(this._router);

  final MemexRouter _router;

  @override
  Future<void> enqueueTask({
    required String taskType,
    required Map<String, dynamic> payload,
    String? bizId,
  }) {
    return _router.enqueueTask(
      taskType: taskType,
      payload: payload,
      bizId: bizId,
    );
  }

  @override
  Future<void> startSuperAgentReprocess({
    required ReprocessCardsDebugOptions options,
  }) async {
    String? sessionId;
    final sessionsResult = await _router.fetchChatSessions(
      agentName: 'memex_agent',
      limit: 30,
    );
    sessionsResult.when(
      onOk: (sessions) {
        for (final session in sessions) {
          if (session['scene'] == 'super_agent_home') {
            sessionId = session['session_id']?.toString();
            return;
          }
        }
      },
      onError: (_, __) {},
    );

    unawaited(
      _router
          .sendMessage(
            options.toSuperAgentMessage(),
            sessionId: sessionId,
            agentName: 'memex_agent',
            scene: 'super_agent_home',
            sceneId: 'debug_reprocess',
            refs: [
              {
                'type': 'debug_reprocess_cards',
                'title': 'Debug reprocess cards',
                'content': options.toReferenceContent(),
              },
            ],
            runMode: 'auto',
          )
          .drain<void>()
          .catchError((_) {}),
    );

    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> clearData() => _router.clearData();

  @override
  Future<int> clearFailedAgentConversationContexts() {
    return _router.clearFailedAgentConversationContexts();
  }

  @override
  Future<SandboxUserCloneResult> cloneToTestUser({
    required String targetUserId,
    required bool overwriteTarget,
  }) {
    return SandboxUserCloneService.instance.cloneCurrentUserToLocalTestUser(
      targetUserId: targetUserId,
      overwriteTarget: overwriteTarget,
    );
  }

  @override
  Future<void> rebuildAllFtsIndexes() => _router.rebuildAllFtsIndexes();

  @override
  Future<void> changeLocalUser(String? userId) =>
      _router.changeLocalUser(userId);
}

class DebugSettingsUserNotFoundException implements Exception {
  const DebugSettingsUserNotFoundException();

  @override
  String toString() => 'User ID not found';
}

class DebugDateRangeTaskOptions {
  const DebugDateRangeTaskOptions({this.dateFrom, this.dateTo, this.limit});

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? limit;

  Map<String, dynamic> toTaskPayload() {
    final payload = <String, dynamic>{};
    final from = dateFrom;
    if (from != null) {
      payload['date_from'] = formatDate(from);
    }
    final to = dateTo;
    if (to != null) {
      payload['date_to'] = formatDate(to);
    }
    final limitValue = limit;
    if (limitValue != null && limitValue > 0) {
      payload['limit'] = limitValue;
    }
    return payload;
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class DebugSettingsViewModel extends ChangeNotifier {
  DebugSettingsViewModel({required DebugSettingsDataController dataController})
      : _dataController = dataController;

  final DebugSettingsDataController _dataController;

  bool _isClearingData = false;
  bool _isClearingFailedAgentContexts = false;
  bool _isCloningTestUser = false;
  bool _isReprocessingCards = false;
  bool _isReprocessingComments = false;
  bool _isRebuildingSearchIndex = false;

  bool get isClearingData => _isClearingData;
  bool get isClearingFailedAgentContexts => _isClearingFailedAgentContexts;
  bool get isCloningTestUser => _isCloningTestUser;
  bool get isReprocessingCards => _isReprocessingCards;
  bool get isReprocessingComments => _isReprocessingComments;
  bool get isRebuildingSearchIndex => _isRebuildingSearchIndex;

  Future<void> clearToken() async {
    await _dataController.changeLocalUser(null);
  }

  Future<bool> clearData() async {
    if (_isClearingData) return false;

    await _runWithLoading(
      setLoading: (value) => _isClearingData = value,
      action: () async {
        await _ensureUser();
        await _dataController.clearData();
      },
    );
    return true;
  }

  Future<int?> clearFailedAgentContexts() async {
    if (_isClearingFailedAgentContexts) return null;

    return _runWithLoading(
      setLoading: (value) => _isClearingFailedAgentContexts = value,
      action: _dataController.clearFailedAgentConversationContexts,
    );
  }

  Future<SandboxUserCloneResult?> cloneToTestUser({
    required String targetUserId,
    required bool overwriteTarget,
  }) async {
    if (_isCloningTestUser) return null;

    return _runWithLoading(
      setLoading: (value) => _isCloningTestUser = value,
      action: () async {
        await _ensureUser();
        final result = await _dataController.cloneToTestUser(
          targetUserId: targetUserId,
          overwriteTarget: overwriteTarget,
        );
        await _dataController.changeLocalUser(result.targetUserId);
        return result;
      },
    );
  }

  Future<bool> createReprocessCardsTask(
    ReprocessCardsDebugOptions options,
  ) async {
    if (_isReprocessingCards) return false;

    await _runWithLoading(
      setLoading: (value) => _isReprocessingCards = value,
      action: () async {
        await _ensureUser();
        await _dataController.startSuperAgentReprocess(
          options: options,
        );
      },
    );
    return true;
  }

  Future<bool> createReprocessCommentsTask(
    DebugDateRangeTaskOptions options,
  ) async {
    if (_isReprocessingComments) return false;

    await _runWithLoading(
      setLoading: (value) => _isReprocessingComments = value,
      action: () async {
        await _ensureUser();
        await _dataController.enqueueTask(
          taskType: 'reprocess_comments_task',
          payload: options.toTaskPayload(),
          bizId: _createBizId('reprocess_comments'),
        );
      },
    );
    return true;
  }

  Future<bool> rebuildSearchIndex() async {
    if (_isRebuildingSearchIndex) return false;

    await _runWithLoading(
      setLoading: (value) => _isRebuildingSearchIndex = value,
      action: _dataController.rebuildAllFtsIndexes,
    );
    return true;
  }

  Future<void> _ensureUser() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw const DebugSettingsUserNotFoundException();
    }
  }

  String _createBizId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<T> _runWithLoading<T>({
    required void Function(bool value) setLoading,
    required Future<T> Function() action,
  }) async {
    setLoading(true);
    notifyListeners();
    try {
      return await action();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }
}
