import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog.dart';
import '../models/inventory_item.dart';
import '../models/pending_order.dart';
import '../services/inventory_service.dart';
import 'app_providers.dart';

class InventoryNotifier extends StateNotifier<Map<String, InventoryItem>> {
  InventoryNotifier(this._service) : super(_snapshot(_service));

  final InventoryService _service;

  static Map<String, InventoryItem> _snapshot(InventoryService svc) {
    return {for (final i in svc.all()) i.productId: i};
  }

  void _refresh() => state = _snapshot(_service);

  /// Yeni unlock'lar için seed; mevcut item'lara dokunmaz.
  void ensureSeeded(Catalog catalog, int storeLevel) {
    _service.seedMissing(catalog, storeLevel);
    _refresh();
  }

  void setItem(InventoryItem item) {
    _service.updateItem(item);
    state = {...state, item.productId: item};
  }

  void depleteShelf(String productId, int qty) {
    _service.depleteShelf(productId, qty);
    _refresh();
  }

  /// Sipariş ekler. Çağıran B-Coin düşümünü ekonomi tarafında yapmalı.
  void placeOrder({
    required String productId,
    required int quantity,
    required int costPaidKurus,
    required int currentShiftNumber,
  }) {
    _service.placeOrder(
      PendingOrder(
        productId: productId,
        quantity: quantity,
        placedShiftNumber: currentShiftNumber,
        costPaidKurus: costPaidKurus,
      ),
    );
  }

  /// Vardiya başında çağrılır: bekleyen siparişleri depoya indir + depodan
  /// rafa taşı. Teslim edilen siparişleri döndürür (UI bilgilendirme için).
  List<PendingOrder> processShiftStart(int currentShiftNumber) {
    final delivered = _service.processDeliveries(currentShiftNumber);
    _service.moveAllWarehouseToShelf();
    _refresh();
    return delivered;
  }

  List<({String productId, int quantity})> autoReorderSuggestions() =>
      _service.autoReorderSuggestions();

  Future<void> reset() async {
    await _service.reset();
    state = {};
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, Map<String, InventoryItem>>(
      (ref) => InventoryNotifier(ref.watch(inventoryServiceProvider)),
    );
