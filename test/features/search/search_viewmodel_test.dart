import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weatherapp/features/search/data/models/favorite_city.dart';
import 'package:weatherapp/features/search/data/models/history_item.dart';
import 'package:weatherapp/features/search/data/repositories/search_repository.dart';
import 'package:weatherapp/features/search/presentation/viewmodels/search_viewmodel.dart';
import 'package:weatherapp/features/weather/data/models/weather.dart';
import 'package:weatherapp/features/weather/data/repositories/weather_repository.dart';

// Fakes for testing without database or API calls

class FakeSearchRepository extends Fake implements SearchRepository {
  List<HistoryItem> history = [];
  List<FavoriteCity> favorites = [];

  @override
  Future<void> saveSearchQuery(String query) async {
    // Chống trùng
    history.removeWhere((item) => item.query.toLowerCase() == query.toLowerCase());
    history.insert(0, HistoryItem(id: history.length + 1, query: query, searchedAt: DateTime.now()));
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }
  }

  @override
  Future<List<HistoryItem>> getSearchHistory() async => history;

  @override
  Future<void> deleteHistoryItem(int id) async {
    history.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearSearchHistory() async {
    history.clear();
  }

  @override
  Future<void> addFavoriteCity(String name, double lat, double lon) async {
    favorites.add(FavoriteCity(id: favorites.length + 1, name: name, latitude: lat, longitude: lon));
  }

  @override
  Future<void> removeFavoriteCity(double lat, double lon) async {
    favorites.removeWhere((city) => (city.latitude - lat).abs() < 0.01 && (city.longitude - lon).abs() < 0.01);
  }

  @override
  Future<void> removeFavoriteCityById(int id) async {
    favorites.removeWhere((city) => city.id == id);
  }

  @override
  Future<List<FavoriteCity>> getFavoriteCities() async => favorites;

  @override
  Future<bool> isCityFavorited(double lat, double lon) async {
    return favorites.any((city) => (city.latitude - lat).abs() < 0.01 && (city.longitude - lon).abs() < 0.01);
  }
}

class FakeWeatherRepository extends Fake implements WeatherRepository {
  bool shouldGeocodeFail = false;

  @override
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    if (shouldGeocodeFail) {
      throw Exception('Network error');
    }
    double lat = 21.0285;
    double lon = 105.8542;
    String name = query;
    if (query.toLowerCase() == 'city a') {
      lat = 1.0;
      lon = 1.0;
      name = 'City A';
    } else if (query.toLowerCase() == 'city b') {
      lat = 2.0;
      lon = 2.0;
      name = 'City B';
    } else if (query.toLowerCase() == 'ha noi') {
      name = 'Hà Nội';
    }
    return [
      {
        'name': name,
        'lat': lat,
        'lon': lon,
      }
    ];
  }

  @override
  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    return Weather(
      cityName: 'Test City',
      latitude: latitude,
      longitude: longitude,
      temperatureCelsius: 25.0,
      feelsLikeCelsius: 27.0,
      temperatureMinCelsius: 20.0,
      temperatureMaxCelsius: 30.0,
      description: 'Mây rải rác',
      condition: 'Clouds',
      iconCode: '03d',
      humidityPercent: 60,
      pressureHectoPascal: 1012,
      windSpeedMeterPerSecond: 3.5,
      sunrise: DateTime.now(),
      sunset: DateTime.now(),
    );
  }
}

void main() {
  late FakeSearchRepository fakeSearchRepository;
  late FakeWeatherRepository fakeWeatherRepository;
  late SearchViewModel viewModel;

  setUp(() {
    fakeSearchRepository = FakeSearchRepository();
    fakeWeatherRepository = FakeWeatherRepository();
    viewModel = SearchViewModel(
      fakeSearchRepository,
      fakeWeatherRepository,
    );
  });

  group('SearchViewModel Test Suite', () {
    test('Initial state values', () {
      expect(viewModel.status, SearchStatus.initial);
      expect(viewModel.history, isEmpty);
      expect(viewModel.favoriteCities, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('load() empty state', () async {
      expect(viewModel.status, SearchStatus.initial);
      await viewModel.load();
      expect(viewModel.status, SearchStatus.empty);
    });

    test('searchLocation() success & updates history', () async {
      final result = await viewModel.searchLocation('Ha Noi');
      expect(result, isNotNull);
      expect(result!['name'], equals('Hà Nội'));
      expect(result['latitude'], equals(21.0285));
      expect(result['longitude'], equals(105.8542));

      expect(viewModel.history.length, equals(1));
      expect(viewModel.history.first.query, equals('Hà Nội'));
    });

    test('searchLocation() error handling when city not found', () async {
      fakeWeatherRepository.shouldGeocodeFail = true;
      final result = await viewModel.searchLocation('UnknownCity');
      expect(result, isNull);
      expect(viewModel.status, SearchStatus.error);
      expect(viewModel.errorMessage, contains('Không thể tìm thấy địa điểm'));
    });

    test('toggleFavorite() updates favorite cities list & caches weather', () async {
      await viewModel.toggleFavorite('Hà Nội', 21.0285, 105.8542);
      expect(viewModel.favoriteCities.length, equals(1));
      expect(viewModel.favoriteCities.first.name, equals('Hà Nội'));

      final weather = viewModel.favoriteWeatherMap['21.0285_105.8542'];
      expect(weather, isNotNull);
      expect(weather!.temperatureCelsius, equals(25.0));

      // Toggle again to remove
      await viewModel.toggleFavorite('Hà Nội', 21.0285, 105.8542);
      expect(viewModel.favoriteCities, isEmpty);
      expect(viewModel.favoriteWeatherMap['21.0285_105.8542'], isNull);
    });

    test('clearAllHistory() removes all history', () async {
      await viewModel.searchLocation('City A');
      await viewModel.searchLocation('City B');
      expect(viewModel.history.length, equals(2));

      await viewModel.clearAllHistory();
      expect(viewModel.history, isEmpty);
    });
  });
}
