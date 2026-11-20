import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    super.propertyId,
    super.tenantId,
    required super.title,
    required super.category,
    required super.amount,
    required super.expenseDate,
    required super.paymentMethod,
    super.description,
    required super.createdAt,
    super.propertyName,
    super.tenantName,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String?,
      tenantId: map['tenant_id'] as String?,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as int?) ?? 0,
      expenseDate: map['expense_date'] as String,
      paymentMethod: map['payment_method'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String,
      propertyName: map['property_name'] as String?,
      tenantName: map['tenant_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'title': title,
      'category': category,
      'amount': amount,
      'expense_date': expenseDate,
      'payment_method': paymentMethod,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      propertyId: entity.propertyId,
      tenantId: entity.tenantId,
      title: entity.title,
      category: entity.category,
      amount: entity.amount,
      expenseDate: entity.expenseDate,
      paymentMethod: entity.paymentMethod,
      description: entity.description,
      createdAt: entity.createdAt,
      propertyName: entity.propertyName,
      tenantName: entity.tenantName,
    );
  }
}
