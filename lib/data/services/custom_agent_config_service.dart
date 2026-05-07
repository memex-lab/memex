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
      '  <created_at>${event.createdAt.toIso8601String()}</created_at>');
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
      '  <created_at>${event.createdAt.toIso8601String()}</created_at>');

  final payload = event.payload;
  if (payload is UserInputSubmittedPayload) {
    final inputTime = dateTimeFromUnixSeconds(payload.createdAtTs);
    buf.writeln('  <fact_id>${_xmlEscape(payload.factId)}</fact_id>');
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
  final Set<String> _registeredSubscriptionIds = {};

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
        'Registered ${_registeredSubscriptionIds.length} custom agent subscriptions');
  }

  void _unregisterAll() {
    final eventBus = GlobalEventBus.instance;
    for (final id in _registeredSubscriptionIds) {
      // We don't know which eventType it was on, so unsubscribe from all known types.
      for (final eventType in SystemEventTypes.allTypes) {
        eventBus.unsubscribe(eventType: eventType, subscriptionId: id);
        eventBus.unsubscribeSync(eventType: eventType, subscriptionId: id);
      }
    }
    _registeredSubscriptionIds.clear();
  }

  void _registerOne(CustomAgentConfig config) {
    final eventBus = GlobalEventBus.instance;
    final subscriptionId = 'custom_agent:${config.agentName}';
    final taskType = 'custom_agent_task:${config.agentName}';

    // Register the task handler (idempotent — overwrites if already registered).
    LocalTaskExecutor.instance.registerHandler(taskType,
        (userId, payload, taskContext) async {
      await _runCustomAgentTask(userId, config, payload);
    });

    // Register generic failure handler for error notification.
    LocalTaskExecutor.instance
        .registerFailureHandler(taskType, handleGenericAgentFailure);

    if (config.executionMode == ExecutionMode.async_) {
      eventBus.subscribe(
        eventType: config.eventType,
        subscription: EventTaskSubscription(
          subscriptionId: subscriptionId,
          taskType: taskType,
          dependsOn: config.dependsOn,
          priority: config.priority,
          maxRetries: config.maxRetries,
          payloadBuilder: (userId, event) async {
            final serializer = getEventSerializer(config.eventSerializerName,
                eventType: event.type);
            return {
              'agent_name': config.agentName,
              'event_xml': serializer(event),
              'event_type': event.type,
              'event_id': event.eventId,
            };
          },
        ),
      );
    } else {
      eventBus.subscribeSync(
        eventType: config.eventType,
        subscription: EventSyncSubscription(
          subscriptionId: subscriptionId,
          dependsOn: config.dependsOn,
          handler: (userId, event) async {
            final serializer = getEventSerializer(config.eventSerializerName,
                eventType: event.type);
            final payload = {
              'agent_name': config.agentName,
              'event_xml': serializer(event),
              'event_type': event.type,
              'event_id': event.eventId,
            };
            await _runCustomAgentTask(userId, config, payload);
          },
        ),
      );
    }

    _registeredSubscriptionIds.add(subscriptionId);
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
}

/// Runner function type for custom agent execution.
/// Injected at app init by [setCustomAgentRunner] to avoid this file
/// importing the heavy agent layer (which would pull in LLM clients,
/// skill loaders, etc.).
typedef CustomAgentRunner = Future<void> Function(
    String userId, CustomAgentConfig config, Map<String, dynamic> payload);

CustomAgentRunner? _customAgentRunner;

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
