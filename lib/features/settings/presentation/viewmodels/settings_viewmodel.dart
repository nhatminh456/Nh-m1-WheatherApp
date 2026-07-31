import 'package:flutter/foundation.dart';

import '../../../../shared/models/user_settings.dart';
import '../../../../shared/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository) {
    loadSettings();
  }

  final SettingsRepository _repository;
  UserSettings _settings = const UserSettings();
  bool _isLoading = true;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _repository.getUserSettings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTemperatureUnit(TemperatureUnit unit) async {
    _settings = _settings.copyWith(temperatureUnit: unit);
    notifyListeners();
    await _repository.saveUserSettings(_settings);
  }

  Future<void> updateAppTheme(AppTheme theme) async {
    _settings = _settings.copyWith(appTheme: theme);
    notifyListeners();
    await _repository.saveUserSettings(_settings);
  }

  Future<void> updateLanguage(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    notifyListeners();
    await _repository.saveUserSettings(_settings);
  }

  Future<void> updateFrequency(int minutes) async {
    _settings = _settings.copyWith(updateFrequencyMinutes: minutes);
    notifyListeners();
    await _repository.saveUserSettings(_settings);
  }

  Future<void> resetToDefault() async {
    await _repository.clearSettings();
    _settings = const UserSettings();
    notifyListeners();
  }
}
