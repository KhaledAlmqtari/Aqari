import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/tenant_controller.dart';
import '../widgets/tenant_card.dart';
import 'tenant_form_screen.dart';

/// TenantListScreen presents all registered tenants with instant phone/name search.
class TenantListScreen extends StatelessWidget {
  final bool showAppBar;

  const TenantListScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TenantController>();

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text('tenants'.tr),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add_outlined, size: 26),
                  tooltip: 'add_tenant'.tr,
                  onPressed: () async {
                    final res = await Get.to(() => const TenantFormScreen());
                    if (res == true) controller.loadTenants();
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CustomTextField(
              label: 'search'.tr,
              prefixIcon: Icons.search,
              onChanged: controller.onSearchChanged,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.tenants.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'no_tenants'.tr,
                  message: 'add_first_tenant'.tr,
                  buttonText: 'add_tenant'.tr,
                  onButtonPressed: () async {
                    final res = await Get.to(() => const TenantFormScreen());
                    if (res == true) controller.loadTenants();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadTenants,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.tenants.length,
                  itemBuilder: (ctx, index) {
                    final tenant = controller.tenants[index];
                    return TenantCard(
                      tenant: tenant,
                      onTap: () async {
                        final res = await Get.to(
                            () => TenantFormScreen(tenantToEdit: tenant));
                        if (res == true) controller.loadTenants();
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
          final res = await Get.to(() => const TenantFormScreen());
          if (res == true) controller.loadTenants();
        },
        icon: const Icon(Icons.person_add),
        label: Text('add_tenant'.tr),
      ),
    );
  }
}
