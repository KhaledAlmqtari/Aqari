import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../payments/domain/entities/payment_entity.dart';
import '../../../payments/domain/usecases/payment_usecases.dart';
import '../../../payments/presentation/screens/payment_form_dialog.dart';
import '../../../payments/presentation/widgets/payment_receipt_card.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../controllers/invoice_controller.dart';

/// InvoiceDetailScreen displays full invoice breakdown, payment collections, and reversals.
class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  InvoiceEntity? _invoice;
  List<PaymentEntity> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = Get.find<InvoiceRepository>();
      final paymentUseCase = Get.find<GetPaymentsUseCase>();

      final inv = await repo.getInvoiceById(widget.invoiceId);
      final payments =
          await paymentUseCase.execute(invoiceId: widget.invoiceId);

      if (mounted) {
        setState(() {
          _invoice = inv;
          _payments = payments;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveInvoice() async {
    final controller = Get.find<InvoiceController>();
    await controller.approveInvoice(widget.invoiceId);
    _loadData();
  }

  void _copyInvoiceSummary() {
    if (_invoice == null) return;
    final inv = _invoice!;
    final isAr = Get.locale?.languageCode == 'ar';
    final text = '''
📄 ${'invoice'.tr} #${inv.invoiceNumber}
👤 ${'tenant'.tr}: ${inv.tenantName ?? ''}
🏢 ${'property'.tr}: ${inv.propertyName ?? ''} (${'unit'.tr} ${inv.unitNumber ?? ''})
📅 ${'period'.tr}: ${DateFormatterUtils.formatIsoDate(inv.periodStart)} - ${DateFormatterUtils.formatIsoDate(inv.periodEnd)}
💰 ${'total_amount'.tr}: ${MoneyUtils.format(inv.totalAmount, isArabic: isAr)}
✅ ${'paid_amount'.tr}: ${MoneyUtils.format(inv.paidAmount, isArabic: isAr)}
⚠️ ${'remaining_amount'.tr}: ${MoneyUtils.format(inv.remainingAmount, isArabic: isAr)}
📌 ${'status'.tr}: ${inv.status.tr}
''';
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'success'.tr,
      'تم نسخ ملخص الفاتورة بنجاح ويمكنك مشاركته عبر واتساب أو رسالة نصية',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  void _showReversePaymentDialog(PaymentEntity payment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('reverse_payment'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('confirm_reverse_payment'.tr),
            const SizedBox(height: 14),
            CustomTextField(
              controller: reasonController,
              label: 'reverse_reason'.tr,
              prefixIcon: Icons.undo_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final reverseUseCase = Get.find<ReversePaymentUseCase>();
              await reverseUseCase.execute(
                paymentId: payment.id,
                invoiceId: payment.invoiceId,
                amount: payment.amount,
                reason: reasonController.text.trim(),
                reversedAt: DateFormatterUtils.toIsoDate(DateTime.now()),
              );
              _loadData();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('error'.tr)),
      );
    }

    final inv = _invoice!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${'invoice'.tr} #${inv.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'مشاركة الفاتورة',
            onPressed: _copyInvoiceSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Invoice Financial Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.darkCardGradient
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
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
                        Text(
                          '#${inv.invoiceNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        StatusBadge(status: inv.status, label: inv.status.tr),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          inv.tenantName ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.apartment,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          '${inv.propertyName ?? ''} - ${'unit'.tr} ${inv.unitNumber ?? ''}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('total_amount'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text(
                              MoneyUtils.format(inv.totalAmount,
                                  isArabic: Get.locale?.languageCode == 'ar'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('paid_amount'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text(
                              MoneyUtils.format(inv.paidAmount,
                                  isArabic: Get.locale?.languageCode == 'ar'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('remaining_amount'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text(
                              MoneyUtils.format(inv.remainingAmount,
                                  isArabic: Get.locale?.languageCode == 'ar'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: inv.remainingAmount > 0
                                    ? AppColors.accentLight
                                    : AppColors.successContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Action Buttons
              if (inv.isDraft) ...[
                CustomButton(
                  text: 'approve_invoice'.tr,
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.success,
                  height: 48,
                  onPressed: _approveInvoice,
                ),
                const SizedBox(height: 14),
              ] else if (inv.remainingAmount > 0) ...[
                CustomButton(
                  text: 'record_payment'.tr,
                  icon: Icons.payments_outlined,
                  backgroundColor: AppColors.primary,
                  height: 48,
                  onPressed: () async {
                    final res = await PaymentFormDialog.show(
                        context: context, invoice: inv);
                    if (res == true) _loadData();
                  },
                ),
                const SizedBox(height: 14),
              ],

              // 3. Payments History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'payments_list'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (_payments.isNotEmpty)
                    Text(
                      '${_payments.length} ${'payment'.tr}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_payments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                  child: Text(
                    'لا توجد دفعات مسجلة لهذه الفاتورة بعد',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                ..._payments.map((p) => PaymentReceiptCard(
                      payment: p,
                      onReverse: p.isReversed
                          ? null
                          : () => _showReversePaymentDialog(p),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
