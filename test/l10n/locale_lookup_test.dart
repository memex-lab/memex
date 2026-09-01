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
}
