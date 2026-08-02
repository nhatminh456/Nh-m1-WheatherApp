import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

class SettingsRepository {
  static const _keyTempUnit = 'settings_temperature_unit';
  static const _keyAppTheme = 'settings_app_theme';
  static const _keyLanguage = 'settings_language_code';
  static const _keyUpdateFrequency = 'settings_update_frequency_minutes';

  Future<UserSettings> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final tempUnitIndex = prefs.getInt(_keyTempUnit);
    final appThemeIndex = prefs.getInt(_keyAppTheme);
    final languageCode = prefs.getString(_keyLanguage);
    final updateFreq = prefs.getInt(_keyUpdateFrequency);

    return UserSettings(
      temperatureUnit: tempUnitIndex != null
          ? TemperatureUnit.values[tempUnitIndex]
          : TemperatureUnit.celsius,
      appTheme: appThemeIndex != null
          ? AppTheme.values[appThemeIndex]
          : AppTheme.system,
      languageCode: languageCode ?? 'vi',
      updateFrequencyMinutes: updateFreq ?? 30,
    );
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyTempUnit, settings.temperatureUnit.index);
    await prefs.setInt(_keyAppTheme, settings.appTheme.index);
    await prefs.setString(_keyLanguage, settings.languageCode);
    await prefs.setInt(_keyUpdateFrequency, settings.updateFrequencyMinutes);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyTempUnit);
    await prefs.remove(_keyAppTheme);
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyUpdateFrequency);
  }
}
