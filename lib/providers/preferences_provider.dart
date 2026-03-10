import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../services/storage_service.dart';

class PreferencesProvider extends ChangeNotifier {
  final StorageService _storage;
  UserPreferences _preferences = UserPreferences();

  PreferencesProvider(this._storage);

  UserPreferences get preferences => _preferences;

  Future<void> loadPreferences() async {
    _preferences = await _storage.loadPreferences();
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.savePreferences(_preferences);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _preferences.themeMode = mode;
    await _save();
  }

  Future<void> setComplexityLevel(ComplexityLevel level) async {
    _preferences.complexityLevel = level;
    await _save();
  }

  Future<void> setFontScale(FontScale scale) async {
    _preferences.fontScale = scale;
    await _save();
  }

  Future<void> setSpacingLevel(SpacingLevel level) async {
    _preferences.spacingLevel = level;
    await _save();
  }

  Future<void> toggleFocusMode() async {
    _preferences.focusMode = !_preferences.focusMode;
    await _save();
  }

  Future<void> resetPreferences() async {
    _preferences = UserPreferences();
    await _save();
  }

  Future<void> importPreferences(UserPreferences prefs) async {
    _preferences = prefs;
    await _save();
  }
}
