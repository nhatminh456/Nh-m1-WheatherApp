import '../models/weather.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);

  final WeatherApiService _apiService;

  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final json = await _apiService.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    return Weather.fromOpenWeatherJson(json);
  }
}
