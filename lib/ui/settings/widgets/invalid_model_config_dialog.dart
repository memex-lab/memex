import 'package:flutter/material.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/user_storage.dart';

/// Shown when an AI-only action cannot run.
///
/// A missing model keeps the "turn AI on" copy. A missing key or endpoint
/// uses the same sentence as the chat error, still without the agent name
/// or config key.
class InvalidModelConfigDialog extends StatelessWidget {
  const InvalidModelConfigDialog({
    super.key,
    this.reason = InvalidModelConfigReason.notConfigured,
    this.detail = '',
    required this.onKeepRecording,
    required this.onTurnOnAi,
  });

  final InvalidModelConfigReason reason;
  final String detail;
  final VoidCallback onKeepRecording;
  final VoidCallback onTurnOnAi;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    final message = reason == InvalidModelConfigReason.notConfigured
        ? l10n.invalidModelConfigPlain
        : l10n.operationFailed(detail);
    return AlertDialog(
      title: Text(l10n.warning),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onKeepRecording,
          child: Text(l10n.keepRecording),
        ),
        ElevatedButton(
          onPressed: onTurnOnAi,
          child: Text(l10n.turnOnAi),
        ),
      ],
    );
  }
}
