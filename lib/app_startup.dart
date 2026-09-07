/// Initializes localization before native callbacks can observe it, then runs
/// the remaining independent first-launch I/O concurrently.
Future<void> initializeStartupServices({
  required Future<void> Function() initL10n,
  required Future<void> Function() initWorkmanager,
  required Future<void> Function() initAgentBridge,
  required Future<void> Function() startLocalServer,
}) async {
  await initL10n();
  await Future.wait<void>([
    initWorkmanager(),
    initAgentBridge(),
    startLocalServer(),
  ]);
}
