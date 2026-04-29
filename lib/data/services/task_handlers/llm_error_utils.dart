import 'dart:async';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final Logger _logger = getLogger('LlmErrorUtils');

/// Unwrap wrapper exceptions to get the root cause error.
/// Handles AgentException and NonRetryableLlmException chains.
Object _unwrapError(Object error) {
  Object actual = error;
  // Unwrap NonRetryableLlmException first (it wraps the original error)
  if (actual is NonRetryableLlmException && actual.originalError != null) {
    actual = actual.originalError!;
  }
  // Then unwrap AgentException
  if (actual is AgentException && actual.error != null) {
    actual = actual.error!;
  }
  return actual;
}

/// LLM API error categories for structured error handling.
enum LlmErrorCategory {
  authenticationError,
  badRequest,
  rateLimit,
  serverError,
  networkError,
  unknownError,
}

/// Classify an error into an [LlmErrorCategory].
///
/// If [error] is an [AgentException], extracts the original exception via
/// `error.error` before classification.
LlmErrorCategory classifyError(Object error) {
  final actual = _unwrapError(error);

  if (actual is SocketException || actual is TimeoutException) {
    return LlmErrorCategory.networkError;
  }

  final errorStr = actual.toString();

  if (RegExp(r'\b40[13]\b').hasMatch(errorStr)) {
    return LlmErrorCategory.authenticationError;
  }
  if (RegExp(r'\b400\b').hasMatch(errorStr)) {
    return LlmErrorCategory.badRequest;
  }
  if (RegExp(r'\b429\b').hasMatch(errorStr)) {
    return LlmErrorCategory.rateLimit;
  }
  if (RegExp(r'\b5\d{2}\b').hasMatch(errorStr)) {
    return LlmErrorCategory.serverError;
  }
  if (errorStr.contains('SocketException') ||
      errorStr.contains('TimeoutException')) {
    return LlmErrorCategory.networkError;
  }

  return LlmErrorCategory.unknownError;
}

/// Generate a localized, user-friendly error message for the given [category].
String getLocalizedErrorMessage(LlmErrorCategory category, Object error) {
  final l10n = UserStorage.l10n;

  String message;
  switch (category) {
    case LlmErrorCategory.authenticationError:
      message = l10n.llmAuthError;
    case LlmErrorCategory.badRequest:
      message = l10n.llmBadRequestError;
    case LlmErrorCategory.rateLimit:
      message = l10n.llmRateLimitError;
    case LlmErrorCategory.serverError:
      message = l10n.llmServerError;
    case LlmErrorCategory.networkError:
      message = l10n.llmNetworkError;
    case LlmErrorCategory.unknownError:
      message = l10n.llmUnknownError;
  }

  Object actual = _unwrapError(error);
  final errorStr = actual.toString();
  final statusMatch = RegExp(r'\b([45]\d{2})\b').firstMatch(errorStr);
  if (statusMatch != null) {
    // Extract the error detail after the status code if possible
    // e.g. "Failed to generate from OpenAI: 400 Bad Request {error: {message: ...}}"
    final errorDetail = _extractErrorDetail(errorStr);
    if (errorDetail != null && errorDetail.isNotEmpty) {
      message = '$message\n\nHTTP ${statusMatch.group(1)}: $errorDetail';
    } else {
      message = '$message (HTTP ${statusMatch.group(1)})';
    }
  }

  return message;
}

/// Try to extract a meaningful error detail from the raw error string.
/// Looks for common patterns like `{message: ...}` or text after status code.
String? _extractErrorDetail(String errorStr) {
  // Try to find JSON-like message field: message: ...
  final msgMatch =
      RegExp(r'message:\s*(.+?)(?:,\s*type:|[}]|$)').firstMatch(errorStr);
  if (msgMatch != null) {
    return msgMatch.group(1)?.trim();
  }
  // Fallback: text after "NNN StatusText "
  final afterCode =
      RegExp(r'\b[45]\d{2}\s+\w[\w\s]*?\s+(.+)').firstMatch(errorStr);
  if (afterCode != null) {
    final detail = afterCode.group(1)?.trim();
    if (detail != null && detail.length > 5) return detail;
  }
  return null;
}

/// Generic failure handler that emits an [ErrorNotificationMessage] via EventBus.
/// Register this for any task type that calls LLM agents.
Future<void> handleGenericAgentFailure(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  _logger.severe(
      'Agent task ${context.taskType} failed permanently for user: $userId, error: $error');

  try {
    if (_unwrapError(error) is InvalidModelConfigException) {
      _logger.info(
          'Suppressing generic error notification for invalid model config.');
      return;
    }

    final category = classifyError(error);
    final friendlyMessage = getLocalizedErrorMessage(category, error);

    EventBusService.instance.emitEvent(ErrorNotificationMessage(
      errorCategory: category.name,
      errorMessage: friendlyMessage,
    ));
  } catch (e) {
    _logger.warning('Failed to emit error notification: $e');
  }
}

/// Check if [error] is a non-retryable LLM error (400, 401, 403, 404).
/// If so, throw a [NonRetryableLlmException] so that [LocalTaskExecutor]
/// skips task-level retries and invokes the failure handler immediately.
///
/// Call this in task handlers after catching agent exceptions:
/// ```dart
/// } catch (e, stack) {
///   rethrowIfNonRetryable(e);
/// }
/// ```
Never rethrowIfNonRetryable(Object error) {
  final category = classifyError(error);
  final statusCode = _extractStatusCode(error);

  // 400-class errors (auth, bad request) are never worth retrying
  if (category == LlmErrorCategory.authenticationError ||
      category == LlmErrorCategory.badRequest ||
      (statusCode != null &&
          statusCode >= 400 &&
          statusCode < 500 &&
          statusCode != 429)) {
    throw NonRetryableLlmException(
      _describeCategory(category, statusCode),
      statusCode: statusCode,
      originalError: error,
    );
  }
  // For other categories (5xx, network, unknown), rethrow to allow task-level retries
  throw error;
}

String _describeCategory(LlmErrorCategory category, int? statusCode) {
  switch (category) {
    case LlmErrorCategory.authenticationError:
      return 'Authentication failed';
    case LlmErrorCategory.badRequest:
      return 'Bad request';
    case LlmErrorCategory.rateLimit:
      return 'Rate limit exceeded';
    case LlmErrorCategory.serverError:
      return 'Server error';
    case LlmErrorCategory.networkError:
      return 'Network error';
    case LlmErrorCategory.unknownError:
      return statusCode != null
          ? 'Client error ($statusCode)'
          : 'Unknown error';
  }
}

int? _extractStatusCode(Object error) {
  final actual = _unwrapError(error);
  final match = RegExp(r'\b([45]\d{2})\b').firstMatch(actual.toString());
  return match != null ? int.tryParse(match.group(1)!) : null;
}

/// Check if the upstream `handle_analyze_assets` task failed for this bizId.
/// If it failed AND [combinedText] contains no user text (media-only input),
/// throw a [NonRetryableLlmException] so downstream agents fail immediately
/// with the original asset analysis error.
///
/// [combinedText] is the raw fact content which may contain asset markers
/// like `![...](fs://...)` and `[audio](fs://...)`.
Future<void> failIfAssetAnalysisFailed({
  required String? bizId,
  required String combinedText,
}) async {
  if (bizId == null) return;

  final assetError = await LocalTaskExecutor.instance
      .getTaskErrorByBizId('handle_analyze_assets', bizId);
  if (assetError == null) return; // not failed or no such task

  // Strip asset markers to check if there's any user text
  final textOnly = combinedText
      .replaceAll(RegExp(r'!\[.*?\]\(fs://[^\)]+\)'), '') // images
      .replaceAll(RegExp(r'\[.*?\]\(fs://[^\)]+\)'), '') // audio
      .trim();

  if (textOnly.isEmpty) {
    // Media-only input with failed analysis — no point running the agent
    // Pass the raw error string so getLocalizedErrorMessage can extract details
    throw NonRetryableLlmException(
      'Media analysis failed',
      originalError: Exception(assetError),
    );
  }
}
