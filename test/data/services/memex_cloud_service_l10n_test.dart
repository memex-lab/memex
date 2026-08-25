import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'language': 'en',
    });
    await UserStorage.initL10n();
  });

  test('auth and payment fallbacks resolve from l10n after init', () {
    expect(UserStorage.l10n.usernameAlreadyTaken, 'Username already taken');
    expect(UserStorage.l10n.registrationFailed, 'Registration failed');
    expect(UserStorage.l10n.loginFailed, 'Login failed');
    expect(UserStorage.l10n.paymentCreationFailed, 'Could not start payment');
  });
}
