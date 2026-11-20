import '../entities/unit_entity.dart';

/// UnitRepository defines data access contracts for property units.
abstract class UnitRepository {
  /// Fetches units belonging to a specific property.
  Future<List<UnitEntity>> getUnitsByPropertyId(String propertyId);

  /// Fetches all units across all properties.
  Future<List<UnitEntity>> getAllUnits({String? statusFilter});

  /// Fetches a unit by ID.
  Future<UnitEntity?> getUnitById(String id);

  /// Creates a new unit and increments the parent property's total_units count.
  Future<void> createUnit(UnitEntity unit);

  /// Updates unit attributes.
  Future<void> updateUnit(UnitEntity unit);

  /// Updates unit operational status (e.g. 'vacant' -> 'rented', 'maintenance').
  Future<void> updateUnitStatus(String unitId, String newStatus);

  /// Deletes or archives a unit.
  Future<void> deleteUnit(String id, String propertyId);
}
