import 'package:barcode_boss/services/bcoin_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BCoinFormatter.format (tr_TR)', () {
    test('küçük değerler 2 ondalıkla, virgül ayraçla', () {
      expect(BCoinFormatter.format(0), '0,00');
      expect(BCoinFormatter.format(5), '0,05');
      expect(BCoinFormatter.format(150), '1,50');
      expect(BCoinFormatter.format(4750), '47,50');
    });

    test('binlik ayraç nokta ile', () {
      expect(BCoinFormatter.format(100000), '1.000,00');
      expect(BCoinFormatter.format(125000), '1.250,00');
      expect(BCoinFormatter.format(999999), '9.999,99');
      expect(BCoinFormatter.format(9999999), '99.999,99');
    });

    test('≥100K B-Coin → K kısaltması', () {
      expect(BCoinFormatter.format(10000000), '100,0K');
      expect(BCoinFormatter.format(99000000), '990,0K');
    });

    test('≥1M B-Coin → M kısaltması', () {
      expect(BCoinFormatter.format(100000000), '1,0M');
      expect(BCoinFormatter.format(250000000), '2,5M');
    });

    test('negatif değerler standart formatta (maliyet satırı)', () {
      expect(BCoinFormatter.format(-9800), '-98,00');
    });
  });

  group('BCoinFormatter.format (en_US)', () {
    test('ondalık/binlik ayraçlar yer değiştirir', () {
      expect(BCoinFormatter.format(4750, locale: 'en_US'), '47.50');
      expect(BCoinFormatter.format(100000, locale: 'en_US'), '1,000.00');
    });
  });

  group('BCoinFormatter.withSymbol / signed', () {
    test('sembol önde, sayı arkada', () {
      expect(BCoinFormatter.withSymbol(4750), '🪙 47,50');
    });

    test('pozitif net kâr açık + işaretiyle', () {
      expect(BCoinFormatter.signed(14950), '+🪙 149,50');
    });

    test('sıfır ve negatif için + eklenmez', () {
      expect(BCoinFormatter.signed(0), '🪙 0,00');
      expect(BCoinFormatter.signed(-9800), '🪙 -98,00');
    });
  });
}
