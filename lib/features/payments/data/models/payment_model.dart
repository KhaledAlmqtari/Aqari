import '../../domain/entities/payment_entity.dart';

/// PaymentModel serializes payment receipts with joined tenant and invoice details.
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.receiptNumber,
    required super.invoiceId,
    required super.tenantId,
    required super.contractId,
    required super.amount,
    required super.paymentDate,
    required super.paymentMethod,
    super.referenceNumber,
    super.notes,
    super.isReversed,
    super.reverseReason,
    super.reversedAt,
    required super.createdAt,
    super.tenantName,
    super.invoiceNumber,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      receiptNumber: map['receipt_number'] as String,
      invoiceId: map['invoice_id'] as String,
      tenantId: map['tenant_id'] as String,
      contractId: map['contract_id'] as String,
      amount: (map['amount'] as int?) ?? 0,
      paymentDate: map['payment_date'] as String,
      paymentMethod: map['payment_method'] as String,
      referenceNumber: map['reference_number'] as String?,
      notes: map['notes'] as String?,
      isReversed: (map['is_reversed'] as int?) == 1,
      reverseReason: map['reverse_reason'] as String?,
      reversedAt: map['reversed_at'] as String?,
      createdAt: map['created_at'] as String,
      tenantName: map['tenant_name'] as String?,
      invoiceNumber: map['invoice_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_number': receiptNumber,
      'invoice_id': invoiceId,
      'tenant_id': tenantId,
      'contract_id': contractId,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'notes': notes,
      'is_reversed': isReversed ? 1 : 0,
      'reverse_reason': reverseReason,
      'reversed_at': reversedAt,
      'created_at': createdAt,
    };
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      receiptNumber: entity.receiptNumber,
      invoiceId: entity.invoiceId,
      tenantId: entity.tenantId,
      contractId: entity.contractId,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      paymentMethod: entity.paymentMethod,
      referenceNumber: entity.referenceNumber,
      notes: entity.notes,
      isReversed: entity.isReversed,
      reverseReason: entity.reverseReason,
      reversedAt: entity.reversedAt,
      createdAt: entity.createdAt,
      tenantName: entity.tenantName,
      invoiceNumber: entity.invoiceNumber,
    );
  }
}
