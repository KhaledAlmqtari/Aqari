import '../../../contracts/domain/entities/contract_entity.dart';
import '../../../invoices/domain/entities/invoice_entity.dart';

/// DashboardStatsEntity aggregates real-time operational and financial KPIs
/// for executive decision-making.
class DashboardStatsEntity {
  final int totalProperties;
  final int totalUnits;
  final int vacantUnits;
  final int rentedUnits;
  final int activeContracts;
  final int totalTenants;

  /// Collected revenues stored in base integer currency
  final int totalCollectedRevenue;

  /// Pending unpaid invoices stored in base integer currency
  final int totalPendingReceivables;

  /// Operational expenses stored in base integer currency
  final int totalExpenses;

  /// Net Cashflow: collectedRevenue - expenses
  final int netCashflow;

  /// Percentage of occupied units (0.0 to 100.0)
  final double occupancyRate;

  final List<ContractEntity> upcomingExpiringContracts;
  final List<InvoiceEntity> recentInvoices;

  const DashboardStatsEntity({
    this.totalProperties = 0,
    this.totalUnits = 0,
    this.vacantUnits = 0,
    this.rentedUnits = 0,
    this.activeContracts = 0,
    this.totalTenants = 0,
    this.totalCollectedRevenue = 0,
    this.totalPendingReceivables = 0,
    this.totalExpenses = 0,
    this.netCashflow = 0,
    this.occupancyRate = 0.0,
    this.upcomingExpiringContracts = const [],
    this.recentInvoices = const [],
  });
}
