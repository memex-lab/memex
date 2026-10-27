/// Lock-screen session for the app shell.
///
/// Cold start stays on the PIN pad until [onUnlock]. After that, pausing
/// covers the journal with the privacy screen, and returning inside the grace
/// period skips the PIN. Pausing before the first unlock must not do that.
class AppLockSession {
  AppLockSession({
    this.isLocked = true,
    this.requiresAuth = true,
    this.sessionUnlocked = false,
    this.lastPausedAt,
  });

  static const int graceMinutes = 5;

  bool isLocked;
  bool requiresAuth;
  bool sessionUnlocked;
  DateTime? lastPausedAt;

  void onLockDisabled() {
    isLocked = false;
  }

  void notePaused(DateTime now) {
    lastPausedAt = now;
  }

  /// Cover the UI when the lock is enabled.
  ///
  /// A session that already passed the PIN gets the privacy screen so the app
  /// switcher does not show the journal. A session that has not unlocked keeps
  /// the PIN pad.
  void coverOnPause({required bool lockEnabled}) {
    if (!lockEnabled) return;
    isLocked = true;
    requiresAuth = !sessionUnlocked;
  }

  void onResume(DateTime now) {
    if (!isLocked) return;

    final pausedAt = lastPausedAt;
    final withinGrace =
        pausedAt != null && now.difference(pausedAt).inMinutes < graceMinutes;
    if (sessionUnlocked && withinGrace) {
      isLocked = false;
      return;
    }

    requiresAuth = true;
    if (pausedAt != null && !withinGrace) {
      sessionUnlocked = false;
    }
  }

  void onUnlock() {
    isLocked = false;
    sessionUnlocked = true;
  }
}
