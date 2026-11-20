/// ExpenseEntity represents operational expenses incurred for properties or general overhead.
class ExpenseEntity {
  final String id;
  final String? propertyId;
  final String? tenantId;
  final String title;
  final String category;
  final int amount;
  final String expenseDate;
  final String paymentMethod;
  final String? description;
  final String createdAt;

  // Joined display attributes
  final String? propertyName;
  final String? tenantName;

  const ExpenseEntity({
    required this.id,
    this.propertyId,
    this.tenantId,
    required this.title,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.paymentMethod,
    this.description,
    required this.createdAt,
    this.propertyName,
    this.tenantName,
  });

  ExpenseEntity copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? title,
    String? category,
    int? amount,
    String? expenseDate,
    String? paymentMethod,
    String? description,
    String? createdAt,
    String? propertyName,
    String? tenantName,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      propertyName: propertyName ?? this.propertyName,
      tenantName: tenantName ?? this.tenantName,
    );
  }
}
