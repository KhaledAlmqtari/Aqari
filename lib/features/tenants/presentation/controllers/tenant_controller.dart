import 'package:get/get.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/usecases/tenant_usecases.dart';

/// TenantController manages tenant list queries, search, and archiving.
class TenantController extends GetxController {
  final GetTenantsUseCase _getTenantsUseCase;
  final ArchiveTenantUseCase _archiveTenantUseCase;

  TenantController(this._getTenantsUseCase, this._archiveTenantUseCase);

  final RxList<TenantEntity> tenants = <TenantEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTenants();
  }

  Future<void> loadTenants() async {
    try {
      isLoading.value = true;
      final result =
          await _getTenantsUseCase.execute(searchQuery: searchQuery.value);
      tenants.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    loadTenants();
  }

  Future<void> archiveTenant(String id) async {
    await _archiveTenantUseCase.execute(id);
    await loadTenants();
  }
}
