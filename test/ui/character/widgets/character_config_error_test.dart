import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/character/widgets/character_config_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('image import fallback has no StateError prefix', () {
    final message = characterImageImportFailureMessage(null);

    expect(
      message,
      UserStorage.l10n.operationFailed(UserStorage.l10n.unknownError),
    );
    expect(message, isNot(contains('Bad state:')));
  });

  test('image import keeps a specific error message', () {
    expect(
      characterImageImportFailureMessage('disk full'),
      UserStorage.l10n.operationFailed('disk full'),
    );
  });
}
