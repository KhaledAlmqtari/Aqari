import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/property_model.dart';

/// PropertyLocalDataSource handles low-level SQLite queries for properties.
class PropertyLocalDataSource {
  final DatabaseService _databaseService;

  PropertyLocalDataSource(this._databaseService);

  /// Retrieves all properties from SQLite, filtering by archive status if requested.
  Future<List<PropertyModel>> getProperties(
      {bool includeArchived = false}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps;

    if (includeArchived) {
      maps = await db.query('properties', orderBy: 'created_at DESC');
    } else {
      maps = await db.query(
        'properties',
        where: 'is_archived = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
      );
    }

    return maps.map((map) => PropertyModel.fromMap(map)).toList();
  }

  /// Finds a specific property by ID
  Future<PropertyModel?> getPropertyById(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return PropertyModel.fromMap(maps.first);
  }

  /// Inserts a new property into the database
  Future<void> insertProperty(PropertyModel property) async {
    final db = await _databaseService.database;
    await db.insert(
      'properties',
      property.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing property
  Future<void> updateProperty(PropertyModel property) async {
    final db = await _databaseService.database;
    await db.update(
      'properties',
      property.toMap(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
  }

  /// Soft archives a property by setting is_archived = 1
  Future<void> archiveProperty(String id) async {
    final db = await _databaseService.database;
    await db.update(
      'properties',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
