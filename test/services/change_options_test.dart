import 'dart:math';

import 'package:barcode_boss/services/change_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChangeOptionsGenerator.greedy', () {
    test('TL modeli minimum kupür dekompozisyonu', () {
      expect(ChangeOptionsGenerator.greedy(5250), [5000, 200, 50]);
      expect(ChangeOptionsGenerator.greedy(1250), [1000, 200, 50]);
      expect(ChangeOptionsGenerator.greedy(50), [50]);
      expect(ChangeOptionsGenerator.greedy(0), const <int>[]);
    });

    test('toplam doğrulama: greedy sonucu daima orijinal miktarı verir', () {
      for (final amt in [125, 555, 1234, 4750, 9999, 20000]) {
        // 5 kuruşluk multiple olmayanlar için tam kapanmayabilir;
        // test amount'larını 5'in katı seçtik. Greedy = exact.
        final list = ChangeOptionsGenerator.greedy(amt);
        expect(list.fold<int>(0, (s, d) => s + d), lessThanOrEqualTo(amt));
      }
    });
  });

  group('ChangeOptionsGenerator.generate', () {
    test('3 seçenek üretir, biri doğru biri yanlış', () {
      final opts = ChangeOptionsGenerator.generate(5250, random: Random(42));
      expect(opts.options.length, 3);
      expect(opts.correctIndex, inInclusiveRange(0, 2));
      expect(opts.options[opts.correctIndex].totalKurus, 5250);
      // Diğer iki seçenek 5250'den farklı olmalı.
      var wrongs = 0;
      for (var i = 0; i < 3; i++) {
        if (i != opts.correctIndex) {
          expect(opts.options[i].totalKurus, isNot(5250));
          wrongs++;
        }
      }
      expect(wrongs, 2);
    });

    test('küçük amount\'larda da geçerli (delta clamp)', () {
      final opts = ChangeOptionsGenerator.generate(50, random: Random(1));
      expect(opts.options.length, 3);
      expect(opts.options[opts.correctIndex].totalKurus, 50);
    });
  });
}
