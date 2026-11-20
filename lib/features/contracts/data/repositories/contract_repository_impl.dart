import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contract_repository.dart';
import '../datasources/contract_local_datasource.dart';
import '../models/contract_model.dart';

/// ContractRepositoryImpl implements [ContractRepository].
class ContractRepositoryImpl implements ContractRepository {
  final ContractLocalDataSource _localDataSource;

  ContractRepositoryImpl(this._localDataSource);

  @override
  Future<List<ContractEntity>> getContracts({String? statusFilter}) async {
    return await _localDataSource.getContracts(statusFilter: statusFilter);
  }

  @override
  Future<ContractEntity?> getContractById(String id) async {
    return await _localDataSource.getContractById(id);
  }

  @override
  Future<List<ContractEntity>> getContractsByTenantId(String tenantId) async {
    return await _localDataSource.getContractsByTenantId(tenantId);
  }

  @override
  Future<List<ContractEntity>> getContractsByPropertyId(
      String propertyId) async {
    return await _localDataSource.getContractsByPropertyId(propertyId);
  }

  @override
  Future<bool> hasActiveContractOnUnit(String unitId,
      {String? excludeContractId}) async {
    return await _localDataSource.hasActiveContractOnUnit(unitId,
        excludeContractId: excludeContractId);
  }

  @override
  Future<void> createContract(ContractEntity contract) async {
    final model = ContractModel.fromEntity(contract);
    await _localDataSource.insertContract(model);
  }

  @override
  Future<void> updateContract(ContractEntity contract) async {
    final model = ContractModel.fromEntity(contract);
    await _localDataSource.updateContract(model);
  }

  @override
  Future<void> renewContract({
    required ContractEntity oldContract,
    required ContractEntity newContract,
  }) async {
    final oldModel = ContractModel.fromEntity(oldContract);
    final newModel = ContractModel.fromEntity(newContract);
    await _localDataSource.renewContract(
        oldContract: oldModel, newContract: newModel);
  }

  @override
  Future<void> terminateContract({
    required String contractId,
    required String unitId,
    required String reason,
    required String terminationDate,
  }) async {
    await _localDataSource.terminateContract(
      contractId: contractId,
      unitId: unitId,
      reason: reason,
      terminationDate: terminationDate,
    );
  }
}
