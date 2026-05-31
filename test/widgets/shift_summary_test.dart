import 'package:barcode_boss/l10n/gen/app_localizations.dart';
import 'package:barcode_boss/models/shift_record.dart';
import 'package:barcode_boss/screens/shift_summary_screen.dart';
import 'package:barcode_boss/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _screen(ShiftRecord record) {
  return ProviderScope(
    overrides: [lastShiftProvider.overrideWith((ref) => record)],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('tr'),
      home: ShiftSummaryScreen(),
    ),
  );
}

void main() {
  testWidgets('ShiftSummaryScreen rapor değerlerini gösterir', (tester) async {
    const record = ShiftRecord(
      shiftNumber: 3,
      customersServed: 8,
      customersLost: 0,
      missedDemand: 2,
      wrongChange: 0,
      revenueKurus: 24750,
      costKurus: 9800,
      xpEarned: 38,
    );

    await tester.pumpWidget(_screen(record));
    await tester.pumpAndSettle();

    expect(find.text('🎉 Kepenk Kapandı!'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('🪙 247,50'), findsOneWidget);
    expect(find.text('-🪙 98,00'), findsOneWidget);
    expect(find.text('+🪙 149,50'), findsOneWidget);
    expect(find.text('+38'), findsOneWidget);

    // §14 alanları sıfır iken hiçbir lifeline satırı gösterilmez.
    expect(find.text('Yeni başlayan bonusu'), findsNothing);
    expect(find.text('Avans geri ödemesi'), findsNothing);
    expect(find.text('Acil avans'), findsNothing);
  });

  testWidgets(
    'ShiftSummaryScreen tutorial bonusu satırını gösterir (§14.3)',
    (tester) async {
      const record = ShiftRecord(
        shiftNumber: 2,
        customersServed: 5,
        customersLost: 0,
        missedDemand: 0,
        wrongChange: 0,
        revenueKurus: 12500,
        costKurus: 6000,
        xpEarned: 20,
        tutorialBonusKurus: 5000,
      );
      await tester.pumpWidget(_screen(record));
      await tester.pumpAndSettle();

      expect(find.text('Yeni başlayan bonusu'), findsOneWidget);
      expect(find.text('+🪙 50,00'), findsOneWidget);
    },
  );

  testWidgets(
    'ShiftSummaryScreen avans geri ödemesi satırını gösterir (§14.2)',
    (tester) async {
      const record = ShiftRecord(
        shiftNumber: 7,
        customersServed: 12,
        customersLost: 0,
        missedDemand: 0,
        wrongChange: 0,
        revenueKurus: 50000,
        costKurus: 20000,
        xpEarned: 40,
        repaymentKurus: 6000,
      );
      await tester.pumpWidget(_screen(record));
      await tester.pumpAndSettle();

      expect(find.text('Avans geri ödemesi'), findsOneWidget);
      expect(find.text('-🪙 60,00'), findsOneWidget);
    },
  );

  testWidgets(
    'ShiftSummaryScreen acil avans dialog\'u açar (§14.2)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const record = ShiftRecord(
        shiftNumber: 10,
        customersServed: 0,
        customersLost: 3,
        missedDemand: 0,
        wrongChange: 0,
        revenueKurus: 0,
        costKurus: 5000,
        xpEarned: 0,
        emergencyAdvanceKurus: 50000,
      );
      await tester.pumpWidget(_screen(record));
      await tester.pumpAndSettle();

      // Rapor satırı
      expect(find.text('Acil avans'), findsOneWidget);
      expect(find.text('+🪙 500,00'), findsOneWidget);
      // Dialog
      expect(find.text('Acil avans aldın!'), findsOneWidget);
      expect(find.textContaining('🪙 500,00'), findsWidgets);
      expect(find.text('Anladım'), findsOneWidget);
    },
  );
}
