// Đây là nơi thao tác với SQLite.
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/location_model.dart';
import '../../data/services/location_service.dart';
import '../../domain/usecases/add_location_usescase.dart';
import '../../domain/usecases/delete_location_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/reorder_locations_usecase.dart';
import '../../domain/usecases/set_default_location_usecase.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../../weather/data/models/weather.dart';
import '../../../weather/data/repositories/weather_repository.dart';

enum LocationStatus { initial, loading, success, error }

class LocationListItem {
  const LocationListItem({required this.location, this.weather});

  final LocationModel location;
  final Weather? weather;

  String get label => location.title;
}

class LocationViewModel extends ChangeNotifier {
  LocationViewModel(
    this._getLocationsUseCase,
    this._addLocationUseCase,
    this._updateLocationUseCase,
    this._deleteLocationUseCase,
    this._reorderLocationsUseCase,
    this._setDefaultLocationUseCase, [
    this._weatherRepository,
  ]) : _locationService = LocationService();

  final GetLocationsUseCase _getLocationsUseCase;
  final AddLocationUseCase _addLocationUseCase;
  final UpdateLocationUseCase _updateLocationUseCase;
  final DeleteLocationUseCase _deleteLocationUseCase;
  final ReorderLocationsUseCase _reorderLocationsUseCase;
  final SetDefaultLocationUseCase _setDefaultLocationUseCase;
  final WeatherRepository? _weatherRepository;
  final LocationService _locationService;

  LocationStatus _status = LocationStatus.initial;
  List<LocationModel> _locations = [];
  List<LocationListItem> _items = [];
  String? _errorMessage;

  LocationStatus get status => _status;
  List<LocationModel> get locations => _locations;
  List<LocationListItem> get items => _items;
  String? get errorMessage => _errorMessage;

  Future<CitySearchResult> searchCity(String cityName) async {
    return _locationService.searchCity(cityName);
  }

  Future<Position> getCurrentPosition() async {
    return _locationService.getCurrentPosition();
  }

  Future<void> loadLocations() async {
    _errorMessage = null;
    final isFirstLoad = _locations.isEmpty;
    if (isFirstLoad) {
      _status = LocationStatus.loading;
    }
    notifyListeners();

    try {
      _locations = await _getLocationsUseCase();
      _items = _locations
          .map((location) => LocationListItem(location: location))
          .toList();
      _status = LocationStatus.success;
      notifyListeners();

      if (_weatherRepository != null) {
        _loadPreviewWeather();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = LocationStatus.error;
      notifyListeners();
    }
  }

  Future<void> _loadPreviewWeather() async {
    try {
      final previewItems = await Future.wait(
        _locations.map((location) async {
          try {
            final weather = await _weatherRepository!.peekCurrentWeather(
              latitude: location.latitude,
              longitude: location.longitude,
            );
            return LocationListItem(location: location, weather: weather);
          } catch (_) {
            return LocationListItem(location: location);
          }
        }),
      );
      _items = previewItems;
      notifyListeners();
    } catch (_) {
      // Ignore preview load failures; keep list visible without weather.
    }
  }

  Future<void> addLocation(LocationModel location) async {
    await _addLocationUseCase(location);
    await loadLocations();
  }

  Future<void> updateLocation(LocationModel location) async {
    await _updateLocationUseCase(location);
    await loadLocations();
  }

  Future<void> deleteLocation(int id) async {
    await _deleteLocationUseCase(id);
    await loadLocations();
  }

  Future<void> reorderLocations(List<LocationModel> locations) async {
    await _reorderLocationsUseCase(locations);
    await loadLocations();
  }

  Future<void> setDefault(int id) async {
    await _setDefaultLocationUseCase(id);
    await loadLocations();
  }
}
