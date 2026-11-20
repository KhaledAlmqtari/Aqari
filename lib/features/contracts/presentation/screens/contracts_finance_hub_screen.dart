import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../expenses/presentation/screens/expense_list_screen.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../invoices/presentation/screens/invoice_list_screen.dart';
import 'contract_list_screen.dart';

/// ContractsFinanceHubScreen unites Contracts, Invoices, and Expenses
/// into a single cohesive executive financial hub with smooth top navigation.
class ContractsFinanceHubScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool isEmbedded;

  const ContractsFinanceHubScreen({
    super.key,
    this.initialTabIndex = 0,
    this.isEmbedded = false,
  });

  @override
  State<ContractsFinanceHubScreen> createState() =>
      _ContractsFinanceHubScreenState();
}

class _ContractsFinanceHubScreenState extends State<ContractsFinanceHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      if (_tabController.index != home.contractsHubInitialTab.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _tabController.index != home.contractsHubInitialTab.value) {
            _tabController.animateTo(home.contractsHubInitialTab.value);
          }
        });
      }
    }

    final tabBarWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard
            : AppColors.lightBorder.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: [
          Tab(
            icon: const Icon(Icons.description_outlined, size: 18),
            text: 'contracts'.tr,
          ),
          Tab(
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            text: 'invoices'.tr,
          ),
          Tab(
            icon: const Icon(Icons.payments_outlined, size: 18),
            text: 'expenses'.tr,
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          tabBarWidget,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ContractListScreen(isEmbedded: true),
                InvoiceListScreen(),
                ExpenseListScreen(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('contracts_and_finance'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: tabBarWidget,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ContractListScreen(isEmbedded: true),
          InvoiceListScreen(),
          ExpenseListScreen(),
        ],
      ),
    );
  }
}
