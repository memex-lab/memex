import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/app_lock/app_lock_session.dart';

void main() {
  final start = DateTime(2026, 10, 27, 9);

  test('backgrounding before the PIN does not unlock on resume', () {
    final session = AppLockSession();

    session.notePaused(start);
    session.coverOnPause(lockEnabled: true);
    session.onResume(start.add(const Duration(minutes: 1)));

    expect(session.isLocked, isTrue);
    expect(session.requiresAuth, isTrue);
    expect(session.sessionUnlocked, isFalse);
  });

  test('an unlocked session returns without a PIN inside the grace period', () {
    final session = AppLockSession();
    session.onUnlock();

    session.notePaused(start);
    session.coverOnPause(lockEnabled: true);
    expect(session.isLocked, isTrue);
    expect(session.requiresAuth, isFalse);

    session.onResume(start.add(const Duration(minutes: 4)));

    expect(session.isLocked, isFalse);
    expect(session.sessionUnlocked, isTrue);
  });

  test('grace expiry asks for the PIN again', () {
    final session = AppLockSession();
    session.onUnlock();
    session.notePaused(start);
    session.coverOnPause(lockEnabled: true);

    session.onResume(start.add(const Duration(minutes: 5)));

    expect(session.isLocked, isTrue);
    expect(session.requiresAuth, isTrue);
    expect(session.sessionUnlocked, isFalse);
  });

  test('a second pause after grace expiry still requires the PIN', () {
    final session = AppLockSession();
    session.onUnlock();
    final paused = start;
    session.notePaused(paused);
    session.coverOnPause(lockEnabled: true);
    session.onResume(paused.add(const Duration(minutes: 5)));

    final again = paused.add(const Duration(minutes: 6));
    session.notePaused(again);
    session.coverOnPause(lockEnabled: true);
    session.onResume(again.add(const Duration(minutes: 1)));

    expect(session.isLocked, isTrue);
    expect(session.requiresAuth, isTrue);
  });

  test('lock disabled leaves the session open across pause', () {
    final session = AppLockSession();
    session.onLockDisabled();

    session.notePaused(start);
    session.coverOnPause(lockEnabled: false);
    session.onResume(start.add(const Duration(minutes: 1)));

    expect(session.isLocked, isFalse);
  });
}
