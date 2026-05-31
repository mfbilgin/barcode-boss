import 'dart:io';

import 'package:barcode_boss/models/catalog.dart';
import 'package:barcode_boss/models/pending_order.dart';
import 'package:barcode_boss/services/inventory_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Catalog _twoProductCatalog() => Catalog.fromJson({
  'schema_version': 1,
  'categories': {
    'gida_temel': {'name_tr': 'Gıda', 'emoji': '🍞', 'unlock_level': 1},
  },
  'products': [
    {
      'id': 'bread',
      'name_i18n': {'tr': 'Ekmek'},
      'category': 'gida_temel',
      'cost_price_kurus': 125,
      'default_sell_price_kurus': 250,
      'elasticity': 0,
      'unlock_level': 1,
      'icon_asset': 'assets/images/products/bread.png',
    },
    {
      'id': 'milk_carton',
      'name_i18n': {'tr': 'Süt'},
      'category': 'gida_temel',
      'cost_price_kurus': 550,
      'default_sell_price_kurus': 800,
      'elasticity': 0,
      'unlock_level': 1,
      'icon_asset': 'assets/images/products/milk_carton.png',
    },
  ],
});

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('hive_inv_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('seedMissing açılmış ürünler için item oluşturur', () async {
    final svc = await InventoryService.open();
    svc.seedMissing(_twoProductCatalog(), 1);
    expect(svc.get('bread'), isNotNull);
    expect(svc.get('milk_carton'), isNotNull);
    expect(svc.get('bread')!.shelfQty, InventoryService.seedShelfQty);
  });

  test('depleteShelf raf stoğunu düşürür, 0\'ın altına inmez', () async {
    final svc = await InventoryService.open();
    svc.seedMissing(_twoProductCatalog(), 1);
    svc.depleteShelf('bread', 3);
    expect(svc.get('bread')!.shelfQty, InventoryService.seedShelfQty - 3);
    svc.depleteShelf('bread', 100);
    expect(svc.get('bread')!.shelfQty, 0);
  });

  test('placeOrder + processDeliveries depoya iner', () async {
    final svc = await InventoryService.open();
    svc.seedMissing(_twoProductCatalog(), 1);
    svc.placeOrder(
      const PendingOrder(
        productId: 'bread',
        quantity: 50,
        placedShiftNumber: 1,
        costPaidKurus: 6250,
      ),
    );
    expect(svc.pendingOrders().length, 1);

    // Aynı vardiyada teslim edilmez.
    final delivered1 = svc.processDeliveries(1);
    expect(delivered1, isEmpty);

    // Sonraki vardiyada teslim edilir.
    final delivered2 = svc.processDeliveries(2);
    expect(delivered2.length, 1);
    expect(
      svc.get('bread')!.warehouseQty,
      InventoryService.seedWarehouseQty + 50,
    );
    expect(svc.pendingOrders(), isEmpty);
  });

  test('moveAllWarehouseToShelf depoyu boşaltır, rafa ekler', () async {
    final svc = await InventoryService.open();
    svc.seedMissing(_twoProductCatalog(), 1);
    final before = svc.get('bread')!;
    svc.moveAllWarehouseToShelf();
    final after = svc.get('bread')!;
    expect(after.warehouseQty, 0);
    expect(after.shelfQty, before.shelfQty + before.warehouseQty);
  });

  test('autoReorderSuggestions yalnızca enabled + eşik altı', () async {
    final svc = await InventoryService.open();
    svc.seedMissing(_twoProductCatalog(), 1);
    // bread: enabled, eşik 30 — toplam 20 < 30 → öneri
    final bread = svc.get('bread')!;
    svc.updateItem(
      bread.copyWith(autoReorderThreshold: 30, autoReorderEnabled: true),
    );
    // milk_carton: disabled
    final s = svc.autoReorderSuggestions();
    expect(s.length, 1);
    expect(s.first.productId, 'bread');
    expect(s.first.quantity, greaterThan(0));
  });
}
