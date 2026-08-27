import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memex/data/repositories/get_aggregated_timeline.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('day labels use the active locale weekday name', () async {
    await initializeDateFormatting('zh');
    await UserStorage.setLocale(const Locale('zh'));

    final (label, subLabel) = getPeriodLabels('2026-08-27', 'days');
    expect(subLabel, isNot(equals('Thursday')));
    expect(label, isNot(contains('Aug')));
  });

  test('month labels use the active locale month name', () async {
    await initializeDateFormatting('zh');
    await UserStorage.setLocale(const Locale('zh'));

    final (label, subLabel) = getPeriodLabels('2026-08', 'months');
    expect(label, isNot(equals('August 2026')));
    expect(subLabel, '');
  });
}
