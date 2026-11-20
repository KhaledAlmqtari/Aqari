import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final DatabaseService _databaseService;

  ExpenseLocalDataSource(this._databaseService);

  String get _joinedQuery => '''
    SELECT 
      e.*,
      p.name AS property_name,
      t.full_name AS tenant_name
    FROM expenses e
    LEFT JOIN properties p ON e.property_id = p.id
    LEFT JOIN tenants t ON e.tenant_id = t.id
  ''';

  Future<List<ExpenseModel>> getExpenses(
      {String? propertyId, String? tenantId}) async {
    final db = await _databaseService.database;
    String sql = _joinedQuery;
    List<dynamic> args = [];
    List<String> conditions = [];

    if (propertyId != null && propertyId.isNotEmpty) {
      conditions.add('e.property_id = ?');
      args.add(propertyId);
    }

    if (tenantId != null && tenantId.isNotEmpty) {
      conditions.add('e.tenant_id = ?');
      args.add(tenantId);
    }

    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    sql += ' ORDER BY e.expense_date DESC';

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await _databaseService.database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> getTotalExpenses({String? tenantId}) async {
    final db = await _databaseService.database;
    if (tenantId != null && tenantId.isNotEmpty) {
      final result = await db.rawQuery(
          'SELECT SUM(amount) as total FROM expenses WHERE tenant_id = ?',
          [tenantId]);
      return Sqflite.firstIntValue(result) ?? 0;
    }
    final result =
        await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
