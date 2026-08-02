import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitSettings extends ChangeNotifier {
  UnitSettings._internal();
  static final UnitSettings instance = UnitSettings._internal();

  static const _keyIsCelsius = 'is_celsius';
  bool _isCelsius = true;

  bool get isCelsius => _isCelsius;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isCelsius = prefs.getBool(_keyIsCelsius) ?? true;
    notifyListeners();
  }

  Future<void> setCelsius(bool value) async {
    if (_isCelsius == value) return;
    _isCelsius = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCelsius, value);
    notifyListeners();
  }

  Future<void> toggleUnit() async {
    await setCelsius(!_isCelsius);
  }

  double formatTemperature(double celsius) {
    if (_isCelsius) {
      return celsius;
    } else {
      return celsius * 1.8 + 32;
    }
  }

  String format(double celsius, {bool showUnit = false}) {
    final value = formatTemperature(celsius).round();
    final suffix = showUnit ? (_isCelsius ? '°C' : '°F') : '°';
    return '$value$suffix';
  }
}
