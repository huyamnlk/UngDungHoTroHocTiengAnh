import 'package:flutter/material.dart';
import '../core/constants/app_languages.dart';
import '../core/services/settings_service.dart';

class LocaleProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  Locale _locale = const Locale(AppLanguages.defaultLanguageCode);

  LocaleProvider({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService() {
    _loadLocale();
  }

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isVietnamese => _locale.languageCode == 'vi';
  bool get isEnglish => _locale.languageCode == 'en';

  void _loadLocale() {
    final code = _settingsService.getLanguageCode();
    final validCode = AppLanguages.isSupported(code)
        ? code
        : AppLanguages.defaultLanguageCode;
    _locale = Locale(validCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    final code = newLocale.languageCode.trim().toLowerCase();
    final targetCode = AppLanguages.isSupported(code)
        ? code
        : AppLanguages.defaultLanguageCode;

    if (_locale.languageCode == targetCode) return;

    _locale = Locale(targetCode);
    notifyListeners();
    try {
      await _settingsService.setLanguageCode(targetCode);
    } catch (e) {
      debugPrint('LocaleProvider persistence warning for "$targetCode": $e');
    }
  }
}
