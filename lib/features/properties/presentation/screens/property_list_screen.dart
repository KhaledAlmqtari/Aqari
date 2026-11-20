import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/property_controller.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';
import 'property_form_screen.dart';

/// PropertyListScreen displays active managed properties with search and creation controls.
class PropertyListScreen extends StatelessWidget {
  final bool showAppBar;

  const PropertyListScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertyController>();

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text('properties'.tr),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 26),
                  tooltip: 'add_property'.tr,
                  onPressed: () async {
                    final result =
                        await Get.to(() => const PropertyFormScreen());
                    if (result == true) {
                      controller.loadProperties();
                    }
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
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.filteredProperties;
              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.apartment_outlined,
                  title: 'no_properties'.tr,
                  message: 'add_first_property'.tr,
                  buttonText: 'add_property'.tr,
                  onButtonPressed: () async {
                    final result =
                        await Get.to(() => const PropertyFormScreen());
                    if (result == true) {
                      controller.loadProperties();
                    }
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadProperties,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (ctx, index) {
                    final prop = list[index];
                    return PropertyCard(
                      property: prop,
                      onTap: () async {
                        await Get.to(() => PropertyDetailScreen(
                              propertyId: prop.id,
                              initialProperty: prop,
                            ));
                        controller.loadProperties();
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
          final result = await Get.to(() => const PropertyFormScreen());
          if (result == true) {
            controller.loadProperties();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('add_property'.tr),
      ),
    );
  }
}
