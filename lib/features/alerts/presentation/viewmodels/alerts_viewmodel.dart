import 'package:flutter/foundation.dart';

import '../../data/models/weather_alert.dart';
import '../../data/repositories/weather_alerts_repository.dart';

enum AlertsLoadStatus { initial, loading, success, error }

class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel(this._repository);

  final WeatherAlertsRepository _repository;

  AlertsLoadStatus _status = AlertsLoadStatus.initial;
  List<WeatherAlert> _alerts = const [];
  String? _errorMessage;

  AlertsLoadStatus get status => _status;
  List<WeatherAlert> get alerts => _alerts;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool forceRefresh = false}) async {
    if (_status == AlertsLoadStatus.loading && !forceRefresh) {
      return;
    }

    _status = AlertsLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _repository.getAll(seedIfEmpty: !forceRefresh);
      _status = AlertsLoadStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = AlertsLoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> createAlert(WeatherAlert alert) async {
    await _repository.create(alert);
    await load(forceRefresh: true);
  }

  Future<void> saveAlert(WeatherAlert alert) async {
    await _repository.update(alert);
    await load(forceRefresh: true);
  }

  Future<void> deleteAlert(WeatherAlert alert) async {
    final id = alert.id;
    if (id == null) return;

    await _repository.delete(id);
    _alerts = List.of(_alerts)..removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> setEnabled(WeatherAlert alert, bool enabled) async {
    await _repository.setEnabled(alert, enabled);
    _alerts = [
      for (final item in _alerts)
        if (item.id == alert.id) item.copyWith(enabled: enabled) else item,
    ];
    notifyListeners();
  }
}
