/// Base exception for tasks that should fail immediately instead of retrying.
abstract class NonRetryableTaskException implements Exception {
  String get message;
}

/// Why [InvalidModelConfigException] was thrown.
///
/// [notConfigured] is the "AI is off" case. Credential failures stay separate
/// so chat does not tell the user to turn AI on when OAuth or a key is the
/// actual problem.
enum InvalidModelConfigReason {
  notConfigured,
  emptyApiKey,
  oauth,
  other,
}

/// Exception thrown when LLM configuration is invalid or missing required fields.
class InvalidModelConfigException implements NonRetryableTaskException {
  @override
  final String message;
  final InvalidModelConfigReason reason;

  InvalidModelConfigException([
    this.message = 'The LLM configuration is invalid.',
    this.reason = InvalidModelConfigReason.notConfigured,
  ]);

  @override
  String toString() => "InvalidModelConfigException: $message";
}

/// Exception thrown when an LLM API call fails with a non-retryable HTTP error
/// (e.g. 401, 403, 400). Task executor will skip retries and invoke the failure handler.
class NonRetryableLlmException implements NonRetryableTaskException {
  @override
  final String message;

  final int? statusCode;
  final Object? originalError;

  NonRetryableLlmException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() {
    final buf = StringBuffer('NonRetryableLlmException: $message');
    if (statusCode != null) buf.write(' (HTTP $statusCode)');
    if (originalError != null) buf.write('\nOriginal error: $originalError');
    return buf.toString();
  }
}

/// Exception thrown when an agent reached its max-turn/loop guard.
class NonRetryableAgentLoopException implements NonRetryableTaskException {
  @override
  final String message;

  final Object? originalError;

  NonRetryableAgentLoopException(this.message, {this.originalError});

  @override
  String toString() {
    final buf = StringBuffer('NonRetryableAgentLoopException: $message');
    if (originalError != null) buf.write('\nOriginal error: $originalError');
    return buf.toString();
  }
}
