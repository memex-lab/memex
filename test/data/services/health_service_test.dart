import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:memex/data/services/health_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'registers only steps on Android and the HealthKit metrics on the other platform branch',
      () {
    final types = HealthService().registeredTypes;
    if (Platform.isAndroid) {
      expect(types, [HealthDataType.STEPS]);
      return;
    }
    expect(
      types,
      containsAll(<HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.WEIGHT,
        HealthDataType.WORKOUT,
      ]),
    );
  });
}
