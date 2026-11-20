import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository _repository;
  GetExpensesUseCase(this._repository);

  Future<List<ExpenseEntity>> execute({String? propertyId}) {
    return _repository.getExpenses(propertyId: propertyId);
  }
}

class CreateExpenseUseCase {
  final ExpenseRepository _repository;
  CreateExpenseUseCase(this._repository);

  Future<void> execute(ExpenseEntity expense) {
    if (expense.title.trim().isEmpty) {
      throw ArgumentError('Expense title cannot be empty');
    }
    if (expense.amount <= 0) {
      throw ArgumentError('Expense amount must be greater than zero');
    }
    return _repository.createExpense(expense);
  }
}
