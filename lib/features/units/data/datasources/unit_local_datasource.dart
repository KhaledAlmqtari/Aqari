import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/unit_model.dart';

/// UnitLocalDataSource executes direct SQLite queries for units with transaction support.
class UnitLocalDataSource {
  final DatabaseService _databaseService;

  UnitLocalDataSource(this._databaseService);

  /// Fetches units by property ID
  Future<List<UnitModel>> getUnitsByPropertyId(String propertyId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'units',
      where: 'property_id = ?',
      whereArgs: [propertyId],
      orderBy: 'unit_number ASC',
    );
    return maps.map((m) => UnitModel.fromMap(m)).toList();
  }

  /// Fetches all units, optionally filtered by status
  Future<List<UnitModel>> getAllUnits({String? statusFilter}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps;

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter.toLowerCase() != 'all') {
      maps = await db.query(
        'units',
        where: 'status = ?',
        whereArgs: [statusFilter],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('units', orderBy: 'created_at DESC');
    }

    return maps.map((m) => UnitModel.fromMap(m)).toList();
  }

  /// Fetches a unit by ID
  Future<UnitModel?> getUnitById(String id) async {
    final db = await _databaseService.database;
    final maps =
        await db.query('units', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return UnitModel.fromMap(maps.first);
  }

  /// Inserts a unit and updates property total_units count atomically
  Future<void> insertUnit(UnitModel unit) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.insert('units', unit.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Recalculate property unit count
      final countResult = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM units WHERE property_id = ?',
        [unit.propertyId],
      );
      final count = Sqflite.firstIntValue(countResult) ?? 0;

      await txn.update(
        'properties',
        {'total_units': count},
        where: 'id = ?',
        whereArgs: [unit.propertyId],
      );
    });
  }

  /// Updates a unit
  Future<void> updateUnit(UnitModel unit) async {
    final db = await _databaseService.database;
    await db.update(
      'units',
      unit.toMap(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
  }

  /// Updates unit status
  Future<void> updateUnitStatus(String unitId, String newStatus) async {
    final db = await _databaseService.database;
    await db.update(
      'units',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [unitId],
    );
  }

  /// Deletes a unit and updates property total_units count
  Future<void> deleteUnit(String id, String propertyId) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete('units', where: 'id = ?', whereArgs: [id]);

      final countResult = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM units WHERE property_id = ?',
        [propertyId],
      );
      final count = Sqflite.firstIntValue(countResult) ?? 0;

      await txn.update(
        'properties',
        {'total_units': count},
        where: 'id = ?',
        whereArgs: [propertyId],
      );
    });
  }
}
