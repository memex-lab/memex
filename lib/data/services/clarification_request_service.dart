import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/table_change_notifier.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:uuid/uuid.dart';

class ClarificationRequestStatus {
  static const pending = 'pending';
  static const answered = 'answered';
  static const completed = 'completed';
  static const dismissed = 'dismissed';
  static const failed = 'failed';
  static const expired = 'expired';
}

class ClarificationResponseType {
  static const confirm = 'confirm';
  static const singleChoice = 'single_choice';
  static const multiChoice = 'multi_choice';
  static const shortText = 'short_text';
}

class ClarificationRequestCreateResult {
  const ClarificationRequestCreateResult({
    required this.id,
    required this.created,
    this.dedupeKey,
  });

  final String id;
  final bool created;
  final String? dedupeKey;

  Map<String, dynamic> toJson() => {
        'request_id': id,
        'created': created,
        if (dedupeKey != null) 'dedupe_key': dedupeKey,
      };
}

class ClarificationRequestService {
  static final ClarificationRequestService instance =
      ClarificationRequestService._internal();
  ClarificationRequestService._internal();

  final _logger = Logger('ClarificationRequestService');
  AppDatabase get _db => AppDatabase.instance;

  /// Millisecond-timestamp threshold used to distinguish global Ask factIds
  /// (system-created, e.g. `2025/04/29.md#ts_1745924567890`) from normal
  /// attachment factIds (user-created, e.g. `2025/04/29.md#ts_1`).
  static const _globalTsThreshold = 1000000000000; // ~2001 in ms

  /// Whether [factId] represents a global Ask that owns its own timeline card.
  static bool isGlobalAsk(String? factId) {
    if (factId == null || factId.isEmpty) return false;
    final tsIdx = factId.lastIndexOf('#ts_');
    if (tsIdx < 0) return false;
    final suffix = factId.substring(tsIdx + 4);
    final num = int.tryParse(suffix);
    return num != null && num >= _globalTsThreshold;
  }

  /// Register table-change watcher. Call once after [TableChangeNotifier.init].
  void init() {
    TableChangeNotifier.instance.watch(
      'clarification_requests',
      (_) => _onTableChanged(),
    );
  }

  Future<void> _onTableChanged() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    // 1. New global requests (no factId) → create timeline card.
    //    Once factId is written back, they won't match this query again.
    final needsCard = await (_db.select(_db.clarificationRequests)
          ..where((t) => t.factId.isNull() | t.factId.equals('')))
        .get();

    for (final request in needsCard) {
      await _createTimelineCard(userId, request);
    }

    // 2. Existing global requests (factId is a global ts) → emit cardUpdated.
    final allRequests = await (_db.select(_db.clarificationRequests)
          ..where((t) => t.factId.isNotNull() & t.factId.isNotValue('')))
        .get();

    for (final request in allRequests) {
      if (isGlobalAsk(request.factId)) {
        _emitCardUpdated(request);
      }
    }
  }

  Future<void> _createTimelineCard(
    String userId,
    ClarificationRequest request,
  ) async {
    try {
      // Optimistic claim: atomically set a placeholder factId so concurrent
      // invocations for the same request will not proceed.
      final claimed = await (_db.update(_db.clarificationRequests)
            ..where((t) =>
                t.id.equals(request.id) &
                (t.factId.isNull() | t.factId.equals(''))))
          .write(ClarificationRequestsCompanion(
        factId: const Value('_claiming'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ));
      if (claimed == 0) {
        // Another invocation already claimed this request.
        return;
      }

      final now = DateTime.now();
      final timestampSec = now.millisecondsSinceEpoch ~/ 1000;
      final dateStr = DateFormat('yyyy/MM/dd').format(now);
      final cardFactId = '$dateStr.md#ts_${now.millisecondsSinceEpoch}';

      final cardData = CardData(
        factId: cardFactId,
        title: request.question,
        timestamp: timestampSec,
        status: 'completed',
        tags: const ['ask'],
        uiConfigs: [
          UiConfig(
            templateId: 'clarification_ask',
            data: {'request_id': request.id},
          ),
        ],
      );

      await FileSystemService.instance
          .safeWriteCardFile(userId, cardFactId, cardData);

      // Write back the factId so this request won't be picked up again.
      await updateFactId(request.id, cardFactId);

      EventBusService.instance.emitEvent(CardAddedMessage(
        id: cardFactId,
        html: '',
        timestamp: timestampSec,
        tags: const ['ask'],
        status: 'completed',
        title: request.question,
        uiConfigs: [
          UiConfig(
            templateId: 'clarification_ask',
            data: {'request_id': request.id},
          ),
        ],
      ));

      _logger.info(
          'Created timeline card $cardFactId for global Ask ${request.id}');
    } catch (e) {
      _logger.warning(
          'Failed to create timeline card for global Ask ${request.id}: $e');
    }
  }

  void _emitCardUpdated(ClarificationRequest request) {
    final factId = request.factId;
    if (factId == null || factId.isEmpty) return;

    final timestampSec =
        request.createdAt ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    EventBusService.instance.emitEvent(CardUpdatedMessage(
      id: factId,
      html: '',
      timestamp: timestampSec,
      tags: const ['ask'],
      status: 'completed',
      title: request.question,
      uiConfigs: [
        UiConfig(
          templateId: 'clarification_ask',
          data: {'request_id': request.id},
        ),
      ],
    ));
  }

  Future<String> createRequest({
    String? id,
    required String question,
    required String responseType,
    List<Map<String, dynamic>>? options,
    String? entityType,
    String? entityLabel,
    List<String>? evidenceFactIds,
    String? reason,
    String? impact,
    double? confidence,
    String? proposedMemory,
    String? resolutionTarget,
    String? sourceAgent,
    String? dedupeKey,
    String? factId,
    int? expiresAt,
  }) async {
    final result = await createRequestWithResult(
      id: id,
      question: question,
      responseType: responseType,
      options: options,
      entityType: entityType,
      entityLabel: entityLabel,
      evidenceFactIds: evidenceFactIds,
      reason: reason,
      impact: impact,
      confidence: confidence,
      proposedMemory: proposedMemory,
      resolutionTarget: resolutionTarget,
      sourceAgent: sourceAgent,
      dedupeKey: dedupeKey,
      factId: factId,
      expiresAt: expiresAt,
    );
    return result.id;
  }

  Future<ClarificationRequestCreateResult> createRequestWithResult({
    String? id,
    required String question,
    required String responseType,
    List<Map<String, dynamic>>? options,
    String? entityType,
    String? entityLabel,
    List<String>? evidenceFactIds,
    String? reason,
    String? impact,
    double? confidence,
    String? proposedMemory,
    String? resolutionTarget,
    String? sourceAgent,
    String? dedupeKey,
    String? factId,
    int? expiresAt,
  }) async {
    final trimmedDedupeKey = dedupeKey?.trim();
    if (trimmedDedupeKey != null && trimmedDedupeKey.isNotEmpty) {
      final existing = await (_db.select(_db.clarificationRequests)
            ..where((t) =>
                t.dedupeKey.equals(trimmedDedupeKey) &
                t.status.isIn([
                  ClarificationRequestStatus.pending,
                  ClarificationRequestStatus.answered,
                ]))
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        _logger.info(
            'Reusing active clarification request ${existing.id} for $trimmedDedupeKey');
        return ClarificationRequestCreateResult(
          id: existing.id,
          created: false,
          dedupeKey: trimmedDedupeKey,
        );
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestId = id ?? const Uuid().v4();

    await _db.into(_db.clarificationRequests).insert(
          ClarificationRequestsCompanion.insert(
            id: requestId,
            question: question,
            responseType: responseType,
            options: Value(options == null ? null : jsonEncode(options)),
            status: ClarificationRequestStatus.pending,
            answerData: const Value(null),
            entityType: Value(entityType),
            entityLabel: Value(entityLabel),
            evidenceFactIds: Value(
              evidenceFactIds == null ? null : jsonEncode(evidenceFactIds),
            ),
            reason: Value(reason),
            impact: Value(impact),
            confidence: Value(confidence),
            proposedMemory: Value(proposedMemory),
            resolutionTarget: Value(resolutionTarget ?? 'auto'),
            sourceAgent: Value(sourceAgent),
            dedupeKey: Value(trimmedDedupeKey),
            factId: Value(factId),
            error: const Value(null),
            createdAt: Value(now),
            updatedAt: Value(now),
            answeredAt: const Value(null),
            expiresAt: Value(expiresAt),
          ),
        );

    _logger.info('Created clarification request $requestId');
    return ClarificationRequestCreateResult(
      id: requestId,
      created: true,
      dedupeKey: trimmedDedupeKey,
    );
  }

  Stream<List<ClarificationRequest>> watchPending() {
    final query = _db.select(_db.clarificationRequests)
      ..where((t) => t.status.equals(ClarificationRequestStatus.pending))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  Future<List<ClarificationRequest>> getPending() {
    final query = _db.select(_db.clarificationRequests)
      ..where((t) => t.status.equals(ClarificationRequestStatus.pending))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  /// Dismiss all pending clarification requests (batch operation).
  Future<int> dismissAllPending() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final count = await (_db.update(_db.clarificationRequests)
            ..where((t) => t.status.equals(ClarificationRequestStatus.pending)))
          .write(ClarificationRequestsCompanion(
        status: const Value(ClarificationRequestStatus.dismissed),
        updatedAt: Value(now),
      ));
      _logger
          .info('Dismissed all pending clarification requests (count=$count)');
      return count;
    } catch (e) {
      _logger.severe('Failed to dismiss all pending requests: $e');
      return 0;
    }
  }

  Future<List<ClarificationRequest>> getVisibleForFact(String factId) async {
    // Skip if factId itself is a global Ask — those are rendered as their own
    // timeline card, not as attachments.
    if (isGlobalAsk(factId)) return const [];

    final query = _db.select(_db.clarificationRequests)
      ..where((t) =>
          t.status.isIn([
            ClarificationRequestStatus.pending,
            ClarificationRequestStatus.answered,
            ClarificationRequestStatus.completed,
            ClarificationRequestStatus.failed,
          ]) &
          t.factId.equals(factId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<ClarificationRequest?> getRequest(String requestId) {
    return (_db.select(_db.clarificationRequests)
          ..where((t) => t.id.equals(requestId)))
        .getSingleOrNull();
  }

  Future<List<ClarificationRequest>> getRecentRequests({int limit = 20}) {
    final safeLimit = limit.clamp(1, 50).toInt();
    final query = _db.select(_db.clarificationRequests)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(safeLimit);
    return query.get();
  }

  Future<bool> answerRequest(
    String requestId,
    Map<String, dynamic> answerData,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final count = await (_db.update(_db.clarificationRequests)
          ..where((t) => t.id.equals(requestId)))
        .write(
      ClarificationRequestsCompanion(
        status: const Value(ClarificationRequestStatus.answered),
        answerData: Value(jsonEncode(answerData)),
        answeredAt: Value(now),
        updatedAt: Value(now),
        error: const Value(null),
      ),
    );

    if (count == 0) return false;

    final userId = await UserStorage.getUserId();
    if (userId != null) {
      await GlobalEventBus.instance.publish(
        userId: userId,
        event: SystemEvent(
          type: SystemEventTypes.clarificationAnswered,
          source: 'clarification_request_service.answerRequest',
          payload: ClarificationAnsweredPayload(requestId: requestId),
        ),
      );
    }
    return true;
  }

  Future<bool> dismissRequest(String requestId) async {
    return updateStatus(requestId, ClarificationRequestStatus.dismissed);
  }

  /// Updates the factId of a clarification request (e.g. after creating a
  /// timeline card for a global Ask).
  Future<void> updateFactId(String requestId, String factId) async {
    await (_db.update(_db.clarificationRequests)
          ..where((t) => t.id.equals(requestId)))
        .write(ClarificationRequestsCompanion(
      factId: Value(factId),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ));
  }

  Future<bool> updateStatus(
    String requestId,
    String status, {
    String? error,
  }) async {
    final count = await (_db.update(_db.clarificationRequests)
          ..where((t) => t.id.equals(requestId)))
        .write(
      ClarificationRequestsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        error: Value(error),
      ),
    );
    return count > 0;
  }

  List<Map<String, dynamic>> decodeOptions(ClarificationRequest request) {
    if (request.options == null || request.options!.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(request.options!) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      _logger.warning('Failed to decode clarification options: $e');
      return const [];
    }
  }

  Map<String, dynamic> decodeAnswerData(ClarificationRequest request) {
    if (request.answerData == null || request.answerData!.isEmpty) {
      return const {};
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(request.answerData!));
    } catch (e) {
      _logger.warning('Failed to decode clarification answer: $e');
      return const {};
    }
  }

  List<String> decodeEvidenceFactIds(ClarificationRequest request) {
    if (request.evidenceFactIds == null || request.evidenceFactIds!.isEmpty) {
      return const [];
    }
    try {
      return (jsonDecode(request.evidenceFactIds!) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      _logger.warning('Failed to decode clarification evidence: $e');
      return const [];
    }
  }
}
