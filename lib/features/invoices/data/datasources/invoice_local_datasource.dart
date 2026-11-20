import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/invoice_model.dart';

/// InvoiceLocalDataSource executes SQLite queries for invoices with robust joined tables.
class InvoiceLocalDataSource {
  final DatabaseService _databaseService;

  InvoiceLocalDataSource(this._databaseService);

  /// Uses LEFT JOIN so invoices are always retrieved safely even if related entities are archived.
  String get _joinedQuery => '''
    SELECT 
      i.*,
      COALESCE(p.name, '') AS property_name,
      COALESCE(u.unit_number, '') AS unit_number,
      COALESCE(t.full_name, '') AS tenant_name,
      COALESCE(c.contract_number, '') AS contract_number
    FROM invoices i
    LEFT JOIN properties p ON i.property_id = p.id
    LEFT JOIN units u ON i.unit_id = u.id
    LEFT JOIN tenants t ON i.tenant_id = t.id
    LEFT JOIN contracts c ON i.contract_id = c.id
  ''';

  /// Retrieves invoices with optional status filter, contract filter, or search text
  Future<List<InvoiceModel>> getInvoices({
    String? statusFilter,
    String? contractId,
    String? searchQuery,
  }) async {
    final db = await _databaseService.database;
    String sql = _joinedQuery;
    List<dynamic> args = [];
    List<String> whereClauses = [];

    // Normalize status filter (support both snake_case and camelCase)
    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter.toLowerCase() != 'all') {
      final normalized = _normalizeStatus(statusFilter);
      whereClauses.add('LOWER(i.status) = ?');
      args.add(normalized.toLowerCase());
    }

    if (contractId != null && contractId.isNotEmpty) {
      whereClauses.add('i.contract_id = ?');
      args.add(contractId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add(
          '(i.invoice_number LIKE ? OR t.full_name LIKE ? OR u.unit_number LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      args.add(q);
      args.add(q);
      args.add(q);
    }

    if (whereClauses.isNotEmpty) {
      sql += ' WHERE ${whereClauses.join(' AND ')}';
    }

    sql += ' ORDER BY i.created_at DESC';

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => InvoiceModel.fromMap(m)).toList();
  }

  /// Finds an individual invoice by its ID
  Future<InvoiceModel?> getInvoiceById(String id) async {
    final db = await _databaseService.database;
    final maps =
        await db.rawQuery('$_joinedQuery WHERE i.id = ? LIMIT 1', [id]);
    if (maps.isEmpty) return null;
    return InvoiceModel.fromMap(maps.first);
  }

  /// Checks if an invoice already exists for the given contract and period (Business Rule 10)
  Future<bool> existsInvoiceForPeriod({
    required String contractId,
    required String periodStart,
    required String periodEnd,
  }) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM invoices WHERE contract_id = ? AND period_start = ? AND period_end = ? AND status != ?',
      [contractId, periodStart, periodEnd, 'cancelled'],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Inserts a new invoice record
  Future<void> insertInvoice(InvoiceModel invoice) async {
    final db = await _databaseService.database;
    await db.insert(
      'invoices',
      invoice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Approves a draft invoice making it pending due
  Future<void> approveInvoice(String id) async {
    final db = await _databaseService.database;
    await db.update(
      'invoices',
      {'status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates paid and remaining amounts after a payment or reversal
  Future<void> updateInvoiceRemaining({
    required String invoiceId,
    required int paidAmountDelta,
  }) async {
    final db = await _databaseService.database;
    final maps = await db.query('invoices',
        where: 'id = ?', whereArgs: [invoiceId], limit: 1);
    if (maps.isEmpty) return;

    final invoice = InvoiceModel.fromMap(maps.first);
    final newPaid = invoice.paidAmount + paidAmountDelta;
    final newRemaining = invoice.totalAmount - newPaid;

    String newStatus;
    if (newRemaining <= 0) {
      newStatus = 'paid';
    } else if (newPaid > 0) {
      newStatus = 'partiallyPaid';
    } else {
      newStatus = 'pending';
    }

    await db.update(
      'invoices',
      {
        'paid_amount': newPaid,
        'remaining_amount': newRemaining,
        'status': newStatus,
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Normalizes status strings between UI chips and database values
  String _normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'partially_paid':
      case 'partiallypaid':
        return 'partiallyPaid';
      case 'overdue':
        return 'overdue';
      case 'paid':
        return 'paid';
      case 'draft':
        return 'draft';
      case 'pending':
        return 'pending';
      default:
        return status;
    }
  }
}
