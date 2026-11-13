import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:memex/db/app_database.dart';
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
    return getVisibleForFacts([factId]);
  }

  Future<List<ClarificationRequest>> getVisibleForFacts(
    List<String> factIds,
  ) async {
    if (factIds.isEmpty) return [];
    final query = _db.select(_db.clarificationRequests)
      ..where((t) =>
          t.status.isIn([
            ClarificationRequestStatus.pending,
            ClarificationRequestStatus.answered,
            ClarificationRequestStatus.completed,
            ClarificationRequestStatus.failed,
          ]) &
          t.factId.isIn(factIds))
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

    return true;
  }

  Future<bool> dismissRequest(String requestId) async {
    return updateStatus(requestId, ClarificationRequestStatus.dismissed);
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
