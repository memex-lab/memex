import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';

/// Shown when an AI-only action runs before a model is configured.
///
/// The copy stays in user language. It does not name the agent or the
/// config key.
class InvalidModelConfigDialog extends StatelessWidget {
  const InvalidModelConfigDialog({
    super.key,
    required this.onKeepRecording,
    required this.onTurnOnAi,
  });

  final VoidCallback onKeepRecording;
  final VoidCallback onTurnOnAi;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return AlertDialog(
      title: Text(l10n.warning),
      content: Text(l10n.invalidModelConfigPlain),
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
