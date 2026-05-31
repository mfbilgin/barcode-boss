/// Bir ürünün depo/raf stoğu, oyuncunun ayarladığı satış fiyatı ve auto-reorder
/// yapılandırması (GDD §3.5, §3.6).
class InventoryItem {
  const InventoryItem({
    required this.productId,
    required this.shelfQty,
    required this.warehouseQty,
    required this.currentSellPriceKurus,
    this.autoReorderThreshold = 0,
    this.autoReorderEnabled = false,
  });

  final String productId;
  final int shelfQty;
  final int warehouseQty;

  /// Oyuncunun fiyat slider'ı ile ayarladığı fiyat (kuruş). Başlangıçta
  /// `defaultSellPriceKurus`'a eşit (GDD §3.2, §3.5).
  final int currentSellPriceKurus;

  /// Auto-reorder eşiği (depo+raf toplam < eşik → vardiya sonu öneri).
  final int autoReorderThreshold;
  final bool autoReorderEnabled;

  int get totalQty => shelfQty + warehouseQty;

  /// `currentSellPrice / defaultSellPrice` oranı için yardımcı (kullanan kod
  /// `defaultSellPriceKurus`'u dışarıdan verir).
  double priceRatio(int defaultSellPriceKurus) =>
      currentSellPriceKurus / defaultSellPriceKurus;

  InventoryItem copyWith({
    int? shelfQty,
    int? warehouseQty,
    int? currentSellPriceKurus,
    int? autoReorderThreshold,
    bool? autoReorderEnabled,
  }) {
    return InventoryItem(
      productId: productId,
      shelfQty: shelfQty ?? this.shelfQty,
      warehouseQty: warehouseQty ?? this.warehouseQty,
      currentSellPriceKurus:
          currentSellPriceKurus ?? this.currentSellPriceKurus,
      autoReorderThreshold: autoReorderThreshold ?? this.autoReorderThreshold,
      autoReorderEnabled: autoReorderEnabled ?? this.autoReorderEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'shelfQty': shelfQty,
    'warehouseQty': warehouseQty,
    'currentSellPriceKurus': currentSellPriceKurus,
    'autoReorderThreshold': autoReorderThreshold,
    'autoReorderEnabled': autoReorderEnabled,
  };

  factory InventoryItem.fromJson(Map json) {
    return InventoryItem(
      productId: json['productId'] as String,
      shelfQty: json['shelfQty'] as int,
      warehouseQty: json['warehouseQty'] as int,
      currentSellPriceKurus: json['currentSellPriceKurus'] as int,
      autoReorderThreshold: (json['autoReorderThreshold'] as int?) ?? 0,
      autoReorderEnabled: (json['autoReorderEnabled'] as bool?) ?? false,
    );
  }
}
