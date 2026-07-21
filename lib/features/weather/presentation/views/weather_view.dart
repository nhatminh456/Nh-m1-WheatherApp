import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Weather')),
      body: RefreshIndicator(
        onRefresh: widget.viewModel.loadCurrentWeather,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            switch (widget.viewModel.status) {
              case WeatherLoadStatus.initial:
              case WeatherLoadStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case WeatherLoadStatus.error:
                return Center(
                  child: Text(widget.viewModel.errorMessage ?? 'Unknown error'),
                );
              case WeatherLoadStatus.success:
                final weather = widget.viewModel.weather!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weather.cityName, style: Theme.of(context).textTheme.headlineSmall),
                      Text('${weather.temperatureCelsius.toStringAsFixed(1)}°C'),
                      Text(weather.description),
                      Text('Humidity: ${weather.humidityPercent}%'),
                      Text('Wind: ${weather.windSpeedMeterPerSecond} m/s'),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
