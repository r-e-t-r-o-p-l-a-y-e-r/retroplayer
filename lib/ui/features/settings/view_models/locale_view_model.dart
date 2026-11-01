import 'package:flutter/material.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/ui/core/preference_mapping.dart';

class LocaleViewModel extends ChangeNotifier {
  LocaleViewModel({required this._storageService});

  final LibraryStorageService _storageService;

  LocalePreference _preference = LocalePreference.system;

  LocalePreference get preference => _preference;
  Locale? get locale => _preference.locale;

  Future<void> load() async {
    _preference = await _storageService.getLocalePreference();
    notifyListeners();
  }

  Future<void> setPreference(LocalePreference preference) async {
    if (_preference == preference) return;
    _preference = preference;
    notifyListeners();
    await _storageService.setLocalePreference(preference);
  }
}
