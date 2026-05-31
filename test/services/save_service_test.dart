import 'dart:io';

import 'package:barcode_boss/models/shift_record.dart';
import 'package:barcode_boss/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('hive_save_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('lastShiftRecord başlangıçta null', () async {
    final svc = await SaveService.open();
    expect(svc.lastShiftRecord, isNull);
  });

  test('lastShiftRecord set + get roundtrip (Hive persistence)', () async {
    final svc1 = await SaveService.open();
    const record = ShiftRecord(
      shiftNumber: 7,
      customersServed: 12,
      customersLost: 1,
      missedDemand: 2,
      wrongChange: 0,
      revenueKurus: 45000,
      costKurus: 18000,
      xpEarned: 25,
      tutorialBonusKurus: 0,
      repaymentKurus: 5400,
      emergencyAdvanceKurus: 0,
    );
    svc1.lastShiftRecord = record;

    // Aynı session içinde okuma
    expect(svc1.lastShiftRecord, isNotNull);
    expect(svc1.lastShiftRecord!.shiftNumber, 7);
    expect(svc1.lastShiftRecord!.repaymentKurus, 5400);

    // Hive'ı kapat + yeniden aç (uygulama restart simülasyonu)
    await Hive.close();
    Hive.init(tempDir.path);
    final svc2 = await SaveService.open();
    final restored = svc2.lastShiftRecord;
    expect(restored, isNotNull);
    expect(restored!.shiftNumber, 7);
    expect(restored.netKurus, 45000 - 18000);
    expect(restored.repaymentKurus, 5400);
    expect(restored.coinDeltaKurus, 45000 - 18000 - 5400);
  });

  test('lastShiftRecord = null silme', () async {
    final svc = await SaveService.open();
    svc.lastShiftRecord = const ShiftRecord(
      shiftNumber: 1,
      customersServed: 0,
      customersLost: 0,
      missedDemand: 0,
      wrongChange: 0,
      revenueKurus: 0,
      costKurus: 0,
      xpEarned: 0,
    );
    expect(svc.lastShiftRecord, isNotNull);
    svc.lastShiftRecord = null;
    expect(svc.lastShiftRecord, isNull);
  });

  test('reset() lastShiftRecord\'u da temizler', () async {
    final svc = await SaveService.open();
    svc.lastShiftRecord = const ShiftRecord(
      shiftNumber: 3,
      customersServed: 5,
      customersLost: 0,
      missedDemand: 0,
      wrongChange: 0,
      revenueKurus: 10000,
      costKurus: 4000,
      xpEarned: 10,
    );
    await svc.reset();
    expect(svc.lastShiftRecord, isNull);
    expect(svc.shiftNumber, 1); // default
  });
}
