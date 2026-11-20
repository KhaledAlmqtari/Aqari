import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_service.dart';
import '../models/payment_model.dart';

/// PaymentLocalDataSource handles SQLite transaction-safe financial payments.
class PaymentLocalDataSource {
  final DatabaseService _databaseService;

  PaymentLocalDataSource(this._databaseService);

  String get _joinedQuery => '''
    SELECT 
      p.*,
      t.full_name AS tenant_name,
      i.invoice_number AS invoice_number
    FROM payments p
    JOIN tenants t ON p.tenant_id = t.id
    JOIN invoices i ON p.invoice_id = i.id
  ''';

  Future<List<PaymentModel>> getPayments(
      {String? invoiceId, String? tenantId}) async {
    final db = await _databaseService.database;
    String sql = _joinedQuery;
    List<dynamic> args = [];
    List<String> where = [];

    if (invoiceId != null && invoiceId.isNotEmpty) {
      where.add('p.invoice_id = ?');
      args.add(invoiceId);
    }
    if (tenantId != null && tenantId.isNotEmpty) {
      where.add('p.tenant_id = ?');
      args.add(tenantId);
    }

    if (where.isNotEmpty) {
      sql += ' WHERE ${where.join(' AND ')}';
    }

    sql += ' ORDER BY p.created_at DESC';

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => PaymentModel.fromMap(m)).toList();
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    final db = await _databaseService.database;
    final maps =
        await db.rawQuery('$_joinedQuery WHERE p.id = ? LIMIT 1', [id]);
    if (maps.isEmpty) return null;
    return PaymentModel.fromMap(maps.first);
  }

  /// Records payment atomically in a transaction and updates the invoice balance and status
  Future<void> recordPayment(PaymentModel payment) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 1. Fetch current invoice balance
      final invoiceRows = await txn.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [payment.invoiceId],
        limit: 1,
      );

      if (invoiceRows.isEmpty) {
        throw StateError('Invoice not found');
      }

      final invoice = invoiceRows.first;
      final int totalAmount = (invoice['total_amount'] as int?) ?? 0;
      final int currentPaid = (invoice['paid_amount'] as int?) ?? 0;
      final int remaining = (invoice['remaining_amount'] as int?) ?? 0;

      // Business Rule 12: Payment cannot exceed remaining balance
      if (payment.amount > remaining) {
        throw StateError('payment_exceeds_remaining');
      }

      // 2. Insert payment record
      await txn.insert('payments', payment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // 3. Calculate new totals
      final int newPaid = currentPaid + payment.amount;
      final int newRemaining = totalAmount - newPaid;

      String newStatus;
      if (newRemaining <= 0) {
        newStatus = 'paid';
      } else {
        newStatus = 'partiallyPaid';
      }

      // 4. Update invoice balance and status
      await txn.update(
        'invoices',
        {
          'paid_amount': newPaid,
          'remaining_amount': newRemaining,
          'status': newStatus,
        },
        where: 'id = ?',
        whereArgs: [payment.invoiceId],
      );
    });
  }

  /// Reverses an approved payment with reason while keeping audit trail intact (Business Rule 19)
  Future<void> reversePayment({
    required String paymentId,
    required String invoiceId,
    required int amount,
    required String reason,
    required String reversedAt,
  }) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 1. Mark payment as reversed
      await txn.update(
        'payments',
        {
          'is_reversed': 1,
          'reverse_reason': reason,
          'reversed_at': reversedAt,
        },
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      // 2. Adjust invoice balance
      final invoiceRows = await txn.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [invoiceId],
        limit: 1,
      );

      if (invoiceRows.isNotEmpty) {
        final invoice = invoiceRows.first;
        final int totalAmount = (invoice['total_amount'] as int?) ?? 0;
        final int currentPaid = (invoice['paid_amount'] as int?) ?? 0;

        final int newPaid = (currentPaid - amount).clamp(0, totalAmount);
        final int newRemaining = totalAmount - newPaid;

        String newStatus;
        if (newRemaining <= 0) {
          newStatus = 'paid';
        } else if (newPaid > 0) {
          newStatus = 'partiallyPaid';
        } else {
          newStatus = 'pending';
        }

        await txn.update(
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
    });
  }
}
