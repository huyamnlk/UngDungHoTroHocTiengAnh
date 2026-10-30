import 'package:flutter/material.dart';
import '../core/services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    return false;
  }

  void _loadTheme() {
    _themeMode = _settingsService.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsService.setThemeMode(mode);
    notifyListeners();
  }
}
