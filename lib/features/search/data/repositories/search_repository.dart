import '../models/favorite_city.dart';
import '../models/history_item.dart';
import '../services/search_local_service.dart';

class SearchRepository {
  SearchRepository(this._localService);

  final SearchLocalService _localService;

  // --- Lịch sử tìm kiếm ---

  Future<void> saveSearchQuery(String query) async {
    await _localService.insertHistory(query);
  }

  Future<List<HistoryItem>> getSearchHistory() async {
    final rawData = await _localService.getHistory();
    return rawData.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<void> deleteHistoryItem(int id) async {
    await _localService.deleteHistoryItem(id);
  }

  Future<void> clearSearchHistory() async {
    await _localService.clearHistory();
  }

  // --- Thành phố yêu thích ---

  Future<void> addFavoriteCity(String name, double lat, double lon) async {
    await _localService.insertFavorite(name, lat, lon);
  }

  Future<void> removeFavoriteCity(double lat, double lon) async {
    await _localService.deleteFavorite(lat, lon);
  }

  Future<void> removeFavoriteCityById(int id) async {
    await _localService.deleteFavoriteById(id);
  }

  Future<List<FavoriteCity>> getFavoriteCities() async {
    final rawData = await _localService.getFavorites();
    return rawData.map((map) => FavoriteCity.fromMap(map)).toList();
  }

  Future<bool> isCityFavorited(double lat, double lon) async {
    return _localService.isFavorite(lat, lon);
  }
}
