import '../entities/contract_entity.dart';

/// ContractRepository defines data access contracts for lease contracts.
abstract class ContractRepository {
  Future<List<ContractEntity>> getContracts({String? statusFilter});
  Future<ContractEntity?> getContractById(String id);
  Future<List<ContractEntity>> getContractsByTenantId(String tenantId);
  Future<List<ContractEntity>> getContractsByPropertyId(String propertyId);
  Future<bool> hasActiveContractOnUnit(String unitId,
      {String? excludeContractId});
  Future<void> createContract(ContractEntity contract);
  Future<void> updateContract(ContractEntity contract);
  Future<void> renewContract({
    required ContractEntity oldContract,
    required ContractEntity newContract,
  });
  Future<void> terminateContract({
    required String contractId,
    required String unitId,
    required String reason,
    required String terminationDate,
  });
}
