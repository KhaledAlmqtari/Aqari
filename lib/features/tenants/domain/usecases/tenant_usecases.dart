import '../entities/tenant_entity.dart';
import '../repositories/tenant_repository.dart';

class GetTenantsUseCase {
  final TenantRepository _repository;
  GetTenantsUseCase(this._repository);

  Future<List<TenantEntity>> execute(
      {bool includeArchived = false, String? searchQuery}) {
    return _repository.getTenants(
        includeArchived: includeArchived, searchQuery: searchQuery);
  }
}

class CreateTenantUseCase {
  final TenantRepository _repository;
  CreateTenantUseCase(this._repository);

  Future<void> execute(TenantEntity tenant) {
    if (tenant.fullName.trim().isEmpty) {
      throw ArgumentError('Tenant name cannot be empty');
    }
    if (tenant.phone.trim().isEmpty) {
      throw ArgumentError('Tenant phone number cannot be empty');
    }
    return _repository.createTenant(tenant);
  }
}

class UpdateTenantUseCase {
  final TenantRepository _repository;
  UpdateTenantUseCase(this._repository);

  Future<void> execute(TenantEntity tenant) {
    return _repository.updateTenant(tenant);
  }
}

class ArchiveTenantUseCase {
  final TenantRepository _repository;
  ArchiveTenantUseCase(this._repository);

  Future<void> execute(String id) {
    // In accordance with Business Rule 5: A tenant is not deleted permanently if linked to history
    return _repository.archiveTenant(id);
  }
}
