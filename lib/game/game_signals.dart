import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../services/change_options.dart';

/// Ödeme istemi (kasa ekranında ödeme widget'ı için), GDD §3.4.
class PaymentPrompt {
  const PaymentPrompt({
    required this.method,
    required this.totalKurus,
    required this.scenario,
    this.givenAmountKurus,
    this.changeKurus,
    this.changeOptions,
  });

  final PaymentMethod method;
  final int totalKurus;
  final ChangeScenario scenario;

  /// bigBill senaryosunda müşterinin uzattığı kupür (kuruş).
  final int? givenAmountKurus;

  /// bigBill senaryosunda hesaplanan para üstü (kuruş).
  final int? changeKurus;

  /// bigBill senaryosunda 3-option seçenekleri.
  final ChangeOptions? changeOptions;
}

/// Flame oyunu ↔ Flutter HUD overlay'leri arasındaki tek yönlü sinyal kanalı.
///
/// Flame component'leri Riverpod'a doğrudan erişemez; oyun bu [ValueNotifier]'ları
/// günceller, overlay widget'ları `ValueListenableBuilder` ile dinler
/// (GDD §9.3 Flame↔Flutter köprüsü).
class GameSignals {
  /// Vardiya geri sayımı (saniye).
  final ValueNotifier<int> timeLeft = ValueNotifier<int>(0);

  /// Bu vardiyanın koşan net B-Coin'i (kuruş).
  final ValueNotifier<int> shiftNet = ValueNotifier<int>(0);

  /// Aktif müşterinin o ana kadar taranan toplamı (kuruş).
  final ValueNotifier<int> total = ValueNotifier<int>(0);

  /// Sabır oranı 0..1 (GDD §13.3).
  final ValueNotifier<double> patience = ValueNotifier<double>(1);

  /// Aktif müşteri (null = kuyrukta kimse yok / vardiya sonu).
  final ValueNotifier<Customer?> customer = ValueNotifier<Customer?>(null);

  /// Combo zinciri (ardışık hızlı swipe sayısı), GDD §3.3.
  final ValueNotifier<int> combo = ValueNotifier<int>(0);

  /// Ödeme beklenirken dolu; null = ödeme yok.
  final ValueNotifier<PaymentPrompt?> payment = ValueNotifier<PaymentPrompt?>(
    null,
  );

  /// Gün ortasında tüm ürünlerin raf+depo stoğu 0'a düştü.
  /// HUD bunu görünce "Stok bitti — gün kapatılıyor" overlay'i gösterir;
  /// motor kısa bir gecikme sonrası `_endShift()` çağırır.
  final ValueNotifier<bool> stockExhausted = ValueNotifier<bool>(false);

  void dispose() {
    timeLeft.dispose();
    shiftNet.dispose();
    total.dispose();
    patience.dispose();
    customer.dispose();
    combo.dispose();
    payment.dispose();
    stockExhausted.dispose();
  }
}
