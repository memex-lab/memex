import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('chat send errors use existing l10n strings', () {
    expect(chatErrorUserNotLoggedIn(), UserStorage.l10n.userIdNotFound);
    expect(chatErrorEmptyMessage(), UserStorage.l10n.unknownError);
    expect(
      chatErrorOperationFailed('timeout'),
      UserStorage.l10n.operationFailed('timeout'),
    );
  });
}
