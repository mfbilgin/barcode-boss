import 'package:barcode_boss/services/elasticity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Elasticity.purchaseChance (GDD §3.5)', () {
    test('inelastik (0) fiyat değişiminden bağımsız %100', () {
      expect(
        Elasticity.purchaseChance(
          currentSellPriceKurus: 500,
          defaultSellPriceKurus: 250,
          elasticity: 0,
        ),
        1.0,
      );
    });

    test('normal (1) fiyat 2x → %40 satar (GDD tablo örneği)', () {
      // priceRatio=2, chance = 1 - (2-1)*1*0.6 = 0.4
      expect(
        Elasticity.purchaseChance(
          currentSellPriceKurus: 1600,
          defaultSellPriceKurus: 800,
          elasticity: 1,
        ),
        closeTo(0.4, 1e-9),
      );
    });

    test('elastik (2) fiyat 2x → %5 (clamp lower bound)', () {
      // priceRatio=2, raw = 1 - 1*2*0.6 = -0.2 → clamp 0.05
      expect(
        Elasticity.purchaseChance(
          currentSellPriceKurus: 5000,
          defaultSellPriceKurus: 2500,
          elasticity: 2,
        ),
        0.05,
      );
    });

    test('priceRatio < 1.0 → her zaman %100', () {
      expect(
        Elasticity.purchaseChance(
          currentSellPriceKurus: 175,
          defaultSellPriceKurus: 250,
          elasticity: 2,
        ),
        1.0,
      );
    });
  });

  group('Elasticity.basketBoost', () {
    test('priceRatio >= 1.0 → boost yok', () {
      expect(
        Elasticity.basketBoost(
          currentSellPriceKurus: 800,
          defaultSellPriceKurus: 800,
          elasticity: 2,
        ),
        0,
      );
    });

    test('elastik (2) 0.7x → boost %48 (GDD tablo örneği)', () {
      // (1-0.7)*2*0.8 = 0.48
      expect(
        Elasticity.basketBoost(
          currentSellPriceKurus: 1750,
          defaultSellPriceKurus: 2500,
          elasticity: 2,
        ),
        closeTo(0.48, 1e-9),
      );
    });

    test('inelastik (0) boost 0', () {
      expect(
        Elasticity.basketBoost(
          currentSellPriceKurus: 175,
          defaultSellPriceKurus: 250,
          elasticity: 0,
        ),
        0,
      );
    });
  });
}
