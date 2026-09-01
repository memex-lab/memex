import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/l10n/app_localizations_ext.dart';
import 'package:memex/l10n/supported_languages.dart';

void main() {
  test('every supported language tag resolves and loads l10n', () {
    for (final language in supportedLanguages) {
      final l10n = lookupAppLocalizations(language.locale);
      final ext = lookupAppLocalizationsExt(language.locale);

      expect(l10n.localeName, isNotEmpty);
      expect(ext.defaultCharacters, isNotEmpty);
      expect(ext.oauthHintTitle, isNotEmpty);
    }
  });

  test('Vietnamese locale exposes translated common actions', () {
    if (!supportedLanguageTags.contains('vi')) {
      return;
    }

    const locale = Locale('vi');
    final l10n = lookupAppLocalizations(locale);

    expect(l10n.localeName, 'vi');
    expect(l10n.retry, 'Thử lại');
    expect(l10n.cancel, 'Hủy');
  });

  test('Farsi locale exposes translated common actions', () {
    if (!supportedLanguageTags.contains('fa')) {
      return;
    }

    const locale = Locale('fa');
    final l10n = lookupAppLocalizations(locale);

    expect(l10n.localeName, 'fa');
    expect(l10n.retry, 'تلاش مجدد');
    expect(l10n.cancel, 'لغو');
  });

  test('new locales expose the simplified AI setup copy', () {
    const expectedCopy = <String, List<String>>{
      'fa': [
        'استفاده از سرویس رسمی Memex',
        'برای استفاده از سرویس رسمی هوش مصنوعی وارد Memex شوید.',
        'ارائه‌دهنده و کلید API خود را اضافه کنید.',
      ],
      'vi': [
        'Đang dùng dịch vụ chính thức Memex',
        'Đăng nhập Memex để sử dụng dịch vụ AI chính thức.',
        'Thêm nhà cung cấp và API Key của bạn.',
      ],
      'th': [
        'ใช้บริการอย่างเป็นทางการของ Memex',
        'ลงชื่อเข้าใช้ Memex เพื่อใช้บริการ AI อย่างเป็นทางการ',
        'เพิ่มผู้ให้บริการและ API Key ของคุณ',
      ],
      'tr': [
        'Memex resmi hizmeti kullanılıyor',
        "Resmi AI hizmetini kullanmak için Memex'te oturum açın.",
        'Kendi sağlayıcınızı ve API anahtarınızı ekleyin.',
      ],
    };

    for (final entry in expectedCopy.entries) {
      final l10n = lookupAppLocalizations(Locale(entry.key));
      expect(l10n.aiSetupStatusMemexTitle, entry.value[0]);
      expect(l10n.aiSetupOfficialRouteDescription, entry.value[1]);
      expect(l10n.aiSetupCustomRouteDescription, entry.value[2]);
      expect(l10n.aiSetupStatusMemexDescription, isNot(contains('MemeX')));
    }
  });
}
