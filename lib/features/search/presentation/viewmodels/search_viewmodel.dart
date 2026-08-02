import 'package:flutter/foundation.dart';
import '../../../../shared/repositories/auth_repository.dart';
import '../../../weather/data/models/weather.dart';
import '../../../weather/data/repositories/weather_repository.dart';
import '../../data/models/favorite_city.dart';
import '../../data/models/history_item.dart';
import '../../data/repositories/search_repository.dart';

enum SearchStatus { initial, loading, success, error, empty }

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(
    this._searchRepository,
    this._weatherRepository,
    this._authRepository,
  );

  final SearchRepository _searchRepository;
  final WeatherRepository _weatherRepository;
  final AuthRepository _authRepository;

  String get _currentUserId => _authRepository.currentUser?.uid ?? 'guest';

  SearchStatus _status = SearchStatus.initial;
  List<HistoryItem> _history = [];
  List<FavoriteCity> _favoriteCities = [];
  final Map<String, Weather> _favoriteWeatherMap = {};
  String? _errorMessage;

  SearchStatus get status => _status;
  List<HistoryItem> get history => _history;
  List<FavoriteCity> get favoriteCities => _favoriteCities;
  Map<String, Weather> get favoriteWeatherMap => _favoriteWeatherMap;
  String? get errorMessage => _errorMessage;

  // --- Khởi tạo dữ liệu ---

  Future<void> load({String? languageCode}) async {
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      await Future.wait([
        _loadHistory(),
        _loadFavorites(languageCode: languageCode),
      ]);
      _status = (_history.isEmpty && _favoriteCities.isEmpty)
          ? SearchStatus.empty
          : SearchStatus.success;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: ${e.toString()}';
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    _history = await _searchRepository.getSearchHistory(_currentUserId);
  }

  Future<void> _loadFavorites({String? languageCode}) async {
    _favoriteCities = await _searchRepository.getFavoriteCities(_currentUserId);
    // Tải thông tin thời tiết song song cho các thành phố yêu thích
    final futures = _favoriteCities.map((city) async {
      try {
        final weather = await _weatherRepository.getCurrentWeather(
          latitude: city.latitude,
          longitude: city.longitude,
          forceRefresh: false, // Sử dụng cache nếu có
          languageCode: languageCode,
        );
        _favoriteWeatherMap['${city.latitude}_${city.longitude}'] = weather;
      } catch (_) {
        // Bỏ qua lỗi tải thời tiết cho từng thành phố riêng lẻ
      }
    });
    await Future.wait(futures);
  }

  // --- Các hành động Lịch sử ---

  Future<void> removeHistoryItem(int id) async {
    try {
      await _searchRepository.deleteHistoryItem(id);
      await _loadHistory();
      if (_history.isEmpty && _favoriteCities.isEmpty) {
        _status = SearchStatus.empty;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa mục lịch sử: $e';
      notifyListeners();
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await _searchRepository.clearSearchHistory(_currentUserId);
      _history.clear();
      if (_history.isEmpty && _favoriteCities.isEmpty) {
        _status = SearchStatus.empty;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa sạch lịch sử: $e';
      notifyListeners();
    }
  }

  // --- Các hành động Tìm kiếm & Yêu thích ---

  /// Tìm kiếm địa điểm bằng Geocoding API.
  /// Trả về đối tượng Location (chứa tọa độ) và tên thành phố đã được chuẩn hóa.
  Future<Map<String, dynamic>?> searchLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Vui lòng nhập tên thành phố cần tìm kiếm.';
      notifyListeners();
      return null;
    }

    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = await _weatherRepository.searchLocation(trimmed);
      if (locations.isEmpty) {
        _errorMessage = 'Không tìm thấy kết quả nào cho "$trimmed".';
        _status = SearchStatus.error;
        notifyListeners();
        return null;
      }

      final loc = locations.first;
      final displayName = loc['name'] as String? ?? trimmed;

      // Lưu vào lịch sử tìm kiếm
      await _searchRepository.saveSearchQuery(displayName, _currentUserId);
      await _loadHistory();

      _status = SearchStatus.success;
      notifyListeners();

      return {
        'latitude': (loc['lat'] as num?)?.toDouble() ?? 0.0,
        'longitude': (loc['lon'] as num?)?.toDouble() ?? 0.0,
        'name': displayName,
      };
    } catch (e) {
      _errorMessage = 'Không thể tìm thấy địa điểm hoặc lỗi mạng: $e';
      _status = SearchStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFavorite(String name, double lat, double lon, {String? languageCode}) async {
    try {
      final isFav = await _searchRepository.isCityFavorited(lat, lon, _currentUserId);
      if (isFav) {
        await _searchRepository.removeFavoriteCity(lat, lon, _currentUserId);
        _favoriteWeatherMap.remove('${lat}_$lon');
      } else {
        await _searchRepository.addFavoriteCity(name, lat, lon, _currentUserId);
        // Tải thời tiết cho mục mới thêm
        try {
          final weather = await _weatherRepository.getCurrentWeather(
            latitude: lat,
            longitude: lon,
            languageCode: languageCode,
          );
          _favoriteWeatherMap['${lat}_$lon'] = weather;
        } catch (_) {}
      }
      await _loadFavorites(languageCode: languageCode);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật danh sách yêu thích: $e';
      notifyListeners();
    }
  }

  Future<bool> checkIsFavorite(double lat, double lon) async {
    return _searchRepository.isCityFavorited(lat, lon, _currentUserId);
  }
}
