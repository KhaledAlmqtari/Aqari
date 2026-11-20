import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../units/domain/entities/unit_entity.dart';
import '../../../units/domain/repositories/unit_repository.dart';
import '../../../units/domain/usecases/unit_usecases.dart';
import '../../../units/presentation/screens/unit_form_screen.dart';
import '../../../units/presentation/widgets/unit_card.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/property_usecases.dart';
import 'property_form_screen.dart';

/// PropertyDetailScreen shows full details of a property and lists all its associated units.
class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  final PropertyEntity? initialProperty;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.initialProperty,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  PropertyEntity? _property;
  List<UnitEntity> _units = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _property = widget.initialProperty;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final propRepo = Get.find<PropertyRepository>();
      final unitsUseCase = Get.find<GetUnitsByPropertyUseCase>();

      final prop = await propRepo.getPropertyById(widget.propertyId);
      final units = await unitsUseCase.execute(widget.propertyId);

      if (mounted) {
        setState(() {
          if (prop != null) _property = prop;
          _units = units;
        });
      }
    } catch (e) {
      debugPrint('Error loading property detail: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProperty() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'delete_property'.tr,
      message: 'confirm_delete_property'.tr,
      confirmText: 'delete'.tr,
      onConfirm: () async {
        final archiveUseCase = Get.find<ArchivePropertyUseCase>();
        await archiveUseCase.execute(widget.propertyId);
        Get.back(result: true);
      },
    );
    if (confirmed == true) {
      Get.back(result: true);
    }
  }

  void _showUnitDetailsSheet(UnitEntity unit, PropertyEntity prop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'unit'.tr} ${unit.unitNumber}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  StatusBadge(status: unit.status, label: unit.status.tr),
                ],
              ),
              const SizedBox(height: 14),
              _buildDetailRow('unit_type'.tr, unit.type.tr),
              _buildDetailRow('floor_number'.tr, '${unit.floorNumber}'),
              _buildDetailRow(
                  'rent_amount'.tr, MoneyUtils.format(unit.rentAmount)),
              _buildDetailRow(
                  'deposit_amount'.tr, MoneyUtils.format(unit.depositAmount)),
              if (unit.electricityMeter != null &&
                  unit.electricityMeter!.isNotEmpty)
                _buildDetailRow('electricity_meter'.tr, unit.electricityMeter!),
              if (unit.waterMeter != null && unit.waterMeter!.isNotEmpty)
                _buildDetailRow('water_meter'.tr, unit.waterMeter!),
              if (unit.notes != null && unit.notes!.isNotEmpty)
                _buildDetailRow('notes'.tr, unit.notes!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Get.back();
                        final res = await Get.to(() => UnitFormScreen(
                              propertyId: prop.id,
                              unitToEdit: unit,
                            ));
                        if (res == true) _loadData();
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('edit'.tr),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Get.back();
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          title: 'delete_unit'.tr,
                          message: 'confirm_delete_unit'.tr,
                          confirmText: 'delete'.tr,
                          onConfirm: () async {
                            final unitRepo = Get.find<UnitRepository>();
                            await unitRepo.deleteUnit(unit.id, prop.id);
                            _loadData();
                          },
                        );
                        if (confirmed == true) {
                          _loadData();
                        }
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text('delete'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _property == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(title: Text('details'.tr)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('error'.tr),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadData,
                child: Text('refresh'.tr),
              ),
            ],
          ),
        ),
      );
    }

    final p = _property!;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'edit'.tr,
            onPressed: () async {
              final res =
                  await Get.to(() => PropertyFormScreen(propertyToEdit: p));
              if (res == true) _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'delete_property'.tr,
            onPressed: _deleteProperty,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Executive Header Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkCardGradient
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p.type.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (p.address != null && p.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${p.city ?? ''} ${p.address ?? ''}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHeaderStat('units'.tr, '${_units.length}'),
                      const SizedBox(width: 24),
                      _buildHeaderStat(
                        'vacant'.tr,
                        '${_units.where((u) => u.isVacant).length}',
                      ),
                      const SizedBox(width: 24),
                      _buildHeaderStat(
                        'rented'.tr,
                        '${_units.where((u) => u.isRented).length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Units section title and Add button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'units'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final res =
                          await Get.to(() => UnitFormScreen(propertyId: p.id));
                      if (res == true) _loadData();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('add_unit'.tr),
                  ),
                ],
              ),
            ),

            // Units List
            Expanded(
              child: _units.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.door_front_door_outlined,
                      title: 'no_units'.tr,
                      message: 'add_first_unit'.tr,
                      buttonText: 'add_unit'.tr,
                      onButtonPressed: () async {
                        final res = await Get.to(
                            () => UnitFormScreen(propertyId: p.id));
                        if (res == true) _loadData();
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: _units.length,
                      itemBuilder: (ctx, index) {
                        final unit = _units[index];
                        return UnitCard(
                          unit: unit,
                          onTap: () => _showUnitDetailsSheet(unit, p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
