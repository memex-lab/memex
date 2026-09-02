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

  test('debug tools strings are localized', () {
    final l10n = UserStorage.l10n;

    expect(l10n.debugging, isNotEmpty);
    expect(l10n.agentStates, isNotEmpty);
    expect(l10n.logLevel, isNotEmpty);
    expect(l10n.taskIdLabel('42'), contains('42'));
    expect(l10n.taskBizIdLabel('biz-1'), contains('biz-1'));
    expect(l10n.taskStatusLabel('pending'), contains('pending'));
    expect(l10n.taskScheduledLabel('2026-01-01'), contains('2026-01-01'));
    expect(l10n.taskCompletedLabel('2026-01-02'), contains('2026-01-02'));
    expect(l10n.oauthCouldNotLaunchBrowser, isNotEmpty);
    expect(l10n.authorizationTimedOut, isNotEmpty);
  });
}
