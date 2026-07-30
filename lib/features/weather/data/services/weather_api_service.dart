import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherApiService {
  WeatherApiService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  static const _currentWeatherUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const _forecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  final String apiKey;
  final http.Client _client;

  Future<Map<String, dynamic>> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) => _get(_currentWeatherUrl, latitude, longitude);

  Future<Map<String, dynamic>> fetchForecast({
    required double latitude,
    required double longitude,
  }) => _get(_forecastUrl, latitude, longitude);

  Future<List<Map<String, dynamic>>> fetchLocationFromAddress(String query) async {
    final uri = Uri.parse('https://api.openweathermap.org/geo/1.0/direct').replace(
      queryParameters: {
        'q': query,
        'limit': '5',
        'appid': apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Geocoding request failed with status ${response.statusCode}',
      );
    }
    final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> _get(
    String url,
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(url).replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'OpenWeatherMap request failed with status ${response.statusCode}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class WeatherApiException implements Exception {
  WeatherApiException(this.message);

  final String message;

  @override
  String toString() => 'WeatherApiException: $message';
}
