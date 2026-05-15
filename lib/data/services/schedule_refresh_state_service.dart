import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/schedule_refresh_state.dart';
import 'package:memex/utils/logger.dart';

class ScheduleRefreshStateService {
  ScheduleRefreshStateService._();

  static final ScheduleRefreshStateService instance =
      ScheduleRefreshStateService._();

  final _logger = getLogger('ScheduleRefreshStateService');

  String _statePath(String userId) {
    return path.join(
      FileSystemService.instance.getSystemPath(userId),
      'schedule_refresh_state.yaml',
    );
  }

  Future<ScheduleRefreshState> read(String userId) async {
    final file = File(_statePath(userId));
    if (!await file.exists()) {
      return ScheduleRefreshState.clean();
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) return ScheduleRefreshState.clean();
      return ScheduleRefreshState.fromJson(_yamlMapToJson(yaml));
    } catch (e, st) {
      _logger.warning('Failed to read schedule refresh state', e, st);
      return ScheduleRefreshState.clean();
    }
  }

  Future<ScheduleRefreshState> markDirty({
    required String userId,
    required String reason,
    List<String> cardIds = const [],
    bool refreshRequested = false,
  }) async {
    final now = DateTime.now();
    final current = await read(userId);
    final mergedCardIds = <String>{
      ...current.cardIds,
      ...cardIds.where((id) => id.isNotEmpty),
    }.toList();

    final next = current.copyWith(
      isDirty: true,
      reason: reason,
      dirtySince: current.dirtySince ?? now,
      updatedAt: now,
      cardIds: mergedCardIds,
      refreshRequested: current.refreshRequested || refreshRequested,
    );

    await _write(userId, next);
    _emit(next);
    return next;
  }

  Future<ScheduleRefreshState> clearDirty({
    required String userId,
    String? aggregationId,
  }) async {
    final now = DateTime.now();
    final current = await read(userId);
    final next = current.copyWith(
      isDirty: false,
      updatedAt: now,
      lastClearedAt: now,
      lastAggregationId: aggregationId,
      cardIds: const [],
      refreshRequested: false,
      clearReason: true,
      clearDirtySince: true,
    );

    await _write(userId, next);
    _emit(next);
    return next;
  }

  Future<void> _write(String userId, ScheduleRefreshState state) async {
    final filePath = _statePath(userId);
    await FileSystemService.instance.writeYamlFile(filePath, state.toJson());
  }

  void _emit(ScheduleRefreshState state) {
    EventBusService.instance.emitEvent(
      ScheduleAggregationDirtyMessage(
        isDirty: state.isDirty,
        reason: state.reason,
        cardIds: state.cardIds,
      ),
    );
  }

  Map<String, dynamic> _yamlMapToJson(YamlMap map) {
    return {
      for (final entry in map.entries)
        entry.key.toString(): _yamlValueToJson(entry.value),
    };
  }

  dynamic _yamlValueToJson(dynamic value) {
    if (value is YamlMap) return _yamlMapToJson(value);
    if (value is YamlList) return value.map(_yamlValueToJson).toList();
    return value;
  }
}
