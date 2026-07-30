class Weather {
  const Weather({
    required this.cityName,
    required this.latitude,
    required this.longitude,
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
    final weatherList = json['weather'] as List?;
    final weatherEntry = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final main = json['main'] as Map<String, dynamic>? ?? const {};
    final wind = json['wind'] as Map<String, dynamic>? ?? const {};
    final sys = json['sys'] as Map<String, dynamic>? ?? const {};
    final coord = json['coord'] as Map<String, dynamic>?;

    return Weather(
      cityName: json['name'] as String? ?? '',
      latitude: (coord != null && coord['lat'] != null)
          ? (coord['lat'] as num).toDouble()
          : 0.0,
      longitude: (coord != null && coord['lon'] != null)
          ? (coord['lon'] as num).toDouble()
          : 0.0,
      temperatureCelsius: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLikeCelsius: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      temperatureMinCelsius: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      temperatureMaxCelsius: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      description: weatherEntry['description'] as String? ?? '',
      condition: weatherEntry['main'] as String? ?? 'Clouds',
      iconCode: weatherEntry['icon'] as String? ?? '',
      humidityPercent: (main['humidity'] as num?)?.toInt() ?? 0,
      pressureHectoPascal: (main['pressure'] as num?)?.toInt() ?? 0,
      windSpeedMeterPerSecond: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDirectionDegrees: (wind['deg'] as num?)?.toInt(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunrise'] as num?)?.toInt() ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunset'] as num?)?.toInt() ?? 0) * 1000,
      ),
    );
  }

  final String cityName;
  final double latitude;
  final double longitude;
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
