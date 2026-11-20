import '../entities/tenant_entity.dart';

/// TenantRepository defines data access contracts for tenants.
abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants(
      {bool includeArchived = false, String? searchQuery});
  Future<TenantEntity?> getTenantById(String id);
  Future<void> createTenant(TenantEntity tenant);
  Future<void> updateTenant(TenantEntity tenant);
  Future<void> archiveTenant(String id);
}
