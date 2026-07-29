import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../shared/utilities/forecast_util.dart';
import '../../../weather/data/models/forecast.dart';
import '../../../weather/data/models/weather.dart';
import 'home_shared.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    const iconColor = kHomeOnSurfaceVariant;

    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white.withAlpha(235),
      elevation: 8,
      selectedItemColor: iconColor,
      unselectedItemColor: iconColor,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      iconSize: 24,
      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/location');
            break;
          default:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Dự báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          label: 'Vị trí',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Cảnh báo',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Cài đặt',
        ),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final description = weather.description.isEmpty
        ? weather.condition
        : '${weather.description[0].toUpperCase()}${weather.description.substring(1)}';
    return Column(
      children: [
        Text(
          weather.cityName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kHomeOnSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 18, color: kHomeOnSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Container(
          width: 160,
          height: 160,
          child: Image.asset(
            Util.findIcon(weather.condition, true),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${weather.temperatureCelsius.round()}°',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w300,
            height: 1.1,
            color: kHomeOnSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'C ${weather.temperatureMaxCelsius.round()}°   '
          'T ${weather.temperatureMinCelsius.round()}°',
          style: const TextStyle(fontSize: 16, color: kHomeOnSurfaceVariant),
        ),
      ],
    );
  }
}

class BentoGrid extends StatelessWidget {
  const BentoGrid({required this.weather});

  final Weather weather;

  static const _compassLabels = [
    'Bắc',
    'Đông Bắc',
    'Đông',
    'Đông Nam',
    'Nam',
    'Tây Nam',
    'Tây',
    'Tây Bắc',
  ];

  String? get _windDirection {
    final deg = weather.windDirectionDegrees;
    if (deg == null) return null;
    return _compassLabels[((deg + 22.5) % 360 ~/ 45)];
  }

  @override
  Widget build(BuildContext context) {
    final windKmh = (weather.windSpeedMeterPerSecond * 3.6).round();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: BentoCard(
                icon: Reicon.outline.drop,
                label: 'ĐỘ ẨM',
                value: '${weather.humidityPercent}%',
                sublabel: weather.humidityPercent >= 70
                    ? 'Hơi oi bức'
                    : 'Dễ chịu',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BentoCard(
                icon: Reicon.outline.wind,
                label: 'GIÓ',
                value: '$windKmh km/h',
                sublabel: _windDirection ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BentoCard(
          icon: Reicon.outline.thermometer,
          label: 'CẢM GIÁC NHƯ',
          value: '${weather.feelsLikeCelsius.round()}°',
          sublabel:
              weather.feelsLikeCelsius.round() >
                  weather.temperatureCelsius.round()
              ? 'Nóng hơn nhiệt độ thực tế'
              : 'Gần với nhiệt độ thực tế',
        ),
      ],
    );
  }
}

class BentoCard extends StatelessWidget {
  const BentoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final String icon;
  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReiconIcon(icon: icon, size: 16, color: kHomeOnSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: kHomeOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: kHomeOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: const TextStyle(fontSize: 12, color: kHomeOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Dự báo hôm nay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kHomeOnSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                for (var i = 0; i < hourly.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: HourlyItem(
                      label: i == 0
                          ? 'Bây giờ'
                          : DateFormat.Hm().format(hourly[i].time),
                      forecast: hourly[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HourlyItem extends StatelessWidget {
  const HourlyItem({required this.label, required this.forecast});

  final String label;
  final HourlyForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kHomeOnSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Image.asset(
          Util.findIcon(forecast.condition, false),
          width: 32,
          height: 32,
        ),
        const SizedBox(height: 8),
        Text(
          '${forecast.temperatureCelsius.round()}°',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: kHomeOnSurface,
          ),
        ),
      ],
    );
  }
}

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({required this.daily});

  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    var globalMin = double.infinity;
    var globalMax = double.negativeInfinity;
    for (final day in daily) {
      if (day.minCelsius < globalMin) globalMin = day.minCelsius;
      if (day.maxCelsius > globalMax) globalMax = day.maxCelsius;
    }

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Những ngày tới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kHomeOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < daily.length; i++)
            DailyRow(
              forecast: daily[i],
              isToday: i == 0,
              isLast: i == daily.length - 1,
              globalMin: globalMin,
              globalMax: globalMax,
            ),
        ],
      ),
    );
  }
}

class DailyRow extends StatelessWidget {
  const DailyRow({
    required this.forecast,
    required this.isToday,
    required this.isLast,
    required this.globalMin,
    required this.globalMax,
  });

  final DailyForecast forecast;
  final bool isToday;
  final bool isLast;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    const barWidth = 100.0;
    const coolColor = Color(0xFF82CFFF);
    const warmColor = Color(0xFFEA8C21);
    final range = globalMax - globalMin;
    final left = range <= 0
        ? 0.0
        : (forecast.minCelsius - globalMin) / range * barWidth;
    final width = range <= 0
        ? barWidth
        : ((forecast.maxCelsius - forecast.minCelsius) / range * barWidth)
              .clamp(8.0, barWidth);
    final startColor = range <= 0
        ? coolColor
        : Color.lerp(
            coolColor,
            warmColor,
            (forecast.minCelsius - globalMin) / range,
          )!;
    final endColor = range <= 0
        ? warmColor
        : Color.lerp(
            coolColor,
            warmColor,
            (forecast.maxCelsius - globalMin) / range,
          )!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: kHomeSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              isToday ? 'H.Nay' : DateFormat.E('vi').format(forecast.date),
              style: const TextStyle(
                fontSize: 15,
                color: kHomeOnSurfaceVariant,
              ),
            ),
          ),
          Image.asset(
            Util.findIcon(forecast.condition, false),
            width: 24,
            height: 24,
          ),
          const Spacer(),
          Text(
            '${forecast.minCelsius.round()}°',
            style: const TextStyle(fontSize: 15, color: kHomeOnSurfaceVariant),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: barWidth,
            height: 6,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kHomeSurfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Positioned(
                  left: left,
                  width: width,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [startColor, endColor]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${forecast.maxCelsius.round()}°',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kHomeOnSurface,
            ),
          ),
        ],
      ),
    );
  }
}
