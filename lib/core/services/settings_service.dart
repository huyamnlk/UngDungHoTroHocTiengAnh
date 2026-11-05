import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLanguageCode = 'app_language_code';
  static const String _keyDailyGoal = 'daily_word_goal';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyStreakDays = 'streak_days';
  static const String _keyLastActiveDate = 'last_active_date';
  static const String _keyAuthSessionUser = 'auth_session_user';
  static const String _keyAuthIdToken = 'auth_id_token';
  static const String _keyAuthRefreshToken = 'auth_refresh_token';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    _updateStreak();
  }

  String getLanguageCode() {
    if (!_isInitialized) return 'vi';
    return _prefs.getString(_keyLanguageCode) ?? 'vi';
  }

  Future<void> setLanguageCode(String code) async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
    await _prefs.setString(_keyLanguageCode, code);
  }

  ThemeMode getThemeMode() {
    if (!_isInitialized) return ThemeMode.system;
    final mode = _prefs.getString(_keyThemeMode) ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (!_isInitialized) return;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
        break;
    }
    await _prefs.setString(_keyThemeMode, value);
  }

  int getDailyGoal() {
    if (!_isInitialized) return 10;
    return _prefs.getInt(_keyDailyGoal) ?? 10;
  }

  Future<void> setDailyGoal(int goal) async {
    if (!_isInitialized) return;
    await _prefs.setInt(_keyDailyGoal, goal);
  }

  bool isSoundEnabled() {
    if (!_isInitialized) return true;
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (!_isInitialized) return;
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  bool isOnboardingDone() {
    if (!_isInitialized) return false;
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone(bool done) async {
    if (!_isInitialized) return;
    await _prefs.setBool(_keyOnboardingDone, done);
  }

  int getStreakDays() {
    if (!_isInitialized) return 1;
    return _prefs.getInt(_keyStreakDays) ?? 1;
  }

  Future<void> saveAuthSession({
    required String sessionJson,
    required String idToken,
    String? refreshToken,
  }) async {
    if (!_isInitialized) return;
    await _prefs.setString(_keyAuthSessionUser, sessionJson);
    if (idToken.isNotEmpty) {
      await _prefs.setString(_keyAuthIdToken, idToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_keyAuthRefreshToken, refreshToken);
    }
  }

  String? getSavedAuthSessionUser() {
    if (!_isInitialized) return null;
    return _prefs.getString(_keyAuthSessionUser);
  }

  String? getSavedAuthIdToken() {
    if (!_isInitialized) return null;
    return _prefs.getString(_keyAuthIdToken);
  }

  String? getSavedAuthRefreshToken() {
    if (!_isInitialized) return null;
    return _prefs.getString(_keyAuthRefreshToken);
  }

  Future<void> clearAuthSession() async {
    if (!_isInitialized) return;
    await _prefs.remove(_keyAuthSessionUser);
    await _prefs.remove(_keyAuthIdToken);
    await _prefs.remove(_keyAuthRefreshToken);
  }

  void _updateStreak() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastActive = _prefs.getString(_keyLastActiveDate);

    if (lastActive == null) {
      _prefs.setString(_keyLastActiveDate, todayStr);
      _prefs.setInt(_keyStreakDays, 1);
      return;
    }

    if (lastActive == todayStr) {
      // Đã ghi nhận hôm nay rồi
      return;
    }

    try {
      final lastDate = DateTime.parse(lastActive);
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        // Chuỗi liên tiếp
        final current = _prefs.getInt(_keyStreakDays) ?? 1;
        _prefs.setInt(_keyStreakDays, current + 1);
      } else if (diff > 1) {
        // Bị đứt chuỗi
        _prefs.setInt(_keyStreakDays, 1);
      }
      _prefs.setString(_keyLastActiveDate, todayStr);
    } catch (_) {
      _prefs.setString(_keyLastActiveDate, todayStr);
    }
  }
}
