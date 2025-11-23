import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/wardrobe_item.dart';
import '../models/outfit.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'la_moda.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profiles(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        bodyType TEXT NOT NULL,
        skinUndertone TEXT NOT NULL,
        faceShape TEXT NOT NULL,
        favoriteColors TEXT,
        dislikedPatterns TEXT,
        measurements TEXT,
        stylePreferences TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wardrobe_items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        color TEXT NOT NULL,
        pattern TEXT,
        fabric TEXT,
        fit TEXT,
        season INTEGER NOT NULL,
        imagePath TEXT,
        tags TEXT,
        rating INTEGER DEFAULT 0,
        wearCount INTEGER DEFAULT 0,
        lastWorn INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE outfits(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        itemIds TEXT NOT NULL,
        occasion TEXT NOT NULL,
        weather TEXT,
        rating INTEGER DEFAULT 0,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        lastWorn INTEGER
      )
    ''');
  }

  // User Profile operations
  Future<void> insertUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert('user_profiles', profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String id) async {
    final db = await database;
    final maps = await db.query('user_profiles', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? UserProfile.fromMap(maps.first) : null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update('user_profiles', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
  }

  // Wardrobe Item operations
  Future<void> insertWardrobeItem(WardrobeItem item) async {
    final db = await database;
    await db.insert('wardrobe_items', item.toMap());
  }

  Future<List<WardrobeItem>> getAllWardrobeItems() async {
    final db = await database;
    final maps = await db.query('wardrobe_items');
    return maps.map((map) => WardrobeItem.fromMap(map)).toList();
  }

  Future<List<WardrobeItem>> getWardrobeItemsByType(ClothingType type) async {
    final db = await database;
    final maps = await db.query('wardrobe_items', where: 'type = ?', whereArgs: [type.index]);
    return maps.map((map) => WardrobeItem.fromMap(map)).toList();
  }

  Future<void> updateWardrobeItem(WardrobeItem item) async {
    final db = await database;
    await db.update('wardrobe_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteWardrobeItem(String id) async {
    final db = await database;
    await db.delete('wardrobe_items', where: 'id = ?', whereArgs: [id]);
  }

  // Outfit operations
  Future<void> insertOutfit(Outfit outfit) async {
    final db = await database;
    await db.insert('outfits', outfit.toMap());
  }

  Future<List<Outfit>> getAllOutfits() async {
    final db = await database;
    final maps = await db.query('outfits');
    return maps.map((map) => Outfit.fromMap(map)).toList();
  }

  Future<void> updateOutfit(Outfit outfit) async {
    final db = await database;
    await db.update('outfits', outfit.toMap(), where: 'id = ?', whereArgs: [outfit.id]);
  }

  Future<void> deleteOutfit(String id) async {
    final db = await database;
    await db.delete('outfits', where: 'id = ?', whereArgs: [id]);
  }
}