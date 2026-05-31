import 'product.dart';

/// Müşteri tipi (GDD §3.1). MVP'de 3 tip; VIP post-launch.
enum CustomerType {
  normal(basePatience: 40, displayTr: 'Normal', portrait: 'customers/normal.png'),
  aceleci(basePatience: 15, displayTr: 'Aceleci', portrait: 'customers/aceleci.png'),
  yasli(basePatience: 60, displayTr: 'Yaşlı', portrait: 'customers/yasli.png');

  const CustomerType({
    required this.basePatience,
    required this.displayTr,
    required this.portrait,
  });

  /// Sabır baz süresi (saniye) — GDD §13.3.
  final int basePatience;
  final String displayTr;

  /// Flame `images` kök dizinine göreli portre yolu.
  final String portrait;
}

/// Ödeme yöntemi (GDD §3.4). MVP: nakit + kart.
enum PaymentMethod { cash, card }

/// Nakit ödemede para üstü senaryosu (GDD §3.4).
enum ChangeScenario { exactCash, bigBill }

/// Kasaya gelen tek bir müşteri. Sepet **spawn anında** belirlenir; kasada
/// müşteri vazgeçmez (GDD §3.1).
class Customer {
  Customer({
    required this.type,
    required this.basket,
    required this.paymentMethod,
    required this.changeScenario,
  });

  final CustomerType type;
  final List<Product> basket;
  final PaymentMethod paymentMethod;
  final ChangeScenario changeScenario;

  /// Sepet satış toplamı (kuruş) — slice'ta `defaultSellPrice` baz alınır.
  int get totalKurus =>
      basket.fold(0, (sum, p) => sum + p.defaultSellPriceKurus);

  /// Sepet maliyet toplamı (kuruş) — kâr/marj raporu için.
  int get costKurus => basket.fold(0, (sum, p) => sum + p.costPriceKurus);

  /// `maxPatience = basePatience(type) + basketSize × 4` (GDD §13.3).
  int get maxPatienceSec => type.basePatience + basket.length * 4;
}
