/// User-selected app theme appearance.
enum ThemePreference {
  light,
  dark,
  system;

  static ThemePreference fromStorage(String? value) {
    return ThemePreference.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemePreference.system,
    );
  }
}
