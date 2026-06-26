import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/sqlite_busy_retry.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';

class AgentForegroundTaskSnapshot {
  const AgentForegroundTaskSnapshot({
    required this.taskSnapshot,
    required this.activeTaskIds,
    required this.attentionTaskErrors,
    required this.paused,
    required this.updatedAt,
    this.pausedMessage,
  });

  const AgentForegroundTaskSnapshot.empty()
      : taskSnapshot = const TaskActivitySnapshot.empty(),
        activeTaskIds = const <String>{},
        attentionTaskErrors = const <String, String>{},
        paused = false,
        pausedMessage = null,
        updatedAt = null;

  final TaskActivitySnapshot taskSnapshot;
  final Set<String> activeTaskIds;
  final Map<String, String> attentionTaskErrors;
  final bool paused;
  final String? pausedMessage;
  final DateTime? updatedAt;

  bool get hasActiveTasks => taskSnapshot.hasActiveTasks;

  bool get hasAttention => attentionTaskErrors.isNotEmpty;

  String? get latestAttentionDetail {
    if (attentionTaskErrors.isEmpty) return null;
    return attentionTaskErrors.values.last;
  }

  @override
  bool operator ==(Object other) {
    return other is AgentForegroundTaskSnapshot &&
        other.taskSnapshot == taskSnapshot &&
        setEquals(other.activeTaskIds, activeTaskIds) &&
        mapEquals(other.attentionTaskErrors, attentionTaskErrors) &&
        other.paused == paused &&
        other.pausedMessage == pausedMessage &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        taskSnapshot,
        Object.hashAllUnordered(activeTaskIds),
        Object.hashAll(
          attentionTaskErrors.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        paused,
        pausedMessage,
        updatedAt,
      );
}

class AgentForegroundTaskTracker {
  AgentForegroundTaskTracker._() : _testDb = null;

  @visibleForTesting
  AgentForegroundTaskTracker.forTesting({AppDatabase? db}) : _testDb = db;

  static AgentForegroundTaskTracker? _instance;
  static AgentForegroundTaskTracker get instance {
    _instance ??= AgentForegroundTaskTracker._();
    return _instance!;
  }

  static const String _key = 'agent_foreground_task_tracker';
  static const String _bucket = 'agent_foreground_task_tracker';

  final AppDatabase? _testDb;
  final _logger = getLogger('AgentForegroundTaskTracker');

  AppDatabase get _db => _testDb ?? AppDatabase.instance;

  Future<void> trackTask(String taskId) async {
    final trimmed = taskId.trim();
    if (trimmed.isEmpty) return;
    await _mutate((state) {
      return state.copyWith(
        activeTaskIds: {...state.activeTaskIds, trimmed},
        attentionTaskErrors: Map<String, String>.from(state.attentionTaskErrors)
          ..remove(trimmed),
        paused: false,
        pausedMessage: null,
      );
    });
    await getSnapshot();
  }

  Future<void> markTaskCompleted(String taskId) {
    return _mutate((state) {
      return state.copyWith(
        activeTaskIds: {...state.activeTaskIds}..remove(taskId),
      );
    });
  }

  Future<void> markTaskFailed(String taskId, Object error) {
    return _mutate((state) {
      if (!state.activeTaskIds.contains(taskId)) return state;
      return state.copyWith(
        activeTaskIds: {...state.activeTaskIds}..remove(taskId),
        attentionTaskErrors: {
          ...state.attentionTaskErrors,
          taskId: _trimError(error),
        },
        paused: false,
        pausedMessage: null,
      );
    });
  }

  Future<void> markPaused({required String message}) async {
    final normalized = await _loadNormalizedState();
    if (normalized.activeTaskIds.isEmpty) return;
    await _saveState(
      normalized.copyWith(
        paused: true,
        pausedMessage: message,
      ),
    );
  }

  Future<void> clearPause() {
    return _mutate((state) {
      if (!state.paused && state.pausedMessage == null) return state;
      return state.copyWith(paused: false, pausedMessage: null);
    });
  }

  Future<void> clearAttention() async {
    final normalized = await _loadNormalizedState();
    if (normalized.attentionTaskErrors.isEmpty) return;
    await _saveState(
      normalized.copyWith(attentionTaskErrors: const <String, String>{}),
    );
  }

  Future<AgentForegroundTaskSnapshot> getSnapshot() async {
    final state = await _loadNormalizedState();
    final taskSnapshot = await _taskSnapshotFor(state.activeTaskIds);
    return AgentForegroundTaskSnapshot(
      taskSnapshot: taskSnapshot,
      activeTaskIds: Set.unmodifiable(state.activeTaskIds),
      attentionTaskErrors: Map.unmodifiable(state.attentionTaskErrors),
      paused: state.paused && taskSnapshot.hasActiveTasks,
      pausedMessage: state.pausedMessage,
      updatedAt: state.updatedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(state.updatedAt! * 1000),
    );
  }

  Stream<AgentForegroundTaskSnapshot> watchSnapshot() {
    late StreamController<AgentForegroundTaskSnapshot> controller;
    StreamSubscription<KvStoreData?>? stateSubscription;
    StreamSubscription<List<Task>>? taskSubscription;
    AgentForegroundTaskSnapshot? lastSnapshot;
    var closed = false;

    Future<void> emit() async {
      if (closed) return;
      try {
        final snapshot = await getSnapshot();
        if (snapshot == lastSnapshot || closed) return;
        lastSnapshot = snapshot;
        controller.add(snapshot);
      } catch (e, stackTrace) {
        if (!closed) {
          controller.addError(e, stackTrace);
        }
      }
    }

    controller = StreamController<AgentForegroundTaskSnapshot>.broadcast(
      onListen: () {
        final stateQuery = _db.select(_db.kvStore)
          ..where((row) => row.key.equals(_key));
        stateSubscription = stateQuery.watchSingleOrNull().listen((_) {
          unawaited(emit());
        });
        taskSubscription = _db.select(_db.tasks).watch().listen((_) {
          unawaited(emit());
        });
        unawaited(emit());
      },
      onCancel: () async {
        closed = true;
        await stateSubscription?.cancel();
        await taskSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @visibleForTesting
  Future<void> resetForTesting() async {
    await (_db.delete(_db.kvStore)..where((row) => row.key.equals(_key))).go();
  }

  Future<void> _mutate(_TrackerState Function(_TrackerState) update) async {
    await SqliteBusyRetry.run<void>(
      operation: 'update foreground task tracker',
      logger: _logger,
      action: () async {
        final state = await _loadState();
        final updated = update(state);
        if (updated == state) return;
        await _saveState(updated);
      },
    );
  }

  Future<_TrackerState> _loadNormalizedState() async {
    final state = await _loadState();
    if (state.activeTaskIds.isEmpty) {
      final normalized = state.copyWith(paused: false, pausedMessage: null);
      if (normalized != state) {
        await _saveState(normalized);
      }
      return normalized;
    }

    final tasks = await _tasksById(state.activeTaskIds);
    final activeTaskIds = <String>{};
    final attentionTaskErrors =
        Map<String, String>.from(state.attentionTaskErrors);

    for (final taskId in state.activeTaskIds) {
      final task = tasks[taskId];
      switch (task?.status) {
        case 'pending':
        case 'processing':
        case 'retrying':
          activeTaskIds.add(taskId);
        case 'failed':
          attentionTaskErrors[taskId] =
              _trimNullable(task?.error) ?? 'Processing failed.';
        case null:
        case 'completed':
        default:
          break;
      }
    }

    final normalized = state.copyWith(
      activeTaskIds: activeTaskIds,
      attentionTaskErrors: attentionTaskErrors,
      paused: activeTaskIds.isNotEmpty && state.paused,
      pausedMessage: activeTaskIds.isEmpty ? null : state.pausedMessage,
    );
    if (normalized != state) {
      await _saveState(normalized);
    }
    return normalized;
  }

  Future<TaskActivitySnapshot> _taskSnapshotFor(Set<String> taskIds) async {
    if (taskIds.isEmpty) return const TaskActivitySnapshot.empty();
    final tasks = await _tasksById(taskIds);
    var pending = 0;
    var processing = 0;
    var retrying = 0;
    final activeIds = <String>{};

    for (final taskId in taskIds) {
      final task = tasks[taskId];
      switch (task?.status) {
        case 'pending':
          pending++;
          activeIds.add(taskId);
        case 'processing':
          processing++;
          activeIds.add(taskId);
        case 'retrying':
          retrying++;
          activeIds.add(taskId);
      }
    }

    return TaskActivitySnapshot(
      pending: pending,
      processing: processing,
      retrying: retrying,
      activeTaskIds: activeIds,
    );
  }

  Future<Map<String, Task>> _tasksById(Set<String> taskIds) async {
    if (taskIds.isEmpty) return const <String, Task>{};
    final rows = await (_db.select(_db.tasks)
          ..where((task) => task.id.isIn(taskIds.toList())))
        .get();
    return {for (final task in rows) task.id: task};
  }

  Future<_TrackerState> _loadState() async {
    final row = await (_db.select(_db.kvStore)
          ..where((kv) => kv.key.equals(_key)))
        .getSingleOrNull();
    final value = row?.value;
    if (value == null || value.trim().isEmpty) {
      return const _TrackerState.empty();
    }
    try {
      return _TrackerState.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (e, stackTrace) {
      _logger.warning(
          'Failed to parse foreground task tracker state', e, stackTrace);
      return const _TrackerState.empty();
    }
  }

  Future<void> _saveState(_TrackerState state) async {
    final normalized = state.withUpdatedAt(_nowSeconds());
    if (normalized.isEmpty) {
      await (_db.delete(_db.kvStore)..where((kv) => kv.key.equals(_key))).go();
      return;
    }
    await _db.into(_db.kvStore).insertOnConflictUpdate(
          KvStoreCompanion.insert(
            key: _key,
            value: Value(jsonEncode(normalized.toJson())),
            bucket: const Value(_bucket),
            updatedAt: Value(normalized.updatedAt),
          ),
        );
  }
}

class _TrackerState {
  const _TrackerState({
    required this.activeTaskIds,
    required this.attentionTaskErrors,
    required this.paused,
    required this.pausedMessage,
    required this.updatedAt,
  });

  const _TrackerState.empty()
      : activeTaskIds = const <String>{},
        attentionTaskErrors = const <String, String>{},
        paused = false,
        pausedMessage = null,
        updatedAt = null;

  final Set<String> activeTaskIds;
  final Map<String, String> attentionTaskErrors;
  final bool paused;
  final String? pausedMessage;
  final int? updatedAt;

  bool get isEmpty =>
      activeTaskIds.isEmpty && attentionTaskErrors.isEmpty && !paused;

  factory _TrackerState.fromJson(Map<String, dynamic> json) {
    final active = (json['active_task_ids'] as List? ?? const [])
        .map((value) => value.toString())
        .where((value) => value.trim().isNotEmpty)
        .toSet();
    final attentionJson = json['attention_task_errors'];
    final attention = <String, String>{};
    if (attentionJson is Map) {
      for (final entry in attentionJson.entries) {
        final key = entry.key.toString();
        final value = entry.value?.toString();
        if (key.trim().isNotEmpty && value != null && value.trim().isNotEmpty) {
          attention[key] = value;
        }
      }
    }
    return _TrackerState(
      activeTaskIds: active,
      attentionTaskErrors: attention,
      paused: json['paused'] == true,
      pausedMessage: json['paused_message'] as String?,
      updatedAt: json['updated_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_task_ids': activeTaskIds.toList()..sort(),
      'attention_task_errors': attentionTaskErrors,
      'paused': paused,
      if (pausedMessage != null) 'paused_message': pausedMessage,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  _TrackerState copyWith({
    Set<String>? activeTaskIds,
    Map<String, String>? attentionTaskErrors,
    bool? paused,
    Object? pausedMessage = _sentinel,
    int? updatedAt,
  }) {
    return _TrackerState(
      activeTaskIds: activeTaskIds ?? this.activeTaskIds,
      attentionTaskErrors: attentionTaskErrors ?? this.attentionTaskErrors,
      paused: paused ?? this.paused,
      pausedMessage: identical(pausedMessage, _sentinel)
          ? this.pausedMessage
          : pausedMessage as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  _TrackerState withUpdatedAt(int value) => copyWith(updatedAt: value);

  @override
  bool operator ==(Object other) {
    return other is _TrackerState &&
        setEquals(other.activeTaskIds, activeTaskIds) &&
        mapEquals(other.attentionTaskErrors, attentionTaskErrors) &&
        other.paused == paused &&
        other.pausedMessage == pausedMessage &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(activeTaskIds),
        Object.hashAll(
          attentionTaskErrors.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        paused,
        pausedMessage,
        updatedAt,
      );
}

const Object _sentinel = Object();

int _nowSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

String _trimError(Object error) {
  return _trimNullable(error.toString()) ?? 'Processing failed.';
}

String? _trimNullable(String? value) {
  final compact = value?.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (compact == null || compact.isEmpty) return null;
  if (compact.length <= 180) return compact;
  return '${compact.substring(0, 177)}...';
}
