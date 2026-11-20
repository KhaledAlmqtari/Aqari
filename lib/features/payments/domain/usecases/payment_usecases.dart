import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository _repository;
  GetPaymentsUseCase(this._repository);

  Future<List<PaymentEntity>> execute({String? invoiceId, String? tenantId}) {
    return _repository.getPayments(invoiceId: invoiceId, tenantId: tenantId);
  }
}

class RecordPaymentUseCase {
  final PaymentRepository _repository;
  RecordPaymentUseCase(this._repository);

  Future<void> execute(PaymentEntity payment) async {
    if (payment.amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero');
    }
    await _repository.recordPayment(payment);
  }
}

class ReversePaymentUseCase {
  final PaymentRepository _repository;
  ReversePaymentUseCase(this._repository);

  Future<void> execute({
    required String paymentId,
    required String invoiceId,
    required int amount,
    required String reason,
    required String reversedAt,
  }) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError('Reversal reason is mandatory');
    }
    // Business Rule 19: Non-destructive reversal with reason and audit preservation
    await _repository.reversePayment(
      paymentId: paymentId,
      invoiceId: invoiceId,
      amount: amount,
      reason: reason,
      reversedAt: reversedAt,
    );
  }
}
