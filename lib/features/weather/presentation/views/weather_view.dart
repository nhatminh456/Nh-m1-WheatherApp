import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../viewmodels/weather_viewmodel.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key, required this.viewModel});

  final WeatherViewModel viewModel;

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.go('/'),
        ),
        title: const Text('Weather'),
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.viewModel.loadCurrentWeather(forceRefresh: true),
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            switch (widget.viewModel.status) {
              case WeatherLoadStatus.initial:
              case WeatherLoadStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case WeatherLoadStatus.error:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.viewModel.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              case WeatherLoadStatus.success:
                final weather = widget.viewModel.weather!;
                final timeFormat = DateFormat.Hm();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            weather.cityName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Image.network(weather.iconUrl, width: 100, height: 100),
                          Text(
                            '${weather.temperatureCelsius.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Text(weather.description),
                          Text(
                            'Feels like ${weather.feelsLikeCelsius.toStringAsFixed(1)}°C',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: 'Min / Max',
                              value:
                                  '${weather.temperatureMinCelsius.toStringAsFixed(1)}°C / '
                                  '${weather.temperatureMaxCelsius.toStringAsFixed(1)}°C',
                            ),
                            _InfoRow(
                              label: 'Humidity',
                              value: '${weather.humidityPercent}%',
                            ),
                            _InfoRow(
                              label: 'Pressure',
                              value: '${weather.pressureHectoPascal} hPa',
                            ),
                            _InfoRow(
                              label: 'Wind',
                              value: '${weather.windSpeedMeterPerSecond} m/s',
                            ),
                            _InfoRow(
                              label: 'Sunrise',
                              value: timeFormat.format(weather.sunrise),
                            ),
                            _InfoRow(
                              label: 'Sunset',
                              value: timeFormat.format(weather.sunset),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
