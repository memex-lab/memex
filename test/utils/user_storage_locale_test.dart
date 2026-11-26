import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserStorage locale resolution', () {
    test('keeps every supported base language when resolving the locale', () {
      for (final code in const [
        'en',
        'zh',
        'de',
        'ja',
        'ko',
        'es',
        'hi',
        'ar',
        'pt',
        'fr',
        'id',
        'fa',
        'vi',
        'th',
        'tr',
        'it',
        'ru',
      ]) {
        expect(UserStorage.resolveToSupportedLocale(Locale(code)), Locale(code),
            reason: code);
      }
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
