import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/unit_entity.dart';

/// UnitCard presents details of a single rentable unit with modern styling and status badge.
class UnitCard extends StatelessWidget {
  final UnitEntity unit;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (unit.isVacant ? AppColors.success : AppColors.primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _resolveTypeIcon(unit.type),
                  color: unit.isVacant ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'unit'.tr} ${unit.unitNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        StatusBadge(
                          status: unit.status,
                          label: unit.status.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${unit.type.tr} - ${'floor_number'.tr} ${unit.floorNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          MoneyUtils.format(unit.rentAmount,
                              isArabic: Get.locale?.languageCode == 'ar'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.accentLight
                                : AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'shop':
        return Icons.storefront_outlined;
      case 'office':
        return Icons.business_center_outlined;
      case 'warehouse':
        return Icons.warehouse_outlined;
      case 'villa':
        return Icons.villa_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'apartment':
      default:
        return Icons.door_front_door_outlined;
    }
  }
}
