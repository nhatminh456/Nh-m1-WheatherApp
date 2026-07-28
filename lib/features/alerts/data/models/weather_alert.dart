enum WeatherAlertMetric { rain, lowTemperature, highUv }

extension WeatherAlertMetricX on WeatherAlertMetric {
  String get value => switch (this) {
    WeatherAlertMetric.rain => 'rain',
    WeatherAlertMetric.lowTemperature => 'low_temperature',
    WeatherAlertMetric.highUv => 'high_uv',
  };

  String get label => switch (this) {
    WeatherAlertMetric.rain => 'Mưa lớn',
    WeatherAlertMetric.lowTemperature => 'Rét đậm',
    WeatherAlertMetric.highUv => 'Chỉ số UV cao',
  };

  String get cityHint => switch (this) {
    WeatherAlertMetric.rain => 'Ví dụ: Hà Nội',
    WeatherAlertMetric.lowTemperature => 'Ví dụ: Sa Pa',
    WeatherAlertMetric.highUv => 'Ví dụ: Đà Nẵng',
  };

  String get unit => switch (this) {
    WeatherAlertMetric.rain => 'mm',
    WeatherAlertMetric.lowTemperature => '°C',
    WeatherAlertMetric.highUv => 'UV',
  };

  String get thresholdLabel => switch (this) {
    WeatherAlertMetric.rain => 'Lượng mưa',
    WeatherAlertMetric.lowTemperature => 'Nhiệt độ',
    WeatherAlertMetric.highUv => 'Ngưỡng UV',
  };

  String get description => switch (this) {
    WeatherAlertMetric.rain => 'Thông báo khi lượng mưa dự báo vượt ngưỡng',
    WeatherAlertMetric.lowTemperature =>
      'Thông báo khi nhiệt độ giảm xuống dưới ngưỡng',
    WeatherAlertMetric.highUv => 'Thông báo khi chỉ số UV vượt ngưỡng',
  };

  double get minThreshold => switch (this) {
    WeatherAlertMetric.rain => 0,
    WeatherAlertMetric.lowTemperature => -10,
    WeatherAlertMetric.highUv => 0,
  };

  double get maxThreshold => switch (this) {
    WeatherAlertMetric.rain => 200,
    WeatherAlertMetric.lowTemperature => 40,
    WeatherAlertMetric.highUv => 12,
  };

  double get step => switch (this) {
    WeatherAlertMetric.rain => 1,
    WeatherAlertMetric.lowTemperature => 0.5,
    WeatherAlertMetric.highUv => 0.1,
  };

  static WeatherAlertMetric fromValue(String value) {
    return WeatherAlertMetric.values.firstWhere(
      (metric) => metric.value == value,
      orElse: () => WeatherAlertMetric.rain,
    );
  }
}

class WeatherAlert {
  const WeatherAlert({
    required this.title,
    required this.city,
    required this.metric,
    required this.threshold,
    required this.enabled,
    this.id,
  });

  factory WeatherAlert.fromMap(Map<String, Object?> map) {
    final rawCity = (map['city_name'] as String? ?? '').trim();
    return WeatherAlert(
      id: (map['id'] as num?)?.toInt(),
      title: map['label'] as String,
      city: rawCity.isEmpty ? 'Chưa đặt' : rawCity,
      metric: WeatherAlertMetricX.fromValue(map['metric'] as String),
      threshold: (map['threshold'] as num).toDouble(),
      enabled: (map['enabled'] as int) == 1,
    );
  }

  final int? id;
  final String title;
  final String city;
  final WeatherAlertMetric metric;
  final double threshold;
  final bool enabled;

  Map<String, Object?> toMap({bool includeId = false}) {
    final data = <String, Object?>{
      'label': title,
      'city_name': city,
      'metric': metric.value,
      'threshold': threshold,
      'enabled': enabled ? 1 : 0,
    };

    if (includeId && id != null) {
      data['id'] = id;
    }

    return data;
  }

  WeatherAlert copyWith({
    int? id,
    String? title,
    String? city,
    WeatherAlertMetric? metric,
    double? threshold,
    bool? enabled,
  }) {
    return WeatherAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      city: city ?? this.city,
      metric: metric ?? this.metric,
      threshold: threshold ?? this.threshold,
      enabled: enabled ?? this.enabled,
    );
  }

  String get thresholdText =>
      (() {
        final value = threshold.toStringAsFixed(_fractionDigits);
        final unit = metric.unit;
        return '$value $unit';
      })();

  String get summary {
    final label = metric.label;
    return '$label · $city';
  }

  String get description {
    final label = metric.description;
    final comparison = _comparison;
    final text = thresholdText;
    return '$label ($comparison $text)';
  }

  String get _comparison => switch (metric) {
    WeatherAlertMetric.lowTemperature => 'dưới',
    WeatherAlertMetric.rain => 'vượt quá',
    WeatherAlertMetric.highUv => 'vượt quá',
  };

  int get _fractionDigits => metric.step < 1 ? 1 : 0;
}
