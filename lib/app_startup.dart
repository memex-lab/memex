/// Runs independent first-launch I/O together so l10n, Workmanager, the
/// agent bridge, and the local asset server do not wait on each other.
Future<void> initializeIndependentStartupServices({
  required Future<void> Function() initL10n,
  required Future<void> Function() initWorkmanager,
  required Future<void> Function() initAgentBridge,
  required Future<void> Function() startLocalServer,
}) {
  return Future.wait<void>([
    initL10n(),
    initWorkmanager(),
    initAgentBridge(),
    startLocalServer(),
  ]);
}
