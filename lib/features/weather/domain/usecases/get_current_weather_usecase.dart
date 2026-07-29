import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/location_service.dart';

class GetCurrentWeatherUseCase {
  GetCurrentWeatherUseCase(this._locationService, this._weatherRepository);

  final LocationService _locationService;
  final WeatherRepository _weatherRepository;

  Future<Weather> call({
    bool forceRefresh = false,
    double? latitude,
    double? longitude,
  }) async {
    if (latitude != null && longitude != null) {
      return _weatherRepository.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        forceRefresh: forceRefresh,
      );
    }

    final position = await _locationService.getCurrentPosition();
    return _weatherRepository.getCurrentWeather(
      latitude: position.latitude,
      longitude: position.longitude,
      forceRefresh: forceRefresh,
    );
  }
}
