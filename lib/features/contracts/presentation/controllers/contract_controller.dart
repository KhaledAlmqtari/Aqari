import 'package:get/get.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/usecases/contract_usecases.dart';

/// ContractController manages contract queries, status filters, renewal, and termination.
class ContractController extends GetxController {
  final GetContractsUseCase _getContractsUseCase;
  final TerminateContractUseCase _terminateContractUseCase;

  ContractController(
    this._getContractsUseCase,
    this._terminateContractUseCase,
  );

  final RxList<ContractEntity> contracts = <ContractEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadContracts();
  }

  Future<void> loadContracts() async {
    try {
      isLoading.value = true;
      final result = await _getContractsUseCase.execute(
        statusFilter: selectedStatusFilter.value == 'all'
            ? null
            : selectedStatusFilter.value,
      );
      contracts.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatusFilter.value = status;
    loadContracts();
  }

  Future<void> terminateContract({
    required String contractId,
    required String unitId,
    required String reason,
    required String date,
  }) async {
    await _terminateContractUseCase.execute(
      contractId: contractId,
      unitId: unitId,
      reason: reason,
      terminationDate: date,
    );
    await loadContracts();
  }
}
