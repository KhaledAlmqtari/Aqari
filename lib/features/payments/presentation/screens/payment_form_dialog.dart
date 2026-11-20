import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../invoices/domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payment_usecases.dart';

/// PaymentFormDialog provides a modal sheet for recording full or partial invoice payments.
class PaymentFormDialog extends StatefulWidget {
  final InvoiceEntity invoice;

  const PaymentFormDialog({super.key, required this.invoice});

  static Future<bool?> show({
    required BuildContext context,
    required InvoiceEntity invoice,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentFormDialog(invoice: invoice),
    );
  }

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _receiptNumberController;
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  String _selectedMethod = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _receiptNumberController = TextEditingController(
      text: 'RCP-${now.millisecondsSinceEpoch.toString().substring(7)}',
    );
    // Pre-fill with remaining amount for easy full payment
    _amountController =
        TextEditingController(text: '${widget.invoice.remainingAmount}');
    _referenceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = MoneyUtils.parse(_amountController.text);
    if (enteredAmount <= 0) {
      Get.snackbar('error'.tr, 'amount_invalid'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Business Rule 12: Reject payment if exceeding remaining balance
    if (enteredAmount > widget.invoice.remainingAmount) {
      Get.snackbar(
        'error'.tr,
        'payment_exceeds_remaining'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final payment = PaymentEntity(
        id: const Uuid().v4(),
        receiptNumber: _receiptNumberController.text.trim(),
        invoiceId: widget.invoice.id,
        tenantId: widget.invoice.tenantId,
        contractId: widget.invoice.contractId,
        amount: enteredAmount,
        paymentDate: DateFormatterUtils.toIsoDate(now),
        paymentMethod: _selectedMethod,
        referenceNumber: _referenceController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: DateFormatterUtils.toIsoDate(now),
      );

      final recordUseCase = Get.find<RecordPaymentUseCase>();
      await recordUseCase.execute(payment);

      Navigator.of(context).pop(true);
      Get.snackbar('success'.tr, 'payment_recorded'.tr,
          snackPosition: SnackPosition.BOTTOM);
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
                'record_payment'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${'remaining_amount'.tr}: ${MoneyUtils.format(widget.invoice.remainingAmount, isArabic: Get.locale?.languageCode == 'ar')}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: _amountController,
                label: 'rent_amount'.tr,
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'field_required'.tr;
                  if (MoneyUtils.parse(v) <= 0) return 'amount_invalid'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'payment_method'.tr,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                      size: 20),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('cash'.tr)),
                  DropdownMenuItem(
                      value: 'bankTransfer', child: Text('bankTransfer'.tr)),
                  DropdownMenuItem(value: 'eWallet', child: Text('eWallet'.tr)),
                  DropdownMenuItem(value: 'cheque', child: Text('cheque'.tr)),
                  DropdownMenuItem(value: 'other', child: Text('other'.tr)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMethod = val);
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _referenceController,
                label: 'reference_number'.tr,
                prefixIcon: Icons.tag,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _notesController,
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
