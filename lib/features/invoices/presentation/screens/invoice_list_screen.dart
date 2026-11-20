import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/invoice_controller.dart';
import '../widgets/invoice_card.dart';
import 'invoice_detail_screen.dart';
import 'invoice_form_screen.dart';

/// InvoiceListScreen displays the complete billing management console:
/// - Financial KPI summary cards
/// - Search and status filters
/// - Interactive invoice list
/// - Creation button to issue new claims
class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvoiceController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text('invoices'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'new_invoice'.tr,
            onPressed: () async {
              final res = await Get.to(() => const InvoiceFormScreen());
              if (res == true) controller.loadInvoices();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Top Financial KPI Summary Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(
              () => Row(
                children: [
                  _buildSummaryBadge(
                    context,
                    label: 'total_amount'.tr,
                    value: MoneyUtils.format(controller.totalBilled.value,
                        isArabic: isArabic),
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryBadge(
                    context,
                    label: 'paid_amount'.tr,
                    value: MoneyUtils.format(controller.totalCollected.value,
                        isArabic: isArabic),
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryBadge(
                    context,
                    label: 'remaining_amount'.tr,
                    value: MoneyUtils.format(controller.totalRemaining.value,
                        isArabic: isArabic),
                    color: controller.totalRemaining.value > 0
                        ? AppColors.error
                        : AppColors.secondary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // 2. Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: CustomTextField(
              label: 'search'.tr,
              prefixIcon: Icons.search,
              onChanged: controller.onSearchChanged,
            ),
          ),

          // 3. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterChip('all', controller),
                  _buildFilterChip('pending', controller),
                  _buildFilterChip('paid', controller),
                  _buildFilterChip('partiallyPaid', controller,
                      label: 'partially_paid'.tr),
                  _buildFilterChip('overdue', controller),
                  _buildFilterChip('draft', controller),
                ],
              ),
            ),
          ),

          // 4. Invoices List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.invoices.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'no_invoices'.tr,
                  message: 'invoices_list'.tr,
                  buttonText: 'new_invoice'.tr,
                  onButtonPressed: () async {
                    final res = await Get.to(() => const InvoiceFormScreen());
                    if (res == true) controller.loadInvoices();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadInvoices,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.invoices.length,
                  itemBuilder: (ctx, index) {
                    final invoice = controller.invoices[index];
                    return InvoiceCard(
                      invoice: invoice,
                      onTap: () async {
                        final res = await Get.to(
                            () => InvoiceDetailScreen(invoiceId: invoice.id));
                        if (res == true) controller.loadInvoices();
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Get.to(() => const InvoiceFormScreen());
          if (res == true) controller.loadInvoices();
        },
        icon: const Icon(Icons.add),
        label: Text('new_invoice'.tr),
      ),
    );
  }

  Widget _buildSummaryBadge(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, InvoiceController controller,
      {String? label}) {
    final isSelected = controller.selectedStatusFilter.value == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label ?? status.tr),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        onSelected: (_) => controller.filterByStatus(status),
      ),
    );
  }
}
