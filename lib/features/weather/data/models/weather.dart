class Weather {
  const Weather({
    required this.cityName,
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.temperatureMinCelsius,
    required this.temperatureMaxCelsius,
    required this.description,
    required this.condition,
    required this.iconCode,
    required this.humidityPercent,
    required this.pressureHectoPascal,
    required this.windSpeedMeterPerSecond,
    this.windDirectionDegrees,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromOpenWeatherJson(Map<String, dynamic> json) {
    final weatherEntry =
        (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    return Weather(
      cityName: json['name'] as String,
      temperatureCelsius: (main['temp'] as num).toDouble(),
      feelsLikeCelsius: (main['feels_like'] as num).toDouble(),
      temperatureMinCelsius: (main['temp_min'] as num).toDouble(),
      temperatureMaxCelsius: (main['temp_max'] as num).toDouble(),
      description: weatherEntry['description'] as String,
      condition: weatherEntry['main'] as String,
      iconCode: weatherEntry['icon'] as String,
      humidityPercent: (main['humidity'] as num).toInt(),
      pressureHectoPascal: (main['pressure'] as num).toInt(),
      windSpeedMeterPerSecond: (wind['speed'] as num).toDouble(),
      windDirectionDegrees: (wind['deg'] as num?)?.toInt(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunrise'] as num).toInt() * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunset'] as num).toInt() * 1000,
      ),
    );
  }

  final String cityName;
  final double temperatureCelsius;
  final double feelsLikeCelsius;
  final double temperatureMinCelsius;
  final double temperatureMaxCelsius;
  final String description;
  final String condition;
  final String iconCode;
  final int humidityPercent;
  final int pressureHectoPascal;
  final double windSpeedMeterPerSecond;
  final int? windDirectionDegrees;
  final DateTime sunrise;
  final DateTime sunset;

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
