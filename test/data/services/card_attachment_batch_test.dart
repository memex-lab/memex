import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/db/app_database.dart';

void main() {
  test('mergeAttachmentsForFacts groups two queries by fact id', () {
    const first = SystemAction(
      id: 'a1',
      actionType: 'calendar',
      actionData: '{}',
      status: 'pending',
      factId: 'fact-a',
      createdAt: 1,
      updatedAt: 1,
    );
    const second = SystemAction(
      id: 'a2',
      actionType: 'calendar',
      actionData: '{}',
      status: 'pending',
      factId: 'fact-b',
      createdAt: 1,
      updatedAt: 1,
    );
    const request = ClarificationRequest(
      id: 'c1',
      question: 'Which day?',
      responseType: 'confirm',
      status: 'pending',
      factId: 'fact-a',
      createdAt: 1,
      updatedAt: 1,
    );

    final merged = mergeAttachmentsForFacts(
      factIds: ['fact-a', 'fact-b', 'fact-c'],
      actions: [first, second],
      requests: [request],
    );

    expect(merged.keys, ['fact-a', 'fact-b', 'fact-c']);
    expect(merged['fact-a']!.map((item) => item.id), [
      'clarification_c1',
      'system_action_a1',
    ]);
    expect(merged['fact-b']!.single.id, 'system_action_a2');
    expect(merged['fact-c'], isEmpty);
  });

  test('mergeAttachmentsForFacts is stable for the same sort key', () {
    const later = SystemAction(
      id: 'a2',
      actionType: 'calendar',
      actionData: '{}',
      status: 'pending',
      factId: 'fact-a',
      createdAt: 1,
      updatedAt: 1,
    );
    const earlier = SystemAction(
      id: 'a1',
      actionType: 'calendar',
      actionData: '{}',
      status: 'pending',
      factId: 'fact-a',
      createdAt: 1,
      updatedAt: 1,
    );

    final merged = mergeAttachmentsForFacts(
      factIds: ['fact-a'],
      actions: [later, earlier],
      requests: const [],
    );

    expect(merged['fact-a']!.map((item) => item.id), [
      'system_action_a1',
      'system_action_a2',
    ]);
  });

  test('mergeAttachmentsForFacts returns an empty map for no facts', () {
    expect(
      mergeAttachmentsForFacts(
        factIds: const [],
        actions: const [],
        requests: const [],
      ),
      isEmpty,
    );
  });
}
