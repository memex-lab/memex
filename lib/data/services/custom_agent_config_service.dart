import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';

/// Escape XML special characters in text content.
String _xmlEscape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

/// Recursively serialize a value to XML string.
/// - Object with toJson() → convert to Map first
/// - Map → child elements
/// - List → repeated <item> elements
/// - Primitives → escaped text
String _valueToXml(dynamic value, {int indent = 2}) {
  final pad = '  ' * indent;
  if (value == null) return '';

  // If the object has a toJson() method, convert to Map first.
  if (value is! Map &&
      value is! List &&
      value is! String &&
      value is! num &&
      value is! bool) {
    try {
      final json = (value as dynamic).toJson();
      return _valueToXml(json, indent: indent);
    } catch (_) {
      // No toJson(), fall through to toString().
    }
  }

  if (value is Map) {
    final buf = StringBuffer();
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final inner = _valueToXml(entry.value, indent: indent + 1);
      if (entry.value is Map || entry.value is List) {
        buf.writeln('$pad<$key>');
        buf.write(inner);
        buf.writeln('$pad</$key>');
      } else {
        buf.writeln('$pad<$key>$inner</$key>');
      }
    }
    return buf.toString();
  }

  if (value is List) {
    final buf = StringBuffer();
    for (final item in value) {
      final inner = _valueToXml(item, indent: indent + 1);
      if (item is Map || item is List) {
        buf.writeln('$pad<item>');
        buf.write(inner);
        buf.writeln('$pad</item>');
      } else {
        buf.writeln('$pad<item>$inner</item>');
      }
    }
    return buf.toString();
  }

  // Primitive: escape for XML.
  if (value is String) return _xmlEscape(value);
  return _xmlEscape(value.toString());
}

/// Default event-to-XML serializer.
String defaultEventToXml(SystemEvent event) {
  final buf = StringBuffer();
  buf.writeln(
      '<event type="${_xmlEscape(event.type)}" id="${_xmlEscape(event.eventId)}" source="${_xmlEscape(event.source)}">');
  buf.writeln(
      '  <created_at>${_xmlEscape(formatLocalDateTimeWithZone(event.createdAt))}</created_at>');
  var payload = event.payload;

  // Convert typed payload objects to Map via toJson() if available.
  if (payload != null &&
      payload is! Map &&
      payload is! List &&
      payload is! String &&
      payload is! num &&
      payload is! bool) {
    try {
      payload = (payload as dynamic).toJson();
    } catch (_) {
      // No toJson(), will be handled as toString() below.
    }
  }

  if (payload is Map) {
    buf.write(_valueToXml(payload, indent: 1));
  } else if (payload is List) {
    buf.writeln('  <payload>');
    buf.write(_valueToXml(payload, indent: 2));
    buf.writeln('  </payload>');
  } else if (payload != null) {
    buf.writeln('  <payload>${_xmlEscape(payload.toString())}</payload>');
  }
  buf.writeln('</event>');
  return buf.toString();
}

/// Compact serializer for user_input_submitted events.
/// Keeps the raw input plus its original local timestamp. Media assets are
/// already sent as multimodal parts, and markdown_entry is internal bookkeeping.
String _userInputCompactXml(SystemEvent event) {
  final buf = StringBuffer();
  buf.writeln(
      '<event type="${_xmlEscape(event.type)}" id="${_xmlEscape(event.eventId)}">');
  buf.writeln(
      '  <created_at>${_xmlEscape(formatLocalDateTimeWithZone(event.createdAt))}</created_at>');

  final payload = event.payload;
  if (payload is UserInputSubmittedPayload) {
    final inputTime = dateTimeFromUnixSeconds(payload.createdAtTs);
    buf.writeln('  <fact_id>${_xmlEscape(payload.factId)}</fact_id>');
    if (payload.locationContextReminder != null &&
        payload.locationContextReminder!.trim().isNotEmpty) {
      buf.writeln('  <location_context>');
      buf.writeln(_xmlEscape(payload.locationContextReminder!.trim()));
      buf.writeln('  </location_context>');
    }
    buf.writeln(
        '  <input_local_time>${_xmlEscape(formatLocalDateTimeWithZone(inputTime))}</input_local_time>');
    buf.writeln(
        '  <input_unix_seconds>${payload.createdAtTs}</input_unix_seconds>');
    buf.writeln(
        '  <combined_text>${_xmlEscape(payload.combinedText)}</combined_text>');
  } else {
    // Fallback: delegate to default serializer logic for the payload part.
    return defaultEventToXml(event);
  }

  buf.writeln('</event>');
  return buf.toString();
}

/// Registry of named event serializers (for explicit override via agent config).
typedef EventSerializer = String Function(SystemEvent event);

final Map<String, EventSerializer> _eventSerializerRegistry = {};

/// Registry of per-event-type default serializers.
/// When an agent config does not specify a serializer name, the event type
/// default is used. If no event type default is registered either, falls back
/// to [defaultEventToXml].
final Map<String, EventSerializer> _eventTypeDefaultSerializerRegistry = {};

void registerEventSerializer(String name, EventSerializer serializer) {
  _eventSerializerRegistry[name] = serializer;
}

/// Register a default serializer for a specific event type.
void registerEventTypeDefaultSerializer(
    String eventType, EventSerializer serializer) {
  _eventTypeDefaultSerializerRegistry[eventType] = serializer;
}

/// Resolve the serializer for a given event.
/// Priority: agent config name > event type default > global default XML.
EventSerializer getEventSerializer(String? name, {String? eventType}) {
  // 1. Explicit name from agent config.
  if (name != null && name.isNotEmpty) {
    final named = _eventSerializerRegistry[name];
    if (named != null) return named;
  }
  // 2. Per-event-type default.
  if (eventType != null) {
    final typed = _eventTypeDefaultSerializerRegistry[eventType];
    if (typed != null) return typed;
  }
  // 3. Global default.
  return defaultEventToXml;
}

/// Returns all registered serializer names (for UI dropdowns).
List<String> getRegisteredSerializerNames() {
  return _eventSerializerRegistry.keys.toList();
}

/// Register built-in event type default serializers.
/// Call once at app init.
void registerBuiltInEventSerializers() {
  registerEventTypeDefaultSerializer(
    SystemEventTypes.userInputSubmitted,
    _userInputCompactXml,
  );
}

/// Service for managing custom agent configurations.
/// Handles file I/O under _UserSettings/agent_configs/ and
/// dynamic registration/unregistration on GlobalEventBus.
class CustomAgentConfigService {
  static CustomAgentConfigService? _instance;
  static CustomAgentConfigService get instance {
    _instance ??= CustomAgentConfigService._();
    return _instance!;
  }

  CustomAgentConfigService._();

  final Logger _logger = getLogger('CustomAgentConfigService');

  /// Tracked subscription IDs so we can unsubscribe on reload.
  final Set<_RegisteredCustomAgentSubscription> _registeredSubscriptions = {};

  String _configDir(String userId) {
    final settingsPath = FileSystemService.instance.getUserSettingsPath(userId);
    return path.join(settingsPath, 'agent_configs');
  }

  /// Load all custom agent configs from disk.
  Future<List<CustomAgentConfig>> loadAll(String userId) async {
    final dir = Directory(_configDir(userId));
    if (!await dir.exists()) return const [];

    final configs = <CustomAgentConfig>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          configs.add(CustomAgentConfig.fromJsonString(content));
        } catch (e) {
          _logger.warning('Failed to load config ${entity.path}: $e');
        }
      }
    }
    return configs;
  }

  /// Save a single config to disk.
  Future<void> save(String userId, CustomAgentConfig config) async {
    final dir = Directory(_configDir(userId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(path.join(dir.path, '${config.agentName}.json'));
    await file.writeAsString(config.toJsonString());
    _logger.info('Saved custom agent config: ${config.agentName}');
  }

  /// Delete a config from disk.
  Future<void> delete(String userId, String agentName) async {
    final file = File(path.join(_configDir(userId), '$agentName.json'));
    if (await file.exists()) {
      await file.delete();
      _logger.info('Deleted custom agent config: $agentName');
    }
  }

  Future<CustomAgentConfig> installDynamicSurfacePageAgent({
    required String userId,
    required String surfaceId,
    String? displayName,
    String triggerEventType = SystemEventTypes.userInputSubmitted,
    String? systemPrompt,
  }) async {
    _validateSurfaceId(surfaceId);

    final agentName = _agentNameForSurface(surfaceId);
    final existing = await _findDynamicSurfacePageAgentConfig(
      userId: userId,
      surfaceId: surfaceId,
    );
    final effectiveSystemPrompt = systemPrompt?.trim().isNotEmpty == true
        ? systemPrompt!.trim()
        : existing?.systemPrompt ??
            _buildDynamicSurfacePageAgentSystemPrompt(surfaceId);

    final config = CustomAgentConfig(
      agentName: agentName,
      hostAgentType: HostAgentType.memex,
      skillDirectoryPath: '',
      workingDirectory: '',
      llmConfigKey: existing?.llmConfigKey,
      eventType: triggerEventType,
      executionMode: existing?.executionMode ?? ExecutionMode.async_,
      dependsOn: existing?.dependsOn ?? const [],
      enabled: existing?.enabled ?? true,
      priority: existing?.priority ?? 0,
      maxRetries: existing?.maxRetries ?? 5,
      isCustom: existing?.isCustom ?? true,
      managedSurfaceId: surfaceId,
      systemPrompt: effectiveSystemPrompt,
      eventSerializerName: existing?.eventSerializerName,
    );

    await saveAndReload(userId, config);
    _logger.info(
      'Installed Dynamic Surface page agent: $agentName for $surfaceId',
    );
    return config;
  }

  /// Register all enabled custom agents on the GlobalEventBus.
  /// Call this at app init (after built-in subscriptions) and after any config change.
  Future<void> registerAll(String userId) async {
    // First unregister all previous custom subscriptions.
    _unregisterAll();

    final configs = await loadAll(userId);
    for (final config in configs) {
      if (!config.enabled) continue;
      _registerOne(config);
    }
    _logger.info(
        'Registered ${_registeredSubscriptions.length} custom agent subscriptions');
  }

  void _unregisterAll() {
    final eventBus = GlobalEventBus.instance;
    for (final registered in _registeredSubscriptions) {
      eventBus.unsubscribe(
        eventType: registered.eventType,
        subscriptionId: registered.subscriptionId,
      );
      eventBus.unsubscribeSync(
        eventType: registered.eventType,
        subscriptionId: registered.subscriptionId,
      );
    }
    _registeredSubscriptions.clear();
  }

  void _registerOne(CustomAgentConfig config) {
    final eventBus = GlobalEventBus.instance;
    final taskType = 'custom_agent_task:${config.agentName}';

    // Register the task handler (idempotent — overwrites if already registered).
    LocalTaskExecutor.instance.registerHandler(taskType,
        (userId, payload, taskContext) async {
      await _runCustomAgentTask(userId, config, payload);
    });

    // Register generic failure handler for error notification.
    LocalTaskExecutor.instance
        .registerFailureHandler(taskType, handleGenericAgentFailure);

    for (final eventType in _eventTypesForConfig(config)) {
      final subscriptionId = 'custom_agent:${config.agentName}:$eventType';
      if (config.executionMode == ExecutionMode.async_) {
        eventBus.subscribe(
          eventType: eventType,
          subscription: EventTaskSubscription(
            subscriptionId: subscriptionId,
            taskType: taskType,
            dependsOn: config.dependsOn,
            priority: config.priority,
            maxRetries: config.maxRetries,
            payloadBuilder: (userId, event) async {
              final serializer = getEventSerializer(config.eventSerializerName,
                  eventType: event.type);
              return _buildCustomAgentTaskPayload(config, event, serializer);
            },
          ),
        );
      } else {
        eventBus.subscribeSync(
          eventType: eventType,
          subscription: EventSyncSubscription(
            subscriptionId: subscriptionId,
            dependsOn: config.dependsOn,
            handler: (userId, event) async {
              final serializer = getEventSerializer(config.eventSerializerName,
                  eventType: event.type);
              final payload =
                  _buildCustomAgentTaskPayload(config, event, serializer);
              await _runCustomAgentTask(userId, config, payload);
            },
          ),
        );
      }
      _registeredSubscriptions.add(
        _RegisteredCustomAgentSubscription(
          eventType: eventType,
          subscriptionId: subscriptionId,
        ),
      );
    }
  }

  List<String> _eventTypesForConfig(CustomAgentConfig config) {
    final eventTypes = <String>{config.eventType};
    final managedSurfaceId = config.managedSurfaceId?.trim();
    if (managedSurfaceId != null && managedSurfaceId.isNotEmpty) {
      eventTypes.add(SystemEventTypes.dynamicSurfaceRefreshRequested);
    }
    return eventTypes
        .where((eventType) => eventType.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _buildCustomAgentTaskPayload(
    CustomAgentConfig config,
    SystemEvent event,
    EventSerializer serializer,
  ) {
    return {
      'agent_name': config.agentName,
      'event_xml': serializer(event),
      'event_type': event.type,
      'event_id': event.eventId,
      if (event.payload is DynamicSurfaceRefreshRequestedPayload)
        'surface_id':
            (event.payload as DynamicSurfaceRefreshRequestedPayload).surfaceId,
    };
  }

  /// Save config and re-register all subscriptions.
  Future<void> saveAndReload(String userId, CustomAgentConfig config) async {
    await save(userId, config);
    await registerAll(userId);
  }

  /// Delete config and re-register all subscriptions.
  Future<void> deleteAndReload(String userId, String agentName) async {
    await delete(userId, agentName);
    await registerAll(userId);
  }

  Future<String?> deleteDynamicSurfacePageAgent({
    required String userId,
    required String surfaceId,
  }) async {
    _validateSurfaceId(surfaceId);
    final config = await _findDynamicSurfacePageAgentConfig(
      userId: userId,
      surfaceId: surfaceId,
    );

    final agentName = config?.agentName ?? _agentNameForSurface(surfaceId);
    await delete(userId, agentName);

    final configuredSkillDirectoryPath =
        config?.skillDirectoryPath.trim() ?? '';
    final legacySkillDirectoryPath = configuredSkillDirectoryPath.isNotEmpty
        ? configuredSkillDirectoryPath
        : path.join('_UserSettings', 'skills', 'dynamic-surfaces', surfaceId);
    final skillPath = FileSystemService.instance.resolveSkillPath(
      userId,
      legacySkillDirectoryPath,
    );
    final skillDir = Directory(skillPath);
    if (await skillDir.exists()) {
      await skillDir.delete(recursive: true);
      _logger.info('Deleted Dynamic Surface page agent skill: $skillPath');
    }

    await registerAll(userId);
    return config == null ? null : agentName;
  }

  Future<CustomAgentConfig?> _findDynamicSurfacePageAgentConfig({
    required String userId,
    required String surfaceId,
  }) async {
    final configs = await loadAll(userId);
    for (final config in configs) {
      if (config.managedSurfaceId == surfaceId) return config;
    }
    return null;
  }

  String _agentNameForSurface(String surfaceId) {
    final normalized = surfaceId
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final suffix = normalized.isEmpty ? 'page' : normalized;
    return 'surface-$suffix';
  }

  void _validateSurfaceId(String surfaceId) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(surfaceId)) {
      throw ArgumentError(
        'Dynamic Surface id may only contain letters, numbers, "_" and "-".',
      );
    }
  }

  String _buildDynamicSurfacePageAgentSystemPrompt(String surfaceId) {
    return '''
You maintain the Memex Dynamic Surface "$surfaceId".

This is a user-defined page, not a Timeline card and not PKM organization.
Keep it useful by maintaining the declared page-owned Markdown source and its
parser.js Markdown data contract.

Native Memex directories may be origin evidence or trigger origins, but the
surface source is the formatted Markdown mapping owned by this page. Runtime
permissions restrict writes to that page-owned source.

After updating, the page should still render from injected JSON:
- `{{memex_data_json}}` is exactly the raw parser.js return value.
- parser.js and view.html decide the JSON shape together; Memex does not wrap
  the value or extract item arrays.
- parser.js is the validation contract. Keep Markdown changes parseable by the
  installed parser.js.

If the user wants to change the page template, parser.js contract, trigger
timing, or agent mechanism, that request should go to the Dynamic Surface
authoring agent.
''';
  }
}

/// Runner function type for custom agent execution.
/// Injected at app init by [setCustomAgentRunner] to avoid this file
/// importing the heavy agent layer (which would pull in LLM clients,
/// skill loaders, etc.).
typedef CustomAgentRunner = Future<void> Function(
    String userId, CustomAgentConfig config, Map<String, dynamic> payload);

CustomAgentRunner? _customAgentRunner;

class _RegisteredCustomAgentSubscription {
  const _RegisteredCustomAgentSubscription({
    required this.eventType,
    required this.subscriptionId,
  });

  final String eventType;
  final String subscriptionId;

  @override
  bool operator ==(Object other) {
    return other is _RegisteredCustomAgentSubscription &&
        other.eventType == eventType &&
        other.subscriptionId == subscriptionId;
  }

  @override
  int get hashCode => Object.hash(eventType, subscriptionId);
}

/// Called by custom_agent_task_handler.dart at app init to inject the real implementation.
void setCustomAgentRunner(CustomAgentRunner runner) {
  _customAgentRunner = runner;
}

/// Execute a custom agent task. Delegates to the runner injected via [setCustomAgentRunner].
Future<void> _runCustomAgentTask(
  String userId,
  CustomAgentConfig config,
  Map<String, dynamic> payload,
) async {
  final runner = _customAgentRunner;
  if (runner == null) {
    throw StateError(
        'Custom agent runner not initialized. Call initCustomAgentHandler() at app startup.');
  }
  await runner(userId, config, payload);
}
