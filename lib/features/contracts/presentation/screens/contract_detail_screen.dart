import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../invoices/domain/entities/invoice_entity.dart';
import '../../../invoices/domain/usecases/invoice_usecases.dart';
import '../../../invoices/presentation/screens/invoice_detail_screen.dart';
import '../../../invoices/presentation/screens/invoice_form_screen.dart';
import '../../../invoices/presentation/widgets/invoice_card.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contract_repository.dart';
import '../controllers/contract_controller.dart';
import 'contract_form_screen.dart';

/// ContractDetailScreen presents full terms, financial cycle, attached invoices, and termination.
class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  ContractEntity? _contract;
  List<InvoiceEntity> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final contractRepo = Get.find<ContractRepository>();
      final invoiceUseCase = Get.find<GetInvoicesUseCase>();

      final c = await contractRepo.getContractById(widget.contractId);
      final invs = await invoiceUseCase.execute(contractId: widget.contractId);

      if (mounted) {
        setState(() {
          _contract = c;
          _invoices = invs;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTerminationDialog() {
    final reasonController = TextEditingController();
    final dateController = TextEditingController(
        text: DateFormatterUtils.toIsoDate(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('terminate_contract'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('confirm_terminate_contract'.tr),
            const SizedBox(height: 16),
            CustomTextField(
              controller: reasonController,
              label: 'terminate_reason'.tr,
              prefixIcon: Icons.edit_note_outlined,
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
              final controller = Get.find<ContractController>();
              await controller.terminateContract(
                contractId: _contract!.id,
                unitId: _contract!.unitId,
                reason: reasonController.text.trim(),
                date: dateController.text.trim(),
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

    if (_contract == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('error'.tr)),
      );
    }

    final c = _contract!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${'contract'.tr} #${c.contractNumber}'),
        actions: [
          if (c.isActive) ...[
            IconButton(
              icon: const Icon(Icons.autorenew_outlined),
              tooltip: 'renew_contract'.tr,
              onPressed: () async {
                final res =
                    await Get.to(() => ContractFormScreen(contractToRenew: c));
                if (res == true) _loadData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              tooltip: 'terminate_contract'.tr,
              onPressed: _showTerminationDialog,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract Summary Card
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
                          '#${c.contractNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        StatusBadge(status: c.status, label: c.status.tr),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          c.tenantName ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
                          '${c.propertyName ?? ''} - ${'unit'.tr} ${c.unitNumber ?? ''}',
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
                            Text('rent_amount'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text(
                              MoneyUtils.format(c.rentAmount,
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
                            Text('payment_cycle'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text(c.paymentCycle.tr,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('due_day'.tr,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70)),
                            Text('${c.dueDay}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Invoices Header & Generate Invoice action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'invoices'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (c.isActive)
                    TextButton.icon(
                      onPressed: () async {
                        final res =
                            await Get.to(() => InvoiceFormScreen(contract: c));
                        if (res == true) _loadData();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('new_invoice'.tr),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (_invoices.isEmpty)
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
                    'no_invoices'.tr,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                ..._invoices.map((inv) => InvoiceCard(
                      invoice: inv,
                      onTap: () async {
                        final res = await Get.to(
                            () => InvoiceDetailScreen(invoiceId: inv.id));
                        if (res == true) _loadData();
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
