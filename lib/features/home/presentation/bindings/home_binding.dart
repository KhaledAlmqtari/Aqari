import 'package:get/get.dart';
import '../../../../core/storage/database_service.dart';

// Properties
import '../../../properties/data/datasources/property_local_datasource.dart';
import '../../../properties/data/repositories/property_repository_impl.dart';
import '../../../properties/domain/repositories/property_repository.dart';
import '../../../properties/domain/usecases/property_usecases.dart';
import '../../../properties/presentation/controllers/property_controller.dart';

// Units
import '../../../units/data/datasources/unit_local_datasource.dart';
import '../../../units/data/repositories/unit_repository_impl.dart';
import '../../../units/domain/repositories/unit_repository.dart';
import '../../../units/domain/usecases/unit_usecases.dart';

// Tenants
import '../../../tenants/data/datasources/tenant_local_datasource.dart';
import '../../../tenants/data/repositories/tenant_repository_impl.dart';
import '../../../tenants/domain/repositories/tenant_repository.dart';
import '../../../tenants/domain/usecases/tenant_usecases.dart';
import '../../../tenants/presentation/controllers/tenant_controller.dart';

// Contracts
import '../../../contracts/data/datasources/contract_local_datasource.dart';
import '../../../contracts/data/repositories/contract_repository_impl.dart';
import '../../../contracts/domain/repositories/contract_repository.dart';
import '../../../contracts/domain/usecases/contract_usecases.dart';
import '../../../contracts/presentation/controllers/contract_controller.dart';

// Invoices
import '../../../invoices/data/datasources/invoice_local_datasource.dart';
import '../../../invoices/data/repositories/invoice_repository_impl.dart';
import '../../../invoices/domain/repositories/invoice_repository.dart';
import '../../../invoices/domain/usecases/invoice_usecases.dart';
import '../../../invoices/presentation/controllers/invoice_controller.dart';

// Payments
import '../../../payments/data/datasources/payment_local_datasource.dart';
import '../../../payments/data/repositories/payment_repository_impl.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../../../payments/domain/usecases/payment_usecases.dart';

// Expenses
import '../../../expenses/data/datasources/expense_local_datasource.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/domain/usecases/expense_usecases.dart';

// Dashboard
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../controllers/home_controller.dart';

/// HomeBinding provides dependency injection for all core real estate management modules.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final dbService = Get.find<DatabaseService>();

    // --- Data Sources ---
    final propertyDataSource = PropertyLocalDataSource(dbService);
    final unitDataSource = UnitLocalDataSource(dbService);
    final tenantDataSource = TenantLocalDataSource(dbService);
    final contractDataSource = ContractLocalDataSource(dbService);
    final invoiceDataSource = InvoiceLocalDataSource(dbService);
    final paymentDataSource = PaymentLocalDataSource(dbService);
    final expenseDataSource = ExpenseLocalDataSource(dbService);
    final dashboardDataSource = DashboardLocalDataSource(dbService);

    // --- Repositories ---
    final PropertyRepository propertyRepository =
        PropertyRepositoryImpl(propertyDataSource);
    final UnitRepository unitRepository = UnitRepositoryImpl(unitDataSource);
    final TenantRepository tenantRepository =
        TenantRepositoryImpl(tenantDataSource);
    final ContractRepository contractRepository =
        ContractRepositoryImpl(contractDataSource);
    final InvoiceRepository invoiceRepository =
        InvoiceRepositoryImpl(invoiceDataSource);
    final PaymentRepository paymentRepository =
        PaymentRepositoryImpl(paymentDataSource);
    final ExpenseRepository expenseRepository =
        ExpenseRepositoryImpl(expenseDataSource);
    final DashboardRepository dashboardRepository =
        DashboardRepositoryImpl(dashboardDataSource);

    Get.lazyPut<PropertyRepository>(() => propertyRepository, fenix: true);
    Get.lazyPut<UnitRepository>(() => unitRepository, fenix: true);
    Get.lazyPut<TenantRepository>(() => tenantRepository, fenix: true);
    Get.lazyPut<ContractRepository>(() => contractRepository, fenix: true);
    Get.lazyPut<InvoiceRepository>(() => invoiceRepository, fenix: true);
    Get.lazyPut<PaymentRepository>(() => paymentRepository, fenix: true);
    Get.lazyPut<ExpenseRepository>(() => expenseRepository, fenix: true);
    Get.lazyPut<DashboardRepository>(() => dashboardRepository, fenix: true);

    // --- Use Cases ---
    // Properties
    Get.lazyPut(() => GetPropertiesUseCase(propertyRepository), fenix: true);
    Get.lazyPut(() => CreatePropertyUseCase(propertyRepository), fenix: true);
    Get.lazyPut(() => UpdatePropertyUseCase(propertyRepository), fenix: true);
    Get.lazyPut(() => ArchivePropertyUseCase(propertyRepository), fenix: true);

    // Units
    Get.lazyPut(() => GetUnitsByPropertyUseCase(unitRepository), fenix: true);
    Get.lazyPut(() => GetAllUnitsUseCase(unitRepository), fenix: true);
    Get.lazyPut(() => CreateUnitUseCase(unitRepository), fenix: true);
    Get.lazyPut(() => UpdateUnitUseCase(unitRepository), fenix: true);
    Get.lazyPut(() => UpdateUnitStatusUseCase(unitRepository), fenix: true);

    // Tenants
    Get.lazyPut(() => GetTenantsUseCase(tenantRepository), fenix: true);
    Get.lazyPut(() => CreateTenantUseCase(tenantRepository), fenix: true);
    Get.lazyPut(() => UpdateTenantUseCase(tenantRepository), fenix: true);
    Get.lazyPut(() => ArchiveTenantUseCase(tenantRepository), fenix: true);

    // Contracts
    Get.lazyPut(() => GetContractsUseCase(contractRepository), fenix: true);
    Get.lazyPut(() => CreateContractUseCase(contractRepository), fenix: true);
    Get.lazyPut(() => RenewContractUseCase(contractRepository), fenix: true);
    Get.lazyPut(() => TerminateContractUseCase(contractRepository),
        fenix: true);

    // Invoices
    Get.lazyPut(() => GetInvoicesUseCase(invoiceRepository), fenix: true);
    Get.lazyPut(() => CreateInvoiceUseCase(invoiceRepository), fenix: true);
    Get.lazyPut(() => ApproveInvoiceUseCase(invoiceRepository), fenix: true);

    // Payments
    Get.lazyPut(() => GetPaymentsUseCase(paymentRepository), fenix: true);
    Get.lazyPut(() => RecordPaymentUseCase(paymentRepository), fenix: true);
    Get.lazyPut(() => ReversePaymentUseCase(paymentRepository), fenix: true);

    // Expenses
    Get.lazyPut(() => GetExpensesUseCase(expenseRepository), fenix: true);
    Get.lazyPut(() => CreateExpenseUseCase(expenseRepository), fenix: true);

    // Dashboard
    final getDashboardStatsUseCase =
        GetDashboardStatsUseCase(dashboardRepository);
    Get.lazyPut(() => getDashboardStatsUseCase, fenix: true);

    // --- Controllers ---
    Get.lazyPut(() => HomeController(getDashboardStatsUseCase), fenix: true);
    Get.lazyPut(
      () => PropertyController(
        Get.find<GetPropertiesUseCase>(),
        Get.find<ArchivePropertyUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => TenantController(
        Get.find<GetTenantsUseCase>(),
        Get.find<ArchiveTenantUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => ContractController(
        Get.find<GetContractsUseCase>(),
        Get.find<TerminateContractUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => InvoiceController(
        Get.find<GetInvoicesUseCase>(),
        Get.find<ApproveInvoiceUseCase>(),
      ),
      fenix: true,
    );
  }
}
