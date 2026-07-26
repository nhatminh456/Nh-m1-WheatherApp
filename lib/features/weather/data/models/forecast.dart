class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperatureCelsius,
    required this.condition,
  });

  final DateTime time;
  final double temperatureCelsius;
  final String condition;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minCelsius,
    required this.maxCelsius,
    required this.condition,
  });

  final DateTime date;
  final double minCelsius;
  final double maxCelsius;
  final String condition;
}

class Forecast {
  const Forecast({required this.hourly, required this.daily});

  // The free OpenWeatherMap tier only exposes the 3-hourly /forecast feed,
  // so daily entries are aggregated client-side from those 3-hour slots.
  factory Forecast.fromOpenWeatherJson(Map<String, dynamic> json) {
    final entries = (json['list'] as List)
        .cast<Map<String, dynamic>>()
        .map(_ForecastEntry.fromJson)
        .toList();

    final hourly = entries
        .take(8)
        .map(
          (e) => HourlyForecast(
            time: e.time,
            temperatureCelsius: e.temperature,
            condition: e.condition,
          ),
        )
        .toList();

    final byDay = <DateTime, List<_ForecastEntry>>{};
    for (final entry in entries) {
      final day = DateTime(entry.time.year, entry.time.month, entry.time.day);
      byDay.putIfAbsent(day, () => []).add(entry);
    }

    final daily = byDay.entries.map((dayEntry) {
      final slots = dayEntry.value;
      // The slot closest to noon best represents the day's condition.
      var representative = slots.first;
      var bestDistance = (representative.time.hour - 12).abs();
      var min = slots.first.minTemperature;
      var max = slots.first.maxTemperature;
      for (final slot in slots) {
        final distance = (slot.time.hour - 12).abs();
        if (distance < bestDistance) {
          bestDistance = distance;
          representative = slot;
        }
        if (slot.minTemperature < min) min = slot.minTemperature;
        if (slot.maxTemperature > max) max = slot.maxTemperature;
      }
      return DailyForecast(
        date: dayEntry.key,
        minCelsius: min,
        maxCelsius: max,
        condition: representative.condition,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    return Forecast(hourly: hourly, daily: daily);
  }

  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
}

class _ForecastEntry {
  const _ForecastEntry({
    required this.time,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.condition,
  });

  factory _ForecastEntry.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return _ForecastEntry(
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] as num).toInt() * 1000),
      temperature: (main['temp'] as num).toDouble(),
      minTemperature: (main['temp_min'] as num).toDouble(),
      maxTemperature: (main['temp_max'] as num).toDouble(),
      condition: weather['main'] as String,
    );
  }

  final DateTime time;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final String condition;
}
