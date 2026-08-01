import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../features/alerts/data/repositories/weather_alerts_repository.dart';
import '../features/alerts/presentation/viewmodels/alerts_viewmodel.dart';
import '../features/alerts/presentation/views/alerts_view.dart';
import '../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/login/presentation/viewmodels/login_viewmodel.dart';
import '../features/login/presentation/views/login_view.dart';
import '../features/search/data/repositories/search_repository.dart';
import '../features/search/data/services/search_local_service.dart';
import '../features/search/presentation/viewmodels/search_viewmodel.dart';
import '../features/search/presentation/views/search_view.dart';
import '../features/weather/data/repositories/weather_repository.dart';
import '../features/weather/data/services/location_service.dart';
import '../features/weather/data/services/weather_api_service.dart';
import '../features/weather/domain/usecases/get_current_weather_usecase.dart';
import '../features/weather/domain/usecases/get_home_weather_usecase.dart';
import '../features/weather/presentation/viewmodels/weather_viewmodel.dart';
import '../features/weather/presentation/views/weather_view.dart';
import '../shared/repositories/auth_repository.dart';

WeatherRepository _buildWeatherRepository() {
  final apiService = WeatherApiService(
    apiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
  );
  return WeatherRepository(apiService);
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final useCase = GetHomeWeatherUseCase(
          LocationService(),
          _buildWeatherRepository(),
        );
        return HomeView(viewModel: HomeViewModel(AuthRepository(), useCase));
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginView(viewModel: LoginViewModel(AuthRepository())),
    ),
    GoRoute(
      path: '/weather',
      builder: (context, state) {
        final latStr = state.uri.queryParameters['lat'];
        final lonStr = state.uri.queryParameters['lon'];
        final name = state.uri.queryParameters['name'];

        final double? lat = latStr != null ? double.tryParse(latStr) : null;
        final double? lon = lonStr != null ? double.tryParse(lonStr) : null;

        final useCase = GetCurrentWeatherUseCase(
          LocationService(),
          _buildWeatherRepository(),
        );
        return WeatherView(
          viewModel: WeatherViewModel(useCase),
          latitude: lat,
          longitude: lon,
          cityName: name,
        );
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final searchRepo = SearchRepository(SearchLocalService());
        final weatherRepo = _buildWeatherRepository();
        return SearchView(
          viewModel: SearchViewModel(searchRepo, weatherRepo, AuthRepository()),
        );
      },
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) {
        return AlertsView(
          viewModel: AlertsViewModel(WeatherAlertsRepository()),
        );
      },
    ),
  ],
);
