import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Added for TimeoutException
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// Abstract interface for fetching health data
abstract class HealthDataFetcher {
  String get name;

  /// Requests permissions for the specified type
  Future<bool> requestPermissions(HealthDataType type);

  /// Fetches data for the specified type.
  /// Returns dynamic because structure varies (e.g. Map<String, int> for steps, List<HealthDataPoint> for others)
  Future<dynamic> fetchData(
      HealthDataType type, DateTime startTime, DateTime endTime);
}

/// Strategy A: Use 'health' package (HealthKit / Health Connect)
class HealthKitFetcher implements HealthDataFetcher {
  final Health _health = Health();
  final Logger _logger = getLogger('HealthKitFetcher');

  @override
  String get name => 'HealthKit/HealthConnect';

  @override
  Future<bool> requestPermissions(HealthDataType type) async {
    try {
      final types = [type];
      // Only check if we have permissions — do NOT request.
      // On iOS, hasPermissions returns null if never requested — treat as "try anyway"
      // because HealthKit won't crash, it just returns empty data if denied.
      bool? hasPermissions = await _health.hasPermissions(types);
      _logger.info('HealthKit hasPermissions($type): $hasPermissions');
      // Allow null (unknown) — let fetchData attempt and return empty if denied
      return hasPermissions != false;
    } catch (e) {
      _logger.warning('Permission check error for $type: $e');
      return false;
    }
  }

  @override
  Future<dynamic> fetchData(
      HealthDataType type, DateTime startTime, DateTime endTime) async {
    try {
      List<HealthDataType> types = [type];

      // If we are asked for sleep, fetch all possible sleep stages and sessions
      // to ensure we get data from Apple Health (iOS only — Health Connect removed on Android)
      if (type == HealthDataType.SLEEP_ASLEEP) {
        types = [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_REM,
        ];
        if (Platform.isIOS) {
          types.add(HealthDataType.SLEEP_IN_BED);
        }
      }

      // Attempt to fetch data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );
      _logger.info('Fetched $type: ${jsonEncode(healthData)} data points');
      // Route to correct aggregation logic
      switch (type) {
        case HealthDataType.STEPS:
          return _aggregateSteps(healthData);
        case HealthDataType.HEART_RATE:
        case HealthDataType.RESTING_HEART_RATE:
          return _aggregateHeartRate(healthData);
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          return _aggregateBloodPressure(healthData, type);
        case HealthDataType.BLOOD_OXYGEN:
          return _aggregateBloodOxygen(healthData);
        case HealthDataType.BLOOD_GLUCOSE:
          return _aggregateBloodGlucose(healthData);
        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_IN_BED:
        case HealthDataType.SLEEP_AWAKE:
          return _aggregateSleep(healthData);
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          return _aggregateActiveEnergy(healthData);
        case HealthDataType.WEIGHT:
          return _aggregateWeight(healthData);
        case HealthDataType.WORKOUT:
          return _aggregateWorkouts(healthData);
        default:
          return healthData;
      }
    } catch (e) {
      _logger.severe('Error fetching $type: $e');
      rethrow;
    }
  }

  Map<String, int> _aggregateSteps(List<HealthDataPoint> healthData) {
    Map<String, int> stepsByDate = {};
    for (var dataPoint in healthData) {
      if (dataPoint.type == HealthDataType.STEPS) {
        final value = dataPoint.value;
        if (value is NumericHealthValue) {
          final date = dataPoint.dateFrom;
          final dateStr = DateTime(date.year, date.month, date.day)
              .toIso8601String()
              .split('T')[0];
          stepsByDate[dateStr] =
              (stepsByDate[dateStr] ?? 0) + value.numericValue.toInt();
        }
      }
    }
    return stepsByDate;
  }

  Map<String, Map<String, dynamic>> _aggregateHeartRate(
      List<HealthDataPoint> healthData) {
    Map<String, Map<String, dynamic>> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];
        final num val = value.numericValue;

        if (!result.containsKey(dateStr)) {
          result[dateStr] = {};
        }

        if (dataPoint.type == HealthDataType.RESTING_HEART_RATE) {
          result[dateStr]!['resting'] = val;
        } else if (dataPoint.type == HealthDataType.HEART_RATE && val > 0) {
          if (!result[dateStr]!.containsKey('min') ||
              val < result[dateStr]!['min']) {
            result[dateStr]!['min'] = val;
          }
          if (!result[dateStr]!.containsKey('max') ||
              val > result[dateStr]!['max']) {
            result[dateStr]!['max'] = val;
          }
        }
      }
    }
    return result;
  }

  Map<String, List<Map<String, dynamic>>> _aggregateBloodPressure(
      List<HealthDataPoint> healthData, HealthDataType type) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];
        // Use HH:mm as key to merge sys and dia
        final timeStr =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        final num val = value.numericValue;

        if (!result.containsKey(dateStr)) {
          result[dateStr] = [];
        }

        // Check if there is already a record for this time
        var existing = result[dateStr]!.where((e) => e['time'] == timeStr);
        if (existing.isNotEmpty) {
          if (type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
            existing.first['systolic'] = val;
          } else {
            existing.first['diastolic'] = val;
          }
        } else {
          result[dateStr]!.add({
            'time': timeStr,
            if (type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) 'systolic': val,
            if (type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC)
              'diastolic': val,
          });
        }
      }
    }
    return result;
  }

  Map<String, Map<String, dynamic>> _aggregateBloodOxygen(
      List<HealthDataPoint> healthData) {
    Map<String, Map<String, dynamic>> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];
        final num val = value.numericValue;

        if (!result.containsKey(dateStr)) {
          result[dateStr] = {'min': val, 'sum': 0.0, 'count': 0};
        }

        if (val < result[dateStr]!['min']) {
          result[dateStr]!['min'] = val;
        }
        result[dateStr]!['sum'] += val;
        result[dateStr]!['count'] += 1;
      }
    }

    // Calculat average
    for (var key in result.keys) {
      if (result[key]!['count'] > 0) {
        double avg = result[key]!['sum'] / result[key]!['count'];
        result[key]!['avg'] = (avg * 10).roundToDouble() / 10;
      }
      result[key]!.remove('sum');
      result[key]!.remove('count');
    }
    return result;
  }

  Map<String, List<Map<String, dynamic>>> _aggregateBloodGlucose(
      List<HealthDataPoint> healthData) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];
        final timeStr =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        final num val = value.numericValue;

        if (!result.containsKey(dateStr)) {
          result[dateStr] = [];
        }
        result[dateStr]!.add({
          'time': timeStr,
          'value': val,
        });
      }
    }
    return result;
  }

  Map<String, dynamic> _aggregateSleep(List<HealthDataPoint> healthData) {
    Map<String, dynamic> result = {};
    for (var dataPoint in healthData) {
      // Typically sleep date is assigned to the day we wake up
      final date = dataPoint.dateTo;
      final dateStr = DateTime(date.year, date.month, date.day)
          .toIso8601String()
          .split('T')[0];

      if (!result.containsKey(dateStr)) {
        result[dateStr] = {
          '_intervals': <Map<String, int>>[],
        };
      }

      // Record interval for actual sleep durations
      bool isSleepStage = [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_UNKNOWN,
        HealthDataType.SLEEP_SESSION,
      ].contains(dataPoint.type);

      if (isSleepStage) {
        (result[dateStr]!['_intervals'] as List<Map<String, int>>).add({
          'start': dataPoint.dateFrom.millisecondsSinceEpoch,
          'end': dataPoint.dateTo.millisecondsSinceEpoch,
        });
      }
    }

    String formatTime(DateTime dt) {
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    // Default processing for each day
    for (var key in result.keys) {
      // Merge overlapping sleep intervals to avoid double counting
      List<Map<String, int>> intervals =
          result[key]!['_intervals'] as List<Map<String, int>>;
      intervals.sort((a, b) => a['start']!.compareTo(b['start']!));

      int totalSleepMs = 0;
      int? mergedStart;
      int? mergedEnd;

      List<Map<String, dynamic>> sessions = [];

      void commitSession() {
        if (mergedStart != null && mergedEnd != null) {
          totalSleepMs += (mergedEnd! - mergedStart!);
          DateTime startDt = DateTime.fromMillisecondsSinceEpoch(mergedStart!);
          DateTime endDt = DateTime.fromMillisecondsSinceEpoch(mergedEnd!);

          sessions.add({
            'bedtime': formatTime(startDt),
            'wake_time': formatTime(endDt),
            'duration_mins': (mergedEnd! - mergedStart!) ~/ 60000,
          });
        }
      }

      for (var interval in intervals) {
        if (mergedStart == null) {
          mergedStart = interval['start'];
          mergedEnd = interval['end'];
        } else {
          if (interval['start']! <= mergedEnd!) {
            // Overlapping, extend end if needed
            if (interval['end']! > mergedEnd!) {
              mergedEnd = interval['end'];
            }
          } else {
            // No overlap, commit previous interval
            commitSession();
            mergedStart = interval['start'];
            mergedEnd = interval['end'];
          }
        }
      }
      commitSession();

      // Only keep the sessions array, removing top-level redundant data
      if (sessions.isNotEmpty) {
        result[key] = sessions;
      } else {
        result[key] = [];
      }
    }

    // Remove empty days
    result.removeWhere((key, value) => (value as List).isEmpty);

    return result;
  }

  Map<String, num> _aggregateActiveEnergy(List<HealthDataPoint> healthData) {
    Map<String, num> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];
        result[dateStr] = (result[dateStr] ?? 0) + value.numericValue;
      }
    }

    // Round to 1 decimal place
    for (var key in result.keys) {
      result[key] = (result[key]! * 10).roundToDouble() / 10;
    }

    return result;
  }

  Map<String, num> _aggregateWeight(List<HealthDataPoint> healthData) {
    Map<String, num> result = {};
    Map<String, DateTime> latestTimes = {};

    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is NumericHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];

        if (!latestTimes.containsKey(dateStr) ||
            date.isAfter(latestTimes[dateStr]!)) {
          latestTimes[dateStr] = date;
          result[dateStr] = value.numericValue;
        }
      }
    }
    return result;
  }

  Map<String, List<Map<String, dynamic>>> _aggregateWorkouts(
      List<HealthDataPoint> healthData) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var dataPoint in healthData) {
      final value = dataPoint.value;
      if (value is WorkoutHealthValue) {
        final date = dataPoint.dateFrom;
        final dateStr = DateTime(date.year, date.month, date.day)
            .toIso8601String()
            .split('T')[0];

        if (!result.containsKey(dateStr)) {
          result[dateStr] = [];
        }

        result[dateStr]!.add({
          'type': value.workoutActivityType.name,
          'duration_mins': dataPoint.dateTo.difference(date).inMinutes,
          'energy_kcal': value.totalEnergyBurned,
          'distance': value.totalDistance,
        });
      }
    }
    return result;
  }
}

/// Strategy B: Use 'pedometer' package + Background Snapshots (STEPS only)
class PedometerFetcher implements HealthDataFetcher {
  static const String _dailyStepSnapshotsKey = 'daily_step_snapshots';
  static const String _androidBackgroundTaskName = 'dailyStepSnapshotTask';
  static const String _iosBackgroundTaskName = 'workmanager.background.task';

  String get _backgroundTaskName =>
      Platform.isIOS ? _iosBackgroundTaskName : _androidBackgroundTaskName;
  final Logger _logger = getLogger('PedometerFetcher');

  @override
  String get name => 'Pedometer';

  @override
  Future<bool> requestPermissions(HealthDataType type) async {
    if (type != HealthDataType.STEPS) {
      _logger.warning('Pedometer strategy only supports STEPS.');
      return false;
    }

    // Only check permission status — do NOT request.
    // Permissions are now requested via System Authorization page.
    Permission permission;
    if (Platform.isIOS) {
      permission = Permission.sensors; // Motion & Fitness on iOS
    } else {
      permission =
          Permission.activityRecognition; // Activity Recognition on Android
    }

    final status = await permission.status;
    return status.isGranted;
  }

  @override
  Future<dynamic> fetchData(
      HealthDataType type, DateTime startTime, DateTime endTime) async {
    if (type != HealthDataType.STEPS) {
      throw UnsupportedError('Pedometer strategy only supports STEPS.');
    }

    // Check permission before accessing pedometer to avoid native crashes
    final hasPermission = await requestPermissions(type);
    if (!hasPermission) {
      _logger.warning(
          'Motion & Fitness permission not granted, skipping step count');
      return <String, int>{};
    }

    // Check if pedometer was previously marked as unavailable
    if (skipThisSession || !_pedometerAvailable) {
      _logger.warning('Pedometer skipped this session');
      return <String, int>{};
    }

    // Mark as "attempting" — if app crashes during pedometer access,
    // this flag will still be set on next launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pedometer_attempting', true);

    // 1. Ensure background task is registered (critical for daily tracking)
    await ensureBackgroundTaskRegistered();

    // 2. Get data from snapshots
    return await _calculateStepsFromSnapshots(startTime, endTime);
  }

  Future<void> ensureBackgroundTaskRegistered() async {
    try {
      // Use a much shorter interval (1 hour) to increase chance of running
      // near the start of the day. Minimum is 15 min on Android.
      // iOS will throttle this based on usage, but 1h is better than 24h.
      await Workmanager().registerPeriodicTask(
        _backgroundTaskName,
        _backgroundTaskName,
        frequency: const Duration(minutes: 20), // User preference: 20mins
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        // CRITICAL: Use 'update' or 'replace' to apply frequency changes.
        // 'keep' ignores changes if task exists.
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
      _logger.info(
          'Background snapshot task registered (Periodic: 20m, Policy: UPDATE)');
    } catch (e) {
      _logger.severe('Failed to register background task: $e');
    }
  }

  /// Track whether pedometer has previously crashed to avoid repeated native crashes.
  static bool _pedometerAvailable = true;

  /// Set by main.dart if previous launch crashed during pedometer access.
  static bool skipThisSession = false;

  Future<Map<String, int>> _calculateStepsFromSnapshots(
      DateTime startTime, DateTime endTime) async {
    if (!_pedometerAvailable) {
      _logger.warning('Pedometer previously failed, skipping');
      return <String, int>{};
    }

    try {
      _logger.info('Calculating steps from snapshots...');

      // Get current cumulative steps (since boot)
      int currentSteps = 0;
      try {
        final stepCountStream = Pedometer.stepCountStream;
        final stepCount =
            await stepCountStream.first.timeout(const Duration(seconds: 5));
        currentSteps = stepCount.steps;
        _logger.info('Current total device steps: $currentSteps');
        // Success — clear the attempting flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pedometer_attempting');
      } catch (e) {
        _logger.severe('Failed to read current pedometer: $e');
        _pedometerAvailable = false;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('pedometer_attempting');
        } catch (_) {}
        return <String, int>{};
      }

      final prefs = await SharedPreferences.getInstance();
      final snapshots = _loadSnapshots(prefs);

      // --- CRITICAL FIX: Ensure Today's Snapshot Exists ---
      // We run this logic every time the app opens or background task runs.
      // If we just crossed midnight and haven't recorded it, do it now.
      await _ensureTodaySnapshot(currentSteps, snapshots, prefs);

      // Now calculate steps for the requested range
      Map<String, int> stepsByDate = {};

      final today = DateTime.now();
      final todayStr = _formatDate(today);

      for (var d = startTime;
          d.isBefore(endTime);
          d = d.add(const Duration(days: 1))) {
        final dStr = _formatDate(d);

        if (dStr == todayStr) {
          // Today's steps = Current - StartOfDaySnapshot
          final startSnapshot = snapshots[todayStr] ?? currentSteps;
          final todaySteps =
              (currentSteps > startSnapshot) ? currentSteps - startSnapshot : 0;
          if (todaySteps > 0) stepsByDate[dStr] = todaySteps;
        } else {
          // Past day's steps = NextDaySnapshot - StartOfDaySnapshot
          final nextDay = d.add(const Duration(days: 1));
          final nextDayStr = _formatDate(nextDay);

          if (snapshots.containsKey(dStr) &&
              snapshots.containsKey(nextDayStr)) {
            final start = snapshots[dStr]!;
            final end = snapshots[nextDayStr]!;
            if (end >= start) {
              stepsByDate[dStr] = end - start;
            }
          }
        }
      }

      return stepsByDate;
    } catch (e) {
      _logger.severe('Error calculating steps: $e');
      return {};
    }
  }

  // Common logic to ensure we have a baseline for "Today"
  Future<void> _ensureTodaySnapshot(int currentSteps,
      Map<String, int> snapshots, SharedPreferences prefs) async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    bool saveNeeded = false;

    // 1. If no snapshot for today, create one.
    // This happens if it's the first run of the day (00:01 AM or 08:00 AM).
    if (!snapshots.containsKey(todayStr)) {
      _logger.info(
          'NEW DAY detected ($todayStr). Initializing snapshot: $currentSteps');
      snapshots[todayStr] = currentSteps;
      saveNeeded = true;
    }
    // 2. Reboot detection (Optional logic: if current < snapshot, device rebooted)
    // Pedometer resets on reboot.
    else if (currentSteps < snapshots[todayStr]!) {
      _logger.info(
          'Reboot detected (Current $currentSteps < Snapshot ${snapshots[todayStr]}). Resetting snapshot.');
      snapshots[todayStr] = currentSteps;
      saveNeeded = true;
    }

    if (saveNeeded) {
      await _saveSnapshots(prefs, snapshots);
    }
  }

  // --- Helper Methods ---

  // Removed _getNextMidnightDelay as we use periodic 1h now.

  String _formatDate(DateTime d) => d.toIso8601String().split('T')[0];

  Map<String, int> _loadSnapshots(SharedPreferences prefs) {
    final json = prefs.getString(_dailyStepSnapshotsKey);
    Map<String, int> snapshots = {};
    if (json != null && json.isNotEmpty) {
      final entries = json.split(',');
      for (var e in entries) {
        final parts = e.split(':');
        if (parts.length == 2) {
          snapshots[parts[0]] = int.parse(parts[1]);
        }
      }
    }
    return snapshots;
  }

  Future<void> _saveSnapshots(
      SharedPreferences prefs, Map<String, int> snapshots) async {
    final str = snapshots.entries.map((e) => '${e.key}:${e.value}').join(',');
    await prefs.setString(_dailyStepSnapshotsKey, str);
  }

  static Future<void> backgroundCallbackLogic() async {
    // Note: Logger initialization is handled by the callbackDispatcher in health_service.dart

    final logger = getLogger('PedometerFetcher');
    logger.severe('Background task triggered (1h periodic)');
    try {
      // 1. Get real-time steps
      final stepCountStream = Pedometer.stepCountStream;
      final stepCount =
          await stepCountStream.first.timeout(const Duration(seconds: 10));
      final currentSteps = stepCount.steps;

      // 2. Load existing snapshots
      final prefs = await SharedPreferences.getInstance();
      final key = 'daily_step_snapshots';

      final json = prefs.getString(key);
      Map<String, int> snapshots = {};
      if (json != null && json.isNotEmpty) {
        json.split(',').forEach((e) {
          final p = e.split(':');
          if (p.length == 2) snapshots[p[0]] = int.parse(p[1]);
        });
      }

      // 3. Logic to check if we entered a new day
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];

      if (!snapshots.containsKey(todayStr)) {
        logger.severe(
            'Background: New Day detected ($todayStr). locking snapshot: $currentSteps');
        snapshots[todayStr] = currentSteps;

        final str =
            snapshots.entries.map((e) => '${e.key}:${e.value}').join(',');
        await prefs.setString(key, str);
      } else {
        logger.severe(
            'Background: Snapshot for $todayStr already exists. No action needed.');
      }
    } on TimeoutException catch (_) {
      // This is expected if the user is stationary (sleeping/sitting) and the sensor doesn't emit updates.
      // We log it as info, not error.
      logger.info(
          'Background: No sensor update (User stationary), skipping snapshot check.');
    } catch (e) {
      logger.severe('Background task unexpected error: $e');
    }
  }
}
