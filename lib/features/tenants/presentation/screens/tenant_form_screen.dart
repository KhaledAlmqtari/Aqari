import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/usecases/tenant_usecases.dart';
import '../controllers/tenant_controller.dart';

/// TenantFormScreen enforces full validation for tenant registration:
/// - Full Name, Phone (9 digits starting with 7), Alternate Phone (9 digits starting with 7),
///   National ID, and Email (proper RFC pattern) are strictly required.
/// - Notes field is optional.
/// - Includes delete functionality when editing existing tenants.
class TenantFormScreen extends StatefulWidget {
  final TenantEntity? tenantToEdit;

  const TenantFormScreen({super.key, this.tenantToEdit});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _alternatePhoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tenantToEdit;
    _nameController = TextEditingController(text: t?.fullName ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _alternatePhoneController =
        TextEditingController(text: t?.alternatePhone ?? '');
    _nationalIdController = TextEditingController(text: t?.nationalId ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
    _addressController = TextEditingController(text: t?.address ?? '');
    _notesController = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _deleteTenant() async {
    final tenant = widget.tenantToEdit;
    if (tenant == null) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'delete_tenant'.tr,
      message: 'confirm_delete_tenant'.tr,
      confirmText: 'delete'.tr,
      onConfirm: () async {
        final controller = Get.find<TenantController>();
        await controller.archiveTenant(tenant.id);
        Get.back(result: true);
      },
    );
    if (confirmed == true) {
      Get.back(result: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final isEditing = widget.tenantToEdit != null;

      final tenant = TenantEntity(
        id: isEditing ? widget.tenantToEdit!.id : const Uuid().v4(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        isArchived: isEditing ? widget.tenantToEdit!.isArchived : false,
        createdAt: isEditing
            ? widget.tenantToEdit!.createdAt
            : DateFormatterUtils.toIsoDate(now),
      );

      if (isEditing) {
        final updateUseCase = Get.find<UpdateTenantUseCase>();
        await updateUseCase.execute(tenant);
      } else {
        final createUseCase = Get.find<CreateTenantUseCase>();
        await createUseCase.execute(tenant);
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
    final isEditing = widget.tenantToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'edit_tenant'.tr : 'add_tenant'.tr),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'delete_tenant'.tr,
              onPressed: _deleteTenant,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Full Name (Required)
                CustomTextField(
                  controller: _nameController,
                  label: '${'full_name'.tr} *',
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Primary Phone (Required, 9 digits starting with 7)
                CustomTextField(
                  controller: _phoneController,
                  label: '${'phone'.tr} *',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    final clean = v.trim();
                    if (!RegExp(r'^7\d{8}$').hasMatch(clean)) {
                      return 'phone_validation_msg'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Alternate Phone (Required, 9 digits starting with 7)
                CustomTextField(
                  controller: _alternatePhoneController,
                  label: '${'alternate_phone'.tr} *',
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    final clean = v.trim();
                    if (!RegExp(r'^7\d{8}$').hasMatch(clean)) {
                      return 'phone_validation_msg'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. National ID / Passport (Required)
                CustomTextField(
                  controller: _nationalIdController,
                  label: '${'national_id'.tr} *',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. Email Address (Required, valid email format)
                CustomTextField(
                  controller: _emailController,
                  label: '${'email'.tr} *',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    final clean = v.trim();
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(clean)) {
                      return 'email_validation_msg'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 6. Address (Required)
                CustomTextField(
                  controller: _addressController,
                  label: '${'address'.tr} *',
                  prefixIcon: Icons.home_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'field_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 7. Notes (Optional)
                CustomTextField(
                  controller: _notesController,
                  label: '${'notes'.tr} (اختياري)',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 28),

                // Save Button
                CustomButton(
                  text: 'save'.tr,
                  isLoading: _isLoading,
                  icon: Icons.check,
                  onPressed: _submit,
                ),

                if (isEditing) ...[
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'delete_tenant'.tr,
                    icon: Icons.delete_forever,
                    backgroundColor: AppColors.error,
                    onPressed: _deleteTenant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
