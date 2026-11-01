import 'package:flutter/material.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };
}

extension LocalePreferenceLocale on LocalePreference {
  /// Null follows the system language.
  Locale? get locale => AppLocaleCatalog.localeForPreference(this);
}
