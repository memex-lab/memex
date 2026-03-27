import 'dart:io';

import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:workmanager/workmanager.dart'; // Added for Workmanager
import 'dart:isolate'; // Added for Isolate
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:memex/data/services/file_logger_service.dart'; // Added
import 'health_strategies.dart';
import 'package:memex/utils/logger.dart';

/// Configuration for handling a specific Health Data Type
class HealthStrategyConfig {
  final HealthDataType type;
  final String prefKeySuffix; // e.g., 'steps' -> last_report_time_steps
  final HealthDataFetcher primaryFetcher;
  final HealthDataFetcher? fallbackFetcher;
  final int reportIntervalMinutes;

  HealthStrategyConfig({
    required this.type,
    required this.prefKeySuffix,
    required this.primaryFetcher,
    this.fallbackFetcher,
    this.reportIntervalMinutes = 30,
  });
}

/// Generic Health Service
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal() {
    _registerStrategies();
  }

  final Logger _logger = getLogger('HealthService');
  // Registry
  final Map<HealthDataType, HealthStrategyConfig> _configs = {};

  /// Returns the list of health data types registered for the current platform.
  List<HealthDataType> get registeredTypes => _configs.keys.toList();

  void _registerStrategies() {
    if (Platform.isAndroid) {
      // Android: Only steps via Pedometer (Health Connect permissions removed
      // to comply with Google Play policy).
      _configs[HealthDataType.STEPS] = HealthStrategyConfig(
        type: HealthDataType.STEPS,
        prefKeySuffix: 'steps',
        primaryFetcher: PedometerFetcher(),
        reportIntervalMinutes: 1,
      );
    } else {
      // iOS: Full HealthKit support
      _configs[HealthDataType.STEPS] = HealthStrategyConfig(
        type: HealthDataType.STEPS,
        prefKeySuffix: 'steps',
        primaryFetcher: HealthKitFetcher(),
        fallbackFetcher: PedometerFetcher(),
        reportIntervalMinutes: 1,
      );

      _configs[HealthDataType.HEART_RATE] = HealthStrategyConfig(
        type: HealthDataType.HEART_RATE,
        prefKeySuffix: 'heart_rate',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );
      _configs[HealthDataType.RESTING_HEART_RATE] = HealthStrategyConfig(
        type: HealthDataType.RESTING_HEART_RATE,
        prefKeySuffix: 'resting_heart_rate',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );

      _configs[HealthDataType.BLOOD_PRESSURE_SYSTOLIC] = HealthStrategyConfig(
        type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        prefKeySuffix: 'bp_sys',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );
      _configs[HealthDataType.BLOOD_PRESSURE_DIASTOLIC] = HealthStrategyConfig(
        type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        prefKeySuffix: 'bp_dia',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );

      _configs[HealthDataType.BLOOD_OXYGEN] = HealthStrategyConfig(
        type: HealthDataType.BLOOD_OXYGEN,
        prefKeySuffix: 'blood_oxygen',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );
      _configs[HealthDataType.BLOOD_GLUCOSE] = HealthStrategyConfig(
        type: HealthDataType.BLOOD_GLUCOSE,
        prefKeySuffix: 'blood_glucose',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );

      _configs[HealthDataType.SLEEP_ASLEEP] = HealthStrategyConfig(
        type: HealthDataType.SLEEP_ASLEEP,
        prefKeySuffix: 'sleep',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );

      _configs[HealthDataType.ACTIVE_ENERGY_BURNED] = HealthStrategyConfig(
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        prefKeySuffix: 'active_energy',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );
      _configs[HealthDataType.WEIGHT] = HealthStrategyConfig(
        type: HealthDataType.WEIGHT,
        prefKeySuffix: 'weight',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 120,
      );

      _configs[HealthDataType.WORKOUT] = HealthStrategyConfig(
        type: HealthDataType.WORKOUT,
        prefKeySuffix: 'workout',
        primaryFetcher: HealthKitFetcher(),
        reportIntervalMinutes: 1,
      );
    }

    // Initialize Background Task for Pedometer (Ensure it's registered on app start)
    final stepsFallback = _configs[HealthDataType.STEPS]?.fallbackFetcher;
    final stepsPrimary = _configs[HealthDataType.STEPS]?.primaryFetcher;
    if (stepsFallback is PedometerFetcher) {
      stepsFallback.ensureBackgroundTaskRegistered();
    } else if (stepsPrimary is PedometerFetcher) {
      stepsPrimary.ensureBackgroundTaskRegistered();
    }
  }

  // --- Public API ---

  /// Request all necessary permissions in one batch prompt
  Future<void> requestAllPermissions() async {
    try {
      // On Android, we only use Pedometer for steps — no Health Connect needed.
      // HealthKit authorization is only requested on iOS.
      if (Platform.isAndroid) {
        // Just request pedometer/activity recognition permission
        if (_configs.containsKey(HealthDataType.STEPS)) {
          final primary = _configs[HealthDataType.STEPS]?.primaryFetcher;
          if (primary != null) {
            await primary.requestPermissions(HealthDataType.STEPS);
          }
        }
        return;
      }

      final health = Health();

      // iOS: Ask for all Health package data types at once
      List<HealthDataType> allTypesToRequest = [];

      for (final config in _configs.values) {
        if (config.primaryFetcher is HealthKitFetcher) {
          if (config.type == HealthDataType.SLEEP_ASLEEP) {
            allTypesToRequest.addAll([
              HealthDataType.SLEEP_ASLEEP,
              HealthDataType.SLEEP_AWAKE,
              HealthDataType.SLEEP_DEEP,
              HealthDataType.SLEEP_LIGHT,
              HealthDataType.SLEEP_REM,
            ]);
            if (Platform.isIOS) {
              allTypesToRequest.add(HealthDataType.SLEEP_IN_BED);
            }
          } else {
            allTypesToRequest.add(config.type);
          }
        }
      }

      allTypesToRequest = allTypesToRequest.toSet().toList();

      if (allTypesToRequest.isNotEmpty) {
        _logger.info(
            'Requesting batched health permissions for ${allTypesToRequest.length} types...');
        bool? hasPermissions = await health.hasPermissions(allTypesToRequest);
        if (hasPermissions != true) {
          await health.requestAuthorization(allTypesToRequest);
        }
      }

      // Also request Pedometer permission as fallback for steps
      if (_configs.containsKey(HealthDataType.STEPS)) {
        final fallback = _configs[HealthDataType.STEPS]?.fallbackFetcher;
        if (fallback != null) {
          await fallback.requestPermissions(HealthDataType.STEPS);
        }
      }
    } catch (e) {
      _logger.severe('Error batch requesting health permissions: $e');
    }
  }

  /// Generic Entry Point
  /// Returns data if reporting is needed and successful, null otherwise.
  Future<T?> checkAndPrepareData<T>(HealthDataType type) async {
    final config = _configs[type];
    if (config == null) {
      _logger.warning('No strategy configured for $type');
      return null;
    }

    try {
      _logger.info('Checking ${config.type}...');

      // 1. Check Interval
      if (!await _shouldReport(config)) {
        _logger.info('Not time to report ${config.type} yet.');
        return null; // Not time yet
      }

      // 2. Fetch Data
      final data = await _fetchWithFallback<T>(config);

      // Check if data is empty (Logic depends on T, assuming Map or List)
      bool isEmpty = false;
      if (data is Map) isEmpty = data.isEmpty;
      if (data is List) isEmpty = data.isEmpty;

      if (data == null || isEmpty) {
        _logger.info('No data found for ${config.type}.');
        return null;
      }

      // 3. Mark check time
      await _saveLastCheckTime(config);

      return data;
    } catch (e) {
      _logger.severe('Error processing ${config.type}: $e');
      return null;
    }
  }

  /// Updates the "Last Reported Date" cursor for a specific type.
  /// This should be called by the UI/Main logic *after* successful API upload.
  Future<void> markReportSuccess(HealthDataType type, dynamic data) async {
    final config = _configs[type];
    if (config == null) return;

    // Update cursor for date maps
    if (data is Map && data.isNotEmpty) {
      await _markGenericSuccess(config, data as Map<String, dynamic>);
    }
  }

  // --- Internal Engine ---

  Future<T?> _fetchWithFallback<T>(HealthStrategyConfig config) async {
    // Determine Time Range
    final range = await _getReportTimeRange(config);
    final start = range.start;
    final end = range.end;

    // Primary
    _logger.info(
        'Trying Primary: ${config.primaryFetcher.name} for ${config.type}');
    try {
      if (await config.primaryFetcher.requestPermissions(config.type)) {
        final data =
            await config.primaryFetcher.fetchData(config.type, start, end);

        bool hasData = false;
        if (data is Map) hasData = data.isNotEmpty;
        if (data is List) hasData = data.isNotEmpty;

        if (hasData) {
          return data as T;
        } else {
          _logger.info('Primary returned empty.');
        }
      } else {
        _logger.warning('Primary denied.');
      }
    } catch (e) {
      _logger.warning('Primary failed: $e');
    }

    // Fallback
    if (config.fallbackFetcher != null) {
      _logger.info(
          'Trying Fallback: ${config.fallbackFetcher!.name} for ${config.type}');
      try {
        if (await config.fallbackFetcher!.requestPermissions(config.type)) {
          final data =
              await config.fallbackFetcher!.fetchData(config.type, start, end);
          return data as T;
        }
      } catch (e) {
        _logger.warning('Fallback failed: $e');
      }
    }

    return null; // Both failed
  }

  Future<bool> _shouldReport(HealthStrategyConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_report_time_${config.prefKeySuffix}';
    final lastStr = prefs.getString(key);
    if (lastStr == null) return true;

    final last = DateTime.parse(lastStr);
    return DateTime.now().difference(last).inMinutes >=
        config.reportIntervalMinutes;
  }

  Future<void> _saveLastCheckTime(HealthStrategyConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_report_time_${config.prefKeySuffix}';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  Future<({DateTime start, DateTime end})> _getReportTimeRange(
      HealthStrategyConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_reported_date_${config.prefKeySuffix}';
    final lastDateStr = prefs.getString(key);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfToday = today.add(const Duration(days: 1));

    DateTime start;
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      start = lastDate.add(const Duration(days: 1));
    } else {
      start = today.subtract(const Duration(days: 7));
    }
    return (start: start, end: endOfToday);
  }

  // --- Type-Specific Helpers ---

  Future<void> _markGenericSuccess(
      HealthStrategyConfig config, Map<String, dynamic> dataByDate) async {
    if (dataByDate.isEmpty) return;

    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final dates = dataByDate.keys.toList()..sort();

    String? lastPastDateStr;
    for (var d in dates) {
      if (d.compareTo(todayStr) < 0) lastPastDateStr = d;
    }

    if (lastPastDateStr != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'last_reported_date_${config.prefKeySuffix}';
      await prefs.setString(key, lastPastDateStr);
      _logger.info('Updated cursor for ${config.type} to $lastPastDateStr');
    }
  }
}

// MUST be top-level function for Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 0. Initialize Logger in Background Isolate
    // Use print() first to ensure we can see it in console/ADB even if file logger fails
    debugPrint(
        'BackgroundCallback: Starting... (Isolate: ${Isolate.current.debugName})');

    // Define logger early so it can be used in try block
    final logger = getLogger('PedometerFetcher');

    try {
      await setupLogger();
      logger.severe('BackgroundCallback: Logger setup complete');
    } catch (e) {
      debugPrint('BackgroundCallback: Logger setup failed: $e');
    }

    try {
      logger.severe('Background task triggered (1h periodic)');
      await PedometerFetcher.backgroundCallbackLogic();
      logger.severe('Background task completed successfully');
      return Future.value(true);
    } catch (e) {
      logger.severe('Error in background task execution: $e');
      return Future.value(false); // Retry if needed
    } finally {
      // Ensure isolate disposes before refresh and close file stream
      // FORCE FLUSH before isolate logic ends
      await FileLoggerService.instance.dispose();
    }
  });
}
