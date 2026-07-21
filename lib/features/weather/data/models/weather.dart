class Weather {
  const Weather({
    required this.cityName,
    required this.temperatureCelsius,
    required this.description,
    required this.iconCode,
    required this.humidityPercent,
    required this.windSpeedMeterPerSecond,
  });

  factory Weather.fromOpenWeatherJson(Map<String, dynamic> json) {
    final weatherEntry = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    return Weather(
      cityName: json['name'] as String,
      temperatureCelsius: (main['temp'] as num).toDouble(),
      description: weatherEntry['description'] as String,
      iconCode: weatherEntry['icon'] as String,
      humidityPercent: (main['humidity'] as num).toInt(),
      windSpeedMeterPerSecond: (wind['speed'] as num).toDouble(),
    );
  }

  final String cityName;
  final double temperatureCelsius;
  final String description;
  final String iconCode;
  final int humidityPercent;
  final double windSpeedMeterPerSecond;
}
