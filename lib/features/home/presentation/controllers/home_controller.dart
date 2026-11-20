import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../tenants/domain/entities/tenant_entity.dart';
import '../../../tenants/domain/repositories/tenant_repository.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../invoices/domain/entities/invoice_entity.dart';
import '../../../invoices/domain/repositories/invoice_repository.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

/// HomeController manages the state of the Executive Dashboard, bottom navigation,
/// owner profile name, and system-level actions.
class HomeController extends GetxController {
  final GetDashboardStatsUseCase _getDashboardStatsUseCase;

  HomeController(this._getDashboardStatsUseCase);

  ThemeController get themeController => Get.find();
  LocaleController get localeController => Get.find();

  /// Active bottom navigation tab index (0: Dashboard, 1: Properties, 2: Hub, 3: Tenants, 4: Settings)
  final RxInt currentTabIndex = 0.obs;

  /// Observable loading state
  final RxBool isLoading = true.obs;

  /// Observable dashboard analytics entity
  final Rx<DashboardStatsEntity> stats = const DashboardStatsEntity().obs;

  /// Selected system currency (default: 'YER', supported: 'YER', 'SAR', 'USD')
  final RxString selectedCurrency = 'YER'.obs;

  /// Owner name retrieved from persistent storage
  final RxString ownerName = ''.obs;

  /// Active carousel card index (0: Total Portfolio, 1: Expenses, 2: Invoices)
  final RxInt activeCarouselIndex = 0.obs;

  /// All active tenants for filters
  final RxList<TenantEntity> tenantsList = <TenantEntity>[].obs;

  /// All expenses for tenant breakdown
  final RxList<ExpenseEntity> allExpenses = <ExpenseEntity>[].obs;

  /// All invoices for tenant payment breakdown
  final RxList<InvoiceEntity> allInvoices = <InvoiceEntity>[].obs;

  /// Selected tenant ID for Card 2 (Expenses) - null means all tenants
  final Rx<String?> selectedExpenseTenantId = Rx<String?>(null);

  /// Selected tenant ID for Card 3 (Invoices / Payment status)
  final Rx<String?> selectedInvoiceTenantId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadOwnerName();
    loadDashboardData();
  }

  /// Loads the saved owner name from SharedPreferences
  void loadOwnerName() {
    try {
      final prefs = Get.find<SharedPreferences>();
      final name = prefs.getString(AppConstants.userNameKey);
      if (name != null && name.trim().isNotEmpty) {
        ownerName.value = name.trim();
      } else {
        ownerName.value = 'المالك';
      }
    } catch (_) {
      ownerName.value = 'المالك';
    }
  }

  /// Updates owner name across app state and SharedPreferences
  Future<void> updateOwnerName(String newName) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString(AppConstants.userNameKey, newName.trim());
      ownerName.value = newName.trim();
    } catch (_) {}
  }

  /// Loads real-time aggregated metrics and datasets from local database
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final result = await _getDashboardStatsUseCase.execute();
      stats.value = result;

      // Load tenants list
      try {
        final tenantRepo = Get.find<TenantRepository>();
        tenantsList.value = await tenantRepo.getTenants();
        if (selectedInvoiceTenantId.value == null && tenantsList.isNotEmpty) {
          selectedInvoiceTenantId.value = tenantsList.first.id;
        }
      } catch (_) {}

      // Load all expenses
      try {
        final expRepo = Get.find<ExpenseRepository>();
        allExpenses.value = await expRepo.getExpenses();
      } catch (_) {}

      // Load all invoices
      try {
        final invRepo = Get.find<InvoiceRepository>();
        allInvoices.value = await invRepo.getInvoices();
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  // --- Card 1 Calculations (Portfolio Inflow Summary) ---
  int get totalExpectedRevenue =>
      stats.value.totalCollectedRevenue + stats.value.totalPendingReceivables;

  String get collectionRatePercentage {
    if (totalExpectedRevenue <= 0) return '100%';
    final rate =
        (stats.value.totalCollectedRevenue / totalExpectedRevenue) * 100;
    return '${rate.toStringAsFixed(0)}%';
  }

  // --- Card 2 Calculations (Expenses & Tenant Filter) ---
  void selectExpenseTenant(String? tenantId) {
    selectedExpenseTenantId.value = tenantId;
  }

  int get filteredExpensesTotal {
    if (selectedExpenseTenantId.value == null) {
      if (allExpenses.isNotEmpty) {
        return allExpenses.fold(0, (sum, e) => sum + e.amount);
      }
      return stats.value.totalExpenses;
    }
    return allExpenses
        .where((e) => e.tenantId == selectedExpenseTenantId.value)
        .fold(0, (sum, e) => sum + e.amount);
  }

  int get filteredExpensesCount {
    if (selectedExpenseTenantId.value == null) {
      return allExpenses.length;
    }
    return allExpenses
        .where((e) => e.tenantId == selectedExpenseTenantId.value)
        .length;
  }

  String get selectedExpenseTenantName {
    if (selectedExpenseTenantId.value == null) {
      return 'جميع المستأجرين';
    }
    final tenant = tenantsList.firstWhereOrNull(
      (t) => t.id == selectedExpenseTenantId.value,
    );
    return tenant?.fullName ?? 'مستأجر محدد';
  }

  // --- Card 3 Calculations (Tenant Invoices & Payment Status) ---
  void selectInvoiceTenant(String? tenantId) {
    selectedInvoiceTenantId.value = tenantId;
  }

  String get activeInvoiceTenantId {
    if (selectedInvoiceTenantId.value != null &&
        selectedInvoiceTenantId.value!.isNotEmpty) {
      return selectedInvoiceTenantId.value!;
    }
    if (tenantsList.isNotEmpty) {
      return tenantsList.first.id;
    }
    return '';
  }

  String get selectedInvoiceTenantName {
    final activeId = activeInvoiceTenantId;
    if (activeId.isEmpty) return 'لا يوجد مستأجرين';
    final tenant = tenantsList.firstWhereOrNull((t) => t.id == activeId);
    return tenant?.fullName ?? 'مستأجر غير معروف';
  }

  List<InvoiceEntity> get activeTenantInvoices {
    final activeId = activeInvoiceTenantId;
    if (activeId.isEmpty) return [];
    return allInvoices.where((inv) => inv.tenantId == activeId).toList();
  }

  int get tenantPaidAmount {
    return activeTenantInvoices.fold(0, (sum, inv) => sum + inv.paidAmount);
  }

  int get tenantRemainingAmount {
    return activeTenantInvoices.fold(
        0, (sum, inv) => sum + inv.remainingAmount);
  }

  int get tenantTotalInvoiced {
    return activeTenantInvoices.fold(0, (sum, inv) => sum + inv.totalAmount);
  }

  /// Payment status: 'paid_full', 'installment', 'pending', 'no_invoices'
  String get tenantPaymentStatusKey {
    final invs = activeTenantInvoices;
    if (invs.isEmpty) return 'no_invoices';
    if (tenantRemainingAmount == 0 && tenantPaidAmount > 0) return 'paid_full';
    if (tenantPaidAmount > 0 && tenantRemainingAmount > 0) return 'installment';
    return 'pending';
  }

  String get tenantPaymentStatusLabel {
    final key = tenantPaymentStatusKey;
    switch (key) {
      case 'paid_full':
        return 'مسدد بالكامل ✓';
      case 'installment':
        return 'سداد بالتقسيط / جزئي ⏳';
      case 'pending':
        return 'معلق / غير مسدد ✕';
      default:
        return 'لا توجد فواتير';
    }
  }

  /// Selected sub-tab in Contracts & Finance hub (0: contracts, 1: invoices, 2: expenses)
  final RxInt contractsHubInitialTab = 0.obs;

  /// Changes the bottom navigation tab index
  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 0) {
      loadDashboardData();
    }
  }

  void navigateToContracts() {
    contractsHubInitialTab.value = 0;
    changeTab(2);
  }

  void navigateToInvoices() {
    contractsHubInitialTab.value = 1;
    changeTab(2);
  }

  /// Updates application currency setting
  void setCurrency(String currencyCode) {
    selectedCurrency.value = currencyCode;
  }

  /// Locks the app and redirects to PIN verification screen
  Future<void> lockApplication() async {
    Get.offAllNamed(
      AppRoutes.pin,
      arguments: {'mode': 'verify'},
    );
  }

  /// Logs out the user and navigates back to PIN screen
  Future<void> logout() async {
    Get.offAllNamed(AppRoutes.pin);
  }

  /// Changes application language
  Future<void> setLanguage(String code) {
    return localeController.changeLanguage(code);
  }
}
