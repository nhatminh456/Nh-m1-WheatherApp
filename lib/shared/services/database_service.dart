import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Single sqflite connection shared by all feature repositories.
/// Feature repositories own their own table schema and SQL; this
/// service only owns opening the database and running migrations.
class DatabaseService {
  DatabaseService._internal();
  // có nghĩa là app này chỉ có 1 db serveice
  static final DatabaseService instance = DatabaseService._internal();

  static const _dbName = 'weatherapp.db';
  static const _dbVersion = 2;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        display_name TEXT NOT NULL DEFAULT '',
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE weather_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        metric TEXT NOT NULL,
        threshold REAL NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        searched_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add ALTER TABLE / new CREATE TABLE migrations here as _dbVersion increases.
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE locations ADD COLUMN display_name TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        'ALTER TABLE locations ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
