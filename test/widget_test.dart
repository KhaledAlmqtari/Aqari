import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate/core/widgets/custom_button.dart';
import 'package:real_estate/core/widgets/kpi_card.dart';
import 'package:real_estate/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders label and dot icon properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'active', label: 'نشط'),
        ),
      ),
    );

    expect(find.text('نشط'), findsOneWidget);
  });

  testWidgets('CustomButton renders text and triggers callback',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'حفظ',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('حفظ'), findsOneWidget);
    await tester.tap(find.byType(CustomButton));
    await tester.pump();
    expect(tapped, true);
  });

  testWidgets('KpiCard renders metric value and title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            title: 'إجمالي العقارات',
            value: '5',
            icon: Icons.apartment,
          ),
        ),
      ),
    );

    expect(find.text('إجمالي العقارات'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.apartment), findsOneWidget);
  });
}
