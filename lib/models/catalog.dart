import 'product.dart';

/// Ürün kategorisi — başlık + emoji (GDD §7.9: kategori başlıkları emoji ile).
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.nameTr,
    required this.emoji,
    required this.unlockLevel,
  });

  final String id;
  final String nameTr;
  final String emoji;
  final int unlockLevel;

  factory ProductCategory.fromJson(String id, Map<String, dynamic> json) {
    return ProductCategory(
      id: id,
      nameTr: json['name_tr'] as String,
      emoji: json['emoji'] as String,
      unlockLevel: json['unlock_level'] as int,
    );
  }

  /// `"🍞 Gıda Temel"` (GDD §7.9).
  String get heading => '$emoji $nameTr';
}

/// `products.json`'dan yüklenen master katalog (GDD §9.4 hibrit JSON+Hive).
class Catalog {
  const Catalog({
    required this.schemaVersion,
    required this.categories,
    required this.products,
  });

  final int schemaVersion;
  final Map<String, ProductCategory> categories;
  final List<Product> products;

  Product byId(String id) => products.firstWhere((p) => p.id == id);

  /// Mağaza seviyesine kadar açılmış ürünler (GDD §13.2 sepet üretimi).
  List<Product> unlocked(int storeLevel) =>
      products.where((p) => p.unlockLevel <= storeLevel).toList();

  /// Faz 1 vertical slice ürünleri (GDD §23.6).
  List<Product> get verticalSlice =>
      products.where((p) => p.verticalSlice).toList();

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final rawCats = (json['categories'] as Map<String, dynamic>?) ?? const {};
    final categories = <String, ProductCategory>{
      for (final entry in rawCats.entries)
        entry.key: ProductCategory.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        ),
    };

    final rawProducts = (json['products'] as List<dynamic>?) ?? const [];
    final products = rawProducts
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();

    return Catalog(
      schemaVersion: (json['schema_version'] as int?) ?? 1,
      categories: categories,
      products: products,
    );
  }
}
