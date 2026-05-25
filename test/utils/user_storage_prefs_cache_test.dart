import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    UserStorage.resetPrefsCache();
    SharedPreferences.setMockInitialValues({'user_id': 'cached-user'});
  });

  tearDown(UserStorage.resetPrefsCache);

  test('getUserId rereads the mock store through sharedPrefs', () async {
    for (var i = 0; i < 20; i++) {
      expect(await UserStorage.getUserId(), 'cached-user');
    }

    SharedPreferences.setMockInitialValues({'user_id': 'next-user'});
    expect(await UserStorage.getUserId(), 'next-user');
  });

  test('getUserId treats blank values as logged out', () async {
    SharedPreferences.setMockInitialValues({'user_id': '   '});
    expect(await UserStorage.getUserId(), isNull);
  });
}
