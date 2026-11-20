import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses(
      {String? propertyId, String? tenantId});
  Future<void> createExpense(ExpenseEntity expense);
  Future<int> getTotalExpenses({String? tenantId});
}
