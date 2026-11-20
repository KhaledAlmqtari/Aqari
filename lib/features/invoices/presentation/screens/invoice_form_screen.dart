import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../contracts/domain/entities/contract_entity.dart';
import '../../../contracts/domain/repositories/contract_repository.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/invoice_usecases.dart';

/// InvoiceFormScreen allows creating a scheduled claim / invoice for a lease contract.
///
/// Can be opened either with a pre-selected [contract], or standalone where the owner
/// selects an active lease contract from a dropdown list.
class InvoiceFormScreen extends StatefulWidget {
  final ContractEntity? contract;

  const InvoiceFormScreen({super.key, this.contract});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<ContractEntity> _activeContracts = [];
  ContractEntity? _selectedContract;
  bool _isLoadingContracts = false;

  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _periodStartController;
  late final TextEditingController _periodEndController;
  late final TextEditingController _issueDateController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  bool _isDraft = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _invoiceNumberController = TextEditingController(
      text: 'INV-${now.millisecondsSinceEpoch.toString().substring(6)}',
    );
    _periodStartController = TextEditingController(
      text: DateFormatterUtils.toIsoDate(now),
    );
    _periodEndController = TextEditingController(
      text: DateFormatterUtils.toIsoDate(now.add(const Duration(days: 30))),
    );
    _issueDateController = TextEditingController(
      text: DateFormatterUtils.toIsoDate(now),
    );
    _dueDateController = TextEditingController(
      text: DateFormatterUtils.toIsoDate(now.add(const Duration(days: 7))),
    );
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.contract != null) {
      _applyContract(widget.contract!);
    } else {
      _loadActiveContracts();
    }
  }

  Future<void> _loadActiveContracts() async {
    setState(() => _isLoadingContracts = true);
    try {
      final contractRepo = Get.find<ContractRepository>();
      final list = await contractRepo.getContracts(statusFilter: 'active');
      setState(() {
        _activeContracts = list;
        if (list.isNotEmpty) {
          _applyContract(list.first);
        }
      });
    } finally {
      if (mounted) setState(() => _isLoadingContracts = false);
    }
  }

  void _applyContract(ContractEntity contract) {
    setState(() {
      _selectedContract = contract;
      _amountController.text = '${contract.rentAmount}';

      final now = DateTime.now();
      _periodStartController.text = DateFormatterUtils.toIsoDate(now);
      final nextDue =
          DateFormatterUtils.calculateNextDueDate(now, contract.paymentCycle);
      _periodEndController.text = DateFormatterUtils.toIsoDate(nextDue);
    });
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _periodStartController.dispose();
    _periodEndController.dispose();
    _issueDateController.dispose();
    _dueDateController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContract == null) {
      Get.snackbar('error'.tr, 'field_required'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final total = MoneyUtils.parse(_amountController.text);
      final c = _selectedContract!;

      final invoice = InvoiceEntity(
        id: const Uuid().v4(),
        invoiceNumber: _invoiceNumberController.text.trim(),
        contractId: c.id,
        tenantId: c.tenantId,
        unitId: c.unitId,
        propertyId: c.propertyId,
        periodStart: _periodStartController.text.trim(),
        periodEnd: _periodEndController.text.trim(),
        issueDate: _issueDateController.text.trim(),
        dueDate: _dueDateController.text.trim(),
        totalAmount: total,
        paidAmount: 0,
        remainingAmount: total,
        status: _isDraft ? 'draft' : 'pending',
        notes: _notesController.text.trim(),
        createdAt: DateFormatterUtils.toIsoDate(now),
      );

      final createUseCase = Get.find<CreateInvoiceUseCase>();
      await createUseCase.execute(invoice);

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
    if (_isLoadingContracts) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('new_invoice'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contract Selector (if not fixed)
                if (widget.contract == null) ...[
                  if (_activeContracts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Text(
                        'no_expirations'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    DropdownButtonFormField<ContractEntity>(
                      value: _selectedContract,
                      decoration: InputDecoration(
                        labelText: 'contract'.tr,
                        prefixIcon:
                            const Icon(Icons.description_outlined, size: 20),
                      ),
                      items: _activeContracts
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  '#${c.contractNumber} - ${c.tenantName ?? ''} (${c.propertyName ?? ''} / ${c.unitNumber ?? ''})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _applyContract(val);
                      },
                    ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _invoiceNumberController,
                  label: 'invoice_number'.tr,
                  prefixIcon: Icons.receipt_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'field_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _periodStartController,
                        label: '${'period'.tr} (${'start_date'.tr})',
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _periodEndController,
                        label: '${'period'.tr} (${'end_date'.tr})',
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
                        controller: _issueDateController,
                        label: 'issue_date'.tr,
                        prefixIcon: Icons.date_range_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _dueDateController,
                        label: 'due_date'.tr,
                        prefixIcon: Icons.alarm_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  label: 'total_amount'.tr,
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'field_required'.tr;
                    if (MoneyUtils.parse(v) <= 0) return 'amount_invalid'.tr;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'notes'.tr,
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('draft'.tr),
                  subtitle: Text('save'.tr),
                  value: _isDraft,
                  onChanged: (val) => setState(() => _isDraft = val),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'save'.tr,
                  isLoading: _isLoading,
                  icon: Icons.check,
                  onPressed: _submit,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
