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
import '../../../properties/presentation/screens/property_form_screen.dart';
import '../../../tenants/domain/entities/tenant_entity.dart';
import '../../../tenants/domain/repositories/tenant_repository.dart';
import '../../../tenants/presentation/screens/tenant_form_screen.dart';
import '../../../units/domain/entities/unit_entity.dart';
import '../../../units/domain/usecases/unit_usecases.dart';
import '../../../units/presentation/screens/unit_form_screen.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/usecases/contract_usecases.dart';

/// ContractFormScreen allows the owner to draft and issue lease agreements.
///
/// Features foolproof auto-selection and instant inline creation for properties,
/// units, and tenants to prevent any empty dropdown blockage.
class ContractFormScreen extends StatefulWidget {
  final ContractEntity? contractToRenew;

  const ContractFormScreen({super.key, this.contractToRenew});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<PropertyEntity> _properties = [];
  List<UnitEntity> _availableUnits = [];
  List<TenantEntity> _tenants = [];

  String? _selectedPropertyId;
  String? _selectedUnitId;
  String? _selectedTenantId;

  late final TextEditingController _contractNumberController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _rentAmountController;
  late final TextEditingController _depositAmountController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _termsController;

  String _selectedCycle = 'monthly';
  bool _isRentSeparate = true;
  bool _isLoading = false;
  bool _isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final oneYearLater = DateTime(now.year + 1, now.month, now.day);

    final renew = widget.contractToRenew;
    _contractNumberController = TextEditingController(
      text: renew != null
          ? '${renew.contractNumber}-R'
          : 'CNT-${now.millisecondsSinceEpoch.toString().substring(7)}',
    );
    _startDateController = TextEditingController(
      text: renew != null ? renew.endDate : DateFormatterUtils.toIsoDate(now),
    );
    _endDateController = TextEditingController(
      text: renew != null
          ? DateFormatterUtils.toIsoDate(
              DateTime.parse(renew.endDate).add(const Duration(days: 365)))
          : DateFormatterUtils.toIsoDate(oneYearLater),
    );
    _rentAmountController = TextEditingController(
      text: renew != null ? '${renew.rentAmount}' : '',
    );
    _depositAmountController = TextEditingController(
      text: renew != null ? '${renew.depositAmount}' : '0',
    );
    _dueDayController = TextEditingController(
      text: renew != null ? '${renew.dueDay}' : '1',
    );
    _termsController = TextEditingController(text: renew?.terms ?? '');

    if (renew != null) {
      _selectedPropertyId = renew.propertyId;
      _selectedUnitId = renew.unitId;
      _selectedTenantId = renew.tenantId;
      _selectedCycle = renew.paymentCycle;
      _isRentSeparate = renew.isRentSeparate;
    }

    _loadInitialDropdownData();
  }

  Future<void> _loadInitialDropdownData() async {
    setState(() => _isLoadingDropdowns = true);
    try {
      final propRepo = Get.find<PropertyRepository>();
      final tenantRepo = Get.find<TenantRepository>();

      final props = await propRepo.getProperties();
      final tenants = await tenantRepo.getTenants();

      setState(() {
        _properties = props;
        _tenants = tenants;

        // Auto-select property if only 1 exists and none selected
        if (_selectedPropertyId == null && _properties.isNotEmpty) {
          _selectedPropertyId = _properties.first.id;
        }

        // Auto-select tenant if only 1 exists and none selected
        if (_selectedTenantId == null && _tenants.isNotEmpty) {
          _selectedTenantId = _tenants.first.id;
        }
      });

      if (_selectedPropertyId != null) {
        await _loadUnitsForProperty(_selectedPropertyId!);
      }
    } catch (e) {
      debugPrint('Error loading dropdown data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingDropdowns = false);
    }
  }

  Future<void> _loadUnitsForProperty(String propId) async {
    try {
      final unitsUseCase = Get.find<GetUnitsByPropertyUseCase>();
      final units = await unitsUseCase.execute(propId);
      if (mounted) {
        setState(() {
          _availableUnits = units
              .where((u) => u.isVacant || u.id == _selectedUnitId)
              .toList();

          // Auto-select unit if only 1 vacant unit exists
          if (_availableUnits.isNotEmpty && _selectedUnitId == null) {
            _selectedUnitId = _availableUnits.first.id;
            _rentAmountController.text = '${_availableUnits.first.rentAmount}';
            _depositAmountController.text =
                '${_availableUnits.first.depositAmount}';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading units: $e');
    }
  }

  @override
  void dispose() {
    _contractNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    _dueDayController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      Get.snackbar('error'.tr, 'يرجى اختيار العقار',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedUnitId == null) {
      Get.snackbar('error'.tr, 'يرجى اختيار الوحدة العقارية',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedTenantId == null) {
      Get.snackbar('error'.tr, 'يرجى اختيار المستأجر',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final rent = MoneyUtils.parse(_rentAmountController.text);
      final deposit = MoneyUtils.parse(_depositAmountController.text);
      final dueDay = int.tryParse(_dueDayController.text.trim()) ?? 1;

      final contract = ContractEntity(
        id: widget.contractToRenew != null
            ? const Uuid().v4()
            : const Uuid().v4(),
        contractNumber: _contractNumberController.text.trim(),
        propertyId: _selectedPropertyId!,
        unitId: _selectedUnitId!,
        tenantId: _selectedTenantId!,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        paymentCycle: _selectedCycle,
        rentAmount: rent,
        depositAmount: deposit,
        dueDay: dueDay,
        terms: _termsController.text.trim(),
        isRentSeparate: _isRentSeparate,
        status: 'active',
        previousContractId: widget.contractToRenew?.id,
        createdAt: DateFormatterUtils.toIsoDate(now),
      );

      if (widget.contractToRenew != null) {
        final renewUseCase = Get.find<RenewContractUseCase>();
        await renewUseCase.execute(
          oldContract: widget.contractToRenew!,
          newContract: contract,
        );
      } else {
        final createUseCase = Get.find<CreateContractUseCase>();
        await createUseCase.execute(contract);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRenewing = widget.contractToRenew != null;

    if (_isLoadingDropdowns) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isRenewing ? 'renew_contract'.tr : 'add_contract'.tr),
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
                  controller: _contractNumberController,
                  label: 'contract_number'.tr,
                  prefixIcon: Icons.confirmation_number_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'field_required'.tr
                      : null,
                ),
                const SizedBox(height: 18),

                // 1. Property Dropdown / Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'property'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final res =
                            await Get.to(() => const PropertyFormScreen());
                        if (res == true) _loadInitialDropdownData();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('add_property'.tr,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _properties.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'no_properties'.tr,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value:
                            _properties.any((p) => p.id == _selectedPropertyId)
                                ? _selectedPropertyId
                                : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'اختر العقار',
                          prefixIcon:
                              const Icon(Icons.apartment_outlined, size: 20),
                        ),
                        items: _properties
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPropertyId = val;
                              _selectedUnitId = null;
                            });
                            _loadUnitsForProperty(val);
                          }
                        },
                      ),
                const SizedBox(height: 18),

                // 2. Unit Dropdown / Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'unit'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (_selectedPropertyId != null)
                      TextButton.icon(
                        onPressed: () async {
                          final res = await Get.to(() =>
                              UnitFormScreen(propertyId: _selectedPropertyId!));
                          if (res == true && _selectedPropertyId != null) {
                            _loadUnitsForProperty(_selectedPropertyId!);
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('add_unit'.tr,
                            style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                _availableUnits.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedPropertyId == null
                                    ? 'يرجى اختيار العقار أولاً'
                                    : 'لا توجد وحدات شاغرة في هذا العقار، اضغط إضافة وحدة',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value:
                            _availableUnits.any((u) => u.id == _selectedUnitId)
                                ? _selectedUnitId
                                : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'اختر الوحدة العقارية',
                          prefixIcon: const Icon(Icons.door_front_door_outlined,
                              size: 20),
                        ),
                        items: _availableUnits
                            .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(
                                    '${'unit'.tr} ${u.unitNumber} (${u.type.tr}) - ${MoneyUtils.format(u.rentAmount)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedUnitId = val);
                            final unit = _availableUnits
                                .firstWhereOrNull((u) => u.id == val);
                            if (unit != null) {
                              _rentAmountController.text = '${unit.rentAmount}';
                              _depositAmountController.text =
                                  '${unit.depositAmount}';
                            }
                          }
                        },
                      ),
                const SizedBox(height: 18),

                // 3. Tenant Dropdown / Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'tenant'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final res =
                            await Get.to(() => const TenantFormScreen());
                        if (res == true) _loadInitialDropdownData();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text('add_tenant'.tr,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _tenants.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'no_tenants'.tr,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _tenants.any((t) => t.id == _selectedTenantId)
                            ? _selectedTenantId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'اختر المستأجر',
                          prefixIcon:
                              const Icon(Icons.person_outline, size: 20),
                        ),
                        items: _tenants
                            .map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(
                                    '${t.fullName} (${t.phone})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTenantId = val);
                          }
                        },
                      ),
                const SizedBox(height: 18),

                // 4. Financial & Dates Section
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _startDateController,
                        label: 'start_date'.tr,
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _endDateController,
                        label: 'end_date'.tr,
                        prefixIcon: Icons.event_available_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
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
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _depositAmountController,
                        label: 'deposit_amount'.tr,
                        prefixIcon: Icons.savings_outlined,
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
                        value: _selectedCycle,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'payment_cycle'.tr,
                          prefixIcon: const Icon(Icons.repeat, size: 20),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'monthly', child: Text('monthly'.tr)),
                          DropdownMenuItem(
                              value: 'quarterly', child: Text('quarterly'.tr)),
                          DropdownMenuItem(
                              value: 'semiAnnual',
                              child: Text('semiAnnual'.tr)),
                          DropdownMenuItem(
                              value: 'annual', child: Text('annual'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCycle = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _dueDayController,
                        label: 'due_day'.tr,
                        prefixIcon: Icons.calendar_view_day_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _termsController,
                  label: 'terms'.tr,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: isRenewing ? 'renew_contract'.tr : 'add_contract'.tr,
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
