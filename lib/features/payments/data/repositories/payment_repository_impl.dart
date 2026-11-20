import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../models/payment_model.dart';

/// PaymentRepositoryImpl implements [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _localDataSource;

  PaymentRepositoryImpl(this._localDataSource);

  @override
  Future<List<PaymentEntity>> getPayments(
      {String? invoiceId, String? tenantId}) async {
    return await _localDataSource.getPayments(
        invoiceId: invoiceId, tenantId: tenantId);
  }

  @override
  Future<PaymentEntity?> getPaymentById(String id) async {
    return await _localDataSource.getPaymentById(id);
  }

  @override
  Future<void> recordPayment(PaymentEntity payment) async {
    final model = PaymentModel.fromEntity(payment);
    await _localDataSource.recordPayment(model);
  }

  @override
  Future<void> reversePayment({
    required String paymentId,
    required String invoiceId,
    required int amount,
    required String reason,
    required String reversedAt,
  }) async {
    await _localDataSource.reversePayment(
      paymentId: paymentId,
      invoiceId: invoiceId,
      amount: amount,
      reason: reason,
      reversedAt: reversedAt,
    );
  }
}
