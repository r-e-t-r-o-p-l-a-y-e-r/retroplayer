/// BCP-47 language codes with app ARB translations (matches [AppLocaleCatalog]).
abstract final class SupportedLocaleCodes {
  static const codes = {
    'en', 'zh', 'hi', 'es', 'fr', 'ar', 'bn', 'pt', 'ru', 'ja', 'de', 'ko',
    'tr', 'vi', 'it', 'id', 'pl', 'nl', 'ur', 'fa', 'he', 'th', 'uk', 'ro',
    'el', 'cs', 'sv', 'hu', 'da', 'fi', 'nb', 'is', 'bg', 'hr', 'sk', 'sl',
    'sr', 'lt', 'lv', 'et', 'ga', 'mt', 'sq', 'mk', 'bs', 'ca',
  };

  static bool contains(String code) => codes.contains(code);
}
