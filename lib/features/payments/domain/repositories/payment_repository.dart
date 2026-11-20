import '../entities/payment_entity.dart';

/// PaymentRepository defines contracts for processing receipts and reversals.
abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments(
      {String? invoiceId, String? tenantId});
  Future<PaymentEntity?> getPaymentById(String id);
  Future<void> recordPayment(PaymentEntity payment);
  Future<void> reversePayment({
    required String paymentId,
    required String invoiceId,
    required int amount,
    required String reason,
    required String reversedAt,
  });
}
