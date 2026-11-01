import 'package:retroplayer/domain/supported_locale_codes.dart';

/// User-selected app language (`system` or a BCP-47 language code).
final class LocalePreference {
  const LocalePreference._(this._storageCode);

  /// Follow the device / OS language.
  static const system = LocalePreference._(null);

  /// Fixed app language (matches ARB suffix, e.g. `de`, `zh`).
  factory LocalePreference.language(String storageCode) {
    assert(storageCode.isNotEmpty && storageCode != 'system');
    return LocalePreference._(storageCode);
  }

  final String? _storageCode;

  bool get isSystem => _storageCode == null;

  String? get languageCode => _storageCode;

  String toStorage() => _storageCode ?? 'system';

  static LocalePreference fromStorage(String? value) {
    if (value == null || value.isEmpty || value == 'system') {
      return system;
    }
    if (!SupportedLocaleCodes.contains(value)) {
      return system;
    }
    return LocalePreference.language(value);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalePreference && other._storageCode == _storageCode;
  }

  @override
  int get hashCode => _storageCode.hashCode;
}
