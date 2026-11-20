import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_local_datasource.dart';
import '../models/invoice_model.dart';

/// InvoiceRepositoryImpl implements [InvoiceRepository].
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceLocalDataSource _localDataSource;

  InvoiceRepositoryImpl(this._localDataSource);

  @override
  Future<List<InvoiceEntity>> getInvoices({
    String? statusFilter,
    String? contractId,
    String? searchQuery,
  }) async {
    return await _localDataSource.getInvoices(
      statusFilter: statusFilter,
      contractId: contractId,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<InvoiceEntity?> getInvoiceById(String id) async {
    return await _localDataSource.getInvoiceById(id);
  }

  @override
  Future<bool> existsInvoiceForPeriod({
    required String contractId,
    required String periodStart,
    required String periodEnd,
  }) async {
    return await _localDataSource.existsInvoiceForPeriod(
      contractId: contractId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  @override
  Future<void> createInvoice(InvoiceEntity invoice) async {
    final model = InvoiceModel.fromEntity(invoice);
    await _localDataSource.insertInvoice(model);
  }

  @override
  Future<void> approveInvoice(String id) async {
    await _localDataSource.approveInvoice(id);
  }

  @override
  Future<void> updateInvoiceRemaining({
    required String invoiceId,
    required int paidAmountDelta,
  }) async {
    await _localDataSource.updateInvoiceRemaining(
      invoiceId: invoiceId,
      paidAmountDelta: paidAmountDelta,
    );
  }
}
