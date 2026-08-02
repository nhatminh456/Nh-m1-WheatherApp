enum TemperatureUnit { celsius, fahrenheit }

enum AppTheme { system, light, dark }

extension TemperatureUnitX on TemperatureUnit {
  String get symbol => switch (this) {
    TemperatureUnit.celsius => '°C',
    TemperatureUnit.fahrenheit => '°F',
  };

  double fromCelsius(double value) => switch (this) {
    TemperatureUnit.celsius => value,
    TemperatureUnit.fahrenheit => (value * 9 / 5) + 32,
  };

  double toCelsius(double value) => switch (this) {
    TemperatureUnit.celsius => value,
    TemperatureUnit.fahrenheit => (value - 32) * 5 / 9,
  };
}

class UserSettings {
  const UserSettings({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.appTheme = AppTheme.system,
    this.languageCode = 'vi',
    this.updateFrequencyMinutes = 30, // Default 30 minutes
  });

  final TemperatureUnit temperatureUnit;
  final AppTheme appTheme;
  final String languageCode;
  final int updateFrequencyMinutes;

  UserSettings copyWith({
    TemperatureUnit? temperatureUnit,
    AppTheme? appTheme,
    String? languageCode,
    int? updateFrequencyMinutes,
  }) {
    return UserSettings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      appTheme: appTheme ?? this.appTheme,
      languageCode: languageCode ?? this.languageCode,
      updateFrequencyMinutes:
          updateFrequencyMinutes ?? this.updateFrequencyMinutes,
    );
  }
}
