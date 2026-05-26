import 'package:drift/drift.dart';

/// Tasks Table
/// Stores persistent background tasks
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get payload => text().nullable()();
  TextColumn get status =>
      text()(); // pending, processing, completed, failed, retrying
  IntColumn get priority => integer().withDefault(const Constant(0))();

  // Timestamps
  IntColumn get createdAt => integer().nullable()();
  IntColumn get scheduledAt => integer().nullable()(); // timestamp
  IntColumn get completedAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  // Retry logic
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();

  TextColumn get error => text().nullable()();
  TextColumn get result => text().nullable()();
  TextColumn get bizId => text().nullable()();
  TextColumn get dependencies => text().nullable()(); // JSON list of task IDs

  @override
  Set<Column> get primaryKey => {id};
}

/// Key-Value Store Table
/// For simple persistent storage
class KvStore extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  TextColumn get bucket => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Agent Activity Messages Table
/// Stores history of agent status updates
class AgentActivityMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 'tool_call', 'thought', 'info', 'error', 'warn', 'plan'
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get agentName => text().withDefault(const Constant('Unknown'))();
  TextColumn get agentId => text().nullable()();
  TextColumn get scene => text().nullable()();
  TextColumn get sceneId => text().nullable()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}

/// Card Metadata Cache Table
/// Stores extracted metadata for quick filtering and querying
class CardCache extends Table {
  TextColumn get factId => text()(); // Primary Key: yyyy/mm/dd.md#ts_n
  TextColumn get cardPath => text()(); // Relative path or absolute path
  IntColumn get timestamp => integer()(); // Seconds since epoch
  TextColumn get tags => text()(); // JSON list of string tags

  @override
  Set<Column> get primaryKey => {factId};
}

/// System Actions Table
/// Stores system-level actions (e.g. Calendar, Reminders) waiting for user confirmation
class SystemActions extends Table {
  TextColumn get id => text()(); // Primary Key: uuid
  TextColumn get actionType => text()(); // 'calendar', 'reminder'
  TextColumn get actionData =>
      text().nullable()(); // JSON payload (title, start_time, etc.)
  TextColumn get status =>
      text()(); // 'pending', 'completed', 'failed', 'dismissed', 'rejected'
  TextColumn get factId => text().nullable()(); // Associated fact_id
  IntColumn get createdAt => integer().nullable()(); // Seconds since epoch
  IntColumn get updatedAt => integer().nullable()(); // Seconds since epoch

  @override
  Set<Column> get primaryKey => {id};
}

/// Clarification Requests Table
/// Stores agent-created questions that need a lightweight user answer.
class ClarificationRequests extends Table {
  TextColumn get id => text()();
  TextColumn get question => text()();
  TextColumn get responseType =>
      text()(); // confirm, single_choice, multi_choice, short_text
  TextColumn get options => text().nullable()(); // JSON list
  TextColumn get status =>
      text()(); // pending, answered, completed, dismissed, failed, expired
  TextColumn get answerData => text().nullable()(); // JSON payload
  TextColumn get entityType => text().nullable()();
  TextColumn get entityLabel => text().nullable()();
  TextColumn get evidenceFactIds => text().nullable()(); // JSON list
  TextColumn get reason => text().nullable()();
  TextColumn get impact => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get proposedMemory => text().nullable()();
  TextColumn get resolutionTarget =>
      text().nullable()(); // auto, memory, pkm, card, insight, none
  TextColumn get sourceAgent => text().nullable()();
  TextColumn get dedupeKey => text().nullable()();
  TextColumn get factId => text().nullable()();
  TextColumn get error => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get answeredAt => integer().nullable()();
  IntColumn get expiresAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Generic per-user notification table. Producer writes rows keyed by
/// (userId, notificationType, subjectKey). Physical delete model:
/// dismissing a notification removes its row. At most one row per triple,
/// enforced by a UNIQUE index.
class UserNotifications extends Table {
  /// UUID v4 string.
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// Open string namespace. First value: 'card_detail_update'.
  TextColumn get notificationType => text()();

  /// Type-specific aggregation key. For card_detail_update: factId.
  TextColumn get subjectKey => text()();

  /// Opaque JSON blob defined by the producer. Null allowed.
  TextColumn get payload => text().nullable()();

  /// Seconds since epoch.
  IntColumn get createdAt => integer()();

  /// Seconds since epoch.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Persona Chat Messages Table
/// Stores chat messages between user and their AI companion character.
class PersonaChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get characterId => text()();
  BoolColumn get isFromCharacter => boolean()();
  TextColumn get content => text()();
  TextColumn get factId => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime()();

  /// Message type: 'chat' (default) or 'action' (narrative/action description).
  TextColumn get messageType => text().withDefault(const Constant('chat'))();
}
