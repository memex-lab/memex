import 'dart:convert';

/// Host agent type for custom agents.
enum HostAgentType {
  pure,
  memex;

  String toJson() => name;

  static HostAgentType fromJson(String value) {
    return HostAgentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HostAgentType.pure,
    );
  }
}

/// Execution mode: sync (await inline) or async (enqueue task).
enum ExecutionMode {
  sync,
  async_;

  String toJson() => name == 'async_' ? 'async' : name;

  static ExecutionMode fromJson(String value) {
    if (value == 'async') return ExecutionMode.async_;
    return ExecutionMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExecutionMode.async_,
    );
  }
}

/// Configuration for a user-defined custom agent.
class CustomAgentConfig {
  final String agentName;
  final HostAgentType hostAgentType;

  /// Relative path under `_UserSettings/skills/`, e.g. `my-agent` resolves to
  /// `<workspace>/_UserSettings/skills/my-agent`.
  final String skillDirectoryPath;

  /// Relative path under workspace for the agent's working directory.
  /// e.g. empty string means workspace root, `my-data` means `<workspace>/my-data`.
  /// Always resolved relative to the user's workspace root.
  final String workingDirectory;
  final String? llmConfigKey;

  /// Automatic trigger event type. Empty string means no automatic trigger.
  /// Managed Dynamic Surface agents still receive manual
  /// `dynamic_surface_refresh_requested` events through [managedSurfaceId].
  final String eventType;

  final ExecutionMode executionMode;
  final List<String> dependsOn;
  final bool enabled;
  final int priority;
  final int maxRetries;
  final bool isCustom;

  /// Additional system prompt appended to the host agent's built-in prompt.
  final String? systemPrompt;

  /// Optional: name of a registered custom event serializer.
  /// null means use default XML serialization.
  final String? eventSerializerName;

  /// Optional Dynamic Surface id maintained by this custom agent.
  /// When set, the runtime treats this as a page maintenance agent: it may read
  /// the workspace but ordinary file writes are restricted to the surface's
  /// declared Markdown source.
  final String? managedSurfaceId;

  const CustomAgentConfig({
    required this.agentName,
    this.hostAgentType = HostAgentType.pure,
    required this.skillDirectoryPath,
    this.workingDirectory = '',
    this.llmConfigKey,
    required this.eventType,
    this.executionMode = ExecutionMode.async_,
    this.dependsOn = const [],
    this.enabled = true,
    this.priority = 0,
    this.maxRetries = 5,
    this.isCustom = true,
    this.systemPrompt,
    this.eventSerializerName,
    this.managedSurfaceId,
  });

  /// Validate agentName: only letters, digits, hyphens.
  static bool isValidAgentName(String name) {
    return RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(name) && name.isNotEmpty;
  }

  /// Validate that [skillDirectoryPath] is a safe relative path (no `..`).
  static bool isValidSkillPath(String p) {
    if (p.isEmpty) return false;
    if (p.startsWith('/') || p.contains('..')) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'agentName': agentName,
        'hostAgentType': hostAgentType.toJson(),
        'skillDirectoryPath': skillDirectoryPath,
        'workingDirectory': workingDirectory,
        if (llmConfigKey != null) 'llmConfigKey': llmConfigKey,
        'eventType': eventType,
        'executionMode': executionMode.toJson(),
        'dependsOn': dependsOn,
        'enabled': enabled,
        'priority': priority,
        'maxRetries': maxRetries,
        'isCustom': isCustom,
        if (systemPrompt != null) 'systemPrompt': systemPrompt,
        if (eventSerializerName != null)
          'eventSerializerName': eventSerializerName,
        if (managedSurfaceId != null) 'managedSurfaceId': managedSurfaceId,
      };

  factory CustomAgentConfig.fromJson(Map<String, dynamic> json) {
    return CustomAgentConfig(
      agentName: json['agentName'] as String,
      hostAgentType:
          HostAgentType.fromJson(json['hostAgentType'] as String? ?? 'pure'),
      skillDirectoryPath: json['skillDirectoryPath'] as String,
      workingDirectory: json['workingDirectory'] as String? ?? '',
      llmConfigKey: json['llmConfigKey'] as String?,
      eventType: json['eventType'] as String,
      executionMode:
          ExecutionMode.fromJson(json['executionMode'] as String? ?? 'async'),
      dependsOn: (json['dependsOn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      enabled: json['enabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 10,
      isCustom: json['isCustom'] as bool? ?? true,
      systemPrompt: json['systemPrompt'] as String?,
      eventSerializerName: json['eventSerializerName'] as String?,
      managedSurfaceId: json['managedSurfaceId'] as String?,
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory CustomAgentConfig.fromJsonString(String jsonString) {
    return CustomAgentConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  CustomAgentConfig copyWith({
    String? agentName,
    HostAgentType? hostAgentType,
    String? skillDirectoryPath,
    String? workingDirectory,
    String? llmConfigKey,
    String? eventType,
    ExecutionMode? executionMode,
    List<String>? dependsOn,
    bool? enabled,
    int? priority,
    int? maxRetries,
    bool? isCustom,
    String? systemPrompt,
    String? eventSerializerName,
    String? managedSurfaceId,
  }) {
    return CustomAgentConfig(
      agentName: agentName ?? this.agentName,
      hostAgentType: hostAgentType ?? this.hostAgentType,
      skillDirectoryPath: skillDirectoryPath ?? this.skillDirectoryPath,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      llmConfigKey: llmConfigKey ?? this.llmConfigKey,
      eventType: eventType ?? this.eventType,
      executionMode: executionMode ?? this.executionMode,
      dependsOn: dependsOn ?? this.dependsOn,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      maxRetries: maxRetries ?? this.maxRetries,
      isCustom: isCustom ?? this.isCustom,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      eventSerializerName: eventSerializerName ?? this.eventSerializerName,
      managedSurfaceId: managedSurfaceId ?? this.managedSurfaceId,
    );
  }
}
