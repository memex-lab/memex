import 'dart:async';

import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:test/test.dart';

void main() {
  test('serializes different scenes for the same character', () async {
    final coordinator = CharacterExecutionCoordinator();
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    var secondStarted = false;

    final first = coordinator.run(
      userId: 'user-1',
      characterId: 'yaoyao',
      action: () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
    );
    await firstStarted.future;

    final second = coordinator.run(
      userId: 'user-1',
      characterId: 'yaoyao',
      action: () async {
        secondStarted = true;
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(secondStarted, isFalse);

    releaseFirst.complete();
    await Future.wait([first, second]);
    expect(secondStarted, isTrue);
  });

  test('does not block a different character', () async {
    final coordinator = CharacterExecutionCoordinator();
    final releaseFirst = Completer<void>();
    final first = coordinator.run(
      userId: 'user-1',
      characterId: 'yaoyao',
      action: () => releaseFirst.future,
    );

    var otherRan = false;
    await coordinator.run(
      userId: 'user-1',
      characterId: 'friend',
      action: () async => otherRan = true,
    );
    expect(otherRan, isTrue);

    releaseFirst.complete();
    await first;
  });
}
