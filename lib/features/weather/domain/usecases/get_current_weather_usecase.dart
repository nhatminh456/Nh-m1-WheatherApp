import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/location_service.dart';

class GetCurrentWeatherUseCase {
  GetCurrentWeatherUseCase(this._locationService, this._weatherRepository);

  final LocationService _locationService;
  final WeatherRepository _weatherRepository;

  Future<Weather> call({
    double? latitude,
    double? longitude,
    bool forceRefresh = false,
    String? languageCode,
  }) async {
    final double lat;
    final double lon;

    if (latitude != null && longitude != null) {
      lat = latitude;
      lon = longitude;
    } else {
      final position = await _locationService.getCurrentPosition();
      lat = position.latitude;
      lon = position.longitude;
    }

    return _weatherRepository.getCurrentWeather(
      latitude: lat,
      longitude: lon,
      forceRefresh: forceRefresh,
      languageCode: languageCode,
    );
  }
}
