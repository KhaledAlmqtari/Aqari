import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/unit_entity.dart';
import '../../domain/usecases/unit_usecases.dart';

/// UnitFormScreen allows adding or editing an individual rentable unit.
class UnitFormScreen extends StatefulWidget {
  final String propertyId;
  final UnitEntity? unitToEdit;

  const UnitFormScreen({
    super.key,
    required this.propertyId,
    this.unitToEdit,
  });

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitNumberController;
  late final TextEditingController _floorNumberController;
  late final TextEditingController _rentAmountController;
  late final TextEditingController _depositAmountController;
  late final TextEditingController _electricityController;
  late final TextEditingController _waterController;
  late final TextEditingController _notesController;

  String _selectedType = 'apartment';
  String _selectedStatus = 'vacant';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.unitToEdit;
    _unitNumberController = TextEditingController(text: u?.unitNumber ?? '');
    _floorNumberController =
        TextEditingController(text: u != null ? '${u.floorNumber}' : '1');
    _rentAmountController =
        TextEditingController(text: u != null ? '${u.rentAmount}' : '');
    _depositAmountController =
        TextEditingController(text: u != null ? '${u.depositAmount}' : '0');
    _electricityController =
        TextEditingController(text: u?.electricityMeter ?? '');
    _waterController = TextEditingController(text: u?.waterMeter ?? '');
    _notesController = TextEditingController(text: u?.notes ?? '');
    if (u != null) {
      _selectedType = u.type;
      _selectedStatus = u.status;
    }
  }

  @override
  void dispose() {
    _unitNumberController.dispose();
    _floorNumberController.dispose();
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final isEditing = widget.unitToEdit != null;
      final rent = MoneyUtils.parse(_rentAmountController.text);
      final deposit = MoneyUtils.parse(_depositAmountController.text);
      final floor = int.tryParse(_floorNumberController.text.trim()) ?? 0;

      final unit = UnitEntity(
        id: isEditing ? widget.unitToEdit!.id : const Uuid().v4(),
        propertyId: widget.propertyId,
        unitNumber: _unitNumberController.text.trim(),
        floorNumber: floor,
        type: _selectedType,
        status: _selectedStatus,
        rentAmount: rent,
        depositAmount: deposit,
        electricityMeter: _electricityController.text.trim(),
        waterMeter: _waterController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: isEditing
            ? widget.unitToEdit!.createdAt
            : DateFormatterUtils.toIsoDate(now),
      );

      if (isEditing) {
        final updateUseCase = Get.find<UpdateUnitUseCase>();
        await updateUseCase.execute(unit);
      } else {
        final createUseCase = Get.find<CreateUnitUseCase>();
        await createUseCase.execute(unit);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.unitToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'edit_unit'.tr : 'add_unit'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _unitNumberController,
                        label: 'unit_number'.tr,
                        prefixIcon: Icons.tag,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'field_required'.tr
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        controller: _floorNumberController,
                        label: 'floor_number'.tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'unit_type'.tr,
                          prefixIcon:
                              const Icon(Icons.category_outlined, size: 20),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'apartment', child: Text('apartment'.tr)),
                          DropdownMenuItem(
                              value: 'shop', child: Text('shop'.tr)),
                          DropdownMenuItem(
                              value: 'office', child: Text('office'.tr)),
                          DropdownMenuItem(
                              value: 'warehouse', child: Text('warehouse'.tr)),
                          DropdownMenuItem(
                              value: 'villa', child: Text('villa'.tr)),
                          DropdownMenuItem(
                              value: 'parking', child: Text('parking'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'status'.tr,
                          prefixIcon: const Icon(Icons.info_outline, size: 20),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'vacant', child: Text('vacant'.tr)),
                          DropdownMenuItem(
                              value: 'rented', child: Text('rented'.tr)),
                          DropdownMenuItem(
                              value: 'maintenance',
                              child: Text('maintenance'.tr)),
                          DropdownMenuItem(
                              value: 'unavailable',
                              child: Text('unavailable'.tr)),
                          DropdownMenuItem(
                              value: 'reserved', child: Text('reserved'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _rentAmountController,
                  label: 'rent_amount'.tr,
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    if (MoneyUtils.parse(v) <= 0) {
                      return 'amount_invalid'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _depositAmountController,
                  label: 'deposit_amount'.tr,
                  prefixIcon: Icons.security_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _electricityController,
                        label: 'electricity_meter'.tr,
                        prefixIcon: Icons.electric_bolt_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _waterController,
                        label: 'water_meter'.tr,
                        prefixIcon: Icons.water_drop_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'notes'.tr,
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'save'.tr,
                  isLoading: _isLoading,
                  icon: Icons.check,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
