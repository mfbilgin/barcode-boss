/// Fiyat elastikiyeti formülleri (GDD §3.5).
///
/// Müşteri spawn anında her uygun ürün için [purchaseChance] hesaplanır;
/// başarılı kontroller sepete eklenir, başarısızlar **kaçırılan talep** olarak
/// raporlanır. İndirimli (priceRatio < 1.0) elastik ürünlerde [basketBoost]
/// ile aynı müşteri ekstra adet ekleyebilir.
abstract class Elasticity {
  /// `clamp(1 - (priceRatio - 1) × elasticity × 0.6, 0.05, 1.0)` (fiyat ≥ default)
  /// veya `1.0` (fiyat < default). [elasticity] 0 = inelastik, 1 = normal, 2 = elastik.
  static double purchaseChance({
    required int currentSellPriceKurus,
    required int defaultSellPriceKurus,
    required int elasticity,
  }) {
    if (defaultSellPriceKurus <= 0) return 0;
    final priceRatio = currentSellPriceKurus / defaultSellPriceKurus;
    if (priceRatio < 1.0) return 1.0;
    final raw = 1 - (priceRatio - 1) * elasticity * 0.6;
    return raw.clamp(0.05, 1.0);
  }

  /// `(1 - priceRatio) × elasticity × 0.8` (yalnızca priceRatio < 1.0). 0..0.8.
  /// Aynı müşteri spawn anında elastik ürüne bu olasılıkla bir ek adet ekler.
  static double basketBoost({
    required int currentSellPriceKurus,
    required int defaultSellPriceKurus,
    required int elasticity,
  }) {
    if (defaultSellPriceKurus <= 0) return 0;
    final priceRatio = currentSellPriceKurus / defaultSellPriceKurus;
    if (priceRatio >= 1.0) return 0;
    return ((1 - priceRatio) * elasticity * 0.8).clamp(0, 0.8);
  }
}
