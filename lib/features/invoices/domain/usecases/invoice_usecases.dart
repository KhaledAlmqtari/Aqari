import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class GetInvoicesUseCase {
  final InvoiceRepository _repository;
  GetInvoicesUseCase(this._repository);

  Future<List<InvoiceEntity>> execute({
    String? statusFilter,
    String? contractId,
    String? searchQuery,
  }) {
    return _repository.getInvoices(
      statusFilter: statusFilter,
      contractId: contractId,
      searchQuery: searchQuery,
    );
  }
}

class CreateInvoiceUseCase {
  final InvoiceRepository _repository;
  CreateInvoiceUseCase(this._repository);

  Future<void> execute(InvoiceEntity invoice) async {
    // Business Rule 10: Prevent duplicate invoice for same contract and period
    final exists = await _repository.existsInvoiceForPeriod(
      contractId: invoice.contractId,
      periodStart: invoice.periodStart,
      periodEnd: invoice.periodEnd,
    );
    if (exists) {
      throw StateError('duplicate_invoice_period');
    }
    await _repository.createInvoice(invoice);
  }
}

class ApproveInvoiceUseCase {
  final InvoiceRepository _repository;
  ApproveInvoiceUseCase(this._repository);

  Future<void> execute(String id) {
    // Business Rule 9: Invoice becomes pending due upon owner approval
    return _repository.approveInvoice(id);
  }
}
