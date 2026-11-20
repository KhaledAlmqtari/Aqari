import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../properties/domain/entities/property_entity.dart';
import '../../../properties/domain/repositories/property_repository.dart';
import '../../../tenants/domain/entities/tenant_entity.dart';
import '../../../tenants/domain/repositories/tenant_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/expense_usecases.dart';

/// ExpenseFormDialog allows recording operating expenses.
class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ExpenseFormDialog(),
    );
  }

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  List<PropertyEntity> _properties = [];
  String? _selectedPropertyId;

  List<TenantEntity> _tenants = [];
  String? _selectedTenantId;

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  String _selectedCategory = 'maintenance_category';
  String _selectedMethod = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadProperties();
    _loadTenants();
  }

  Future<void> _loadProperties() async {
    final propRepo = Get.find<PropertyRepository>();
    final props = await propRepo.getProperties();
    setState(() => _properties = props);
  }

  Future<void> _loadTenants() async {
    try {
      final tenantRepo = Get.find<TenantRepository>();
      final tenants = await tenantRepo.getTenants();
      if (mounted) setState(() => _tenants = tenants);
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = MoneyUtils.parse(_amountController.text);
    if (amount <= 0) {
      Get.snackbar('error'.tr, 'amount_invalid'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final expense = ExpenseEntity(
        id: const Uuid().v4(),
        propertyId: _selectedPropertyId,
        tenantId: _selectedTenantId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        expenseDate: DateFormatterUtils.toIsoDate(now),
        paymentMethod: _selectedMethod,
        description: _descriptionController.text.trim(),
        createdAt: DateFormatterUtils.toIsoDate(now),
      );

      final createUseCase = Get.find<CreateExpenseUseCase>();
      await createUseCase.execute(expense);

      Navigator.of(context).pop(true);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                        (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'add_expense'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'expense_title'.tr,
                prefixIcon: Icons.edit_note_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'field_required'.tr
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String?>(
                value: _selectedPropertyId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'property'.tr,
                  prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                ),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text('all'.tr)),
                  ..._properties.map((p) => DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (val) => setState(() => _selectedPropertyId = val),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String?>(
                value: _selectedTenantId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'المستأجر المعني بالمصروف (اختياري)',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('عام (لا يخص مستأجر محدد)'.tr),
                  ),
                  ..._tenants.map((t) => DropdownMenuItem<String?>(
                        value: t.id,
                        child:
                            Text(t.fullName, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedTenantId = val),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'expense_category'.tr,
                  prefixIcon: const Icon(Icons.category_outlined, size: 20),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'maintenance_category',
                      child: Text('maintenance_category'.tr,
                          overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(
                      value: 'cleaning',
                      child:
                          Text('cleaning'.tr, overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(
                      value: 'electricity',
                      child: Text('electricity'.tr,
                          overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(
                      value: 'water',
                      child: Text('water'.tr, overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(
                      value: 'security_guarding',
                      child: Text('security_guarding'.tr,
                          overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(
                      value: 'admin',
                      child: Text('admin'.tr, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _amountController,
                label: 'total_amount'.tr,
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
              const SizedBox(height: 14),
              CustomTextField(
                controller: _descriptionController,
                label: 'notes'.tr,
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 24),
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
    );
  }
}
