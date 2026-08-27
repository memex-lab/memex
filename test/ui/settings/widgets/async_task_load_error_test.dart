import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/settings/widgets/async_task_list_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('uses localized operationFailed for load errors', () {
    expect(
      asyncTaskLoadErrorMessage('timeout'),
      UserStorage.l10n.operationFailed('timeout'),
    );
  });
}
