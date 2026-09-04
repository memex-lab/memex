import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserStorage locale resolution', () {
    test('keeps supported German locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('de'));

      expect(locale.languageCode, 'de');
    });

    test('keeps supported Japanese locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('ja'));

      expect(locale.languageCode, 'ja');
    });

    test('keeps supported Spanish locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('es'));

      expect(locale.languageCode, 'es');
    });

    test('keeps supported Portuguese locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('pt'));

      expect(locale.languageCode, 'pt');
    });

    test('keeps supported French locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('fr'));

      expect(locale.languageCode, 'fr');
    });

    test('keeps supported Korean locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('ko'));

      expect(locale.languageCode, 'ko');
    });

    test('keeps supported Hindi locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('hi'));

      expect(locale.languageCode, 'hi');
    });

    test('keeps supported Indonesian locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('id'));

      expect(locale.languageCode, 'id');
    });

    test('keeps supported Arabic locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('ar'));

      expect(locale.languageCode, 'ar');
    });

    test('keeps supported Russian locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('ru'));

      expect(locale.languageCode, 'ru');
    });

    test('keeps supported Italian locale', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('it'));

      expect(locale.languageCode, 'it');
    });

    test('keeps supported Traditional Chinese locale', () {
      final locale = UserStorage.resolveToSupportedLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );

      expect(UserStorage.localeTag(locale), 'zh_Hant');
    });

    test('resolves Traditional Chinese regions to zh_Hant', () {
      final locale = UserStorage.resolveToSupportedLocale(
        const Locale('zh', 'TW'),
      );

      expect(UserStorage.localeTag(locale), 'zh_Hant');
    });

    test('parses locale tags with script codes', () {
      final locale = UserStorage.localeFromTag('zh_Hant');

      expect(locale.languageCode, 'zh');
      expect(locale.scriptCode, 'Hant');
      expect(UserStorage.localeTag(locale), 'zh_Hant');
    });

    test('falls back unsupported locales to English', () {
      final locale = UserStorage.resolveToSupportedLocale(const Locale('nl'));

      expect(locale.languageCode, 'en');
    });
  });

  group('UserStorage Memex Agent notification permission marker', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('is scoped to the active user', () async {
      await UserStorage.saveUser('user-a');

      expect(
        await UserStorage.hasPromptedMemexAgentNotificationPermission(),
        isFalse,
      );

      await UserStorage.setMemexAgentNotificationPermissionPrompted();
      expect(
        await UserStorage.hasPromptedMemexAgentNotificationPermission(),
        isTrue,
      );

      await UserStorage.saveUser('user-b');
      expect(
        await UserStorage.hasPromptedMemexAgentNotificationPermission(),
        isFalse,
      );

      await UserStorage.saveUser('user-a');
      expect(
        await UserStorage.hasPromptedMemexAgentNotificationPermission(),
        isTrue,
      );
    });

    test('does not set a marker without a user', () async {
      await UserStorage.setMemexAgentNotificationPermissionPrompted();

      expect(
        await UserStorage.hasPromptedMemexAgentNotificationPermission(),
        isFalse,
      );
    });

    test('classifies the permission prompt marker as device-local', () {
      expect(
        UserStorage.isDeviceLocalPreferenceKey(
          'memex_agent_notification_permission_prompted_user-a',
        ),
        isTrue,
      );
      expect(
        UserStorage.isDeviceLocalPreferenceKey('language'),
        isFalse,
      );
    });
  });
}
