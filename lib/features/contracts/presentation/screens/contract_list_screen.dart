import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/contract_controller.dart';
import '../widgets/contract_card.dart';
import 'contract_detail_screen.dart';
import 'contract_form_screen.dart';

/// ContractListScreen displays leases with filter tabs (All, Active, Expired, Terminated).
class ContractListScreen extends StatelessWidget {
  final bool isEmbedded;

  const ContractListScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContractController>();

    final content = Column(
      children: [
        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(
            () => Row(
              children: [
                _buildFilterChip('all', controller),
                _buildFilterChip('active', controller),
                _buildFilterChip('expired', controller),
                _buildFilterChip('terminated', controller),
                _buildFilterChip('draft', controller),
              ],
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.contracts.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.description_outlined,
                title: 'contracts'.tr,
                message: 'no_expirations'.tr,
                buttonText: 'add_contract'.tr,
                onButtonPressed: () async {
                  final res = await Get.to(() => const ContractFormScreen());
                  if (res == true) controller.loadContracts();
                },
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadContracts,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.contracts.length,
                itemBuilder: (ctx, index) {
                  final contract = controller.contracts[index];
                  return ContractCard(
                    contract: contract,
                    onTap: () async {
                      final res = await Get.to(
                          () => ContractDetailScreen(contractId: contract.id));
                      if (res == true) controller.loadContracts();
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );

    if (isEmbedded) {
      return Scaffold(
        body: content,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final res = await Get.to(() => const ContractFormScreen());
            if (res == true) controller.loadContracts();
          },
          icon: const Icon(Icons.add),
          label: Text('add_contract'.tr),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('contracts'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add_outlined, size: 26),
            tooltip: 'add_contract'.tr,
            onPressed: () async {
              final res = await Get.to(() => const ContractFormScreen());
              if (res == true) controller.loadContracts();
            },
          ),
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Get.to(() => const ContractFormScreen());
          if (res == true) controller.loadContracts();
        },
        icon: const Icon(Icons.add),
        label: Text('add_contract'.tr),
      ),
    );
  }

  Widget _buildFilterChip(String status, ContractController controller) {
    final isSelected = controller.selectedStatusFilter.value == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status.tr),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        onSelected: (_) => controller.filterByStatus(status),
      ),
    );
  }
}
