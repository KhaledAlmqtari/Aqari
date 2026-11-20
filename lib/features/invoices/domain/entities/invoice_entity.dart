/// InvoiceEntity represents a billing claim generated for a contract period.
///
/// Follows financial rules:
/// - Amounts stored as Integer base currency units.
/// - Stores a snapshot of items at time of issuance.
/// - Status transitions: draft -> pending -> partiallyPaid -> paid (or overdue).
class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final String contractId;
  final String tenantId;
  final String unitId;
  final String propertyId;
  final String periodStart;
  final String periodEnd;
  final String issueDate;
  final String dueDate;

  /// Total billed amount stored as Integer
  final int totalAmount;

  /// Collected amount stored as Integer
  final int paidAmount;

  /// Remaining balance stored as Integer (totalAmount - paidAmount)
  final int remainingAmount;

  /// Status: 'draft', 'pending', 'partiallyPaid', 'paid', 'overdue', 'cancelled'
  final String status;

  /// JSON snapshot of itemized charges
  final String? itemsJson;

  final String? notes;
  final String createdAt;

  // Joined display attributes
  final String? tenantName;
  final String? unitNumber;
  final String? propertyName;
  final String? contractNumber;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.contractId,
    required this.tenantId,
    required this.unitId,
    required this.propertyId,
    required this.periodStart,
    required this.periodEnd,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    this.status = 'pending',
    this.itemsJson,
    this.notes,
    required this.createdAt,
    this.tenantName,
    this.unitNumber,
    this.propertyName,
    this.contractNumber,
  });

  bool get isPaid => remainingAmount <= 0;
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isPending => status.toLowerCase() == 'pending';

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? contractId,
    String? tenantId,
    String? unitId,
    String? propertyId,
    String? periodStart,
    String? periodEnd,
    String? issueDate,
    String? dueDate,
    int? totalAmount,
    int? paidAmount,
    int? remainingAmount,
    String? status,
    String? itemsJson,
    String? notes,
    String? createdAt,
    String? tenantName,
    String? unitNumber,
    String? propertyName,
    String? contractNumber,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      contractId: contractId ?? this.contractId,
      tenantId: tenantId ?? this.tenantId,
      unitId: unitId ?? this.unitId,
      propertyId: propertyId ?? this.propertyId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      itemsJson: itemsJson ?? this.itemsJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      tenantName: tenantName ?? this.tenantName,
      unitNumber: unitNumber ?? this.unitNumber,
      propertyName: propertyName ?? this.propertyName,
      contractNumber: contractNumber ?? this.contractNumber,
    );
  }
}
