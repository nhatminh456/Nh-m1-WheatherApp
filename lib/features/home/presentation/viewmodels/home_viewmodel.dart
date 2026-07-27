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
        if (_isDisposed) return;
        _loggedInEmail = user?.email;
        _notifyIfAlive();
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
  bool _isDisposed = false;

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
    if (_isDisposed) return;

    _status = HomeLoadStatus.loading;
    _errorMessage = null;
    _notifyIfAlive();

    try {
      final data = await _getHomeWeather(forceRefresh: forceRefresh);
      if (_isDisposed) return;
      _weather = data.weather;
      _forecast = data.forecast;
      _status = HomeLoadStatus.success;
    } catch (error) {
      if (_isDisposed) return;
      _errorMessage = error.toString();
      _status = HomeLoadStatus.error;
    }
    _notifyIfAlive();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  void _notifyIfAlive() {
    if (_isDisposed) return;
    notifyListeners();
  }
}
