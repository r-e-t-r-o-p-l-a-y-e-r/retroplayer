import 'package:flutter/material.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/ui/core/preference_mapping.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({required LibraryStorageService storageService})
      : _storageService = storageService;

  final LibraryStorageService _storageService;

  ThemePreference _preference = ThemePreference.system;
  bool _loaded = false;

  ThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _preference = await _storageService.getThemePreference();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPreference(ThemePreference preference) async {
    if (_preference == preference) return;
    _preference = preference;
    notifyListeners();
    await _storageService.setThemePreference(preference);
  }
}
