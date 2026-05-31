import 'package:barcode_boss/services/balance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Balance.levelForXp (GDD §23.1)', () {
    test('eşiklere göre seviye', () {
      expect(Balance.levelForXp(0), 1);
      expect(Balance.levelForXp(99), 1);
      expect(Balance.levelForXp(100), 2);
      expect(Balance.levelForXp(299), 2);
      expect(Balance.levelForXp(300), 3);
      expect(Balance.levelForXp(800), 4);
      expect(Balance.levelForXp(2000), 5);
      expect(Balance.levelForXp(99999), 5);
    });
  });

  group('Balance.shiftDurationSec (Faz 5 playtest tuning)', () {
    test('tüm seviyelerde 105 sn = 1dk 45sn (playtest iterasyonu)', () {
      expect(Balance.shiftDurationSec(1), 105);
      expect(Balance.shiftDurationSec(3), 105);
      expect(Balance.shiftDurationSec(5), 105);
    });
  });

  group('Balance.maxBasket (GDD §13.2)', () {
    test('lvl 1: 4, lvl 5: 12 (cap)', () {
      expect(Balance.maxBasket(1), 4);
      expect(Balance.maxBasket(5), 12);
      expect(Balance.maxBasket(8), 12); // 10 cap
    });
  });
}
