import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/insight/widgets/insight_template_gallery_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('uses localized operationFailed when a template fails to build', () {
    expect(
      insightTemplateBuildError('classic'),
      UserStorage.l10n.operationFailed('classic'),
    );
  });
}
