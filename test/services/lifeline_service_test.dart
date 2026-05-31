import 'dart:io';

import 'package:barcode_boss/services/lifeline_service.dart';
import 'package:barcode_boss/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late SaveService save;
  late LifelineService lifeline;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_lifeline_test_');
    Hive.init(tempDir.path);
    save = await SaveService.open();
    lifeline = LifelineService(save);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('§14.3 tutorial bonusu', () {
    test('ilk 5 vardiya boyunca her vardiya sonu +50 BC eklenir', () {
      for (var s = 1; s <= Lifelines.tutorialBonusShifts; s++) {
        final r = lifeline.processShiftEnd(
          shiftNumber: s,
          netKurus: 10000,
          coinsBeforeKurus: 100000,
          inventoryAllZero: false,
          pendingOrdersEmpty: false,
        );
        expect(
          r.tutorialBonusKurus,
          Lifelines.tutorialBonusKurus,
          reason: 'Vardiya $s bonus almalı',
        );
      }
    });

    test('6. vardiyadan itibaren bonus verilmez', () {
      final r = lifeline.processShiftEnd(
        shiftNumber: 6,
        netKurus: 10000,
        coinsBeforeKurus: 100000,
        inventoryAllZero: false,
        pendingOrdersEmpty: false,
      );
      expect(r.tutorialBonusKurus, 0);
    });
  });

  group('§14.2 acil avans tetik', () {
    test(
      'bakiye<100 + inventory boş + pending boş → +500 BC + repay=3',
      () {
        save.coinsKurus = 5000; // 50 BC, net 0 olunca da eşiğin altında
        final r = lifeline.processShiftEnd(
          shiftNumber: 10, // tutorial bonus dışı
          netKurus: 0,
          coinsBeforeKurus: save.coinsKurus,
          inventoryAllZero: true,
          pendingOrdersEmpty: true,
        );
        expect(r.emergencyAdvanceKurus, Lifelines.emergencyAdvanceKurus);
        expect(save.emergencyAdvanceCount, 1);
        expect(
          save.advanceRepayShiftsRemaining,
          Lifelines.repaymentShifts,
        );
      },
    );

    test('bakiye yeterli ise tetiklenmez', () {
      save.coinsKurus = 50000; // 500 BC > 100 eşiği
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 0,
        coinsBeforeKurus: save.coinsKurus,
        inventoryAllZero: true,
        pendingOrdersEmpty: true,
      );
      expect(r.emergencyAdvanceKurus, 0);
      expect(save.emergencyAdvanceCount, 0);
    });

    test('inventory varsa tetiklenmez', () {
      save.coinsKurus = 1000;
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 0,
        coinsBeforeKurus: save.coinsKurus,
        inventoryAllZero: false,
        pendingOrdersEmpty: true,
      );
      expect(r.emergencyAdvanceKurus, 0);
    });

    test('pending sipariş varsa tetiklenmez', () {
      save.coinsKurus = 1000;
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 0,
        coinsBeforeKurus: save.coinsKurus,
        inventoryAllZero: true,
        pendingOrdersEmpty: false,
      );
      expect(r.emergencyAdvanceKurus, 0);
    });

    test('lifetime 3. tetik sonrası bir daha verilmez', () {
      save
        ..coinsKurus = 0
        ..emergencyAdvanceCount = Lifelines.emergencyAdvanceMaxLifetime;
      final r = lifeline.processShiftEnd(
        shiftNumber: 20,
        netKurus: 0,
        coinsBeforeKurus: 0,
        inventoryAllZero: true,
        pendingOrdersEmpty: true,
      );
      expect(r.emergencyAdvanceKurus, 0);
      expect(
        save.emergencyAdvanceCount,
        Lifelines.emergencyAdvanceMaxLifetime,
      );
    });
  });

  group('§14.2 geri ödeme', () {
    test('aktif repayment varsa net\'in %20\'si kesilir, counter azalır', () {
      save.advanceRepayShiftsRemaining = 3;
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 50000, // 500 BC
        coinsBeforeKurus: 100000,
        inventoryAllZero: false,
        pendingOrdersEmpty: false,
      );
      expect(r.repaymentKurus, 10000); // %20 × 500 = 100 BC
      expect(save.advanceRepayShiftsRemaining, 2);
    });

    test('net negatif/sıfır ise repayment alınmaz, counter azalmaz', () {
      save.advanceRepayShiftsRemaining = 3;
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: -5000,
        coinsBeforeKurus: 100000,
        inventoryAllZero: false,
        pendingOrdersEmpty: false,
      );
      expect(r.repaymentKurus, 0);
      expect(save.advanceRepayShiftsRemaining, 3);
    });

    test('vardiya başına max 200 BC kesilir (yüksek net cap\'lenir)', () {
      save.advanceRepayShiftsRemaining = 3;
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 200000, // 2000 BC × %20 = 400 BC → 200 BC cap
        coinsBeforeKurus: 100000,
        inventoryAllZero: false,
        pendingOrdersEmpty: false,
      );
      expect(r.repaymentKurus, Lifelines.repaymentMaxPerShiftKurus);
    });

    test('counter 0 ise repayment uygulanmaz', () {
      final r = lifeline.processShiftEnd(
        shiftNumber: 10,
        netKurus: 50000,
        coinsBeforeKurus: 100000,
        inventoryAllZero: false,
        pendingOrdersEmpty: false,
      );
      expect(r.repaymentKurus, 0);
    });
  });

  group('§14.4 stok=0 lifeline', () {
    test('inventory varsa allow döner', () {
      final r = lifeline.checkStockZero(inventoryAllZero: false);
      expect(r.shouldBlockStart, false);
      expect(r.advanceKurus, 0);
    });

    test('inventory boş + bakiye yetersiz → block + 200 BC avans', () {
      save.coinsKurus = 5000; // 50 BC < 200 BC eşik
      final coinsBefore = save.coinsKurus;
      final r = lifeline.checkStockZero(inventoryAllZero: true);
      expect(r.shouldBlockStart, true);
      expect(r.advanceKurus, Lifelines.stockZeroAdvanceKurus);
      expect(save.coinsKurus, coinsBefore + Lifelines.stockZeroAdvanceKurus);
      expect(save.stockZeroAdvanceCount, 1);
    });

    test('inventory boş + bakiye yeterli → block ama avans verilmez', () {
      save.coinsKurus = 50000; // 500 BC yeterli
      final r = lifeline.checkStockZero(inventoryAllZero: true);
      expect(r.shouldBlockStart, true);
      expect(r.advanceKurus, 0);
      expect(save.coinsKurus, 50000);
      expect(save.stockZeroAdvanceCount, 0);
    });

    test('lifetime 3 sonrası avans verilmez (block hâlâ true)', () {
      save
        ..coinsKurus = 1000
        ..stockZeroAdvanceCount = Lifelines.stockZeroAdvanceMaxLifetime;
      final r = lifeline.checkStockZero(inventoryAllZero: true);
      expect(r.shouldBlockStart, true);
      expect(r.advanceKurus, 0);
      expect(save.coinsKurus, 1000);
    });
  });

  group('integrasyon: bonus + repayment + lifeline aynı vardiyada', () {
    test('hepsi tek seferde uygulanır', () {
      save
        ..coinsKurus = 1000 // 10 BC — eşik altı
        ..advanceRepayShiftsRemaining = 2;
      final r = lifeline.processShiftEnd(
        shiftNumber: 3, // tutorial bonus aktif
        netKurus: 30000, // 300 BC
        coinsBeforeKurus: save.coinsKurus,
        inventoryAllZero: true,
        pendingOrdersEmpty: true,
      );
      // tutorial bonus = 5000
      expect(r.tutorialBonusKurus, Lifelines.tutorialBonusKurus);
      // repayment = 30000 × 20% = 6000
      expect(r.repaymentKurus, 6000);
      // coinsAfterRegular = 1000 + 30000 + 5000 - 6000 = 30000 → 300 BC,
      // 10.000 kuruş eşiği üstünde, advance TETİKLENMEMELİ.
      expect(r.emergencyAdvanceKurus, 0);
      expect(save.advanceRepayShiftsRemaining, 1);
    });
  });
}
