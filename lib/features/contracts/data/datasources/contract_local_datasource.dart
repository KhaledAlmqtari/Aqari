import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/contract_model.dart';

/// ContractLocalDataSource handles SQLite persistence and joined queries for contracts.
class ContractLocalDataSource {
  final DatabaseService _databaseService;

  ContractLocalDataSource(this._databaseService);

  /// Builds the joined SELECT query to attach Property, Unit, and Tenant names
  String get _joinedQuery => '''
    SELECT 
      c.*,
      p.name AS property_name,
      u.unit_number AS unit_number,
      t.full_name AS tenant_name
    FROM contracts c
    JOIN properties p ON c.property_id = p.id
    JOIN units u ON c.unit_id = u.id
    JOIN tenants t ON c.tenant_id = t.id
  ''';

  /// Fetches all contracts, optionally filtered by status
  Future<List<ContractModel>> getContracts({String? statusFilter}) async {
    final db = await _databaseService.database;
    String sql = _joinedQuery;
    List<dynamic> args = [];

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter.toLowerCase() != 'all') {
      sql += ' WHERE c.status = ?';
      args.add(statusFilter);
    }
    sql += ' ORDER BY c.created_at DESC';

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => ContractModel.fromMap(m)).toList();
  }

  /// Fetches a single contract by ID with joined names
  Future<ContractModel?> getContractById(String id) async {
    final db = await _databaseService.database;
    final maps =
        await db.rawQuery('$_joinedQuery WHERE c.id = ? LIMIT 1', [id]);
    if (maps.isEmpty) return null;
    return ContractModel.fromMap(maps.first);
  }

  /// Checks if a unit already has an active contract (Business Rule 3)
  Future<bool> hasActiveContractOnUnit(String unitId,
      {String? excludeContractId}) async {
    final db = await _databaseService.database;
    String query =
        "SELECT COUNT(*) as count FROM contracts WHERE unit_id = ? AND status = 'active'";
    List<dynamic> args = [unitId];

    if (excludeContractId != null) {
      query += ' AND id != ?';
      args.add(excludeContractId);
    }

    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Inserts a new contract and updates unit status to 'rented' atomically
  Future<void> insertContract(ContractModel contract) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.insert('contracts', contract.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Business Rule 4: Activating a contract converts the unit to 'rented'
      if (contract.isActive) {
        await txn.update(
          'units',
          {'status': 'rented'},
          where: 'id = ?',
          whereArgs: [contract.unitId],
        );
      }
    });
  }

  /// Updates contract details
  Future<void> updateContract(ContractModel contract) async {
    final db = await _databaseService.database;
    await db.update(
      'contracts',
      contract.toMap(),
      where: 'id = ?',
      whereArgs: [contract.id],
    );
  }

  /// Renews a contract: sets old contract to 'expired' and inserts new contract atomically
  Future<void> renewContract({
    required ContractModel oldContract,
    required ContractModel newContract,
  }) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      // 1. Mark old contract as expired
      await txn.update(
        'contracts',
        {'status': 'expired'},
        where: 'id = ?',
        whereArgs: [oldContract.id],
      );

      // 2. Insert new contract
      await txn.insert(
        'contracts',
        newContract.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 3. Keep unit status as rented
      await txn.update(
        'units',
        {'status': 'rented'},
        where: 'id = ?',
        whereArgs: [newContract.unitId],
      );
    });
  }

  /// Terminates a contract and updates unit status to 'vacant' atomically (Business Rule 22)
  Future<void> terminateContract({
    required String contractId,
    required String unitId,
    required String reason,
    required String terminationDate,
  }) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.update(
        'contracts',
        {
          'status': 'terminated',
          'terminated_at': terminationDate,
          'termination_reason': reason,
        },
        where: 'id = ?',
        whereArgs: [contractId],
      );

      // Record unit as vacant after handover
      await txn.update(
        'units',
        {'status': 'vacant'},
        where: 'id = ?',
        whereArgs: [unitId],
      );
    });
  }

  /// Fetches contracts by Tenant ID
  Future<List<ContractModel>> getContractsByTenantId(String tenantId) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '$_joinedQuery WHERE c.tenant_id = ? ORDER BY c.created_at DESC',
      [tenantId],
    );
    return maps.map((m) => ContractModel.fromMap(m)).toList();
  }

  /// Fetches contracts by Property ID
  Future<List<ContractModel>> getContractsByPropertyId(
      String propertyId) async {
    final db = await _databaseService.database;
    final maps = await db.rawQuery(
      '$_joinedQuery WHERE c.property_id = ? ORDER BY c.created_at DESC',
      [propertyId],
    );
    return maps.map((m) => ContractModel.fromMap(m)).toList();
  }
}
