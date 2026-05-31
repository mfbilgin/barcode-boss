import 'dart:math';

/// Tek bir para üstü seçeneği — denomination'ların toplamı [totalKurus]
/// olarak verilir. Doğru/yanlış kontrolü `total == hedef change`.
class ChangeOption {
  const ChangeOption(this.denominationsKurus);

  /// Denominationların listesi (kuruş cinsinden), çoktan büyüğe sıralı.
  final List<int> denominationsKurus;

  int get totalKurus =>
      denominationsKurus.fold(0, (sum, d) => sum + d);
}

/// 3-option para üstü teklif paketi (GDD §3.4). Liste shuffled; [correctIndex]
/// doğru seçeneğin indexi.
class ChangeOptions {
  const ChangeOptions({required this.options, required this.correctIndex});
  final List<ChangeOption> options;
  final int correctIndex;
}

abstract class ChangeOptionsGenerator {
  /// TL modeli denominations kuruş cinsinden (GDD §3.7).
  static const List<int> denominationsDesc = [
    20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 25, 10, 5,
  ];

  /// Greedy decomposition — TL modeli için minimum kupür sayısı verir.
  static List<int> greedy(int amountKurus) {
    if (amountKurus <= 0) return const [];
    final out = <int>[];
    var remaining = amountKurus;
    for (final d in denominationsDesc) {
      while (remaining >= d) {
        out.add(d);
        remaining -= d;
      }
      if (remaining == 0) break;
    }
    return out;
  }

  /// [changeKurus] hedef para üstü için 1 doğru + 2 yakın yanlış seçenek
  /// üretir. [random] tohum kontrolü için (test).
  static ChangeOptions generate(int changeKurus, {Random? random}) {
    final rng = random ?? Random();
    final correct = ChangeOption(greedy(changeKurus));

    // Hata büyüklüğü change boyutuna göre — küçük amount, küçük hata.
    final delta1 = changeKurus >= 1000 ? 100 : 50; // 1 BC veya 0,50
    final delta2 = changeKurus >= 1000 ? 250 : 100; // 2,5 BC veya 1 BC

    final wrong1 = ChangeOption(greedy(changeKurus + delta1));
    final wrong2 = ChangeOption(
      greedy((changeKurus - delta2).clamp(5, 1 << 30)),
    );

    final ordered = [correct, wrong1, wrong2];
    final indices = [0, 1, 2]..shuffle(rng);
    final shuffled = [for (final i in indices) ordered[i]];
    return ChangeOptions(
      options: shuffled,
      correctIndex: indices.indexOf(0),
    );
  }
}
