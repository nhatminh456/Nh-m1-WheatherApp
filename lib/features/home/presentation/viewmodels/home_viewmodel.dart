import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../shared/repositories/auth_repository.dart';
import '../../../weather/data/models/forecast.dart';
import '../../../weather/data/models/weather.dart';
import '../../../weather/domain/usecases/get_home_weather_usecase.dart';

enum HomeLoadStatus { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._authRepository, this._getHomeWeather) {
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
  StreamSubscription<void>? _authSubscription;

  HomeLoadStatus _status = HomeLoadStatus.initial;
  Weather? _weather;
  Forecast? _forecast;
  String? _errorMessage;
  String? _loggedInEmail;

  HomeLoadStatus get status => _status;
  Weather? get weather => _weather;
  List<HourlyForecast> get hourly => _forecast?.hourly ?? const [];
  List<DailyForecast> get daily => _forecast?.daily ?? const [];
  String? get errorMessage => _errorMessage;
  String? get loggedInEmail => _loggedInEmail;
  bool get isLoggedIn => _loggedInEmail != null;

  Future<void> load({bool forceRefresh = false}) async {
    _status = HomeLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _getHomeWeather(forceRefresh: forceRefresh);
      _weather = data.weather;
      _forecast = data.forecast;
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
