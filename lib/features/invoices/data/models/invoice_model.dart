import '../../domain/entities/invoice_entity.dart';

/// InvoiceModel serializes and deserializes invoice records with joined metadata.
class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.contractId,
    required super.tenantId,
    required super.unitId,
    required super.propertyId,
    required super.periodStart,
    required super.periodEnd,
    required super.issueDate,
    required super.dueDate,
    required super.totalAmount,
    super.paidAmount,
    required super.remainingAmount,
    super.status,
    super.itemsJson,
    super.notes,
    required super.createdAt,
    super.tenantName,
    super.unitNumber,
    super.propertyName,
    super.contractNumber,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      contractId: map['contract_id'] as String,
      tenantId: map['tenant_id'] as String,
      unitId: map['unit_id'] as String,
      propertyId: map['property_id'] as String,
      periodStart: map['period_start'] as String,
      periodEnd: map['period_end'] as String,
      issueDate: map['issue_date'] as String,
      dueDate: map['due_date'] as String,
      totalAmount: (map['total_amount'] as int?) ?? 0,
      paidAmount: (map['paid_amount'] as int?) ?? 0,
      remainingAmount: (map['remaining_amount'] as int?) ?? 0,
      status: map['status'] as String? ?? 'pending',
      itemsJson: map['items_json'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      tenantName: map['tenant_name'] as String?,
      unitNumber: map['unit_number'] as String?,
      propertyName: map['property_name'] as String?,
      contractNumber: map['contract_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'contract_id': contractId,
      'tenant_id': tenantId,
      'unit_id': unitId,
      'property_id': propertyId,
      'period_start': periodStart,
      'period_end': periodEnd,
      'issue_date': issueDate,
      'due_date': dueDate,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'items_json': itemsJson,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      contractId: entity.contractId,
      tenantId: entity.tenantId,
      unitId: entity.unitId,
      propertyId: entity.propertyId,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      issueDate: entity.issueDate,
      dueDate: entity.dueDate,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      remainingAmount: entity.remainingAmount,
      status: entity.status,
      itemsJson: entity.itemsJson,
      notes: entity.notes,
      createdAt: entity.createdAt,
      tenantName: entity.tenantName,
      unitNumber: entity.unitNumber,
      propertyName: entity.propertyName,
      contractNumber: entity.contractNumber,
    );
  }
}
