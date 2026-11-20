import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/tenant_model.dart';

/// TenantLocalDataSource handles low-level SQLite queries for tenants.
class TenantLocalDataSource {
  final DatabaseService _databaseService;

  TenantLocalDataSource(this._databaseService);

  Future<List<TenantModel>> getTenants(
      {bool includeArchived = false, String? searchQuery}) async {
    final db = await _databaseService.database;
    String whereClause = includeArchived ? '1=1' : 'is_archived = 0';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause += ' AND (full_name LIKE ? OR phone LIKE ?)';
      whereArgs.add('%${searchQuery.trim()}%');
      whereArgs.add('%${searchQuery.trim()}%');
    }

    final maps = await db.query(
      'tenants',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'full_name ASC',
    );

    return maps.map((m) => TenantModel.fromMap(m)).toList();
  }

  Future<TenantModel?> getTenantById(String id) async {
    final db = await _databaseService.database;
    final maps =
        await db.query('tenants', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return TenantModel.fromMap(maps.first);
  }

  Future<void> insertTenant(TenantModel tenant) async {
    final db = await _databaseService.database;
    await db.insert('tenants', tenant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTenant(TenantModel tenant) async {
    final db = await _databaseService.database;
    await db.update('tenants', tenant.toMap(),
        where: 'id = ?', whereArgs: [tenant.id]);
  }

  Future<void> archiveTenant(String id) async {
    final db = await _databaseService.database;
    await db.update('tenants', {'is_archived': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
