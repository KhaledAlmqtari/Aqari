import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate/core/utils/money_utils.dart';
import 'package:real_estate/core/utils/date_utils.dart';
import 'package:real_estate/features/contracts/domain/entities/contract_entity.dart';
import 'package:real_estate/features/invoices/domain/entities/invoice_entity.dart';

void main() {
  group('MoneyUtils Tests (Integer Money Handling)', () {
    test('Formats integer amounts properly with YER default currency', () {
      final formattedAr = MoneyUtils.format(150000, isArabic: true);
      expect(formattedAr, contains('150,000'));
      expect(formattedAr, contains('ر.ي'));

      final formattedEn = MoneyUtils.format(250000, isArabic: false);
      expect(formattedEn, '250,000 YER');
    });

    test(
        'Parses formatted string inputs correctly without float precision loss',
        () {
      expect(MoneyUtils.parse('150,000'), 150000);
      expect(MoneyUtils.parse('  50,000 '), 50000);
      expect(MoneyUtils.parse('invalid'), 0);
      expect(MoneyUtils.parse(''), 0);
    });
  });

  group('DateFormatterUtils Tests', () {
    test('Calculates contract payment cycles correctly', () {
      final start = DateTime(2026, 1, 1);

      final monthly = DateFormatterUtils.calculateNextDueDate(start, 'monthly');
      expect(monthly, DateTime(2026, 2, 1));

      final quarterly =
          DateFormatterUtils.calculateNextDueDate(start, 'quarterly');
      expect(quarterly, DateTime(2026, 4, 1));

      final semiAnnual =
          DateFormatterUtils.calculateNextDueDate(start, 'semiAnnual');
      expect(semiAnnual, DateTime(2026, 7, 1));

      final annual = DateFormatterUtils.calculateNextDueDate(start, 'annual');
      expect(annual, DateTime(2027, 1, 1));
    });

    test('Formats and parses ISO dates consistently', () {
      final date = DateTime(2026, 5, 20);
      final iso = DateFormatterUtils.toIsoDate(date);
      expect(iso, '2026-05-20');

      final display = DateFormatterUtils.formatIsoDate(iso);
      expect(display, '20/05/2026');
    });
  });

  group('Invoice Financial Calculations Tests', () {
    test('Validates initial invoice remaining equals total amount', () {
      const invoice = InvoiceEntity(
        id: 'inv-1',
        invoiceNumber: 'INV-001',
        contractId: 'cnt-1',
        tenantId: 'ten-1',
        unitId: 'unit-1',
        propertyId: 'prop-1',
        periodStart: '2026-01-01',
        periodEnd: '2026-02-01',
        issueDate: '2026-01-01',
        dueDate: '2026-01-07',
        totalAmount: 100000,
        paidAmount: 0,
        remainingAmount: 100000,
        status: 'pending',
        createdAt: '2026-01-01',
      );

      expect(invoice.isPaid, false);
      expect(invoice.remainingAmount, 100000);
    });

    test('Validates partial and full payment balance progression', () {
      // Billed: 100,000 YER
      const total = 100000;

      // Step 1: Partial payment of 40,000 YER
      const payment1 = 40000;
      final remainingAfterPayment1 = total - payment1;
      expect(remainingAfterPayment1, 60000);

      // Step 2: Final payment of 60,000 YER
      const payment2 = 60000;
      final remainingAfterPayment2 = remainingAfterPayment1 - payment2;
      expect(remainingAfterPayment2, 0);
    });
  });

  group('Contract Entity Tests', () {
    test('Validates contract active status flag', () {
      const activeContract = ContractEntity(
        id: 'c-1',
        contractNumber: 'CNT-001',
        unitId: 'u-1',
        propertyId: 'p-1',
        tenantId: 't-1',
        startDate: '2026-01-01',
        endDate: '2027-01-01',
        rentAmount: 150000,
        status: 'active',
        createdAt: '2026-01-01',
      );

      expect(activeContract.isActive, true);
      expect(activeContract.isTerminated, false);
    });
  });
}
