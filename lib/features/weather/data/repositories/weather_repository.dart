import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forecast.dart';
import '../models/weather.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);

  static const _cacheTtl = Duration(minutes: 15);

  final WeatherApiService _apiService;

  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(latitude, longitude, 'weather');
    final timestampKey = _cacheKey(latitude, longitude, 'weather_timestamp');

    if (!forceRefresh) {
      final cached = _readFreshJson(prefs, cacheKey, timestampKey);
      if (cached != null) return Weather.fromOpenWeatherJson(cached);
    }

    final json = await _apiService.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    await prefs.setString(cacheKey, jsonEncode(json));
    await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    return Weather.fromOpenWeatherJson(json);
  }

  Future<Weather> peekCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final json = await _apiService.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    return Weather.fromOpenWeatherJson(json);
  }

  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(latitude, longitude, 'forecast');
    final timestampKey = _cacheKey(latitude, longitude, 'forecast_timestamp');

    if (!forceRefresh) {
      final cached = _readFreshJson(prefs, cacheKey, timestampKey);
      if (cached != null) return Forecast.fromOpenWeatherJson(cached);
    }

    final json = await _apiService.fetchForecast(
      latitude: latitude,
      longitude: longitude,
    );
    await prefs.setString(cacheKey, jsonEncode(json));
    await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    return Forecast.fromOpenWeatherJson(json);
  }

  static String _cacheKey(double latitude, double longitude, String suffix) {
    return '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}_$suffix';
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
