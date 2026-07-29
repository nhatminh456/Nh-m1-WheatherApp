import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../shared/repositories/auth_repository.dart';
import '../../../location/data/models/location_model.dart';
import '../../../location/data/repositories/location_repository.dart';
import '../../../weather/data/models/forecast.dart';
import '../../../weather/data/models/weather.dart';
import '../../../weather/domain/usecases/get_home_weather_usecase.dart';

enum HomeLoadStatus { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
    AuthRepository authRepository,
    GetHomeWeatherUseCase getHomeWeather,
    LocationRepository locationRepository,
  ) : _authRepository = authRepository,
      _getHomeWeather = getHomeWeather,
      _locationRepository = locationRepository {
    try {
      _authSubscription = _authRepository.authStateChanges.listen((user) {
        _loggedInEmail = user?.email;
        notifyListeners();
      });
    } catch (_) {
      // Firebase isn't initialized (e.g. running in a widget test) — treat
      // as logged out instead of crashing the home screen.
      _authSubscription = null;
    }
  }

  final AuthRepository _authRepository;
  final GetHomeWeatherUseCase _getHomeWeather;
  final LocationRepository _locationRepository;
  StreamSubscription<void>? _authSubscription;

  HomeLoadStatus _status = HomeLoadStatus.initial;
  Weather? _weather;
  Forecast? _forecast;
  LocationModel? _defaultLocation;
  String? _errorMessage;
  String? _loggedInEmail;

  HomeLoadStatus get status => _status;
  Weather? get weather => _weather;
  List<HourlyForecast> get hourly => _forecast?.hourly ?? const [];
  List<DailyForecast> get daily => _forecast?.daily ?? const [];
  String? get errorMessage => _errorMessage;
  String? get loggedInEmail => _loggedInEmail;
  bool get isLoggedIn => _loggedInEmail != null;
  LocationModel? get defaultLocation => _defaultLocation;

  Future<void> load({
    LocationModel? location,
    bool forceRefresh = false,
  }) async {
    _status = HomeLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _getHomeWeather(
        forceRefresh: forceRefresh,
        locationOverride: location,
      );
      _weather = data.weather;
      _forecast = data.forecast;
      _defaultLocation = location ?? await _locationRepository.getDefault();
      _status = HomeLoadStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = HomeLoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
