import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../features/home/presentation/views/home_view.dart';

import '../features/location/data/models/location_model.dart';
import '../features/location/data/repositories/location_repository.dart';
import '../features/location/domain/usecases/add_location_usescase.dart';
import '../features/location/domain/usecases/delete_location_usecase.dart';
import '../features/location/domain/usecases/get_locations_usecase.dart';
import '../features/location/domain/usecases/reorder_locations_usecase.dart';
import '../features/location/domain/usecases/set_default_location_usecase.dart';
import '../features/location/domain/usecases/update_location_usecase.dart';
import '../features/location/presentation/viewmodels/location_viewmodel.dart';
import '../features/location/presentation/views/location_view.dart';

import '../features/login/presentation/viewmodels/login_viewmodel.dart';
import '../features/login/presentation/views/login_view.dart';

import '../features/weather/data/repositories/weather_repository.dart';
import '../features/weather/data/services/location_service.dart';
import '../features/weather/data/services/weather_api_service.dart';
import '../features/weather/domain/usecases/get_home_weather_usecase.dart';

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
          LocationRepository(),
        );

        return HomeView(
          viewModel: HomeViewModel(
            AuthRepository(),
            useCase,
            LocationRepository(),
          ),
        );
      },
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return LoginView(viewModel: LoginViewModel(AuthRepository()));
      },
    ),

    GoRoute(
      path: '/weather',
      builder: (context, state) {
        final selectedLocation = state.extra is LocationModel
            ? state.extra as LocationModel
            : null;
        final useCase = GetHomeWeatherUseCase(
          LocationService(),
          _buildWeatherRepository(),
          LocationRepository(),
        );

        return HomeView(
          viewModel: HomeViewModel(
            AuthRepository(),
            useCase,
            LocationRepository(),
          ),
          location: selectedLocation,
        );
      },
    ),

    GoRoute(
      path: '/location',
      builder: (context, state) {
        final locationRepository = LocationRepository();
        return LocationView(
          viewModel: LocationViewModel(
            GetLocationsUseCase(locationRepository),
            AddLocationUseCase(locationRepository),
            UpdateLocationUseCase(locationRepository),
            DeleteLocationUseCase(locationRepository),
            ReorderLocationsUseCase(locationRepository),
            SetDefaultLocationUseCase(locationRepository),
            _buildWeatherRepository(),
          ),
        );
      },
    ),
  ],
);
