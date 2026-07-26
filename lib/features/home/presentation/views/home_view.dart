import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../shared/utilities/forecast_util.dart';
import '../../../weather/data/models/forecast.dart';
import '../../../weather/data/models/weather.dart';
import '../viewmodels/home_viewmodel.dart';

// Palette from the "Atmosphere" design (test.html).
const _primary = Color(0xFF00658D);
const _primaryFixed = Color(0xFFC6E7FF);
const _surface = Color(0xFFF5FAFF);
const _onSurface = Color(0xFF171C20);
const _onSurfaceVariant = Color(0xFF3E4850);
const _surfaceVariant = Color(0xFFDEE3E8);

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryFixed, _surface],
          stops: [0, 0.6],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: _ReiconIcon(
              icon: Reicon.outline.menu,
              color: _onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          title: const Text(
            'Atmosphere',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) => IconButton(
                icon: _ReiconIcon(
                  icon: widget.viewModel.isLoggedIn
                      ? Reicon.filled.userTick
                      : Reicon.outline.user,
                  color: widget.viewModel.isLoggedIn
                      ? Colors.green
                      : _onSurfaceVariant,
                ),
                tooltip: widget.viewModel.isLoggedIn
                    ? 'Đã đăng nhập: ${widget.viewModel.loggedInEmail}'
                    : 'Chưa đăng nhập',
                onPressed: () => context.go('/login'),
              ),
            ),
            IconButton(
              icon: _ReiconIcon(
                icon: Reicon.outline.search,
                color: _onSurfaceVariant,
              ),
              tooltip: 'Chi tiết thời tiết',
              onPressed: () => context.go('/weather'),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: RefreshIndicator(
              onRefresh: () => widget.viewModel.load(forceRefresh: true),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => _buildBody(),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const _HomeBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.viewModel.status) {
      case HomeLoadStatus.initial:
      case HomeLoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: _primary));
      case HomeLoadStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(
              child: _ReiconIcon(
                icon: Reicon.outline.cloudCross,
                size: 48,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _primary),
                onPressed: () => widget.viewModel.load(forceRefresh: true),
                child: const Text('Thử lại'),
              ),
            ),
          ],
        );
      case HomeLoadStatus.success:
        final weather = widget.viewModel.weather!;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _HeroSection(weather: weather),
            const SizedBox(height: 32),
            _BentoGrid(weather: weather),
            const SizedBox(height: 32),
            _HourlyForecastCard(hourly: widget.viewModel.hourly),
            const SizedBox(height: 32),
            _DailyForecastCard(daily: widget.viewModel.daily),
          ],
        );
    }
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.weather});

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
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 18, color: _onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primaryFixed.withValues(alpha: 0.8),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
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
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'C ${weather.temperatureMaxCelsius.round()}°   '
          'T ${weather.temperatureMinCelsius.round()}°',
          style: const TextStyle(fontSize: 16, color: _onSurfaceVariant),
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.weather});

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
              child: _BentoCard(
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
              child: _BentoCard(
                icon: Reicon.outline.wind,
                label: 'GIÓ',
                value: '$windKmh km/h',
                sublabel: _windDirection ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _BentoCard(
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

class _BentoCard extends StatelessWidget {
  const _BentoCard({
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
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ReiconIcon(icon: icon, size: 16, color: _onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: _onSurfaceVariant,
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
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
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
                color: _onSurface,
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
                    child: _HourlyItem(
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

class _HourlyItem extends StatelessWidget {
  const _HourlyItem({required this.label, required this.forecast});

  final String label;
  final HourlyForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
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
            color: _onSurface,
          ),
        ),
      ],
    );
  }
}

class _DailyForecastCard extends StatelessWidget {
  const _DailyForecastCard({required this.daily});

  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    var globalMin = double.infinity;
    var globalMax = double.negativeInfinity;
    for (final day in daily) {
      if (day.minCelsius < globalMin) globalMin = day.minCelsius;
      if (day.maxCelsius > globalMax) globalMax = day.maxCelsius;
    }

    return _GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Những ngày tới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < daily.length; i++)
            _DailyRow(
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

class _DailyRow extends StatelessWidget {
  const _DailyRow({
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
                  color: _surfaceVariant.withValues(alpha: 0.5),
                ),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              isToday ? 'H.Nay' : DateFormat.E('vi').format(forecast.date),
              style: const TextStyle(fontSize: 15, color: _onSurfaceVariant),
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
            style: const TextStyle(fontSize: 15, color: _onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: barWidth,
            height: 6,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _surfaceVariant,
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
                      gradient: LinearGradient(
                        colors: [startColor, endColor],
                      ),
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
              color: _onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReiconIcon extends StatelessWidget {
  const _ReiconIcon({required this.icon, this.size = 24, required this.color});

  final String icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      reiconSvg(icon),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _HomeBottomNavigationBar extends StatelessWidget {
  const _HomeBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      // Chỉ "Dự báo" (màn hình hiện tại) có sẵn; các tab còn lại chưa có
      // màn hình tương ứng nên tạm khoá (onTap không đổi currentIndex).
      onTap: (_) {},
      backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: disabledColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.chartBar, disabledColor),
          activeIcon: _navIcon(Reicon.filled.chartBar, colorScheme.primary),
          label: 'Dự báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.location, disabledColor),
          label: 'Vị trí',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.bellAlert, disabledColor),
          label: 'Cảnh báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.history, disabledColor),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.settings, disabledColor),
          label: 'Cài đặt',
        ),
      ],
    );
  }

  Widget _navIcon(String path, Color color) {
    return _ReiconIcon(icon: path, color: color);
  }
}
