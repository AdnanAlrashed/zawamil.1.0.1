import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zawamil.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE artists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        audio_url TEXT NOT NULL,
        artist_id INTEGER,
        FOREIGN KEY (artist_id) REFERENCES artists (id)
      )
    ''');
  }

  // Artist CRUD operations
  Future<int> createArtist(Map<String, dynamic> artist) async {
    final db = await instance.database;
    return await db.insert('artists', artist);
  }

  Future<List<Map<String, dynamic>>> getAllArtists() async {
    final db = await instance.database;
    return await db.query('artists');
  }

  Future<int> updateArtist(Map<String, dynamic> artist) async {
    final db = await instance.database;
    return await db.update(
      'artists',
      artist,
      where: 'id = ?',
      whereArgs: [artist['id']],
    );
  }

  Future<int> deleteArtist(int artistId) async {
    final db = await instance.database;
    // حذف جميع الأغاني المرتبطة بالفنان أولاً
    await db.delete(
      'songs',
      where: 'artist_id = ?',
      whereArgs: [artistId],
    );
    // ثم حذف الفنان
    return await db.delete(
      'artists',
      where: 'id = ?',
      whereArgs: [artistId],
    );
  }

  // Song CRUD operations
  Future<int> createSong(Map<String, dynamic> song) async {
    final db = await instance.database;
    return await db.insert('songs', song);
  }

  Future<List<Map<String, dynamic>>> getSongsByArtist(int artistId) async {
    final db = await instance.database;
    return await db.query(
      'songs',
      where: 'artist_id = ?',
      whereArgs: [artistId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllSongs() async {
    final db = await instance.database;
    return await db.query('songs');
  }

  Future<int> updateSong(Map<String, dynamic> song) async {
    final db = await instance.database;
    return await db.update(
      'songs',
      song,
      where: 'id = ?',
      whereArgs: [song['id']],
    );
  }

  Future<int> deleteSong(int songId) async {
    final db = await instance.database;
    return await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [songId],
    );
  }
}
