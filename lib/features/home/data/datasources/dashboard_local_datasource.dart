import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../../../contracts/data/models/contract_model.dart';
import '../../../invoices/data/models/invoice_model.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardLocalDataSource {
  final DatabaseService _databaseService;

  DashboardLocalDataSource(this._databaseService);

  Future<DashboardStatsEntity> getDashboardStats() async {
    final db = await _databaseService.database;

    // 1. Total Properties
    final propResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM properties WHERE is_archived = 0',
    );
    final totalProperties = Sqflite.firstIntValue(propResult) ?? 0;

    // 2. Units: Total, Vacant, Rented
    final totalUnitsResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM units');
    final totalUnits = Sqflite.firstIntValue(totalUnitsResult) ?? 0;

    final vacantResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM units WHERE status = 'vacant'",
    );
    final vacantUnits = Sqflite.firstIntValue(vacantResult) ?? 0;

    final rentedResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM units WHERE status = 'rented'",
    );
    final rentedUnits = Sqflite.firstIntValue(rentedResult) ?? 0;

    // 3. Active Contracts
    final contractsResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM contracts WHERE status = 'active'",
    );
    final activeContracts = Sqflite.firstIntValue(contractsResult) ?? 0;

    // 4. Total Active Tenants
    final tenantsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tenants WHERE is_archived = 0',
    );
    final totalTenants = Sqflite.firstIntValue(tenantsResult) ?? 0;

    // 5. Total Collected Revenue (Sum of non-reversed payments)
    final revenueResult = await db.rawQuery(
      'SELECT SUM(amount) as sum FROM payments WHERE is_reversed = 0',
    );
    final totalCollected = Sqflite.firstIntValue(revenueResult) ?? 0;

    // 6. Total Pending Receivables (Sum of remaining_amount on non-cancelled invoices)
    final pendingResult = await db.rawQuery(
      "SELECT SUM(remaining_amount) as sum FROM invoices WHERE status != 'cancelled'",
    );
    final totalPending = Sqflite.firstIntValue(pendingResult) ?? 0;

    // 7. Total Expenses
    final expensesResult =
        await db.rawQuery('SELECT SUM(amount) as sum FROM expenses');
    final totalExpenses = Sqflite.firstIntValue(expensesResult) ?? 0;

    // 8. Net Cashflow
    final netCashflow = totalCollected - totalExpenses;

    // 9. Occupancy Rate
    final double occupancyRate =
        totalUnits > 0 ? (rentedUnits / totalUnits) * 100.0 : 0.0;

    // 10. Recent Invoices (limit 5)
    final invoiceMaps = await db.rawQuery('''
      SELECT 
        i.*,
        p.name AS property_name,
        u.unit_number AS unit_number,
        t.full_name AS tenant_name,
        c.contract_number AS contract_number
      FROM invoices i
      JOIN properties p ON i.property_id = p.id
      JOIN units u ON i.unit_id = u.id
      JOIN tenants t ON i.tenant_id = t.id
      JOIN contracts c ON i.contract_id = c.id
      ORDER BY i.created_at DESC
      LIMIT 5
    ''');
    final recentInvoices =
        invoiceMaps.map((m) => InvoiceModel.fromMap(m)).toList();

    // 11. Upcoming Expiring Contracts (limit 5)
    final contractMaps = await db.rawQuery('''
      SELECT 
        c.*,
        p.name AS property_name,
        u.unit_number AS unit_number,
        t.full_name AS tenant_name
      FROM contracts c
      JOIN properties p ON c.property_id = p.id
      JOIN units u ON c.unit_id = u.id
      JOIN tenants t ON c.tenant_id = t.id
      WHERE c.status = 'active'
      ORDER BY c.end_date ASC
      LIMIT 5
    ''');
    final expiringContracts =
        contractMaps.map((m) => ContractModel.fromMap(m)).toList();

    return DashboardStatsEntity(
      totalProperties: totalProperties,
      totalUnits: totalUnits,
      vacantUnits: vacantUnits,
      rentedUnits: rentedUnits,
      activeContracts: activeContracts,
      totalTenants: totalTenants,
      totalCollectedRevenue: totalCollected,
      totalPendingReceivables: totalPending,
      totalExpenses: totalExpenses,
      netCashflow: netCashflow,
      occupancyRate: occupancyRate,
      recentInvoices: recentInvoices,
      upcomingExpiringContracts: expiringContracts,
    );
  }
}
