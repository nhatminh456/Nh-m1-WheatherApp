import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../shared/services/database_service.dart';
import '../models/weather_alert.dart';

class WeatherAlertsRepository {
  WeatherAlertsRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  static const _tableName = 'weather_alerts';
  static const _seededPrefKey = 'weather_alerts_seeded_v1';
  static const _webStorageKey = 'weather_alerts_web_storage_v1';

  final DatabaseService _databaseService;

  Future<List<WeatherAlert>> getAll({bool seedIfEmpty = true}) async {
    if (kIsWeb) {
      return _getAllWeb(seedIfEmpty: seedIfEmpty);
    }

    final db = await _databaseService.database;
    final rows = await db.query(_tableName, orderBy: 'enabled DESC, id DESC');

    if (rows.isEmpty && seedIfEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final hasSeeded = prefs.getBool(_seededPrefKey) ?? false;
      if (!hasSeeded) {
        await _seedDefaults(db);
        await prefs.setBool(_seededPrefKey, true);
        return getAll(seedIfEmpty: false);
      }
    }

    return rows.map(WeatherAlert.fromMap).toList(growable: false);
  }

  Future<WeatherAlert> create(WeatherAlert alert) async {
    if (kIsWeb) {
      return _createWeb(alert);
    }

    final db = await _databaseService.database;
    final id = await db.insert(_tableName, alert.toMap());
    return alert.copyWith(id: id);
  }

  Future<WeatherAlert> update(WeatherAlert alert) async {
    if (kIsWeb) {
      return _updateWeb(alert);
    }

    final db = await _databaseService.database;
    final id = alert.id;
    if (id == null) {
      return create(alert);
    }

    await db.update(
      _tableName,
      alert.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return alert;
  }

  Future<void> delete(int id) async {
    if (kIsWeb) {
      await _deleteWeb(id);
      return;
    }

    final db = await _databaseService.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<WeatherAlert> setEnabled(WeatherAlert alert, bool enabled) {
    return update(alert.copyWith(enabled: enabled));
  }

  Future<List<WeatherAlert>> _getAllWeb({bool seedIfEmpty = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_webStorageKey);

    if (rawJson == null || rawJson.isEmpty) {
      if (seedIfEmpty && !(prefs.getBool(_seededPrefKey) ?? false)) {
        final seeded = _defaultAlerts();
        await _saveWebAlerts(prefs, seeded);
        await prefs.setBool(_seededPrefKey, true);
        return seeded;
      }
      return const [];
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final alerts = <WeatherAlert>[];
    var migrated = false;

    for (var index = 0; index < decoded.length; index++) {
      final item = decoded[index] as Map<String, dynamic>;
      final alert = WeatherAlert.fromMap(item);
      if (alert.id == null) {
        alerts.add(alert.copyWith(id: index + 1));
        migrated = true;
      } else {
        alerts.add(alert);
      }
    }

    if (migrated) {
      await _saveWebAlerts(prefs, alerts);
    }

    return alerts.toList(growable: false);
  }

  Future<WeatherAlert> _createWeb(WeatherAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await _getAllWeb(seedIfEmpty: false);
    final nextId = _nextWebId(alerts);
    final created = alert.copyWith(id: nextId);
    await _saveWebAlerts(prefs, [...alerts, created]);
    return created;
  }

  Future<WeatherAlert> _updateWeb(WeatherAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await _getAllWeb(seedIfEmpty: false);
    final updated = [
      for (final item in alerts)
        if (item.id == alert.id) alert.copyWith(id: item.id) else item,
    ];
    await _saveWebAlerts(prefs, updated);
    return alert;
  }

  Future<void> _deleteWeb(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await _getAllWeb(seedIfEmpty: false);
    final updated = alerts.where((item) => item.id != id).toList(growable: false);
    await _saveWebAlerts(prefs, updated);
  }

  Future<void> _saveWebAlerts(
    SharedPreferences prefs,
    List<WeatherAlert> alerts,
  ) async {
    final jsonList = alerts
        .map((alert) => alert.toMap(includeId: true))
        .toList(growable: false);
    await prefs.setString(_webStorageKey, jsonEncode(jsonList));
  }

  int _nextWebId(List<WeatherAlert> alerts) {
    if (alerts.isEmpty) return 1;
    final maxId = alerts.map((alert) => alert.id ?? 0).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  List<WeatherAlert> _defaultAlerts() {
    return const [
      WeatherAlert(
        id: 1,
        title: 'Mưa lớn',
        city: 'Hà Nội',
        metric: WeatherAlertMetric.rain,
        threshold: 20,
        enabled: true,
      ),
      WeatherAlert(
        id: 2,
        title: 'Rét đậm',
        city: 'Sa Pa',
        metric: WeatherAlertMetric.lowTemperature,
        threshold: 12,
        enabled: true,
      ),
      WeatherAlert(
        id: 3,
        title: 'Chỉ số UV cao',
        city: 'Đà Nẵng',
        metric: WeatherAlertMetric.highUv,
        threshold: 8,
        enabled: false,
      ),
    ];
  }

  Future<void> _seedDefaults(Database db) async {
    final batch = db.batch();
    for (final alert in _defaultAlerts()) {
      batch.insert(_tableName, alert.toMap());
    }
    await batch.commit(noResult: true);
  }
}
