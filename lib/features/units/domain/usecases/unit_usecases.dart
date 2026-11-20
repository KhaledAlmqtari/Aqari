import '../entities/unit_entity.dart';
import '../repositories/unit_repository.dart';

/// GetUnitsByPropertyUseCase retrieves units belonging to a property.
class GetUnitsByPropertyUseCase {
  final UnitRepository _repository;

  GetUnitsByPropertyUseCase(this._repository);

  Future<List<UnitEntity>> execute(String propertyId) {
    return _repository.getUnitsByPropertyId(propertyId);
  }
}

/// GetAllUnitsUseCase retrieves all units across the portfolio.
class GetAllUnitsUseCase {
  final UnitRepository _repository;

  GetAllUnitsUseCase(this._repository);

  Future<List<UnitEntity>> execute({String? statusFilter}) {
    return _repository.getAllUnits(statusFilter: statusFilter);
  }
}

/// CreateUnitUseCase validates and creates a unit.
class CreateUnitUseCase {
  final UnitRepository _repository;

  CreateUnitUseCase(this._repository);

  Future<void> execute(UnitEntity unit) {
    if (unit.unitNumber.trim().isEmpty) {
      throw ArgumentError('Unit number cannot be empty');
    }
    if (unit.rentAmount < 0) {
      throw ArgumentError('Rent amount cannot be negative');
    }
    return _repository.createUnit(unit);
  }
}

/// UpdateUnitUseCase validates and updates a unit.
class UpdateUnitUseCase {
  final UnitRepository _repository;

  UpdateUnitUseCase(this._repository);

  Future<void> execute(UnitEntity unit) {
    return _repository.updateUnit(unit);
  }
}

/// UpdateUnitStatusUseCase changes the unit's operational status.
class UpdateUnitStatusUseCase {
  final UnitRepository _repository;

  UpdateUnitStatusUseCase(this._repository);

  Future<void> execute(String unitId, String newStatus) {
    return _repository.updateUnitStatus(unitId, newStatus);
  }
}
