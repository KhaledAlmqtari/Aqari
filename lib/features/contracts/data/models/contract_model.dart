import '../../domain/entities/contract_entity.dart';

/// ContractModel serializes contract records with joined unit, property, and tenant metadata.
class ContractModel extends ContractEntity {
  const ContractModel({
    required super.id,
    required super.contractNumber,
    required super.unitId,
    required super.propertyId,
    required super.tenantId,
    required super.startDate,
    required super.endDate,
    super.paymentCycle,
    super.dueDay,
    required super.rentAmount,
    super.depositAmount,
    super.isRentSeparate,
    super.status,
    super.terms,
    super.previousContractId,
    super.terminatedAt,
    super.terminationReason,
    required super.createdAt,
    super.tenantName,
    super.unitNumber,
    super.propertyName,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] as String,
      contractNumber: map['contract_number'] as String,
      unitId: map['unit_id'] as String,
      propertyId: map['property_id'] as String,
      tenantId: map['tenant_id'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      paymentCycle: map['payment_cycle'] as String? ?? 'monthly',
      dueDay: (map['due_day'] as int?) ?? 1,
      rentAmount: (map['rent_amount'] as int?) ?? 0,
      depositAmount: (map['deposit_amount'] as int?) ?? 0,
      isRentSeparate: (map['is_rent_separate'] as int?) != 0,
      status: map['status'] as String? ?? 'active',
      terms: map['terms'] as String?,
      previousContractId: map['previous_contract_id'] as String?,
      terminatedAt: map['terminated_at'] as String?,
      terminationReason: map['termination_reason'] as String?,
      createdAt: map['created_at'] as String,
      tenantName: map['tenant_name'] as String?,
      unitNumber: map['unit_number'] as String?,
      propertyName: map['property_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contract_number': contractNumber,
      'unit_id': unitId,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'start_date': startDate,
      'end_date': endDate,
      'payment_cycle': paymentCycle,
      'due_day': dueDay,
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
      'is_rent_separate': isRentSeparate ? 1 : 0,
      'status': status,
      'terms': terms,
      'previous_contract_id': previousContractId,
      'terminated_at': terminatedAt,
      'termination_reason': terminationReason,
      'created_at': createdAt,
    };
  }

  factory ContractModel.fromEntity(ContractEntity entity) {
    return ContractModel(
      id: entity.id,
      contractNumber: entity.contractNumber,
      unitId: entity.unitId,
      propertyId: entity.propertyId,
      tenantId: entity.tenantId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      paymentCycle: entity.paymentCycle,
      dueDay: entity.dueDay,
      rentAmount: entity.rentAmount,
      depositAmount: entity.depositAmount,
      isRentSeparate: entity.isRentSeparate,
      status: entity.status,
      terms: entity.terms,
      previousContractId: entity.previousContractId,
      terminatedAt: entity.terminatedAt,
      terminationReason: entity.terminationReason,
      createdAt: entity.createdAt,
      tenantName: entity.tenantName,
      unitNumber: entity.unitNumber,
      propertyName: entity.propertyName,
    );
  }
}
