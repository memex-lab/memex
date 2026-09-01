import 'package:flutter/widgets.dart';

class SupportedLanguage {
  const SupportedLanguage({
    required this.locale,
    required this.localeTag,
    required this.nativeName,
    required this.englishName,
    required this.shortLabel,
  });

  final Locale locale;
  final String localeTag;
  final String nativeName;
  final String englishName;
  final String shortLabel;
}

const List<SupportedLanguage> supportedLanguages = <SupportedLanguage>[
  SupportedLanguage(
    locale: Locale('en'),
    localeTag: 'en',
    nativeName: 'English',
    englishName: 'English',
    shortLabel: 'EN',
  ),
  SupportedLanguage(
    locale: Locale('zh'),
    localeTag: 'zh',
    nativeName: '简体中文',
    englishName: 'Simplified Chinese',
    shortLabel: '简',
  ),
  SupportedLanguage(
    locale: Locale('de'),
    localeTag: 'de',
    nativeName: 'Deutsch',
    englishName: 'German',
    shortLabel: 'DE',
  ),
  SupportedLanguage(
    locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    localeTag: 'zh_Hant',
    nativeName: '繁體中文',
    englishName: 'Traditional Chinese',
    shortLabel: '繁',
  ),
  SupportedLanguage(
    locale: Locale('ja'),
    localeTag: 'ja',
    nativeName: '日本語',
    englishName: 'Japanese',
    shortLabel: '日',
  ),
  SupportedLanguage(
    locale: Locale('ko'),
    localeTag: 'ko',
    nativeName: '한국어',
    englishName: 'Korean',
    shortLabel: '한',
  ),
  SupportedLanguage(
    locale: Locale('es'),
    localeTag: 'es',
    nativeName: 'Español',
    englishName: 'Spanish',
    shortLabel: 'ES',
  ),
  SupportedLanguage(
    locale: Locale('hi'),
    localeTag: 'hi',
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
    shortLabel: 'हि',
  ),
  SupportedLanguage(
    locale: Locale('ar'),
    localeTag: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    shortLabel: 'عر',
  ),
  SupportedLanguage(
    locale: Locale('pt'),
    localeTag: 'pt',
    nativeName: 'Português',
    englishName: 'Portuguese',
    shortLabel: 'PT',
  ),
  SupportedLanguage(
    locale: Locale('fr'),
    localeTag: 'fr',
    nativeName: 'Français',
    englishName: 'French',
    shortLabel: 'FR',
  ),
  SupportedLanguage(
    locale: Locale('id'),
    localeTag: 'id',
    nativeName: 'Bahasa Indonesia',
    englishName: 'Indonesian',
    shortLabel: 'ID',
  ),
  SupportedLanguage(
    locale: Locale('fa'),
    localeTag: 'fa',
    nativeName: 'فارسی',
    englishName: 'Persian',
    shortLabel: 'FA',
  ),
  SupportedLanguage(
    locale: Locale('vi'),
    localeTag: 'vi',
    nativeName: 'Tiếng Việt',
    englishName: 'Vietnamese',
    shortLabel: 'VI',
  ),
  // th was on the upstream i18n wishlist
  SupportedLanguage(
    locale: Locale('th'),
    localeTag: 'th',
    nativeName: 'ไทย',
    englishName: 'Thai',
    shortLabel: 'TH',
  ),
  SupportedLanguage(
    locale: Locale('ru'),
    localeTag: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    shortLabel: 'RU',
  ),
];

const List<Locale> supportedLanguageLocales = <Locale>[
  Locale('en'),
  Locale('zh'),
  Locale('de'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('ja'),
  Locale('ko'),
  Locale('es'),
  Locale('hi'),
  Locale('ar'),
  Locale('pt'),
  Locale('fr'),
  Locale('id'),
  Locale('fa'),
  Locale('vi'),
  Locale('th'),
  Locale('ru'),
];

const List<String> supportedLanguageTags = <String>[
  'en',
  'zh',
  'de',
  'zh_Hant',
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
  'ru',
];

SupportedLanguage supportedLanguageByTag(String localeTag) {
  return supportedLanguages.firstWhere(
    (language) => language.localeTag == localeTag,
    orElse: () => supportedLanguages.first,
  );
}
