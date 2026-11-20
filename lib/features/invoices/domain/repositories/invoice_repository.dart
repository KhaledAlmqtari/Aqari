import '../entities/invoice_entity.dart';

/// InvoiceRepository defines operations for billing, draft generation, and invoice tracking.
abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({
    String? statusFilter,
    String? contractId,
    String? searchQuery,
  });
  Future<InvoiceEntity?> getInvoiceById(String id);
  Future<bool> existsInvoiceForPeriod({
    required String contractId,
    required String periodStart,
    required String periodEnd,
  });
  Future<void> createInvoice(InvoiceEntity invoice);
  Future<void> approveInvoice(String id);
  Future<void> updateInvoiceRemaining({
    required String invoiceId,
    required int paidAmountDelta,
  });
}
