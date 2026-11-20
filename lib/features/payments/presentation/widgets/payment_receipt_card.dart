import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/entities/payment_entity.dart';

/// PaymentReceiptCard renders an individual payment receipt in financial histories.
class PaymentReceiptCard extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback? onReverse;

  const PaymentReceiptCard({
    super.key,
    required this.payment,
    this.onReverse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: payment.isReversed
              ? AppColors.error.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      payment.isReversed
                          ? Icons.cancel_outlined
                          : Icons.check_circle_outline,
                      size: 18,
                      color: payment.isReversed
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${payment.receiptNumber}',
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
                Text(
                  MoneyUtils.format(payment.amount,
                      isArabic: Get.locale?.languageCode == 'ar'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    decoration:
                        payment.isReversed ? TextDecoration.lineThrough : null,
                    color: payment.isReversed
                        ? AppColors.error
                        : (isDark
                            ? AppColors.successContainer
                            : AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${'payment_method'.tr}: ${payment.paymentMethod.tr}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatterUtils.formatIsoDate(payment.paymentDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
            if (payment.referenceNumber != null &&
                payment.referenceNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${'reference_number'.tr}: ${payment.referenceNumber}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
            if (payment.isReversed) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${'reversed'.tr}: ${payment.reverseReason ?? ''}',
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ),
            ] else if (onReverse != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onReverse,
                  icon:
                      const Icon(Icons.undo, size: 14, color: AppColors.error),
                  label: Text(
                    'reverse_payment'.tr,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
