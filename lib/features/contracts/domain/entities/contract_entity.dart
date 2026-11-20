/// ContractEntity represents a legally binding lease agreement between owner and tenant.
///
/// Enforces business rules:
/// - One active contract per unit at any given time.
/// - Stores agreed monetary amounts as Integer base units.
/// - Records payment cycle ('monthly', 'quarterly', 'semiAnnual', 'annual').
/// - Preserves historical linkages during renewal or termination.
class ContractEntity {
  final String id;
  final String contractNumber;
  final String unitId;
  final String propertyId;
  final String tenantId;
  final String startDate;
  final String endDate;

  /// Cycle: 'monthly', 'quarterly', 'semiAnnual', 'annual'
  final String paymentCycle;

  /// Monthly day of due (1 - 31)
  final int dueDay;

  /// Rent amount stored as Integer
  final int rentAmount;

  /// Deposit amount stored as Integer
  final int depositAmount;

  /// Whether rent is calculated separately or bundled with services
  final bool isRentSeparate;

  /// Status: 'draft', 'active', 'expired', 'terminated', 'cancelled'
  final String status;

  final String? terms;
  final String? previousContractId;
  final String? terminatedAt;
  final String? terminationReason;
  final String createdAt;

  // Joined display attributes for presentation convenience
  final String? tenantName;
  final String? unitNumber;
  final String? propertyName;

  const ContractEntity({
    required this.id,
    required this.contractNumber,
    required this.unitId,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    this.paymentCycle = 'monthly',
    this.dueDay = 1,
    required this.rentAmount,
    this.depositAmount = 0,
    this.isRentSeparate = true,
    this.status = 'active',
    this.terms,
    this.previousContractId,
    this.terminatedAt,
    this.terminationReason,
    required this.createdAt,
    this.tenantName,
    this.unitNumber,
    this.propertyName,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isTerminated => status.toLowerCase() == 'terminated';

  ContractEntity copyWith({
    String? id,
    String? contractNumber,
    String? unitId,
    String? propertyId,
    String? tenantId,
    String? startDate,
    String? endDate,
    String? paymentCycle,
    int? dueDay,
    int? rentAmount,
    int? depositAmount,
    bool? isRentSeparate,
    String? status,
    String? terms,
    String? previousContractId,
    String? terminatedAt,
    String? terminationReason,
    String? createdAt,
    String? tenantName,
    String? unitNumber,
    String? propertyName,
  }) {
    return ContractEntity(
      id: id ?? this.id,
      contractNumber: contractNumber ?? this.contractNumber,
      unitId: unitId ?? this.unitId,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentCycle: paymentCycle ?? this.paymentCycle,
      dueDay: dueDay ?? this.dueDay,
      rentAmount: rentAmount ?? this.rentAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      isRentSeparate: isRentSeparate ?? this.isRentSeparate,
      status: status ?? this.status,
      terms: terms ?? this.terms,
      previousContractId: previousContractId ?? this.previousContractId,
      terminatedAt: terminatedAt ?? this.terminatedAt,
      terminationReason: terminationReason ?? this.terminationReason,
      createdAt: createdAt ?? this.createdAt,
      tenantName: tenantName ?? this.tenantName,
      unitNumber: unitNumber ?? this.unitNumber,
      propertyName: propertyName ?? this.propertyName,
    );
  }
}
