/// PaymentEntity represents an official payment receipt collected against an invoice.
///
/// Enforces financial integrity:
/// - Payment amount cannot exceed the invoice's remaining balance.
/// - Once approved, payments are never deleted permanently; they are reversed with a logged reason.
/// - Stores payment method ('cash', 'bankTransfer', 'eWallet', 'cheque', 'other').
class PaymentEntity {
  final String id;
  final String receiptNumber;
  final String invoiceId;
  final String tenantId;
  final String contractId;

  /// Collected amount stored as Integer in base currency units
  final int amount;

  final String paymentDate;

  /// Payment method: 'cash', 'bankTransfer', 'eWallet', 'cheque', 'other'
  final String paymentMethod;

  final String? referenceNumber;
  final String? notes;

  /// Whether this payment was cancelled/reversed
  final bool isReversed;

  final String? reverseReason;
  final String? reversedAt;
  final String createdAt;

  // Joined display attributes
  final String? tenantName;
  final String? invoiceNumber;

  const PaymentEntity({
    required this.id,
    required this.receiptNumber,
    required this.invoiceId,
    required this.tenantId,
    required this.contractId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.isReversed = false,
    this.reverseReason,
    this.reversedAt,
    required this.createdAt,
    this.tenantName,
    this.invoiceNumber,
  });

  PaymentEntity copyWith({
    String? id,
    String? receiptNumber,
    String? invoiceId,
    String? tenantId,
    String? contractId,
    int? amount,
    String? paymentDate,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    bool? isReversed,
    String? reverseReason,
    String? reversedAt,
    String? createdAt,
    String? tenantName,
    String? invoiceNumber,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      tenantId: tenantId ?? this.tenantId,
      contractId: contractId ?? this.contractId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      isReversed: isReversed ?? this.isReversed,
      reverseReason: reverseReason ?? this.reverseReason,
      reversedAt: reversedAt ?? this.reversedAt,
      createdAt: createdAt ?? this.createdAt,
      tenantName: tenantName ?? this.tenantName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }
}
