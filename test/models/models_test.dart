import 'package:barcode_boss/models/catalog.dart';
import 'package:barcode_boss/models/customer_model.dart';
import 'package:barcode_boss/models/product.dart';
import 'package:barcode_boss/models/shift_record.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p(String id, {int sell = 500, int cost = 250, int unlock = 1, bool vs = false}) {
  return Product(
    id: id,
    nameTr: id,
    category: 'gida_temel',
    costPriceKurus: cost,
    defaultSellPriceKurus: sell,
    elasticity: 1,
    unlockLevel: unlock,
    iconAsset: 'assets/images/products/$id.png',
    verticalSlice: vs,
  );
}

void main() {
  group('Customer.maxPatienceSec (GDD §13.3)', () {
    test('normal 5 ürünlü = 60s, aceleci = 35s, yaşlı = 80s', () {
      final basket = [for (var i = 0; i < 5; i++) _p('x$i')];
      expect(
        Customer(
          type: CustomerType.normal,
          basket: basket,
          paymentMethod: PaymentMethod.cash,
          changeScenario: ChangeScenario.exactCash,
        ).maxPatienceSec,
        60,
      );
      expect(
        Customer(
          type: CustomerType.aceleci,
          basket: basket,
          paymentMethod: PaymentMethod.cash,
          changeScenario: ChangeScenario.exactCash,
        ).maxPatienceSec,
        35,
      );
      expect(
        Customer(
          type: CustomerType.yasli,
          basket: basket,
          paymentMethod: PaymentMethod.cash,
          changeScenario: ChangeScenario.exactCash,
        ).maxPatienceSec,
        80,
      );
    });

    test('sepet toplamı = satış fiyatları toplamı', () {
      final c = Customer(
        type: CustomerType.normal,
        basket: [_p('a', sell: 250), _p('b', sell: 800)],
        paymentMethod: PaymentMethod.cash,
        changeScenario: ChangeScenario.exactCash,
      );
      expect(c.totalKurus, 1050);
    });
  });

  group('ShiftRecord (GDD §6.4, §13.5)', () {
    test('net kâr ve yıldız', () {
      const r = ShiftRecord(
        shiftNumber: 1,
        customersServed: 8,
        customersLost: 0,
        missedDemand: 2,
        wrongChange: 0,
        revenueKurus: 24750,
        costKurus: 9800,
        xpEarned: 38,
      );
      expect(r.netKurus, 14950);
      expect(r.satisfaction, 1.0);
      expect(r.stars, 5);
    });

    test('kötü vardiya negatif memnuniyet, düşük yıldız', () {
      const r = ShiftRecord(
        shiftNumber: 2,
        customersServed: 2,
        customersLost: 2,
        missedDemand: 0,
        wrongChange: 0,
        revenueKurus: 1000,
        costKurus: 500,
        xpEarned: 5,
      );
      expect(r.satisfaction, -0.5);
      expect(r.stars, 2);
    });
  });

  group('Catalog.fromJson (GDD §9.4)', () {
    final catalog = Catalog.fromJson({
      'schema_version': 1,
      'categories': {
        'gida_temel': {'name_tr': 'Gıda Temel', 'emoji': '🍞', 'unlock_level': 1},
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
          'vertical_slice': true,
        },
        {
          'id': 'apple',
          'name_i18n': {'tr': 'Elma'},
          'category': 'manav',
          'cost_price_kurus': 250,
          'default_sell_price_kurus': 500,
          'elasticity': 1,
          'unlock_level': 5,
          'icon_asset': 'assets/images/products/apple.png',
        },
      ],
    });

    test('kategori başlığı emoji ile', () {
      expect(catalog.categories['gida_temel']!.heading, '🍞 Gıda Temel');
    });

    test('byId ve sprite yolu', () {
      expect(catalog.byId('bread').nameTr, 'Ekmek');
      expect(catalog.byId('bread').spriteName, 'products/bread.png');
    });

    test('unlocked seviye filtresi', () {
      expect(catalog.unlocked(1).map((p) => p.id), ['bread']);
      expect(catalog.unlocked(5).length, 2);
    });

    test('verticalSlice ürünleri', () {
      expect(catalog.verticalSlice.map((p) => p.id), ['bread']);
    });
  });
}
