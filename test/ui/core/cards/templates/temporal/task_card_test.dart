import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/cards/templates/temporal/task_card.dart';

void main() {
  testWidgets('parent completion updates every grouped subtask', (
    tester,
  ) async {
    final updates = <Map<String, dynamic>>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            cardId: 'task-1',
            configIndex: 0,
            data: const {
              'title': 'Visa checklist',
              'is_completed': false,
              'subtasks': [
                {'title': 'Collect documents', 'completed': false},
                {'title': 'Submit form', 'completed': false},
              ],
            },
            onUpdate: (_, __, data) => updates.add(data),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task_card_toggle_task-1')));
    await tester.pump();

    expect(updates.last['is_completed'], isTrue);
    expect(
      (updates.last['subtasks'] as List).map(
        (subtask) => (subtask as Map)['completed'],
      ),
      [true, true],
    );
  });

  testWidgets('last completed subtask completes the parent task', (
    tester,
  ) async {
    final updates = <Map<String, dynamic>>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            cardId: 'task-1',
            configIndex: 0,
            data: const {
              'title': 'Visa checklist',
              'is_completed': false,
              'subtasks': [
                {'title': 'Collect documents', 'completed': true},
                {'title': 'Submit form', 'completed': false},
              ],
            },
            onUpdate: (_, __, data) => updates.add(data),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task_card_subtask_task-1_1')));
    await tester.pump();

    expect(updates.last['is_completed'], isTrue);
    expect(
      (updates.last['subtasks'] as List).map(
        (subtask) => (subtask as Map)['completed'],
      ),
      [true, true],
    );
  });
}
