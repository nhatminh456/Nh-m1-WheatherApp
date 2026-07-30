import 'package:sqflite/sqflite.dart';

import '../../../../shared/services/database_service.dart';

class SearchLocalService {
  SearchLocalService({DatabaseService? databaseService})
      : _dbService = databaseService ?? DatabaseService.instance;

  final DatabaseService _dbService;

  Future<Database> get _database => _dbService.database;

  // --- Lịch sử tìm kiếm (search_history table) ---

  Future<void> insertHistory(String query) async {
    final db = await _database;
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    await db.transaction((txn) async {
      // Chống trùng: kiểm tra xem từ khóa đã tồn tại trong lịch sử chưa
      final List<Map<String, dynamic>> existing = await txn.query(
        'search_history',
        where: 'LOWER(query) = ?',
        whereArgs: [trimmedQuery.toLowerCase()],
      );

      final now = DateTime.now().millisecondsSinceEpoch;

      if (existing.isNotEmpty) {
        // Nếu đã tồn tại, cập nhật thời gian tìm kiếm mới nhất
        final int id = existing.first['id'] as int;
        await txn.update(
          'search_history',
          {'searched_at': now},
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        // Nếu chưa tồn tại, chèn bản ghi mới
        await txn.insert('search_history', {
          'query': trimmedQuery,
          'searched_at': now,
          'is_favorite': 0,
        });
      }

      // Giới hạn số lượng lịch sử tối đa 10 mục: xóa các mục cũ nhất vượt quá giới hạn
      await txn.execute('''
        DELETE FROM search_history 
        WHERE id NOT IN (
          SELECT id FROM search_history 
          ORDER BY searched_at DESC 
          LIMIT 10
        )
      ''');
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await _database;
    return db.query(
      'search_history',
      orderBy: 'searched_at DESC',
    );
  }

  Future<void> deleteHistoryItem(int id) async {
    final db = await _database;
    await db.delete(
      'search_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearHistory() async {
    final db = await _database;
    await db.delete('search_history');
  }

  // --- Thành phố yêu thích (locations table) ---

  Future<void> insertFavorite(String name, double lat, double lon) async {
    final db = await _database;
    final trimmedName = name.trim();

    await db.transaction((txn) async {
      // Tránh thêm trùng: kiểm tra dựa trên khoảng tọa độ gần nhau (sai số nhỏ hơn 0.01 độ ~ 1km)
      final List<Map<String, dynamic>> existing = await txn.rawQuery('''
        SELECT id FROM locations 
        WHERE ABS(latitude - ?) < 0.01 AND ABS(longitude - ?) < 0.01
      ''', [lat, lon]);

      if (existing.isEmpty) {
        await txn.insert('locations', {
          'name': trimmedName,
          'latitude': lat,
          'longitude': lon,
          'sort_order': 0,
        });
      }
    });
  }

  Future<void> deleteFavorite(double lat, double lon) async {
    final db = await _database;
    await db.delete(
      'locations',
      where: 'ABS(latitude - ?) < 0.01 AND ABS(longitude - ?) < 0.01',
      whereArgs: [lat, lon],
    );
  }

  Future<void> deleteFavoriteById(int id) async {
    final db = await _database;
    await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await _database;
    return db.query('locations', orderBy: 'id DESC');
  }

  Future<bool> isFavorite(double lat, double lon) async {
    final db = await _database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM locations 
      WHERE ABS(latitude - ?) < 0.01 AND ABS(longitude - ?) < 0.01
    ''', [lat, lon]);

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
