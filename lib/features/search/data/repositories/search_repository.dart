import '../models/favorite_city.dart';
import '../models/history_item.dart';
import '../services/search_local_service.dart';

class SearchRepository {
  SearchRepository(this._localService);

  final SearchLocalService _localService;

  // --- Lịch sử tìm kiếm ---

  Future<void> saveSearchQuery(String query, String userId) async {
    await _localService.insertHistory(query, userId);
  }

  Future<List<HistoryItem>> getSearchHistory(String userId) async {
    final rawData = await _localService.getHistory(userId);
    return rawData.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<void> deleteHistoryItem(int id) async {
    await _localService.deleteHistoryItem(id);
  }

  Future<void> clearSearchHistory(String userId) async {
    await _localService.clearHistory(userId);
  }

  // --- Thành phố yêu thích ---

  Future<void> addFavoriteCity(String name, double lat, double lon, String userId) async {
    await _localService.insertFavorite(name, lat, lon, userId);
  }

  Future<void> removeFavoriteCity(double lat, double lon, String userId) async {
    await _localService.deleteFavorite(lat, lon, userId);
  }

  Future<void> removeFavoriteCityById(int id) async {
    await _localService.deleteFavoriteById(id);
  }

  Future<List<FavoriteCity>> getFavoriteCities(String userId) async {
    final rawData = await _localService.getFavorites(userId);
    return rawData.map((map) => FavoriteCity.fromMap(map)).toList();
  }

  Future<bool> isCityFavorited(double lat, double lon, String userId) async {
    return _localService.isFavorite(lat, lon, userId);
  }
}
