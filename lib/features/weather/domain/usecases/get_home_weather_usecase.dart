import '../../data/models/forecast.dart';
import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../../../location/data/models/location_model.dart';
import '../../../location/data/repositories/location_repository.dart';
import '../../data/services/location_service.dart';

class HomeWeatherData {
  const HomeWeatherData({required this.weather, required this.forecast});

  final Weather weather;
  final Forecast forecast;
}

class GetHomeWeatherUseCase {
  GetHomeWeatherUseCase(
    this._locationService,
    this._weatherRepository,
    this._locationRepository,
  );

  final LocationService _locationService;
  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  Future<HomeWeatherData> call({
    bool forceRefresh = false,
    LocationModel? locationOverride,
  }) async {
    final selectedLocation =
        locationOverride ?? await _locationRepository.getDefault();
    final latitude = selectedLocation?.latitude;
    final longitude = selectedLocation?.longitude;

    if (latitude != null && longitude != null) {
      final results = await Future.wait([
        _weatherRepository.getCurrentWeather(
          latitude: latitude,
          longitude: longitude,
          forceRefresh: forceRefresh,
        ),
        _weatherRepository.getForecast(
          latitude: latitude,
          longitude: longitude,
          forceRefresh: forceRefresh,
        ),
      ]);
      return HomeWeatherData(
        weather: results[0] as Weather,
        forecast: results[1] as Forecast,
      );
    }

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
