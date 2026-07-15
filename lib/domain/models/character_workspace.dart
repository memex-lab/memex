class CharacterObservationSources {
  CharacterObservationSources._();

  static const String userRecord = 'user_record';
}

/// A one-time piece of source material delivered to a character.
///
/// Raw [content] lives only in the character inbox. After digestion, the
/// workspace keeps a content-free index entry while the character's own PKM
/// and journal become the durable memory.
class CharacterObservation {
  const CharacterObservation({
    required this.id,
    required this.sequence,
    required this.sourceEventId,
    required this.source,
    required this.content,
    required this.observedAt,
    this.factId,
  });

  final String id;
  final int sequence;
  final String sourceEventId;
  final String source;
  final String? factId;
  final String content;
  final DateTime observedAt;

  factory CharacterObservation.fromJson(Map<String, dynamic> json) {
    return CharacterObservation(
      id: json['id'] as String,
      sequence: (json['sequence'] as num).toInt(),
      sourceEventId: json['source_event_id'] as String,
      source: json['source'] as String,
      factId: json['fact_id'] as String?,
      content: json['content'] as String,
      observedAt: DateTime.parse(json['observed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequence': sequence,
        'source_event_id': sourceEventId,
        'source': source,
        if (factId != null) 'fact_id': factId,
        'content': content,
        'observed_at': observedAt.toIso8601String(),
      };
}

/// Operational cursor for a character workspace.
///
/// This deliberately contains no modeled mood, intimacy, or relationship
/// state. Those belong in character-authored memory, not runtime fields.
class CharacterWorkspaceRuntime {
  const CharacterWorkspaceRuntime({
    required this.nextObservationSequence,
    required this.lastDigestedSequence,
    this.schemaVersion = 1,
  });

  const CharacterWorkspaceRuntime.initial()
      : schemaVersion = 1,
        nextObservationSequence = 1,
        lastDigestedSequence = 0;

  final int schemaVersion;
  final int nextObservationSequence;
  final int lastDigestedSequence;

  factory CharacterWorkspaceRuntime.fromJson(Map<String, dynamic> json) {
    return CharacterWorkspaceRuntime(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      nextObservationSequence:
          (json['next_observation_sequence'] as num?)?.toInt() ?? 1,
      lastDigestedSequence:
          (json['last_digested_sequence'] as num?)?.toInt() ?? 0,
    );
  }

  CharacterWorkspaceRuntime copyWith({
    int? nextObservationSequence,
    int? lastDigestedSequence,
  }) {
    return CharacterWorkspaceRuntime(
      schemaVersion: schemaVersion,
      nextObservationSequence:
          nextObservationSequence ?? this.nextObservationSequence,
      lastDigestedSequence: lastDigestedSequence ?? this.lastDigestedSequence,
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'next_observation_sequence': nextObservationSequence,
        'last_digested_sequence': lastDigestedSequence,
      };
}
