import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/catalog.dart';
import '../models/customer_model.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/shift_record.dart';
import '../services/audio_service.dart';
import '../services/balance.dart';
import '../services/change_options.dart';
import '../services/elasticity.dart';
import '../services/telemetry/telemetry_service.dart';
import '../theme/app_theme.dart';
import 'components/belt.dart';
import 'components/product_component.dart';
import 'components/scan_line_fx.dart';
import 'components/scanner.dart';
import 'game_signals.dart';
import 'input/scan_handler.dart';

/// Kasa ekranı oyunu (GDD §6.3). Faz 2: catalog/inventory tabanlı basket
/// generation + elastikiyet + kart ödeme + 3-option para üstü.
class CashierGame extends FlameGame {
  CashierGame({
    required this.catalog,
    required this.inventorySnapshot,
    required this.onShelfDepletion,
    required this.cardCapacityPercent,
    required this.shiftNumber,
    required this.storeLevel,
    required this.shiftDurationSec,
    required this.onShiftComplete,
    ScanHandler? scanHandler,
  }) : scanHandler = scanHandler ?? const ScanHandler();

  static const String hudOverlay = 'hud';
  static const String paymentOverlay = 'payment';

  final Catalog catalog;

  /// Anlık inventory snapshot getter — basket spawn anında çağrılır.
  final Map<String, InventoryItem> Function() inventorySnapshot;

  /// Sepete giren her ürün için raf stoğunu eksiltmek üzere çağrılır.
  final void Function(String productId, int qty) onShelfDepletion;

  /// Kart-müşteri oranı % (default 5, upgrade ile max 20 — GDD §3.1, §23.4).
  final int cardCapacityPercent;

  final int shiftNumber;
  final int storeLevel;
  final int shiftDurationSec;
  final void Function(ShiftRecord record) onShiftComplete;
  final ScanHandler scanHandler;

  final GameSignals signals = GameSignals();
  final Random _rng = Random();
  final Map<String, Sprite> _sprites = {};

  // --- vardiya/zaman ---
  double _gameTime = 0;
  double _elapsed = 0;
  bool _shiftOver = false;

  // --- müşteri durumu ---
  Customer? _active;
  final List<Product> _remaining = [];
  ProductComponent? _activeProduct;
  bool _awaitingPayment = false;
  bool _inGap = true;
  double _gapTimer = 1.0;
  double _patienceElapsed = 0;
  PaymentPrompt? _currentPrompt;
  double _customerStartTime = 0; // telemetri: scan_time_sec

  // --- combo (GDD §3.3) ---
  int _combo = 0;
  double _lastScan = -999;
  bool _tipEarned = false;

  // --- tally ---
  int _served = 0;
  int _lost = 0;
  int _wrongChange = 0;
  int _missed = 0;
  int _revenueKurus = 0;
  int _costKurus = 0;

  // --- geometri ---
  late Vector2 _scannerCenter;
  late double _scanZoneWidth;

  double get gameTime => _gameTime;
  double get _difficulty => Balance.difficultyMultiplier(storeLevel);

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    // Faz 2: tüm açılmış ürünlerin sprite'larını ön-yükle (basket dinamik).
    for (final p in catalog.unlocked(storeLevel)) {
      _sprites[p.id] = await loadSprite(p.spriteName);
    }
    _layout();
    signals.timeLeft.value = shiftDurationSec;
    signals.patience.value = 1;
    unawaited(
      TelemetryService.instance.shiftStarted(
        shiftNumber: shiftNumber,
        storeLevel: storeLevel,
      ),
    );
  }

  void _layout() {
    final beltY = size.y * 0.52;
    final beltHeight = size.y * 0.16;
    final beltWidth = size.x * 0.92;
    final beltX = (size.x - beltWidth) / 2;
    _scannerCenter = Vector2(size.x / 2, beltY + beltHeight / 2);
    _scanZoneWidth = beltWidth * 0.34;

    add(
      BeltComponent(
        position: Vector2(beltX, beltY),
        size: Vector2(beltWidth, beltHeight),
      ),
    );
    add(
      ScannerComponent(
        position: _scannerCenter.clone(),
        size: Vector2(_scanZoneWidth, beltHeight * 0.78),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _gameTime += dt;
    if (_shiftOver || !isLoaded) return;

    _elapsed += dt;
    final remaining = shiftDurationSec - _elapsed;
    final remCeil = remaining.ceil().clamp(0, shiftDurationSec);
    if (signals.timeLeft.value != remCeil) signals.timeLeft.value = remCeil;

    if (_inGap) {
      _gapTimer -= dt;
      if (_gapTimer <= 0) {
        _inGap = false;
        if (remaining <= 0) {
          _endShift();
        } else {
          _spawnCustomer();
        }
      }
      return;
    }

    final customer = _active;
    if (customer != null) {
      final mult = _awaitingPayment ? 1.2 : 1.0;
      _patienceElapsed +=
          dt * Balance.patienceDecayRate * _difficulty * mult;
      final maxP = customer.maxPatienceSec.toDouble();
      final rem = (maxP - _patienceElapsed).clamp(0.0, maxP);
      signals.patience.value = rem / maxP;
      if (rem <= 0) _loseCustomer();
    }
  }

  // --- müşteri yaşam döngüsü ---

  void _spawnCustomer() {
    final customer = _generateCustomer();
    if (customer == null) {
      // Hiçbir üründe stok yok — kısa bir bekleyişten sonra tekrar dene.
      _inGap = true;
      _gapTimer = 1.5;
      return;
    }
    _active = customer;
    _remaining
      ..clear()
      ..addAll(customer.basket);
    _patienceElapsed = 0;
    _combo = 0;
    _tipEarned = false;
    _awaitingPayment = false;
    _customerStartTime = _gameTime;
    signals
      ..customer.value = customer
      ..total.value = 0
      ..combo.value = 0
      ..patience.value = 1;
    _presentNext();
  }

  /// GDD §13.2: sepet spawn anında stok + elastikiyet kontrolüyle oluşturulur.
  /// Stok 0 olan ürün hiç gözükmez; pahalı/elastik ürünler sepetten "düşer"
  /// (kaçırılan talep). Aynı ürün indirimde basket boost ile birden fazla
  /// kez eklenebilir.
  Customer? _generateCustomer() {
    final inv = inventorySnapshot();
    final available = <Product>[];
    for (final p in catalog.unlocked(storeLevel)) {
      final item = inv[p.id];
      if (item != null && item.shelfQty > 0) available.add(p);
    }
    if (available.isEmpty) return null;

    available.shuffle(_rng);
    final maxSize = Balance.maxBasket(storeLevel);
    final targetSize = 2 + _rng.nextInt(maxSize - 1);
    final basket = <Product>[];
    // Yerel raf sayacı — basket gen sırasında stoğu eksiltir; aynı ürünü
    // birden fazla kez eklemek raf < 0'a düşmesin diye.
    final localShelf = {
      for (final p in available) p.id: inv[p.id]!.shelfQty,
    };

    for (final p in available) {
      if (basket.length >= targetSize) break;
      if ((localShelf[p.id] ?? 0) <= 0) continue;
      final item = inv[p.id]!;
      final chance = Elasticity.purchaseChance(
        currentSellPriceKurus: item.currentSellPriceKurus,
        defaultSellPriceKurus: p.defaultSellPriceKurus,
        elasticity: p.elasticity,
      );
      if (_rng.nextDouble() < chance) {
        basket.add(p);
        localShelf[p.id] = (localShelf[p.id] ?? 0) - 1;
        onShelfDepletion(p.id, 1);
        // İndirimli elastik ürünlerde basket boost — ekstra adet.
        if (basket.length < targetSize && (localShelf[p.id] ?? 0) > 0) {
          final boost = Elasticity.basketBoost(
            currentSellPriceKurus: item.currentSellPriceKurus,
            defaultSellPriceKurus: p.defaultSellPriceKurus,
            elasticity: p.elasticity,
          );
          if (boost > 0 && _rng.nextDouble() < boost) {
            basket.add(p);
            localShelf[p.id] = (localShelf[p.id] ?? 0) - 1;
            onShelfDepletion(p.id, 1);
          }
        }
      } else {
        _missed++;
      }
    }

    if (basket.isEmpty) {
      // Tüm ürünler fiyat sebebiyle reddedildi — yine de bir müşteri yarat
      // ki kuyruk akışı durmasın. Tek bir random uygun ürün ekle.
      final fallback = available.firstWhere(
        (p) => (localShelf[p.id] ?? 0) > 0,
        orElse: () => available.first,
      );
      basket.add(fallback);
      onShelfDepletion(fallback.id, 1);
    }

    return Customer(
      type: _pickType(),
      basket: basket,
      paymentMethod: _pickPayment(),
      changeScenario: _pickChangeScenario(),
    );
  }

  CustomerType _pickType() {
    final r = _rng.nextDouble();
    if (r < 0.65) return CustomerType.normal;
    if (r < 0.85) return CustomerType.aceleci;
    return CustomerType.yasli;
  }

  PaymentMethod _pickPayment() {
    final cardRate = cardCapacityPercent / 100.0;
    return _rng.nextDouble() < cardRate
        ? PaymentMethod.card
        : PaymentMethod.cash;
  }

  /// %30 bozuk para senaryosu (GDD §13.4).
  ChangeScenario _pickChangeScenario() {
    return _rng.nextDouble() < 0.30
        ? ChangeScenario.bigBill
        : ChangeScenario.exactCash;
  }

  void _presentNext() {
    if (_remaining.isEmpty) {
      _startPayment();
      return;
    }
    final product = _remaining.removeAt(0);
    final sprite = _sprites[product.id]!;
    final comp = ProductComponent(
      product: product,
      sprite: sprite,
      scanHandler: scanHandler,
      onScanned: _onScanned,
      nowSeconds: () => _gameTime,
      position: Vector2(size.x + 120, _scannerCenter.y),
    );
    _activeProduct = comp;
    add(comp);
    comp.add(
      MoveToEffect(
        _scannerCenter.clone(),
        EffectController(duration: 0.38, curve: Curves.easeOut),
        onComplete: () => comp.interactive = true,
      ),
    );
  }

  void _onScanned(ProductComponent comp) {
    _combo = (_gameTime - _lastScan <= Balance.comboMaxGapSec) ? _combo + 1 : 1;
    _lastScan = _gameTime;
    if (_combo >= Balance.comboThreshold) _tipEarned = true;
    signals.combo.value = _combo;

    // Faz 2: oyuncunun belirlediği currentSellPrice kullanılır.
    final inv = inventorySnapshot();
    final price = inv[comp.product.id]?.currentSellPriceKurus
        ?? comp.product.defaultSellPriceKurus;
    signals.total.value += price;

    AudioService.instance.playSfx(SfxId.beep);
    add(ScanLineFx(center: _scannerCenter.clone(), width: _scanZoneWidth));
    add(BeepText(position: Vector2(_scannerCenter.x, _scannerCenter.y - 72)));

    comp
      ..add(
        MoveToEffect(
          Vector2(-150, _scannerCenter.y + 24),
          EffectController(duration: 0.3, curve: Curves.easeIn),
          onComplete: comp.removeFromParent,
        ),
      )
      ..add(ScaleEffect.to(Vector2.all(0.55), EffectController(duration: 0.3)));
    _activeProduct = null;
    _presentNext();
  }

  // --- Ödeme ---

  void _startPayment() {
    final customer = _active;
    if (customer == null) return;
    _awaitingPayment = true;
    final total = signals.total.value;
    PaymentPrompt prompt;
    if (customer.paymentMethod == PaymentMethod.card ||
        customer.changeScenario == ChangeScenario.exactCash) {
      prompt = PaymentPrompt(
        method: customer.paymentMethod,
        scenario: customer.changeScenario,
        totalKurus: total,
      );
    } else {
      // bigBill: müşteri toplamdan büyük bir kupür uzatır.
      final given = _pickGivenAmount(total);
      final change = given - total;
      prompt = PaymentPrompt(
        method: customer.paymentMethod,
        scenario: customer.changeScenario,
        totalKurus: total,
        givenAmountKurus: given,
        changeKurus: change,
        changeOptions: ChangeOptionsGenerator.generate(change, random: _rng),
      );
    }
    _currentPrompt = prompt;
    signals.payment.value = prompt;
    overlays.add(paymentOverlay);
  }

  /// Müşterinin uzattığı kupür: total'den büyük TL-modeli denomination.
  /// Çeşitlilik için %60 olasılıkla "en yakın üst", %30 "bir üst", %10
  /// "iki üst" kupür uzatılır — tester'ın aynı para üstü tekrarını azaltır.
  int _pickGivenAmount(int totalKurus) {
    const denoms = [200, 500, 1000, 2000, 5000, 10000, 20000];
    final candidates = <int>[];
    for (final d in denoms) {
      if (d >= totalKurus + 50) candidates.add(d);
    }
    if (candidates.isEmpty) return denoms.last;
    final r = _rng.nextDouble();
    final int idx;
    if (r < 0.6 || candidates.length == 1) {
      idx = 0;
    } else if (r < 0.9 || candidates.length == 2) {
      idx = 1;
    } else {
      idx = 2;
    }
    return candidates[idx.clamp(0, candidates.length - 1)];
  }

  /// Nakit tam-para "Tamam" veya kart "Onayla" düğmesi.
  void confirmPayment() {
    final customer = _active;
    final prompt = _currentPrompt;
    if (!_awaitingPayment || customer == null || prompt == null) return;
    if (prompt.scenario == ChangeScenario.bigBill &&
        prompt.method == PaymentMethod.cash) {
      // bigBill akışı submitChange ile bitirilmeli — yanlış kullanım.
      return;
    }
    _completeSale(customer, extraPenaltyKurus: 0);
  }

  /// bigBill 3-option seçeneği gönderildi (overlay'den).
  void submitChange(int selectedIndex) {
    final customer = _active;
    final prompt = _currentPrompt;
    if (!_awaitingPayment ||
        customer == null ||
        prompt == null ||
        prompt.changeOptions == null) {
      return;
    }
    final opts = prompt.changeOptions!;
    final selectedSum = opts.options[selectedIndex].totalKurus;
    final correctSum = opts.options[opts.correctIndex].totalKurus;
    final isCorrect = selectedIndex == opts.correctIndex;
    if (!isCorrect) {
      AudioService.instance.playSfx(SfxId.buzz);
      _wrongChange++;
      // GDD §3.4: yanlış → memnuniyet -1, B-Coin'den fark kesilir.
      _completeSale(
        customer,
        extraPenaltyKurus: (selectedSum - correctSum).abs(),
      );
    } else {
      _completeSale(customer, extraPenaltyKurus: 0);
    }
  }

  void _completeSale(Customer customer, {required int extraPenaltyKurus}) {
    AudioService.instance.playSfx(
      customer.paymentMethod == PaymentMethod.card ? SfxId.card : SfxId.coin,
    );
    overlays.remove(paymentOverlay);
    signals.payment.value = null;
    _currentPrompt = null;
    _awaitingPayment = false;

    final inv = inventorySnapshot();
    var revenue = 0;
    var cost = 0;
    for (final p in customer.basket) {
      final price = inv[p.id]?.currentSellPriceKurus ?? p.defaultSellPriceKurus;
      revenue += price;
      cost += p.costPriceKurus;
    }
    if (_tipEarned) revenue += (revenue * Balance.comboTipRate).round();
    revenue -= extraPenaltyKurus;

    _revenueKurus += revenue;
    _costKurus += cost;
    _served++;
    signals.shiftNet.value = _revenueKurus - _costKurus;

    unawaited(
      TelemetryService.instance.customerCompleted(
        customerType: customer.type.name,
        basketSize: customer.basket.length,
        scanTimeSec: _gameTime - _customerStartTime,
        paymentCorrect: extraPenaltyKurus == 0,
      ),
    );

    _finishCustomer();
  }

  void _loseCustomer() {
    final customer = _active;
    if (customer == null) return;
    // Sepet değeri × 0.5 ceza (GDD §13.3) — maliyet hanesine eklenir
    // (ciro temiz kalsın diye, slice'tan beri kullandığımız yaklaşım).
    final inv = inventorySnapshot();
    var basketValue = 0;
    for (final p in customer.basket) {
      basketValue +=
          inv[p.id]?.currentSellPriceKurus ?? p.defaultSellPriceKurus;
    }
    _costKurus += (basketValue * 0.5).round();
    _lost++;
    if (_awaitingPayment) {
      overlays.remove(paymentOverlay);
      signals.payment.value = null;
      _awaitingPayment = false;
      _currentPrompt = null;
    }
    signals.shiftNet.value = _revenueKurus - _costKurus;
    unawaited(
      TelemetryService.instance.customerLost(reason: 'patience_zero'),
    );
    _finishCustomer();
  }

  void _finishCustomer() {
    _activeProduct?.removeFromParent();
    _activeProduct = null;
    _remaining.clear();
    _active = null;
    signals
      ..customer.value = null
      ..total.value = 0
      ..combo.value = 0
      ..patience.value = 1;
    _inGap = true;
    _gapTimer = 0.5 + _rng.nextDouble();
  }

  void _endShift() {
    if (_shiftOver) return;
    _shiftOver = true;
    AudioService.instance.playSfx(SfxId.drawer);
    pauseEngine();
    final record = ShiftRecord(
      shiftNumber: shiftNumber,
      customersServed: _served,
      customersLost: _lost,
      missedDemand: _missed,
      wrongChange: _wrongChange,
      revenueKurus: _revenueKurus,
      costKurus: _costKurus,
      xpEarned: _computeXp(),
    );
    unawaited(
      TelemetryService.instance.shiftCompleted(
        shiftNumber: record.shiftNumber,
        customersServed: record.customersServed,
        customersLost: record.customersLost,
        coinsEarned: record.netKurus,
        coinsSpentOnOrders: 0, // sipariş kaydı ekonomi tarafında
        satisfactionScore: record.satisfaction,
      ),
    );
    onShiftComplete(record);
  }

  int _computeXp() {
    var xp = _served * Balance.xpCustomerNormal + Balance.xpShiftComplete;
    xp += (_served - _wrongChange).clamp(0, _served) * Balance.xpCorrectChange;
    final total = _served + _lost;
    final satisfaction = total == 0
        ? 0.0
        : ((_served - _lost * 2 - _wrongChange) / total).clamp(-1.0, 1.0);
    if (satisfaction > 0.8) xp += Balance.xpHighSatisfaction;
    if (_lost == 0 && _wrongChange == 0 && _served > 0) {
      xp += Balance.xpPerfectShift;
    }
    return xp;
  }

  @override
  void onRemove() {
    signals.dispose();
    super.onRemove();
  }
}
