import 'package:flutter/material.dart';
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

  test('week labels use German week label', () async {
    await initializeDateFormatting('de');
    await UserStorage.setLocale(const Locale('de'));

    final (label, subLabel) = getPeriodLabels('2026-W10', 'weeks');

    expect(label, contains('Woche'));
    expect(label, contains('10'));
    expect(subLabel, isNotEmpty);
  });
}
