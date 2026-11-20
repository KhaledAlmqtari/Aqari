import '../../domain/entities/tenant_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_local_datasource.dart';
import '../models/tenant_model.dart';

/// TenantRepositoryImpl implements [TenantRepository] using local SQLite data source.
class TenantRepositoryImpl implements TenantRepository {
  final TenantLocalDataSource _localDataSource;

  TenantRepositoryImpl(this._localDataSource);

  @override
  Future<List<TenantEntity>> getTenants(
      {bool includeArchived = false, String? searchQuery}) async {
    return await _localDataSource.getTenants(
        includeArchived: includeArchived, searchQuery: searchQuery);
  }

  @override
  Future<TenantEntity?> getTenantById(String id) async {
    return await _localDataSource.getTenantById(id);
  }

  @override
  Future<void> createTenant(TenantEntity tenant) async {
    final model = TenantModel.fromEntity(tenant);
    await _localDataSource.insertTenant(model);
  }

  @override
  Future<void> updateTenant(TenantEntity tenant) async {
    final model = TenantModel.fromEntity(tenant);
    await _localDataSource.updateTenant(model);
  }

  @override
  Future<void> archiveTenant(String id) async {
    await _localDataSource.archiveTenant(id);
  }
}
