import 'package:flutter/material.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/supported_locale_codes.dart';

/// One selectable app language (storage code matches `app_<code>.arb`).
final class AppLocaleEntry {
  const AppLocaleEntry({
    required this.storageCode,
    required this.locale,
    required this.endonym,
  });

  final String storageCode;
  final Locale locale;
  final String endonym;
}

/// Supported app locales and picker endonyms (native language names).
abstract final class AppLocaleCatalog {
  static const entries = <AppLocaleEntry>[
    AppLocaleEntry(storageCode: 'en', locale: Locale('en'), endonym: 'English'),
    AppLocaleEntry(storageCode: 'zh', locale: Locale('zh'), endonym: '中文'),
    AppLocaleEntry(storageCode: 'hi', locale: Locale('hi'), endonym: 'हिन्दी'),
    AppLocaleEntry(storageCode: 'es', locale: Locale('es'), endonym: 'Español'),
    AppLocaleEntry(storageCode: 'fr', locale: Locale('fr'), endonym: 'Français'),
    AppLocaleEntry(storageCode: 'ar', locale: Locale('ar'), endonym: 'العربية'),
    AppLocaleEntry(storageCode: 'bn', locale: Locale('bn'), endonym: 'বাংলা'),
    AppLocaleEntry(storageCode: 'pt', locale: Locale('pt'), endonym: 'Português'),
    AppLocaleEntry(storageCode: 'ru', locale: Locale('ru'), endonym: 'Русский'),
    AppLocaleEntry(storageCode: 'ja', locale: Locale('ja'), endonym: '日本語'),
    AppLocaleEntry(storageCode: 'de', locale: Locale('de'), endonym: 'Deutsch'),
    AppLocaleEntry(storageCode: 'ko', locale: Locale('ko'), endonym: '한국어'),
    AppLocaleEntry(storageCode: 'tr', locale: Locale('tr'), endonym: 'Türkçe'),
    AppLocaleEntry(storageCode: 'vi', locale: Locale('vi'), endonym: 'Tiếng Việt'),
    AppLocaleEntry(storageCode: 'it', locale: Locale('it'), endonym: 'Italiano'),
    AppLocaleEntry(storageCode: 'id', locale: Locale('id'), endonym: 'Indonesia'),
    AppLocaleEntry(storageCode: 'pl', locale: Locale('pl'), endonym: 'Polski'),
    AppLocaleEntry(storageCode: 'nl', locale: Locale('nl'), endonym: 'Nederlands'),
    AppLocaleEntry(storageCode: 'ur', locale: Locale('ur'), endonym: 'اردو'),
    AppLocaleEntry(storageCode: 'fa', locale: Locale('fa'), endonym: 'فارسی'),
    AppLocaleEntry(storageCode: 'he', locale: Locale('he'), endonym: 'עברית'),
    AppLocaleEntry(storageCode: 'th', locale: Locale('th'), endonym: 'ไทย'),
    AppLocaleEntry(storageCode: 'uk', locale: Locale('uk'), endonym: 'Українська'),
    AppLocaleEntry(storageCode: 'ro', locale: Locale('ro'), endonym: 'Română'),
    AppLocaleEntry(storageCode: 'el', locale: Locale('el'), endonym: 'Ελληνικά'),
    AppLocaleEntry(storageCode: 'cs', locale: Locale('cs'), endonym: 'Čeština'),
    AppLocaleEntry(storageCode: 'sv', locale: Locale('sv'), endonym: 'Svenska'),
    AppLocaleEntry(storageCode: 'hu', locale: Locale('hu'), endonym: 'Magyar'),
    AppLocaleEntry(storageCode: 'da', locale: Locale('da'), endonym: 'Dansk'),
    AppLocaleEntry(storageCode: 'fi', locale: Locale('fi'), endonym: 'Suomi'),
    AppLocaleEntry(storageCode: 'nb', locale: Locale('nb'), endonym: 'Norsk bokmål'),
    AppLocaleEntry(storageCode: 'is', locale: Locale('is'), endonym: 'Íslenska'),
    AppLocaleEntry(storageCode: 'bg', locale: Locale('bg'), endonym: 'Български'),
    AppLocaleEntry(storageCode: 'hr', locale: Locale('hr'), endonym: 'Hrvatski'),
    AppLocaleEntry(storageCode: 'sk', locale: Locale('sk'), endonym: 'Slovenčina'),
    AppLocaleEntry(storageCode: 'sl', locale: Locale('sl'), endonym: 'Slovenščina'),
    AppLocaleEntry(storageCode: 'sr', locale: Locale('sr'), endonym: 'Српски'),
    AppLocaleEntry(storageCode: 'lt', locale: Locale('lt'), endonym: 'Lietuvių'),
    AppLocaleEntry(storageCode: 'lv', locale: Locale('lv'), endonym: 'Latviešu'),
    AppLocaleEntry(storageCode: 'et', locale: Locale('et'), endonym: 'Eesti'),
    AppLocaleEntry(storageCode: 'ga', locale: Locale('ga'), endonym: 'Gaeilge'),
    AppLocaleEntry(storageCode: 'mt', locale: Locale('mt'), endonym: 'Malti'),
    AppLocaleEntry(storageCode: 'sq', locale: Locale('sq'), endonym: 'Shqip'),
    AppLocaleEntry(storageCode: 'mk', locale: Locale('mk'), endonym: 'Македонски'),
    AppLocaleEntry(storageCode: 'bs', locale: Locale('bs'), endonym: 'Bosanski'),
    AppLocaleEntry(storageCode: 'ca', locale: Locale('ca'), endonym: 'Català'),
  ];

  static List<Locale> get supportedLocales =>
      entries.map((e) => e.locale).toList(growable: false);

  /// Picker list order: alphabetical by endonym (Unicode code-point order).
  static List<AppLocaleEntry> pickerEntries(Locale _) {
    final sorted = List<AppLocaleEntry>.from(entries)
      ..sort((a, b) => a.endonym.compareTo(b.endonym));
    return sorted;
  }

  static bool isKnownStorageCode(String code) =>
      SupportedLocaleCodes.contains(code);

  static AppLocaleEntry? entryForCode(String code) {
    for (final e in entries) {
      if (e.storageCode == code) return e;
    }
    return null;
  }

  static String endonymForCode(String code) =>
      entryForCode(code)?.endonym ?? code;

  static Locale? localeForPreference(LocalePreference preference) {
    if (preference.isSystem) return null;
    return entryForCode(preference.languageCode!)?.locale ??
        Locale(preference.languageCode!);
  }
}
