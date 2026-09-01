import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('OAuth authorize UI strings are localized', () {
    final l10n = UserStorage.l10n;

    expect(l10n.authorizedSuccessfully, isNotEmpty);
    expect(l10n.authorizedAs('user@example.com'), contains('user@example.com'));
    expect(l10n.reAuthorize, isNotEmpty);
    expect(l10n.authorizeWithOpenAi, isNotEmpty);
    expect(l10n.authorizeWithGoogle, isNotEmpty);
    expect(l10n.authorized, isNotEmpty);
    expect(l10n.unauthorized, isNotEmpty);
    expect(l10n.loadHistoryFailed('timeout'), contains('timeout'));
  });
}
