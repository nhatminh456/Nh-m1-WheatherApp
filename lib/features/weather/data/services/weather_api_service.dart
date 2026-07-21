import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherApiService {
  WeatherApiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;
  final http.Client _client;

  Future<Map<String, dynamic>> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'appid': apiKey,
      'units': 'metric',
    });

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
