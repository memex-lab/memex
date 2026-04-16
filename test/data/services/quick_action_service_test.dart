import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/quick_action_service.dart';

void main() {
  late QuickActionService service;

  setUp(() {
    service = QuickActionService.instance;
  });

  tearDown(() {
    // Reset internal state between tests
    service.detach();
  });

  group('QuickActionService', () {
    test('consumePendingAction returns null when no action queued', () async {
      service.attach();
      final action = await service.consumePendingAction();
      expect(action, isNull);
    });

    test('handleAction then consumePendingAction returns the action', () async {
      service.attach();
      service.handleAction('quick_note');
      final action = await service.consumePendingAction();
      expect(action, 'quick_note');
    });

    test('consumePendingAction is idempotent — second call returns null',
        () async {
      service.attach();
      service.handleAction('quick_note');
      await service.consumePendingAction();
      final action2 = await service.consumePendingAction();
      expect(action2, isNull);
    });

    test('cold start: action queued before attach is still consumed', () async {
      // Simulate: platform callback fires before MainScreen is built
      service.handleAction('quick_note');

      // Only after widget is ready:
      service.attach();
      final action = await service.consumePendingAction();
      expect(action, 'quick_note');
    });

    test('warm start: action arrives while no listener is attached', () async {
      service.attach();
      // Consume any initial pending action
      await service.consumePendingAction();

      // Simulate: action arrives after detach (app went to background)
      service.detach();
      service.handleAction('quick_note');

      // App comes back to foreground — re-attach and consume
      service.attach();
      final action = await service.consumePendingAction();
      expect(action, 'quick_note');
    });

    test('multiple actions — only the last one is kept', () async {
      service.attach();
      service.handleAction('action_a');
      service.handleAction('quick_note');
      final action = await service.consumePendingAction();
      // Last one wins (realistic — user can only tap one shortcut)
      expect(action, 'quick_note');
    });

    test('unknown action type is still passed through', () async {
      service.attach();
      service.handleAction('unknown_action');
      final action = await service.consumePendingAction();
      expect(action, 'unknown_action');
    });

    test('consumePendingAction times out gracefully', () async {
      service.attach();
      // No action queued — should timeout and return null
      final action = await service.consumePendingAction();
      expect(action, isNull);
    });
  });
}
