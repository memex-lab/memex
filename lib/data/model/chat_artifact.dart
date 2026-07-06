/// A user-visible UI artifact produced by an agent turn.
///
/// Tool trace events stay transient. Artifacts are persisted on the completed
/// assistant message so reopened chats can reconstruct the final app updates.
class ChatArtifact {
  ChatArtifact({
    required this.artifactId,
    required this.kind,
    required this.operation,
    this.title,
    this.summary,
    this.targetUri,
    this.storageUri,
    this.sourceRunId,
    this.sourceToolCallId,
    DateTime? createdAt,
    Map<String, dynamic> metadata = const {},
    this.version = schemaVersion,
  })  : createdAt = createdAt ?? DateTime.now(),
        metadata = Map.unmodifiable(metadata);

  static const int schemaVersion = 2;

  static const String kindTimelineCard = 'timeline_card';
  static const String kindKnowledgeInsight = 'knowledge_insight';
  static const String kindKnowledgeFile = 'knowledge_file';
  static const String kindWorkspaceFile = 'workspace_file';
  static const String kindSchedule = 'schedule';
  static const String kindSystemAction = 'system_action';
  static const String kindUiTemplate = 'ui_template';

  static const String operationCreate = 'create';
  static const String operationUpdate = 'update';
  static const String operationSave = 'save';

  static const Set<String> _knownKinds = {
    kindTimelineCard,
    kindKnowledgeInsight,
    kindKnowledgeFile,
    kindWorkspaceFile,
    kindSchedule,
    kindSystemAction,
    kindUiTemplate,
  };

  static const Set<String> _knownOperations = {
    operationCreate,
    operationUpdate,
    operationSave,
  };

  final String artifactId;
  final String kind;
  final String operation;
  final String? title;
  final String? summary;

  /// Deep-link destination, e.g. `memex://timeline-card/<id>`,
  /// `memex://insight/<id>`, `memex://schedule`, or `workspace:///PKM/a.md`.
  final String? targetUri;

  /// Physical storage location when different from [targetUri].
  final String? storageUri;

  /// Current chat turn id until a durable AgentRun id exists.
  final String? sourceRunId;
  final String? sourceToolCallId;
  final int version;
  final DateTime createdAt;

  /// Domain-specific display hints such as tags, image paths, or file excerpts.
  final Map<String, dynamic> metadata;

  bool get updated => operation == operationUpdate;

  List<String> get imagePaths => _stringList(metadata['image_paths']);

  List<String> get tags => _stringList(metadata['tags']);

  String? get systemActionKind => _nonEmpty(metadata['system_action_kind']);

  String? get timelineCardId => _memexTargetId('timeline-card');

  String? get knowledgeInsightId => _memexTargetId('insight');

  String? get knowledgeFilePath {
    if (kind != kindKnowledgeFile) return null;
    return knowledgeFilePathFromWorkspacePath(workspacePath);
  }

  String? get workspacePath {
    for (final value in [targetUri, storageUri]) {
      final uri = _tryParseUri(value);
      if (uri == null || uri.scheme != 'workspace') continue;
      if (uri.pathSegments.isEmpty) continue;
      return uri.pathSegments.join('/');
    }
    return null;
  }

  factory ChatArtifact.timelineCard({
    required String cardId,
    String? title,
    String? summary,
    List<String> imagePaths = const [],
    List<String> tags = const [],
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final targetUri = timelineCardTargetUri(cardId);
    return ChatArtifact(
      artifactId: artifactIdFor(kindTimelineCard, targetUri),
      kind: kindTimelineCard,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
      metadata: {
        if (imagePaths.isNotEmpty) 'image_paths': imagePaths,
        if (tags.isNotEmpty) 'tags': tags,
      },
    );
  }

  factory ChatArtifact.knowledgeInsight({
    required String insightId,
    String? title,
    String? summary,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final targetUri = insightTargetUri(insightId);
    return ChatArtifact(
      artifactId: artifactIdFor(kindKnowledgeInsight, targetUri),
      kind: kindKnowledgeInsight,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
    );
  }

  factory ChatArtifact.knowledgeFile({
    required String path,
    String? title,
    String? summary,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final targetUri = workspaceTargetUri(path);
    return ChatArtifact(
      artifactId: artifactIdFor(kindKnowledgeFile, targetUri),
      kind: kindKnowledgeFile,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      storageUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
    );
  }

  factory ChatArtifact.workspaceFile({
    required String path,
    String? title,
    String? summary,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final targetUri = workspaceTargetUri(path);
    return ChatArtifact(
      artifactId: artifactIdFor(kindWorkspaceFile, targetUri),
      kind: kindWorkspaceFile,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      storageUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
    );
  }

  factory ChatArtifact.uiTemplate({
    required String templateId,
    required String path,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final targetUri = workspaceTargetUri(path);
    return ChatArtifact(
      artifactId: artifactIdFor(kindUiTemplate, targetUri),
      kind: kindUiTemplate,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(templateId),
      targetUri: targetUri,
      storageUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
    );
  }

  factory ChatArtifact.schedule({
    String? title,
    String? summary,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    const targetUri = 'memex://schedule';
    return ChatArtifact(
      artifactId: artifactIdFor(kindSchedule, targetUri),
      kind: kindSchedule,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
    );
  }

  factory ChatArtifact.systemAction({
    required String systemActionKind,
    String? title,
    String? summary,
    required bool updated,
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final normalizedKind = _nonEmpty(systemActionKind) ?? 'action';
    final targetUri =
        'memex://system-action/${Uri.encodeComponent(normalizedKind)}';
    return ChatArtifact(
      artifactId: artifactIdFor(kindSystemAction, targetUri),
      kind: kindSystemAction,
      operation: updated ? operationUpdate : operationCreate,
      title: _nonEmpty(title),
      summary: _nonEmpty(summary),
      targetUri: targetUri,
      sourceRunId: sourceRunId,
      sourceToolCallId: sourceToolCallId,
      createdAt: createdAt,
      metadata: {'system_action_kind': normalizedKind},
    );
  }

  static ChatArtifact? fromToolMetadata(Map<String, dynamic>? metadata) {
    final raw = metadata?['artifact'];
    if (raw is Map) return fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  static List<ChatArtifact> listFromToolMetadata(
    Map<String, dynamic>? metadata,
  ) {
    if (metadata == null) return const [];
    final artifacts = <ChatArtifact>[];
    final single = fromToolMetadata(metadata);
    if (single != null) artifacts.add(single);

    final rawList = metadata['artifacts'];
    if (rawList is List) {
      for (final raw in rawList) {
        if (raw is! Map) continue;
        final artifact = fromJson(Map<String, dynamic>.from(raw));
        if (artifact != null) artifacts.add(artifact);
      }
    }
    return artifacts;
  }

  static ChatArtifact? fromJson(Map<String, dynamic> map) {
    if (map['version'] != schemaVersion) return null;

    final artifactId = _nonEmpty(map['artifact_id']);
    final kind = _nonEmpty(map['kind']);
    final operation = _nonEmpty(map['operation']);
    if (artifactId == null ||
        kind == null ||
        operation == null ||
        !_knownKinds.contains(kind) ||
        !_knownOperations.contains(operation)) {
      return null;
    }

    final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.now();
    final rawMetadata = map['metadata'];

    return ChatArtifact(
      artifactId: artifactId,
      kind: kind,
      operation: operation,
      title: _nonEmpty(map['title']),
      summary: _nonEmpty(map['summary']),
      targetUri: _nonEmpty(map['target_uri']),
      storageUri: _nonEmpty(map['storage_uri']),
      sourceRunId: _nonEmpty(map['source_run_id']),
      sourceToolCallId: _nonEmpty(map['source_tool_call_id']),
      createdAt: createdAt,
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : const <String, dynamic>{},
    );
  }

  ChatArtifact withSource({
    String? sourceRunId,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    return ChatArtifact(
      artifactId: artifactId,
      kind: kind,
      operation: operation,
      title: title,
      summary: summary,
      targetUri: targetUri,
      storageUri: storageUri,
      sourceRunId: this.sourceRunId ?? _nonEmpty(sourceRunId),
      sourceToolCallId: this.sourceToolCallId ?? _nonEmpty(sourceToolCallId),
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata,
      version: version,
    );
  }

  Map<String, dynamic> toJson() => {
        'artifact_id': artifactId,
        'kind': kind,
        'operation': operation,
        if (title != null) 'title': title,
        if (summary != null) 'summary': summary,
        if (targetUri != null) 'target_uri': targetUri,
        if (storageUri != null) 'storage_uri': storageUri,
        if (sourceRunId != null) 'source_run_id': sourceRunId,
        if (sourceToolCallId != null) 'source_tool_call_id': sourceToolCallId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  String? _memexTargetId(String host) {
    final uri = _tryParseUri(targetUri);
    if (uri == null || uri.scheme != 'memex' || uri.host != host) {
      return null;
    }
    if (uri.pathSegments.isEmpty) return null;
    return uri.pathSegments.first;
  }

  static String timelineCardTargetUri(String cardId) {
    return 'memex://timeline-card/${Uri.encodeComponent(cardId)}';
  }

  static String insightTargetUri(String insightId) {
    return 'memex://insight/${Uri.encodeComponent(insightId)}';
  }

  static String workspaceTargetUri(String path) {
    final normalized = path.trim().replaceAll('\\', '/');
    final encoded = normalized
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
    return 'workspace:///$encoded';
  }

  static String? knowledgeFilePathFromWorkspacePath(String? path) {
    final normalized = _normalizeWorkspacePath(path);
    if (normalized == null || !normalized.endsWith('.md')) return null;
    if (!normalized.startsWith('PKM/')) return null;
    final relativePath = normalized.substring('PKM/'.length).trim();
    return relativePath.isEmpty ? null : relativePath;
  }

  static String artifactIdFor(String kind, String targetUri) {
    return '$kind:$targetUri';
  }

  static Uri? _tryParseUri(String? value) {
    final text = _nonEmpty(value);
    if (text == null) return null;
    return Uri.tryParse(text);
  }

  static String? _normalizeWorkspacePath(String? value) {
    final text = _nonEmpty(value)?.replaceAll('\\', '/');
    if (text == null) return null;
    final normalized =
        text.split('/').where((segment) => segment.trim().isNotEmpty).join('/');
    return normalized.isEmpty ? null : normalized;
  }

  static String? _nonEmpty(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

class ChatTurnArtifactCollector {
  ChatTurnArtifactCollector({required this.sourceRunId});

  final String sourceRunId;
  final Map<String, ChatArtifact> _artifactsByKey = {};

  List<ChatArtifact> addFromToolResult({
    required Map<String, dynamic>? metadata,
    String? sourceToolCallId,
    DateTime? createdAt,
  }) {
    final added = <ChatArtifact>[];
    for (final artifact in ChatArtifact.listFromToolMetadata(metadata)) {
      final sourced = artifact.withSource(
        sourceRunId: sourceRunId,
        sourceToolCallId: sourceToolCallId,
        createdAt: createdAt,
      );
      final key = _keyFor(sourced);
      if (!_artifactsByKey.containsKey(key)) {
        added.add(sourced);
      }
      _artifactsByKey[key] = sourced;
    }
    return added;
  }

  List<ChatArtifact> get artifacts => List.unmodifiable(_artifactsByKey.values);

  String _keyFor(ChatArtifact artifact) {
    return artifact.targetUri ?? artifact.storageUri ?? artifact.artifactId;
  }
}

class ChatArtifactSessionMigration {
  static const String schemaVersionKey = 'artifact_schema_version';

  static bool migrateSessionData(Map<String, dynamic> sessionData) {
    if (sessionData[schemaVersionKey] == ChatArtifact.schemaVersion) {
      return false;
    }

    final rawMessages = sessionData['messages'];
    if (rawMessages is List) {
      final messages = <dynamic>[];
      var messagesChanged = false;
      for (final rawMessage in rawMessages) {
        if (rawMessage is! Map) {
          messages.add(rawMessage);
          continue;
        }
        final message = Map<String, dynamic>.from(rawMessage);
        final migrated = _migrateMessageArtifacts(message);
        if (migrated != null) {
          messages.add(migrated);
          messagesChanged = true;
        } else {
          messages.add(rawMessage);
        }
      }
      if (messagesChanged) {
        sessionData['messages'] = messages;
      }
    }

    sessionData[schemaVersionKey] = ChatArtifact.schemaVersion;
    return true;
  }

  static Map<String, dynamic>? _migrateMessageArtifacts(
    Map<String, dynamic> message,
  ) {
    final rawArtifacts = message['artifacts'];
    if (rawArtifacts is! List) return null;

    final sourceRunId = ChatArtifact._nonEmpty(message['turn_id']);
    final createdAt = DateTime.tryParse(message['timestamp']?.toString() ?? '');
    final artifacts = <Map<String, dynamic>>[];
    var changed = false;

    for (final raw in rawArtifacts) {
      if (raw is! Map) {
        changed = true;
        continue;
      }
      final map = Map<String, dynamic>.from(raw);
      if (map['version'] == ChatArtifact.schemaVersion) {
        artifacts.add(map);
        continue;
      }

      final migrated = _migrateLegacyArtifact(
        map,
        sourceRunId: sourceRunId,
        createdAt: createdAt,
      );
      if (migrated != null) artifacts.add(migrated.toJson());
      changed = true;
    }

    if (!changed) return null;
    if (artifacts.isEmpty) {
      message.remove('artifacts');
    } else {
      message['artifacts'] = artifacts;
    }
    return message;
  }

  static ChatArtifact? _migrateLegacyArtifact(
    Map<String, dynamic> legacy, {
    required String? sourceRunId,
    required DateTime? createdAt,
  }) {
    final type = ChatArtifact._nonEmpty(legacy['type']);
    final updated = legacy['updated'] == true;
    final title = ChatArtifact._nonEmpty(legacy['title']);
    final summary = ChatArtifact._nonEmpty(legacy['summary']) ??
        ChatArtifact._nonEmpty(legacy['snippet']);

    switch (type) {
      case 'record':
      case 'html_card':
      case 'card':
        final id = ChatArtifact._nonEmpty(legacy['id']);
        if (id == null) return null;
        return ChatArtifact.timelineCard(
          cardId: id,
          title: title,
          summary: summary,
          imagePaths: ChatArtifact._stringList(legacy['image_paths']),
          tags: ChatArtifact._stringList(legacy['tags']),
          updated: updated,
          sourceRunId: sourceRunId,
          createdAt: createdAt,
        );
      case 'file':
        final path = ChatArtifact._nonEmpty(legacy['path']);
        if (path == null) return null;
        if (_isKnowledgeArtifactPath(path)) {
          return ChatArtifact.knowledgeFile(
            path: path,
            title: title,
            summary: summary,
            updated: updated,
            sourceRunId: sourceRunId,
            createdAt: createdAt,
          );
        }
        return ChatArtifact.workspaceFile(
          path: path,
          title: title,
          summary: summary,
          updated: updated,
          sourceRunId: sourceRunId,
          createdAt: createdAt,
        );
      case 'insight':
        final id = ChatArtifact._nonEmpty(legacy['id']);
        if (id == null) return null;
        return ChatArtifact.knowledgeInsight(
          insightId: id,
          title: title,
          summary: summary,
          updated: updated,
          sourceRunId: sourceRunId,
          createdAt: createdAt,
        );
      case 'schedule':
        return ChatArtifact.schedule(
          title: title,
          summary: summary,
          updated: updated,
          sourceRunId: sourceRunId,
          createdAt: createdAt,
        );
      case 'system_action':
        return ChatArtifact.systemAction(
          systemActionKind: ChatArtifact._nonEmpty(legacy['kind']) ?? 'action',
          title: title,
          summary: summary,
          updated: updated,
          sourceRunId: sourceRunId,
          createdAt: createdAt,
        );
      default:
        return null;
    }
  }

  static bool _isKnowledgeArtifactPath(String path) {
    final normalized = path.trim();
    return normalized.startsWith('PKM/') && normalized.endsWith('.md');
  }
}
