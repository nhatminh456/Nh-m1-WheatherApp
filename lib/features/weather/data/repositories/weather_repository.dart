import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);

  static const _cacheTtl = Duration(minutes: 15);
  static const _cachedJsonKey = 'weather_cache_json';
  static const _cachedAtKey = 'weather_cache_timestamp';

  final WeatherApiService _apiService;

  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = _readCache(prefs);
      if (cached != null) return cached;
    }

    final json = await _apiService.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    await prefs.setString(_cachedJsonKey, jsonEncode(json));
    await prefs.setInt(_cachedAtKey, DateTime.now().millisecondsSinceEpoch);
    return Weather.fromOpenWeatherJson(json);
  }

  Weather? _readCache(SharedPreferences prefs) {
    final cachedJson = prefs.getString(_cachedJsonKey);
    final cachedAtMillis = prefs.getInt(_cachedAtKey);
    if (cachedJson == null || cachedAtMillis == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    if (DateTime.now().difference(cachedAt) > _cacheTtl) return null;

    return Weather.fromOpenWeatherJson(
      jsonDecode(cachedJson) as Map<String, dynamic>,
    );
  }
}
