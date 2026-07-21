import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/location_service.dart';

class GetCurrentWeatherUseCase {
  GetCurrentWeatherUseCase(this._locationService, this._weatherRepository);

  final LocationService _locationService;
  final WeatherRepository _weatherRepository;

  Future<Weather> call() async {
    final position = await _locationService.getCurrentPosition();
    return _weatherRepository.getCurrentWeather(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
