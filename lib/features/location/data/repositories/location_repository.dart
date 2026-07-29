import '../../../../shared/services/database_service.dart';
import '../models/location_model.dart';

class LocationRepository {
  Future<List<LocationModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'locations',
      orderBy: 'is_default DESC, sort_order ASC, id ASC',
    );
    return rows.map(LocationModel.fromMap).toList();
  }

  Future<LocationModel?> getDefault() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'locations',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocationModel.fromMap(rows.first);
  }

  Future<int> add(LocationModel location) async {
    final db = await DatabaseService.instance.database;
    return db.insert('locations', location.toMap());
  }

  Future<int> update(LocationModel location) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseService.instance.database;
    return db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorder(List<LocationModel> locations) async {
    final db = await DatabaseService.instance.database;
    final batch = db.batch();

    for (var index = 0; index < locations.length; index++) {
      batch.update(
        'locations',
        {'sort_order': index},
        where: 'id = ?',
        whereArgs: [locations[index].id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> setDefault(int id) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.update('locations', {'is_default': 0});
      await txn.update(
        'locations',
        {'is_default': 1, 'sort_order': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
