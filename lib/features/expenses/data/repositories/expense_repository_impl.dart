import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl(this._localDataSource);

  @override
  Future<List<ExpenseEntity>> getExpenses(
      {String? propertyId, String? tenantId}) async {
    return await _localDataSource.getExpenses(
        propertyId: propertyId, tenantId: tenantId);
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.insertExpense(model);
  }

  @override
  Future<int> getTotalExpenses({String? tenantId}) async {
    return await _localDataSource.getTotalExpenses(tenantId: tenantId);
  }
}
