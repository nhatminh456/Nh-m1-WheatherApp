import 'package:flutter/foundation.dart';

import '../../data/models/weather.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';

enum WeatherLoadStatus { initial, loading, success, error }

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._getCurrentWeatherUseCase);

  final GetCurrentWeatherUseCase _getCurrentWeatherUseCase;

  WeatherLoadStatus _status = WeatherLoadStatus.initial;
  Weather? _weather;
  String? _errorMessage;

  WeatherLoadStatus get status => _status;
  Weather? get weather => _weather;
  String? get errorMessage => _errorMessage;

  Future<void> loadCurrentWeather({
    bool forceRefresh = false,
    double? latitude,
    double? longitude,
  }) async {
    _status = WeatherLoadStatus.loading;
    notifyListeners();

    try {
      _weather = await _getCurrentWeatherUseCase(
        forceRefresh: forceRefresh,
        latitude: latitude,
        longitude: longitude,
      );
      _status = WeatherLoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherLoadStatus.error;
    }
    notifyListeners();
  }
}
