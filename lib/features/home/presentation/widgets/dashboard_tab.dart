import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../contracts/presentation/screens/contract_detail_screen.dart';
import '../../../contracts/presentation/screens/contract_form_screen.dart';
import '../../../expenses/presentation/screens/expense_form_dialog.dart';
import '../../../invoices/presentation/screens/invoice_detail_screen.dart';
import '../../../invoices/presentation/screens/invoice_form_screen.dart';
import '../../../properties/presentation/screens/property_form_screen.dart';
import '../controllers/home_controller.dart';

/// DashboardTab renders the high-end executive overview for property owners with
/// interactive swipeable carousel cards and compact KPIs.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late final PageController _cardPageController;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    final controller = Get.find<HomeController>();
    final nextIndex = (controller.activeCarouselIndex.value + 1) % 3;
    _cardPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showTenantPickerSheet(BuildContext context,
      {required bool forExpenses}) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        forExpenses
                            ? 'تحديد المستأجر لعرض المصروفات'
                            : 'تحديد المستأجر لعرض الفواتير والسداد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (forExpenses)
                        ListTile(
                          leading: const Icon(Icons.all_inclusive,
                              color: AppColors.primary),
                          title: const Text('جميع المستأجرين (إجمالي شامل)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          trailing:
                              controller.selectedExpenseTenantId.value == null
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primary)
                                  : null,
                          onTap: () {
                            controller.selectExpenseTenant(null);
                            Navigator.pop(ctx);
                          },
                        ),
                      if (controller.tenantsList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'لا يوجد مستأجرين مسجلين حالياً',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...controller.tenantsList.map((t) {
                          final isSelected = forExpenses
                              ? controller.selectedExpenseTenantId.value == t.id
                              : controller.activeInvoiceTenantId == t.id;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.12),
                              child: Text(
                                t.fullName.isNotEmpty ? t.fullName[0] : '?',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            title: Text(t.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(t.phone,
                                style: const TextStyle(fontSize: 12)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.primary)
                                : null,
                            onTap: () {
                              if (forExpenses) {
                                controller.selectExpenseTenant(t.id);
                              } else {
                                controller.selectInvoiceTenant(t.id);
                              }
                              Navigator.pop(ctx);
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final stats = controller.stats.value;
              final currency = controller.selectedCurrency.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Personalized Header Greeting directly on screen background
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          'مرحباً، ${controller.ownerName.value.isNotEmpty ? controller.ownerName.value : 'المالك'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '👋',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Interactive Executive Carousel (3 Compact Cards)
                  SizedBox(
                    height: 168,
                    child: PageView(
                      controller: _cardPageController,
                      onPageChanged: (index) {
                        controller.activeCarouselIndex.value = index;
                      },
                      children: [
                        // Card 1: Total Portfolio & Net Inflow (Charcoal & Gold)
                        _buildPortfolioSummaryCard(
                          context: context,
                          controller: controller,
                          currency: currency,
                          isArabic: isArabic,
                          isDark: isDark,
                        ),

                        // Card 2: Operating Expenses & Tenant Filter (Royal Purple)
                        _buildExpensesCard(
                          context: context,
                          controller: controller,
                          currency: currency,
                          isArabic: isArabic,
                        ),

                        // Card 3: Invoices, Payment Status & Installments (Deep Petrol/Teal)
                        _buildInvoicesStatusCard(
                          context: context,
                          controller: controller,
                          currency: currency,
                          isArabic: isArabic,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Carousel Animated Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isSelected =
                          controller.activeCarouselIndex.value == index;
                      Color dotColor;
                      if (index == 0) {
                        dotColor = const Color(0xFFBF9B68); // Gold
                      } else if (index == 1) {
                        dotColor = const Color(0xFF7C3AED); // Purple
                      } else {
                        dotColor = const Color(0xFF0D9488); // Teal
                      }

                      return GestureDetector(
                        onTap: () {
                          _cardPageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? dotColor
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 18),

                  // 3. Quick Actions
                  Text(
                    'quick_actions'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.apartment_outlined,
                          label: 'add_property'.tr,
                          color: AppColors.primary,
                          onTap: () async {
                            final res =
                                await Get.to(() => const PropertyFormScreen());
                            if (res == true) controller.loadDashboardData();
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionButton(
                          icon: Icons.description_outlined,
                          label: 'add_contract'.tr,
                          color: AppColors.accent,
                          onTap: () async {
                            final res =
                                await Get.to(() => const ContractFormScreen());
                            if (res == true) controller.loadDashboardData();
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionButton(
                          icon: Icons.receipt_long_outlined,
                          label: 'new_invoice'.tr,
                          color: AppColors.info,
                          onTap: () async {
                            final res =
                                await Get.to(() => const InvoiceFormScreen());
                            if (res == true) controller.loadDashboardData();
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionButton(
                          icon: Icons.payments_outlined,
                          label: 'add_expense'.tr,
                          color: AppColors.error,
                          onTap: () async {
                            final res = await ExpenseFormDialog.show(context);
                            if (res == true) controller.loadDashboardData();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. Portfolio Operational KPI Grid (Compact 2x2 Sleek Cards)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.65,
                    children: [
                      KpiCard(
                        title: 'total_properties'.tr,
                        value: '${stats.totalProperties}',
                        icon: Icons.apartment,
                        color: AppColors.primary,
                        onTap: () => controller.changeTab(1),
                      ),
                      KpiCard(
                        title: 'total_units'.tr,
                        value: '${stats.totalUnits}',
                        icon: Icons.door_front_door_outlined,
                        color: AppColors.info,
                        onTap: () => controller.changeTab(1),
                      ),
                      KpiCard(
                        title: 'active_contracts'.tr,
                        value: '${stats.activeContracts}',
                        icon: Icons.assignment_outlined,
                        color: AppColors.success,
                        onTap: () => controller.navigateToContracts(),
                      ),
                      KpiCard(
                        title: 'tenants'.tr,
                        value: '${stats.totalTenants}',
                        icon: Icons.people_outline,
                        color: AppColors.secondary,
                        onTap: () => controller.changeTab(3),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 5. Upcoming Contract Expirations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'upcoming_expirations'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.navigateToContracts(),
                        child: Text('all'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (stats.upcomingExpiringContracts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                      child: Text(
                        'no_expirations'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    )
                  else
                    ...stats.upcomingExpiringContracts.map((c) {
                      final days = DateFormatterUtils.daysRemaining(
                          DateTime.parse(c.endDate));
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => Get.to(
                              () => ContractDetailScreen(contractId: c.id)),
                          leading: CircleAvatar(
                            backgroundColor: (days <= 30
                                    ? AppColors.warning
                                    : AppColors.primary)
                                .withOpacity(0.12),
                            child: Icon(
                              Icons.access_time_filled_outlined,
                              color: days <= 30
                                  ? AppColors.warning
                                  : AppColors.primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            c.tenantName ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${c.propertyName ?? ''} - ${'unit'.tr} ${c.unitNumber ?? ''}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$days ${'date'.tr}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: days <= 30
                                      ? AppColors.warning
                                      : AppColors.primary,
                                ),
                              ),
                              Text(
                                DateFormatterUtils.formatIsoDate(c.endDate),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // 6. Recent Invoices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'recent_invoices'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.navigateToInvoices(),
                        child: Text('all'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (stats.recentInvoices.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                      child: Text(
                        'no_invoices'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    )
                  else
                    ...stats.recentInvoices.map((inv) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => Get.to(
                                () => InvoiceDetailScreen(invoiceId: inv.id)),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_outlined,
                                  color: AppColors.primary, size: 18),
                            ),
                            title: Text(
                              '#${inv.invoiceNumber} - ${inv.tenantName ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${'remaining_amount'.tr}: ${MoneyUtils.format(inv.remainingAmount, currencyCode: currency, isArabic: isArabic)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: inv.remainingAmount > 0
                                    ? AppColors.error
                                    : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: StatusBadge(
                                status: inv.status, label: inv.status.tr),
                          ),
                        )),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // --- Card 1: Total Portfolio & Net Inflow (Charcoal Gray & Warm Gold) ---
  Widget _buildPortfolioSummaryCard({
    required BuildContext context,
    required HomeController controller,
    required String currency,
    required bool isArabic,
    required bool isDark,
  }) {
    final stats = controller.stats.value;

    return GestureDetector(
      onTap: _nextCard,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF22242A),
              Color(0xFF191A1E),
              Color(0xFF131417),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFBF9B68).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF9B68).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFFE2C292),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ملخص المحفظة الشامل',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF9B68).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFBF9B68).withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        currency,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE2C292),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إجمالي الإيرادات المحصلة (كافة المستأجرين)',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    MoneyUtils.format(stats.totalCollectedRevenue,
                        currencyCode: currency, isArabic: isArabic),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE2C292),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetricItem(
                  'إجمالي المطالبات',
                  MoneyUtils.format(controller.totalExpectedRevenue,
                      currencyCode: currency, isArabic: isArabic),
                  Colors.white,
                ),
                _buildCardMetricItem(
                  'المتبقي غير المحصل',
                  MoneyUtils.format(stats.totalPendingReceivables,
                      currencyCode: currency, isArabic: isArabic),
                  const Color(0xFFFCA5A5),
                ),
                _buildCardMetricItem(
                  'نسبة التحصيل',
                  controller.collectionRatePercentage,
                  const Color(0xFF34D399),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Card 2: Operating Expenses & Tenant Filter (Deep Royal Purple) ---
  Widget _buildExpensesCard({
    required BuildContext context,
    required HomeController controller,
    required String currency,
    required bool isArabic,
  }) {
    return GestureDetector(
      onTap: _nextCard,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4C1D95),
              Color(0xFF5B21B6),
              Color(0xFF6D28D9),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFA78BFA).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D28D9).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'المصروفات التشغيلية',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Tenant Selector Pill
                InkWell(
                  onTap: () =>
                      _showTenantPickerSheet(context, forExpenses: true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_pin,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 85),
                          child: Text(
                            controller.selectedExpenseTenantName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المصروفات (${controller.selectedExpenseTenantName})',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    MoneyUtils.format(controller.filteredExpensesTotal,
                        currencyCode: currency, isArabic: isArabic),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetricItem(
                  'عدد السندات',
                  '${controller.filteredExpensesCount} سند',
                  Colors.white,
                ),
                _buildCardMetricItem(
                  'المستأجر المعني',
                  controller.selectedExpenseTenantName,
                  const Color(0xFFDDD6FE),
                ),
                InkWell(
                  onTap: () async {
                    final res = await ExpenseFormDialog.show(context);
                    if (res == true) controller.loadDashboardData();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          'سند جديد',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Card 3: Invoices, Payment Status & Installments (Deep Petrol/Teal) ---
  Widget _buildInvoicesStatusCard({
    required BuildContext context,
    required HomeController controller,
    required String currency,
    required bool isArabic,
  }) {
    Color statusBgColor;
    if (controller.tenantPaymentStatusKey == 'paid_full') {
      statusBgColor = const Color(0xFF059669);
    } else if (controller.tenantPaymentStatusKey == 'installment') {
      statusBgColor = const Color(0xFFD97706);
    } else {
      statusBgColor = const Color(0xFFDC2626);
    }

    return GestureDetector(
      onTap: _nextCard,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF042F2E),
              Color(0xFF0F766E),
              Color(0xFF115E59),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2DD4BF).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F766E).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'حالة سداد المستأجر',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Tenant Selector Pill
                InkWell(
                  onTap: () =>
                      _showTenantPickerSheet(context, forExpenses: false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 85),
                          child: Text(
                            controller.selectedInvoiceTenantName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المبلغ المدفوع (كم دفع):',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      child: Text(
                        MoneyUtils.format(controller.tenantPaidAmount,
                            currencyCode: currency, isArabic: isArabic),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFCCFBF1),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    controller.tenantPaymentStatusLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetricItem(
                  'المتبقي عليه',
                  MoneyUtils.format(controller.tenantRemainingAmount,
                      currencyCode: currency, isArabic: isArabic),
                  controller.tenantRemainingAmount > 0
                      ? const Color(0xFFFCA5A5)
                      : Colors.white,
                ),
                _buildCardMetricItem(
                  'إجمالي الفواتير',
                  MoneyUtils.format(controller.tenantTotalInvoiced,
                      currencyCode: currency, isArabic: isArabic),
                  Colors.white70,
                ),
                _buildCardMetricItem(
                  'الفواتير',
                  '${controller.activeTenantInvoices.length} فواتير',
                  const Color(0xFF99F6E4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMetricItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
