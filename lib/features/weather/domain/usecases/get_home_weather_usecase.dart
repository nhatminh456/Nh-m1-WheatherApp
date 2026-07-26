import '../../data/models/forecast.dart';
import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/location_service.dart';

class HomeWeatherData {
  const HomeWeatherData({required this.weather, required this.forecast});

  final Weather weather;
  final Forecast forecast;
}

class GetHomeWeatherUseCase {
  GetHomeWeatherUseCase(this._locationService, this._weatherRepository);

  final LocationService _locationService;
  final WeatherRepository _weatherRepository;

  Future<HomeWeatherData> call({bool forceRefresh = false}) async {
    final position = await _locationService.getCurrentPosition();
    final results = await Future.wait([
      _weatherRepository.getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
        forceRefresh: forceRefresh,
      ),
      _weatherRepository.getForecast(
        latitude: position.latitude,
        longitude: position.longitude,
        forceRefresh: forceRefresh,
      ),
    ]);
    return HomeWeatherData(
      weather: results[0] as Weather,
      forecast: results[1] as Forecast,
    );
  }
}
