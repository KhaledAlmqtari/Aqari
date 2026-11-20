import '../entities/property_entity.dart';
import '../repositories/property_repository.dart';

/// GetPropertiesUseCase encapsulates retrieval of property assets.
class GetPropertiesUseCase {
  final PropertyRepository _repository;

  GetPropertiesUseCase(this._repository);

  Future<List<PropertyEntity>> execute({bool includeArchived = false}) {
    return _repository.getProperties(includeArchived: includeArchived);
  }
}

/// CreatePropertyUseCase encapsulates creation and business validation for properties.
class CreatePropertyUseCase {
  final PropertyRepository _repository;

  CreatePropertyUseCase(this._repository);

  Future<void> execute(PropertyEntity property) {
    if (property.name.trim().isEmpty) {
      throw ArgumentError('Property name cannot be empty');
    }
    return _repository.createProperty(property);
  }
}

/// UpdatePropertyUseCase encapsulates modification of property details.
class UpdatePropertyUseCase {
  final PropertyRepository _repository;

  UpdatePropertyUseCase(this._repository);

  Future<void> execute(PropertyEntity property) {
    return _repository.updateProperty(property);
  }
}

/// ArchivePropertyUseCase encapsulates soft archiving of properties.
class ArchivePropertyUseCase {
  final PropertyRepository _repository;

  ArchivePropertyUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.archiveProperty(id);
  }
}
