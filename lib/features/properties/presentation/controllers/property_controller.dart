import 'package:get/get.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/usecases/property_usecases.dart';

/// PropertyController handles state management for properties listing and actions.
class PropertyController extends GetxController {
  final GetPropertiesUseCase _getPropertiesUseCase;
  final ArchivePropertyUseCase _archivePropertyUseCase;

  PropertyController(
    this._getPropertiesUseCase,
    this._archivePropertyUseCase,
  );

  final RxList<PropertyEntity> properties = <PropertyEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      isLoading.value = true;
      final result = await _getPropertiesUseCase.execute();
      properties.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  List<PropertyEntity> get filteredProperties {
    if (searchQuery.value.trim().isEmpty) return properties;
    return properties.where((p) {
      final q = searchQuery.value.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.city?.toLowerCase().contains(q) ?? false) ||
          (p.address?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> archiveProperty(String id) async {
    await _archivePropertyUseCase.execute(id);
    await loadProperties();
  }
}
