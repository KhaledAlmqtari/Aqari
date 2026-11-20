import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_local_datasource.dart';
import '../models/property_model.dart';

/// PropertyRepositoryImpl implements [PropertyRepository] using local SQLite data source.
class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyLocalDataSource _localDataSource;

  PropertyRepositoryImpl(this._localDataSource);

  @override
  Future<List<PropertyEntity>> getProperties(
      {bool includeArchived = false}) async {
    return await _localDataSource.getProperties(
        includeArchived: includeArchived);
  }

  @override
  Future<PropertyEntity?> getPropertyById(String id) async {
    return await _localDataSource.getPropertyById(id);
  }

  @override
  Future<void> createProperty(PropertyEntity property) async {
    final model = PropertyModel.fromEntity(property);
    await _localDataSource.insertProperty(model);
  }

  @override
  Future<void> updateProperty(PropertyEntity property) async {
    final model = PropertyModel.fromEntity(property);
    await _localDataSource.updateProperty(model);
  }

  @override
  Future<void> archiveProperty(String id) async {
    await _localDataSource.archiveProperty(id);
  }
}
