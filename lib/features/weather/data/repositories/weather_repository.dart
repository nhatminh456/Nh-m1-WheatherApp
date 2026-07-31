import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forecast.dart';
import '../models/weather.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);

  static const _cacheTtl = Duration(minutes: 15);
  static const _cachedJsonKey = 'weather_cache_json';
  static const _cachedAtKey = 'weather_cache_timestamp';
  static const _cachedForecastJsonKey = 'forecast_cache_json';
  static const _cachedForecastAtKey = 'forecast_cache_timestamp';

  final WeatherApiService _apiService;

  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonKey = '${_cachedJsonKey}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final atKey = '${_cachedAtKey}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    if (!forceRefresh) {
      final cached = _readCache(prefs, jsonKey, atKey);
      if (cached != null) return cached;
    }

    final json = await _apiService.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    await prefs.setString(jsonKey, jsonEncode(json));
    await prefs.setInt(atKey, DateTime.now().millisecondsSinceEpoch);
    return Weather.fromOpenWeatherJson(json);
  }

  Future<List<Map<String, dynamic>>> searchLocation(String query) {
    return _apiService.fetchLocationFromAddress(query);
  }

  Weather? _readCache(SharedPreferences prefs, String jsonKey, String atKey) {
    final json = _readFreshJson(prefs, jsonKey, atKey);
    return json == null ? null : Weather.fromOpenWeatherJson(json);
  }

  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonKey = '${_cachedForecastJsonKey}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    final atKey = '${_cachedForecastAtKey}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    if (!forceRefresh) {
      final cached = _readFreshJson(
        prefs,
        jsonKey,
        atKey,
      );
      if (cached != null) return Forecast.fromOpenWeatherJson(cached);
    }

    final json = await _apiService.fetchForecast(
      latitude: latitude,
      longitude: longitude,
    );
    await prefs.setString(jsonKey, jsonEncode(json));
    await prefs.setInt(
      atKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    return Forecast.fromOpenWeatherJson(json);
  }

  Map<String, dynamic>? _readFreshJson(
    SharedPreferences prefs,
    String jsonKey,
    String atKey,
  ) {
    final cachedJson = prefs.getString(jsonKey);
    final cachedAtMillis = prefs.getInt(atKey);
    if (cachedJson == null || cachedAtMillis == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    if (DateTime.now().difference(cachedAt) > _cacheTtl) return null;

    return jsonDecode(cachedJson) as Map<String, dynamic>;
  }
}
