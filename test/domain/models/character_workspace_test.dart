import 'package:memex/domain/models/character_workspace.dart';
import 'package:test/test.dart';

void main() {
  test('character observation round-trips its one-time source material', () {
    final observedAt = DateTime.parse('2026-07-13T08:30:00+08:00');
    final observation = CharacterObservation(
      id: 'observation-1',
      sequence: 4,
      sourceEventId: 'event-1',
      source: CharacterObservationSources.userRecord,
      factId: '2026/07/13.md#ts_1',
      content: '66 said she still had not played enough today.',
      observedAt: observedAt,
    );

    final restored = CharacterObservation.fromJson(observation.toJson());

    expect(restored.id, observation.id);
    expect(restored.sequence, 4);
    expect(restored.sourceEventId, 'event-1');
    expect(restored.factId, '2026/07/13.md#ts_1');
    expect(restored.content, observation.content);
    expect(restored.observedAt, observedAt);
  });

  test('runtime contains only operational cursors', () {
    final runtime = const CharacterWorkspaceRuntime.initial().copyWith(
      nextObservationSequence: 8,
      lastDigestedSequence: 7,
    );

    expect(runtime.toJson(), {
      'schema_version': 1,
      'next_observation_sequence': 8,
      'last_digested_sequence': 7,
    });
    expect(runtime.toJson().keys, isNot(contains('mood')));
    expect(runtime.toJson().keys, isNot(contains('intimacy')));
    expect(runtime.toJson().keys, isNot(contains('desire')));
  });
}
