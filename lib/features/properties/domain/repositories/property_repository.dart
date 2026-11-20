import '../entities/property_entity.dart';

/// PropertyRepository defines the abstract contract for property operations.
abstract class PropertyRepository {
  /// Fetches all active (non-archived) properties.
  Future<List<PropertyEntity>> getProperties({bool includeArchived = false});

  /// Fetches a property by its ID.
  Future<PropertyEntity?> getPropertyById(String id);

  /// Creates a new property.
  Future<void> createProperty(PropertyEntity property);

  /// Updates an existing property.
  Future<void> updateProperty(PropertyEntity property);

  /// Archives a property (soft delete preserving historical links).
  Future<void> archiveProperty(String id);
}
