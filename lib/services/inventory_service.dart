import 'package:hive/hive.dart';

import '../models/catalog.dart';
import '../models/inventory_item.dart';
import '../models/pending_order.dart';

/// Stok + raf + bekleyen siparişler (GDD §3.5, §3.6, §9.4 `inventory_v1` box).
///
/// Faz 2 sadeleştirmesi: depo→raf transferi vardiya başında **anlık**
/// (otomatik raflama hızı upgrade'i Faz 3+'da). Raf boş → ürün sepete eklenmez
/// (basket gen tarafı kontrol eder).
class InventoryService {
  InventoryService._(this._box);

  static const String _boxName = 'inventory_v1';
  static const String _itemKeyPrefix = 'i:';
  static const String _pendingKey = 'pending_orders';

  /// Yeni ürün açıldığında seed edilen başlangıç stoku (shelf + warehouse).
  static const int seedShelfQty = 10;
  static const int seedWarehouseQty = 10;

  final Box<dynamic> _box;

  static Future<InventoryService> open() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    return InventoryService._(box);
  }

  /// Katalogdaki açılmış (`storeLevel`) her ürün için item yoksa seed eder.
  void seedMissing(Catalog catalog, int storeLevel) {
    for (final p in catalog.unlocked(storeLevel)) {
      if (_box.get('$_itemKeyPrefix${p.id}') != null) continue;
      _put(
        InventoryItem(
          productId: p.id,
          shelfQty: seedShelfQty,
          warehouseQty: seedWarehouseQty,
          currentSellPriceKurus: p.defaultSellPriceKurus,
        ),
      );
    }
  }

  Iterable<InventoryItem> all() sync* {
    for (final key in _box.keys) {
      if (key is String && key.startsWith(_itemKeyPrefix)) {
        final raw = _box.get(key);
        if (raw is Map) yield InventoryItem.fromJson(raw);
      }
    }
  }

  InventoryItem? get(String productId) {
    final raw = _box.get('$_itemKeyPrefix$productId');
    return raw is Map ? InventoryItem.fromJson(raw) : null;
  }

  void _put(InventoryItem item) {
    _box.put('$_itemKeyPrefix${item.productId}', item.toJson());
  }

  void updateItem(InventoryItem item) => _put(item);

  /// Raf stoğunu [qty] kadar düşürür (satış / sepet ekleme).
  void depleteShelf(String productId, int qty) {
    final item = get(productId);
    if (item == null) return;
    final newShelf = (item.shelfQty - qty).clamp(0, 1 << 30);
    _put(item.copyWith(shelfQty: newShelf));
  }

  // --- Pending Orders ---

  List<PendingOrder> pendingOrders() {
    final raw = _box.get(_pendingKey);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) PendingOrder.fromJson(e),
    ];
  }

  void _savePending(List<PendingOrder> orders) {
    _box.put(_pendingKey, [for (final o in orders) o.toJson()]);
  }

  /// Yeni sipariş ekler — çağıran [SaveService.coinsKurus]'tan
  /// [costPaidKurus] düşmeli (UI tarafı).
  void placeOrder(PendingOrder order) {
    _savePending([...pendingOrders(), order]);
  }

  /// Vardiya [currentShiftNumber] başlamadan önce çağrılır: önceki
  /// vardiyalardan kalan siparişler depoya iner ve listeden silinir.
  /// Teslim edilen siparişleri döndürür (rapor/log için).
  List<PendingOrder> processDeliveries(int currentShiftNumber) {
    final pending = pendingOrders();
    final delivered = <PendingOrder>[];
    final remaining = <PendingOrder>[];
    for (final o in pending) {
      if (o.placedShiftNumber < currentShiftNumber) {
        delivered.add(o);
        final item = get(o.productId);
        if (item != null) {
          _put(item.copyWith(warehouseQty: item.warehouseQty + o.quantity));
        }
      } else {
        remaining.add(o);
      }
    }
    if (delivered.isNotEmpty) _savePending(remaining);
    return delivered;
  }

  /// Depoda biriken mal anlık olarak rafa taşınır (Faz 2 sadeleştirmesi).
  void moveAllWarehouseToShelf() {
    for (final item in all().toList()) {
      if (item.warehouseQty <= 0) continue;
      _put(
        item.copyWith(
          shelfQty: item.shelfQty + item.warehouseQty,
          warehouseQty: 0,
        ),
      );
    }
  }

  /// Auto-reorder eşiği altına düşen ürünler için **öneri** sipariş listesi
  /// (oyuncu vardiya sonunda "Tümünü onayla" der; GDD §23.5).
  /// Önerilen miktar: eşiğin 2 katı kadar tampon (yaklaşık 2 vardiya stoğu).
  List<({String productId, int quantity})> autoReorderSuggestions() {
    final out = <({String productId, int quantity})>[];
    for (final item in all()) {
      if (!item.autoReorderEnabled) continue;
      if (item.autoReorderThreshold <= 0) continue;
      if (item.totalQty >= item.autoReorderThreshold) continue;
      final target = item.autoReorderThreshold * 2;
      final qty = target - item.totalQty;
      if (qty > 0) out.add((productId: item.productId, quantity: qty));
    }
    return out;
  }

  Future<void> reset() async => _box.clear();
}
