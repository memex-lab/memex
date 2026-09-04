import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/l10n/app_localizations_ext.dart';
import 'package:memex/l10n/supported_languages.dart';

void main() {
  test('Italian locale resolves and loads l10n', () {
    if (!supportedLanguageTags.contains('it')) {
      return;
    }

    const locale = Locale('it');
    final l10n = lookupAppLocalizations(locale);
    final ext = lookupAppLocalizationsExt(locale);

    expect(l10n.localeName, 'it');
    expect(l10n.retry, 'Riprova');
    expect(l10n.cancel, 'Cancellare');
    expect(ext.defaultCharacters, isNotEmpty);
    expect(ext.oauthHintTitle, isNotEmpty);
  });

  test('Italian locale exposes the simplified AI setup copy', () {
    if (!supportedLanguageTags.contains('it')) {
      return;
    }

    const locale = Locale('it');
    final l10n = lookupAppLocalizations(locale);

    expect(l10n.aiSetupStatusMemexTitle, 'Utilizzando il servizio ufficiale Memex');
    expect(
      l10n.aiSetupOfficialRouteDescription,
      'Accedi a Memex per utilizzare il servizio AI ufficiale.',
    );
    expect(
      l10n.aiSetupCustomRouteDescription,
      'Aggiungi il tuo provider e la chiave API.',
    );
    expect(l10n.aiSetupStatusMemexDescription, isNot(contains('MemeX')));
  });
}
