import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/logger.dart';

/// Context for task execution
class TaskContext {
  final String taskId;
  final String taskType;
  final String? bizId;

  TaskContext({
    required this.taskId,
    required this.taskType,
    this.bizId,
  });
}

/// Lightweight snapshot of active background task pressure.
class TaskActivitySnapshot {
  final int pending;
  final int processing;
  final int retrying;

  const TaskActivitySnapshot({
    required this.pending,
    required this.processing,
    required this.retrying,
  });

  const TaskActivitySnapshot.empty()
      : pending = 0,
        processing = 0,
        retrying = 0;

  int get total => pending + processing + retrying;

  bool get hasActiveTasks => total > 0;

  @override
  bool operator ==(Object other) {
    return other is TaskActivitySnapshot &&
        other.pending == pending &&
        other.processing == processing &&
        other.retrying == retrying;
  }

  @override
  int get hashCode => Object.hash(pending, processing, retrying);
}

/// Handler function type
typedef TaskHandler = Future<void> Function(
    String userId, Map<String, dynamic> payload, TaskContext context);

/// Failure handler function type - called when all retries are exhausted
typedef TaskFailureHandler = Future<void> Function(
    String userId,
    Map<String, dynamic> payload,
    TaskContext context,
    Object error,
    StackTrace? stackTrace);

class LocalTaskExecutor {
  static LocalTaskExecutor? _instance;
  static LocalTaskExecutor get instance {
    _instance ??= LocalTaskExecutor._();
    return _instance!;
  }

  LocalTaskExecutor._() : _testDb = null;

  @visibleForTesting
  LocalTaskExecutor.forTesting({AppDatabase? db}) : _testDb = db;

  final Logger _logger = getLogger('LocalTaskExecutor');
  final AppDatabase? _testDb;
  // Dynamic getter to ensure we always use the current active DB instance (handling user switches)
  AppDatabase get _db => _testDb ?? AppDatabase.instance;
  String? _currentUserId; // Track current user ID for worker context
  String? get currentUserId => _currentUserId;

  // Handlers registry
  final Map<String, TaskHandler> _handlers = {};

  // Failure handlers registry
  final Map<String, TaskFailureHandler> _failureHandlers = {};

  // Worker state
  bool _isRunning = false;
  Timer? _pollTimer;
  bool _isProcessing = false;

  // Polling interval
  static const Duration _pollInterval = Duration(seconds: 1);
  static const String _crashGuardBucket = 'local_task_executor_crash_guard';
  static const String _activeTaskMarkerKeyPrefix = 'active_task_marker:';
  static const String _gracefulExitMarkerKey = 'graceful_exit_marker';
  static const int crashLoopFailureThreshold = 2;
  static const Duration crashLikeExitWindow = Duration(minutes: 10);

  /// Stream that emits true if there are any active (pending, processing, retrying) tasks in the DB.
  /// Useful for global UI loading indicators.
  Stream<bool> get hasActiveTasksStream {
    final query = _db.select(_db.tasks)
      ..where((t) => t.status.isIn(['pending', 'processing', 'retrying']));
    return query.watch().map((tasks) => tasks.isNotEmpty).distinct();
  }

  Future<TaskActivitySnapshot> getTaskActivitySnapshot() async {
    final query = _db.select(_db.tasks)
      ..where((t) => t.status.isIn(['pending', 'processing', 'retrying']));
    return _snapshotFromTasks(await query.get());
  }

  TaskActivitySnapshot _snapshotFromTasks(List<Task> tasks) {
    var pending = 0;
    var processing = 0;
    var retrying = 0;
    for (final task in tasks) {
      switch (task.status) {
        case 'pending':
          pending++;
          break;
        case 'processing':
          processing++;
          break;
        case 'retrying':
          retrying++;
          break;
      }
    }
    return TaskActivitySnapshot(
      pending: pending,
      processing: processing,
      retrying: retrying,
    );
  }

  void registerHandler(String taskType, TaskHandler handler) {
    _handlers[taskType] = handler;
  }

  /// Register a failure handler for a task type
  /// This handler will be called when all retries are exhausted and the task is permanently failed
  void registerFailureHandler(String taskType, TaskFailureHandler handler) {
    _failureHandlers[taskType] = handler;
  }

  /// Start the worker loop
  Future<void> start({String? userId}) async {
    if (_isRunning) return;
    _currentUserId = userId; // Store for use in worker loop

    // Detect whether the previous process exited while a task was running.
    // This must happen before resetting stale tasks, otherwise we lose the only
    // durable signal that a crash-like exit happened during task execution.
    await _handlePreviousExecutionMarkers();

    // Reset any stale 'processing' tasks that might have been left over from a crash
    await _resetStaleTasks();

    _isRunning = true;
    _logger.info('LocalTaskExecutor started for user $_currentUserId');
    _scheduleNextPoll();
  }

  /// Reset tasks that are stuck in 'processing' state to 'pending'
  Future<void> _resetStaleTasks() async {
    try {
      final count = await (_db.update(_db.tasks)
            ..where((t) => t.status.equals('processing')))
          .write(TasksCompanion(
        status: const Value('pending'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ));

      if (count > 0) {
        _logger.info('Reset $count stale processing tasks to pending');
      }
    } catch (e) {
      _logger.severe('Failed to reset stale tasks: $e');
    }
  }

  /// Stop the worker loop
  void stop() {
    _isRunning = false;
    _pollTimer?.cancel();
    _logger.info('LocalTaskExecutor stopped');
  }

  Future<void> recordGracefulShutdown({String reason = 'unknown'}) async {
    if (!AppDatabase.isInitialized) return;

    final marker = _GracefulExitMarker(
      markedAt: DateTime.now(),
      reason: reason,
    );
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.into(_db.kvStore).insertOnConflictUpdate(
          KvStoreCompanion.insert(
            key: _gracefulExitMarkerKey,
            value: Value(jsonEncode(marker.toJson())),
            bucket: const Value(_crashGuardBucket),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> clearGracefulShutdownMarker() async {
    if (!AppDatabase.isInitialized) return;

    await (_db.delete(_db.kvStore)
          ..where((kv) => kv.key.equals(_gracefulExitMarkerKey)))
        .go();
  }

  // Max concurrent tasks
  static const int _maxConcurrency = 5;
  static const int _candidatePageSize = 50;
  static const int _maxCandidateScan = 500;

  /// Enqueue a new task
  Future<String> enqueueTask({
    required String userId,
    required String taskType,
    required Map<String, dynamic> payload,
    int priority = 0,
    int? scheduledAt,
    int maxRetries = 5,
    String? bizId,
    List<String>? dependencies,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // We use a manual UUID or let Drift handle it?
    // Our schema defined ID as Text. Drift doesn't auto-generate Text IDs usually.
    // So we generate one.
    final taskId =
        DateTime.now().microsecondsSinceEpoch.toString(); // Simple ID for now

    await _db.into(_db.tasks).insert(TasksCompanion.insert(
          id: taskId,
          type: taskType,
          payload: Value(jsonEncode(payload)),
          status: 'pending',
          priority: Value(priority),
          createdAt: Value(now),
          scheduledAt: Value(scheduledAt),
          maxRetries: Value(maxRetries),
          bizId: Value(bizId),
          dependencies: Value(dependencies != null && dependencies.isNotEmpty
              ? jsonEncode(dependencies)
              : null),
        ));

    _logger.info('Enqueued task $taskId ($taskType)');

    // Trigger immediate poll if running
    if (_isRunning) {
      _scheduleNextPoll(immediate: true);
    }

    return taskId;
  }

  void _scheduleNextPoll({bool immediate = false}) {
    _pollTimer?.cancel();
    if (!_isRunning) return;

    if (immediate) {
      _pollTimer = Timer(Duration.zero, _workerLoop);
    } else {
      _pollTimer = Timer(_pollInterval, _workerLoop);
    }
  }

  Future<void> _workerLoop() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // 1. Check current active tasks count
      final activeCountQuery = _db.select(_db.tasks)
        ..where((t) => t.status.isIn(['processing']));
      final activeTasks = await activeCountQuery.get();

      if (activeTasks.length >= _maxConcurrency) {
        _isProcessing = false;
        _scheduleNextPoll(); // Wait for next slot
        return;
      }

      final slotsAvailable = _maxConcurrency - activeTasks.length;

      // 2. Fetch runnable tasks. Dependency-blocked tasks at the front of the
      // queue should not starve later tasks that can safely run now.
      final tasksToRun = await _findRunnableTasks(
        slotsAvailable: slotsAvailable,
        now: now,
      );

      if (tasksToRun.isEmpty) {
        // No runnable tasks found in top candidates
        _isProcessing = false;
        _scheduleNextPoll();
        return;
      }

      // 3. Mark and Execute
      for (final task in tasksToRun) {
        // Fire and forget execution - don't await
        _executeTask(task);
      }

      // Loop immediately to check for more tasks or completion
      _isProcessing = false;

      // If we filled all slots, wait. If we didn't, maybe check again soon.
      // Easiest is to just schedule next poll.
      _scheduleNextPoll(immediate: true);
    } catch (e) {
      _logger.severe('Error in worker loop, $e', e);
      _isProcessing = false;
      _scheduleNextPoll();
    }
  }

  Future<List<Task>> _findRunnableTasks({
    required int slotsAvailable,
    required int now,
  }) async {
    final tasksToRun = <Task>[];
    var offset = 0;
    var scanned = 0;

    while (tasksToRun.length < slotsAvailable && scanned < _maxCandidateScan) {
      final remainingScan = _maxCandidateScan - scanned;
      final pageSize = remainingScan < _candidatePageSize
          ? remainingScan
          : _candidatePageSize;

      final query = _db.select(_db.tasks)
        ..where((t) => t.status.isIn(['pending', 'retrying']))
        ..where((t) =>
            t.scheduledAt.isNull() | t.scheduledAt.isSmallerOrEqualValue(now))
        ..orderBy([
          (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.rowId, mode: OrderingMode.asc),
        ])
        ..limit(pageSize, offset: offset);

      final candidates = await query.get();
      if (candidates.isEmpty) break;

      scanned += candidates.length;
      offset += candidates.length;

      for (final task in candidates) {
        if (tasksToRun.length >= slotsAvailable) break;
        if (await _dependenciesMet(task)) {
          tasksToRun.add(task);
        }
      }
    }

    if (tasksToRun.isEmpty && scanned >= _maxCandidateScan) {
      _logger.warning(
          'No runnable tasks found after scanning $_maxCandidateScan candidates');
    }

    return tasksToRun;
  }

  Future<bool> _dependenciesMet(Task task) async {
    if (task.dependencies == null) return true;

    try {
      final deps = (jsonDecode(task.dependencies!) as List).cast<String>();
      if (deps.isEmpty) return true;

      // Check if any dependency is NOT completed or failed.
      final pendingDepsQuery = _db.selectOnly(_db.tasks)
        ..addColumns([_db.tasks.id.count()])
        ..where(_db.tasks.id.isIn(deps))
        ..where(_db.tasks.status.isNotIn(['completed', 'failed']));

      final pendingCount = await pendingDepsQuery.getSingle();
      return (pendingCount.read(_db.tasks.id.count()) ?? 0) == 0;
    } catch (e) {
      _logger.warning('Failed to parse dependencies for task ${task.id}: $e');
      await _failTask(task, 'Invalid task dependencies: $e');
      return false;
    }
  }

  Future<void> _executeTask(Task task) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Mark as processing
      await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(
          status: const Value('processing'),
          updatedAt: Value(now),
        ),
      );
      await _markTaskExecutionStarted(task);

      final handler = _handlers[task.type];
      if (handler == null) {
        throw Exception('No handler registered for task type: ${task.type}');
      }

      final payloadMap = task.payload != null
          ? jsonDecode(task.payload!) as Map<String, dynamic>
          : <String, dynamic>{};

      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw StateError(
          'Task execution failed: no active user ID in LocalTaskExecutor',
        );
      }

      await handler(
        currentUserId,
        payloadMap,
        TaskContext(
          taskId: task.id,
          taskType: task.type,
          bizId: task.bizId,
        ),
      );

      // Success
      await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(
          status: const Value('completed'),
          completedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        ),
      );

      _logger.info('Task ${task.id} completed');
    } catch (e, stack) {
      _logger.severe('Task ${task.id} failed', e, stack);

      // Retry Logic
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final nextRetry = task.retryCount + 1;

      if (e is! NonRetryableTaskException && nextRetry <= task.maxRetries) {
        // Exponential backoff
        const backoff = 30; //* (1 << (task.retryCount));
        final nextRun = now + backoff;

        await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
          TasksCompanion(
            status: const Value('retrying'),
            retryCount: Value(nextRetry),
            updatedAt: Value(now),
            // For simple polling, we don't strictly update scheduledAt for retries currently in query logic
            // but we should if we want valid backoff.
            // Existing query handles scheduledAt logic, so updating it works.
            scheduledAt: Value(nextRun),
            error: Value(e.toString()),
          ),
        );
        _logger.info('Task ${task.id} scheduled for retry at $nextRun');
      } else {
        // Permanently failed
        final failureHandler = _failureHandlers[task.type];
        if (failureHandler != null) {
          try {
            final payloadMap = task.payload != null
                ? jsonDecode(task.payload!) as Map<String, dynamic>
                : <String, dynamic>{};
            final currentUserId = _currentUserId;
            if (currentUserId != null) {
              await failureHandler(
                currentUserId,
                payloadMap,
                TaskContext(
                  taskId: task.id,
                  taskType: task.type,
                  bizId: task.bizId,
                ),
                e,
                stack,
              );
            }
          } catch (fhError, fhStack) {
            _logger.severe('Failure handler error', fhError, fhStack);
          }
        }

        await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
          TasksCompanion(
            status: const Value('failed'),
            completedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
            updatedAt: Value(now),
            error: Value(e.toString()),
          ),
        );
        _logger.severe('Task ${task.id} permanently failed');
      }
    } finally {
      await _clearTaskExecutionMarker(task.id);

      // Trigger poll to pick up next tasks immediately upon completion of one
      if (_isRunning) {
        _scheduleNextPoll(immediate: true);
      }
    }
  }

  Future<void> _handlePreviousExecutionMarkers() async {
    try {
      final markers = await _loadTaskExecutionMarkers();
      if (markers.isEmpty) return;
      final gracefulExitMarker = await _loadGracefulExitMarker();

      for (final marker in markers) {
        await _handlePreviousExecutionMarker(marker, gracefulExitMarker);
      }
      await _deleteGracefulExitMarker();
    } catch (e, stack) {
      _logger.severe(
        'Failed to handle previous task execution markers',
        e,
        stack,
      );
    }
  }

  Future<void> _handlePreviousExecutionMarker(
    _TaskExecutionMarker marker,
    _GracefulExitMarker? gracefulExitMarker,
  ) async {
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(marker.taskId)))
        .getSingleOrNull();
    if (task == null || task.status != 'processing') {
      await _deleteTaskExecutionMarker(marker.taskId);
      return;
    }

    if (!marker.matchesTask(task)) {
      _logger.warning(
        'Ignoring stale crash guard marker for task ${marker.taskId}: task metadata changed',
      );
      await _deleteTaskExecutionMarker(marker.taskId);
      return;
    }

    if (gracefulExitMarker != null &&
        !gracefulExitMarker.markedAt.isBefore(marker.startedAt)) {
      _logger.info(
        'Ignoring crash guard marker for task ${marker.taskId}: previous app exit was graceful (${gracefulExitMarker.reason})',
      );
      await _deleteTaskExecutionMarker(marker.taskId);
      return;
    }

    final now = DateTime.now();
    if (now.difference(marker.startedAt) > crashLikeExitWindow) {
      _logger.info(
        'Ignoring old crash guard marker for task ${marker.taskId}; previous process likely stopped outside crash window',
      );
      await _deleteTaskExecutionMarker(marker.taskId);
      return;
    }

    final updatedMarker = marker.copyWith(crashCount: marker.crashCount + 1);
    if (updatedMarker.crashCount >= crashLoopFailureThreshold) {
      await _failTask(
        task,
        'Task failed after ${updatedMarker.crashCount} crash-like exits while processing. '
        'Marked failed to stop startup crash loop.',
      );
      await _deleteTaskExecutionMarker(marker.taskId);
      _logger.severe(
        'Task ${task.id} failed by crash loop guard after ${updatedMarker.crashCount} crash-like exits',
      );
      return;
    }

    await _saveTaskExecutionMarker(updatedMarker);
    _logger.warning(
      'Detected crash-like exit while processing task ${task.id}; crash count is ${updatedMarker.crashCount}',
    );
  }

  Future<void> _markTaskExecutionStarted(Task task) async {
    await clearGracefulShutdownMarker();
    final existing = await _loadTaskExecutionMarker(task.id);
    final marker = _TaskExecutionMarker.fromTask(
      task,
      crashCount: existing != null && existing.matchesTask(task)
          ? existing.crashCount
          : 0,
    );
    await _saveTaskExecutionMarker(marker);
  }

  Future<_TaskExecutionMarker?> _loadTaskExecutionMarker(String taskId) async {
    final row = await (_db.select(
      _db.kvStore,
    )..where((kv) => kv.key.equals(_taskExecutionMarkerKey(taskId))))
        .getSingleOrNull();
    if (row?.value == null) return null;

    try {
      return _TaskExecutionMarker.fromJson(
        jsonDecode(row!.value!) as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.warning('Failed to parse task execution marker: $e');
      await _deleteTaskExecutionMarker(taskId);
      return null;
    }
  }

  Future<List<_TaskExecutionMarker>> _loadTaskExecutionMarkers() async {
    final rows = await (_db.select(_db.kvStore)
          ..where((kv) => kv.key.like('$_activeTaskMarkerKeyPrefix%')))
        .get();
    final markers = <_TaskExecutionMarker>[];

    for (final row in rows) {
      if (row.value == null) {
        await _deleteTaskExecutionMarkerByKey(row.key);
        continue;
      }

      try {
        markers.add(
          _TaskExecutionMarker.fromJson(
            jsonDecode(row.value!) as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        _logger.warning('Failed to parse task execution marker: $e');
        await _deleteTaskExecutionMarkerByKey(row.key);
      }
    }

    return markers;
  }

  Future<_GracefulExitMarker?> _loadGracefulExitMarker() async {
    final row = await (_db.select(_db.kvStore)
          ..where((kv) => kv.key.equals(_gracefulExitMarkerKey)))
        .getSingleOrNull();
    if (row?.value == null) return null;

    try {
      return _GracefulExitMarker.fromJson(
        jsonDecode(row!.value!) as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.warning('Failed to parse graceful exit marker: $e');
      await _deleteGracefulExitMarker();
      return null;
    }
  }

  Future<void> _deleteGracefulExitMarker() async {
    await (_db.delete(_db.kvStore)
          ..where((kv) => kv.key.equals(_gracefulExitMarkerKey)))
        .go();
  }

  Future<void> _saveTaskExecutionMarker(_TaskExecutionMarker marker) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.into(_db.kvStore).insertOnConflictUpdate(
          KvStoreCompanion.insert(
            key: _taskExecutionMarkerKey(marker.taskId),
            value: Value(jsonEncode(marker.toJson())),
            bucket: const Value(_crashGuardBucket),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> _deleteTaskExecutionMarker(String taskId) {
    return _deleteTaskExecutionMarkerByKey(_taskExecutionMarkerKey(taskId));
  }

  Future<void> _deleteTaskExecutionMarkerByKey(String key) async {
    await (_db.delete(
      _db.kvStore,
    )..where((kv) => kv.key.equals(key)))
        .go();
  }

  Future<void> _clearTaskExecutionMarker(String taskId) async {
    final marker = await _loadTaskExecutionMarker(taskId);
    if (marker == null || marker.taskId != taskId) return;
    await _deleteTaskExecutionMarker(taskId);
  }

  String _taskExecutionMarkerKey(String taskId) {
    return '$_activeTaskMarkerKeyPrefix$taskId';
  }

  Future<void> _failTask(Task task, String error) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(
        status: const Value('failed'),
        completedAt: Value(now),
        updatedAt: Value(now),
        error: Value(error),
      ),
    );
  }

  @visibleForTesting
  Future<void> markTaskExecutionStartedForTesting(Task task) =>
      _markTaskExecutionStarted(task);

  @visibleForTesting
  Future<KvStoreData?> getTaskExecutionMarkerForTesting([String? taskId]) {
    if (taskId != null) {
      return (_db.select(
        _db.kvStore,
      )..where((kv) => kv.key.equals(_taskExecutionMarkerKey(taskId))))
          .getSingleOrNull();
    }

    return (_db.select(
      _db.kvStore,
    )
          ..where((kv) => kv.key.like('$_activeTaskMarkerKeyPrefix%'))
          ..limit(1))
        .getSingleOrNull();
  }

  @visibleForTesting
  Future<List<KvStoreData>> getTaskExecutionMarkersForTesting() {
    return (_db.select(
      _db.kvStore,
    )..where((kv) => kv.key.like('$_activeTaskMarkerKeyPrefix%')))
        .get();
  }

  @visibleForTesting
  Future<KvStoreData?> getGracefulExitMarkerForTesting() {
    return (_db.select(_db.kvStore)
          ..where((kv) => kv.key.equals(_gracefulExitMarkerKey)))
        .getSingleOrNull();
  }

  /// Check if a task of [taskType] with [bizId] has failed.
  /// Returns the error string if failed, null otherwise.
  Future<String?> getTaskErrorByBizId(String taskType, String bizId) async {
    final query = _db.select(_db.tasks)
      ..where((t) => t.type.equals(taskType))
      ..where((t) => t.bizId.equals(bizId))
      ..where((t) => t.status.equals('failed'))
      ..limit(1);
    final task = await query.getSingleOrNull();
    return task?.error;
  }

  /// Update task result (called by handlers)
  Future<void> updateTaskResult(String taskId, String result) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        result: Value(result),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  /// Create a completed task record with the given result directly.
  /// Useful for mocking task results that were not produced by an actual task execution.
  Future<void> saveTaskResult({
    required String userId,
    required String taskType,
    required String bizId,
    required Map<String, dynamic> result,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final taskId = DateTime.now().microsecondsSinceEpoch.toString();
    final resultStr = jsonEncode(result);

    await _db.into(_db.tasks).insert(TasksCompanion.insert(
          id: taskId,
          type: taskType,
          payload: const Value("{}"),
          status: 'completed',
          priority: const Value(0),
          createdAt: Value(now),
          completedAt: Value(now),
          updatedAt: Value(now),
          maxRetries: const Value(1),
          bizId: Value(bizId),
          result: Value(resultStr),
        ));
  }

  /// Get task result by taskId (for resumption)
  Future<Map<String, dynamic>?> getTaskResult(String taskId) async {
    final query = _db.select(_db.tasks)..where((t) => t.id.equals(taskId));
    final task = await query.getSingleOrNull();

    if (task != null && task.result != null) {
      try {
        return jsonDecode(task.result!) as Map<String, dynamic>;
      } catch (e) {
        _logger.warning('Failed to parse task result for task ${task.id}: $e');
      }
    }
    return null;
  }

  /// Get task result by bizId
  Future<Map<String, dynamic>?> getTaskResultByBizId(
      String userId, String taskType, String bizId) async {
    final query = _db.select(_db.tasks)
      ..where((t) => t.type.equals(taskType))
      ..where((t) => t.bizId.equals(bizId))
      ..where((t) => t.status.equals('completed'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)
      ])
      ..limit(1);

    final task = await query.getSingleOrNull();
    if (task != null && task.result != null) {
      try {
        return jsonDecode(task.result!) as Map<String, dynamic>;
      } catch (e) {
        _logger.warning('Failed to parse task result for task ${task.id}: $e');
      }
    }
    return null;
  }

  /// Get tasks with pagination
  Future<List<Task>> getTasks({int limit = 10, int offset = 0}) async {
    final query = _db.select(_db.tasks)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);

    return await query.get();
  }

  /// Get the last task by type
  /// This is useful for restoring sequential dependency chains after app restart
  Future<String?> getLastTaskByType(String taskType) async {
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([_db.tasks.id])
      ..where(_db.tasks.type.equals(taskType))
      ..orderBy([
        OrderingTerm(expression: _db.tasks.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.read(_db.tasks.id);
  }
}

class _TaskExecutionMarker {
  _TaskExecutionMarker({
    required this.taskId,
    required this.taskType,
    required this.payloadHash,
    required this.startedAt,
    required this.crashCount,
    this.bizId,
  });

  final String taskId;
  final String taskType;
  final String? bizId;
  final String payloadHash;
  final DateTime startedAt;
  final int crashCount;

  factory _TaskExecutionMarker.fromTask(Task task, {required int crashCount}) {
    return _TaskExecutionMarker(
      taskId: task.id,
      taskType: task.type,
      bizId: task.bizId,
      payloadHash: _payloadHashFor(task.payload),
      startedAt: DateTime.now(),
      crashCount: crashCount,
    );
  }

  factory _TaskExecutionMarker.fromJson(Map<String, dynamic> json) {
    return _TaskExecutionMarker(
      taskId: json['task_id'] as String,
      taskType: json['task_type'] as String,
      bizId: json['biz_id'] as String?,
      payloadHash: json['payload_hash'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        json['started_at_ms'] as int,
      ),
      crashCount: json['crash_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_type': taskType,
      'biz_id': bizId,
      'payload_hash': payloadHash,
      'started_at_ms': startedAt.millisecondsSinceEpoch,
      'crash_count': crashCount,
    };
  }

  _TaskExecutionMarker copyWith({int? crashCount}) {
    return _TaskExecutionMarker(
      taskId: taskId,
      taskType: taskType,
      bizId: bizId,
      payloadHash: payloadHash,
      startedAt: startedAt,
      crashCount: crashCount ?? this.crashCount,
    );
  }

  bool matchesTask(Task task) {
    return task.id == taskId &&
        task.type == taskType &&
        task.bizId == bizId &&
        _payloadHashFor(task.payload) == payloadHash;
  }

  static String _payloadHashFor(String? payload) {
    return sha256.convert(utf8.encode(payload ?? '')).toString();
  }
}

class _GracefulExitMarker {
  _GracefulExitMarker({
    required this.markedAt,
    required this.reason,
  });

  final DateTime markedAt;
  final String reason;

  factory _GracefulExitMarker.fromJson(Map<String, dynamic> json) {
    return _GracefulExitMarker(
      markedAt: DateTime.fromMillisecondsSinceEpoch(
        json['marked_at_ms'] as int,
      ),
      reason: json['reason'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marked_at_ms': markedAt.millisecondsSinceEpoch,
      'reason': reason,
    };
  }
}
