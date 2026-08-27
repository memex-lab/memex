import 'package:flutter/widgets.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('uses unknownError when the error text is empty', () {
    expect(
      ToastHelper.formatErrorMessage(ApiException('  ')),
      UserStorage.l10n.unknownError,
    );
  });

  test('keeps ApiException messages', () {
    expect(ToastHelper.formatErrorMessage(ApiException('nope')), 'nope');
  });
}
