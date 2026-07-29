import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class CitySearchResult {
  const CitySearchResult({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.country,
    this.state,
  });

  final String cityName;
  final double latitude;
  final double longitude;
  final String? country;
  final String? state;
}

class LocationService {
  LocationService({http.Client? client}) : _client = client ?? http.Client();

  static const _geocodingUrl = 'https://api.openweathermap.org/geo/1.0/direct';

  final http.Client _client;

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission permanently denied.',
      );
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
    } on UnsupportedError {
      // Web has no cached positions; fall through to a live fix.
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<CitySearchResult> searchCity(String query) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw const LocationServiceException('Missing OPENWEATHER_API_KEY.');
    }

    final uri = Uri.parse(
      _geocodingUrl,
    ).replace(queryParameters: {'q': query, 'limit': '1', 'appid': apiKey});

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw LocationServiceException(
        'City lookup failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    if (decoded.isEmpty) {
      throw LocationServiceException('City "$query" not found.');
    }

    final first = decoded.first as Map<String, dynamic>;
    return CitySearchResult(
      cityName: first['name'] as String,
      latitude: (first['lat'] as num).toDouble(),
      longitude: (first['lon'] as num).toDouble(),
      country: first['country'] as String?,
      state: first['state'] as String?,
    );
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}
