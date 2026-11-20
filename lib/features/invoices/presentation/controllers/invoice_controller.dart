import 'package:get/get.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/invoice_usecases.dart';

/// InvoiceController manages billing records, status filters, search, and KPI calculations.
class InvoiceController extends GetxController {
  final GetInvoicesUseCase _getInvoicesUseCase;
  final ApproveInvoiceUseCase _approveInvoiceUseCase;

  InvoiceController(this._getInvoicesUseCase, this._approveInvoiceUseCase);

  final RxList<InvoiceEntity> invoices = <InvoiceEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Aggregated financial metrics
  final RxInt totalBilled = 0.obs;
  final RxInt totalCollected = 0.obs;
  final RxInt totalRemaining = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;
      final result = await _getInvoicesUseCase.execute(
        statusFilter: selectedStatusFilter.value == 'all'
            ? null
            : selectedStatusFilter.value,
        searchQuery: searchQuery.value,
      );
      invoices.value = result;

      // Calculate totals
      int billed = 0;
      int collected = 0;
      int remaining = 0;
      for (final inv in result) {
        billed += inv.totalAmount;
        collected += inv.paidAmount;
        remaining += inv.remainingAmount;
      }
      totalBilled.value = billed;
      totalCollected.value = collected;
      totalRemaining.value = remaining;
    } catch (e) {
      invoices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatusFilter.value = status;
    loadInvoices();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    loadInvoices();
  }

  Future<void> approveInvoice(String id) async {
    await _approveInvoiceUseCase.execute(id);
    await loadInvoices();
  }
}
