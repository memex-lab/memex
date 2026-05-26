class CardGenerationRetryResult {
  final int requested;
  final int retried;
  final int skipped;
  final Map<String, String> errors;

  const CardGenerationRetryResult({
    required this.requested,
    required this.retried,
    required this.skipped,
    this.errors = const {},
  });

  bool get hasErrors => errors.isNotEmpty;
}
