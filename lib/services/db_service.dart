import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT,
        voteAverage REAL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT,
        voteAverage REAL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE watchlist (
          id INTEGER PRIMARY KEY,
          title TEXT,
          overview TEXT,
          posterPath TEXT,
          voteAverage REAL
        )
      ''');
    }
  }

  Future<void> addFavorite(Movie movie) async {
    final db = await database;
    await db.insert('favorites', movie.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  // Watchlist methods
  Future<void> addWatchlist(Movie movie) async {
    final db = await database;
    await db.insert('watchlist', movie.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeWatchlist(int id) async {
    final db = await database;
    await db.delete('watchlist', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> getWatchlist() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('watchlist');
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  Future<bool> isWatchlist(int id) async {
    final db = await database;
    final maps = await db.query('watchlist', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }
}
