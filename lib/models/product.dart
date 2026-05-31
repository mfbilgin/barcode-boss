/// Tek bir ürün katalog kaydı (GDD §3.2, §23.2).
///
/// Tüm fiyatlar **integer kuruş** cinsinden (1 B-Coin = 100 kuruş).
class Product {
  const Product({
    required this.id,
    required this.nameTr,
    required this.category,
    required this.costPriceKurus,
    required this.defaultSellPriceKurus,
    required this.elasticity,
    required this.unlockLevel,
    required this.iconAsset,
    this.verticalSlice = false,
  });

  final String id;
  final String nameTr;
  final String category;
  final int costPriceKurus;
  final int defaultSellPriceKurus;

  /// 0 = inelastik, 1 = normal, 2 = elastik (GDD §3.2).
  final int elasticity;
  final int unlockLevel;
  final String iconAsset;

  /// Faz 1 vertical slice prototipinde kullanılan ilk 3 ürün (GDD §23.6).
  final bool verticalSlice;

  factory Product.fromJson(Map<String, dynamic> json) {
    final names = (json['name_i18n'] as Map<String, dynamic>?) ?? const {};
    return Product(
      id: json['id'] as String,
      nameTr: (names['tr'] as String?) ?? (json['id'] as String),
      category: json['category'] as String,
      costPriceKurus: json['cost_price_kurus'] as int,
      defaultSellPriceKurus: json['default_sell_price_kurus'] as int,
      elasticity: json['elasticity'] as int,
      unlockLevel: json['unlock_level'] as int,
      iconAsset: json['icon_asset'] as String,
      verticalSlice: (json['vertical_slice'] as bool?) ?? false,
    );
  }

  /// Sprite yükleme yolu — `assets/` öneki Flame `images` prefix'ine göre çıkarılır.
  /// (Flame `Images` kök dizini `assets/images/` olarak ayarlanır.)
  String get spriteName {
    const prefix = 'assets/images/';
    return iconAsset.startsWith(prefix)
        ? iconAsset.substring(prefix.length)
        : iconAsset;
  }
}
