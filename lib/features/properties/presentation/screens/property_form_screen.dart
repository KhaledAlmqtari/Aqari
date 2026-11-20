import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/usecases/property_usecases.dart';

/// PropertyFormScreen allows the owner to create or edit a property record.
class PropertyFormScreen extends StatefulWidget {
  final PropertyEntity? propertyToEdit;

  const PropertyFormScreen({super.key, this.propertyToEdit});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _notesController;

  String _selectedType = 'residential';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.propertyToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _cityController = TextEditingController(text: p?.city ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    if (p != null) {
      _selectedType = p.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final isEditing = widget.propertyToEdit != null;

      final property = PropertyEntity(
        id: isEditing ? widget.propertyToEdit!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        notes: _notesController.text.trim(),
        totalUnits: isEditing ? widget.propertyToEdit!.totalUnits : 0,
        isArchived: isEditing ? widget.propertyToEdit!.isArchived : false,
        createdAt: isEditing
            ? widget.propertyToEdit!.createdAt
            : DateFormatterUtils.toIsoDate(now),
      );

      if (isEditing) {
        final updateUseCase = Get.find<UpdatePropertyUseCase>();
        await updateUseCase.execute(property);
      } else {
        final createUseCase = Get.find<CreatePropertyUseCase>();
        await createUseCase.execute(property);
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
    final isEditing = widget.propertyToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'edit_property'.tr : 'add_property'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'property_name'.tr,
                  prefixIcon: Icons.apartment_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'field_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'property_type'.tr,
                    prefixIcon: const Icon(Icons.category_outlined, size: 20),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'residential', child: Text('residential'.tr)),
                    DropdownMenuItem(
                        value: 'commercial', child: Text('commercial'.tr)),
                    DropdownMenuItem(value: 'mixed', child: Text('mixed'.tr)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _cityController,
                  label: 'city'.tr,
                  prefixIcon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'address'.tr,
                  prefixIcon: Icons.place_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'notes'.tr,
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 3,
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
