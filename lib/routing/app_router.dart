import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../features/counter/presentation/views/counter_view.dart';
import '../features/weather/data/repositories/weather_repository.dart';
import '../features/weather/data/services/location_service.dart';
import '../features/weather/data/services/weather_api_service.dart';
import '../features/weather/domain/usecases/get_current_weather_usecase.dart';
import '../features/weather/presentation/viewmodels/weather_viewmodel.dart';
import '../features/weather/presentation/views/weather_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const CounterView(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(
      path: '/weather',
      builder: (context, state) {
        final apiService = WeatherApiService(
          apiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
        );
        final repository = WeatherRepository(apiService);
        final useCase = GetCurrentWeatherUseCase(
          LocationService(),
          repository,
        );
        return WeatherView(viewModel: WeatherViewModel(useCase));
      },
    ),
  ],
);
