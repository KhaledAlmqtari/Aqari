import '../entities/dashboard_stats_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository _repository;
  GetDashboardStatsUseCase(this._repository);

  Future<DashboardStatsEntity> execute() {
    return _repository.getDashboardStats();
  }
}
