import '../entities/contract_entity.dart';
import '../repositories/contract_repository.dart';

class GetContractsUseCase {
  final ContractRepository _repository;
  GetContractsUseCase(this._repository);

  Future<List<ContractEntity>> execute({String? statusFilter}) {
    return _repository.getContracts(statusFilter: statusFilter);
  }
}

class CreateContractUseCase {
  final ContractRepository _repository;
  CreateContractUseCase(this._repository);

  Future<void> execute(ContractEntity contract) async {
    // Business Rule 3: Check that there are no overlapping active contracts on the unit
    final hasActive =
        await _repository.hasActiveContractOnUnit(contract.unitId);
    if (hasActive && contract.isActive) {
      throw StateError('unit_already_rented');
    }
    await _repository.createContract(contract);
  }
}

class RenewContractUseCase {
  final ContractRepository _repository;
  RenewContractUseCase(this._repository);

  Future<void> execute({
    required ContractEntity oldContract,
    required ContractEntity newContract,
  }) async {
    await _repository.renewContract(
      oldContract: oldContract,
      newContract: newContract,
    );
  }
}

class TerminateContractUseCase {
  final ContractRepository _repository;
  TerminateContractUseCase(this._repository);

  Future<void> execute({
    required String contractId,
    required String unitId,
    required String reason,
    required String terminationDate,
  }) async {
    await _repository.terminateContract(
      contractId: contractId,
      unitId: unitId,
      reason: reason,
      terminationDate: terminationDate,
    );
  }
}
