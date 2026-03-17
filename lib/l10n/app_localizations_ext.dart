// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';
import 'app_localizations_ext_en.dart';
import 'app_localizations_ext_zh.dart';
import 'package:flutter/material.dart';

// ignore_for_file: type=lint

/// The extension for AppLocalizations.
mixin AppLocalizationsExt on AppLocalizations {
  String get pkmPARAStructureExample;
  String get timelineCardLanguageInstruction;
  String get pkmFileLanguageInstruction;
  String get pkmInsightLanguageInstruction;
  String get commentLanguageInstruction;
  String get knowledgeInsightLanguageInstruction;
  String get assetAnalysisLanguageInstruction;

  String get userLanguageInstruction;

  String get chatLanguageInstruction;

  String get memorySummarizeLanguageInstruction;

  String get memorySummarizeIdentityHeader;

  String get memorySummarizeInterestsHeader;

  String get memorySummarizeAssetsHeader;

  String get memorySummarizeFocusHeader;

  /// Android OAuth hint dialog (before opening browser).
  String get oauthHintTitle;
  String get oauthHintMessage;

  /// OAuth success page (HTML) after redirect.
  String get oauthSuccessTitle;
  String get oauthSuccessMessage;

  /// Share poster localization.
  String get sharePreviewTitle;
  String get shareNow;
  String get sharedFromMemex;
  String get appTagline;

  /// Default built-in characters (used to seed `Characters/*.yaml`).
  List<Map<String, dynamic>> get defaultCharacters;
}

/// Standalone function to lookup AppLocalizationsExt instances by locale.
AppLocalizationsExt lookupAppLocalizationsExt(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsExtEn();
    case 'zh':
      return AppLocalizationsExtZh();
  }

  throw FlutterError(
      'AppLocalizationsExt.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
