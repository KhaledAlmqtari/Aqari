import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/unit_repository.dart';
import '../datasources/unit_local_datasource.dart';
import '../models/unit_model.dart';

/// UnitRepositoryImpl implements [UnitRepository] via [UnitLocalDataSource].
class UnitRepositoryImpl implements UnitRepository {
  final UnitLocalDataSource _localDataSource;

  UnitRepositoryImpl(this._localDataSource);

  @override
  Future<List<UnitEntity>> getUnitsByPropertyId(String propertyId) async {
    return await _localDataSource.getUnitsByPropertyId(propertyId);
  }

  @override
  Future<List<UnitEntity>> getAllUnits({String? statusFilter}) async {
    return await _localDataSource.getAllUnits(statusFilter: statusFilter);
  }

  @override
  Future<UnitEntity?> getUnitById(String id) async {
    return await _localDataSource.getUnitById(id);
  }

  @override
  Future<void> createUnit(UnitEntity unit) async {
    final model = UnitModel.fromEntity(unit);
    await _localDataSource.insertUnit(model);
  }

  @override
  Future<void> updateUnit(UnitEntity unit) async {
    final model = UnitModel.fromEntity(unit);
    await _localDataSource.updateUnit(model);
  }

  @override
  Future<void> updateUnitStatus(String unitId, String newStatus) async {
    await _localDataSource.updateUnitStatus(unitId, newStatus);
  }

  @override
  Future<void> deleteUnit(String id, String propertyId) async {
    await _localDataSource.deleteUnit(id, propertyId);
  }
}
