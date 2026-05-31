import 'noop_telemetry_backend.dart';
import 'telemetry_backend.dart';

/// Tipli telemetry API'si — GDD §15.2 event taxonomy birebir.
///
/// Singleton: `TelemetryService.instance`. Firebase aktif edildiğinde
/// `TelemetryService.swap(FirebaseTelemetryBackend(...))` ile arka uç değişir.
class TelemetryService {
  TelemetryService._(this._backend);

  static TelemetryService instance =
      TelemetryService._(const NoopTelemetryBackend());

  final TelemetryBackend _backend;

  /// Arka ucu değiştir (örn. uygulama açılışında Firebase init sonrası).
  static void swap(TelemetryBackend backend) {
    instance = TelemetryService._(backend);
  }

  // -------------------- Lifecycle (GDD §15.2) --------------------

  Future<void> appOpened() => _backend.logEvent('app_opened');

  Future<void> appClosed({required int sessionDurationSec}) =>
      _backend.logEvent('app_closed', {
        'session_duration_sec': sessionDurationSec,
      });

  Future<void> tutorialStepCompleted({
    required int stepId,
    required String stepName,
  }) =>
      _backend.logEvent('tutorial_step_completed', {
        'step_id': stepId,
        'step_name': stepName,
      });

  Future<void> tutorialSkipped({required int lastStep}) =>
      _backend.logEvent('tutorial_skipped', {'last_step': lastStep});

  // -------------------- Gameplay --------------------

  Future<void> shiftStarted({
    required int shiftNumber,
    required int storeLevel,
  }) =>
      _backend.logEvent('shift_started', {
        'shift_number': shiftNumber,
        'store_level': storeLevel,
      });

  Future<void> shiftCompleted({
    required int shiftNumber,
    required int customersServed,
    required int customersLost,
    required int coinsEarned,
    required int coinsSpentOnOrders,
    required double satisfactionScore,
  }) =>
      _backend.logEvent('shift_completed', {
        'shift_number': shiftNumber,
        'customers_served': customersServed,
        'customers_lost': customersLost,
        'coins_earned': coinsEarned,
        'coins_spent_on_orders': coinsSpentOnOrders,
        'satisfaction_score': satisfactionScore,
      });

  Future<void> customerCompleted({
    required String customerType,
    required int basketSize,
    required double scanTimeSec,
    required bool paymentCorrect,
  }) =>
      _backend.logEvent('customer_completed', {
        'customer_type': customerType,
        'basket_size': basketSize,
        'scan_time_sec': scanTimeSec,
        'payment_correct': paymentCorrect,
      });

  Future<void> customerLost({required String reason}) =>
      _backend.logEvent('customer_lost', {'reason': reason});

  // -------------------- Economy --------------------

  Future<void> orderPlaced({
    required List<String> productIds,
    required int totalCostKurus,
  }) =>
      _backend.logEvent('order_placed', {
        'product_ids': productIds.join(','),
        'total_cost': totalCostKurus,
      });

  Future<void> priceChanged({
    required String productId,
    required int oldPriceKurus,
    required int newPriceKurus,
    required int elasticity,
  }) =>
      _backend.logEvent('price_changed', {
        'product_id': productId,
        'old_price': oldPriceKurus,
        'new_price': newPriceKurus,
        'elasticity': elasticity,
      });

  Future<void> emergencyAdvanceTriggered({required int count}) =>
      _backend.logEvent('emergency_advance_triggered', {'count': count});

  // -------------------- Progression --------------------

  Future<void> storeLevelUp({required int newLevel, required int totalXp}) =>
      _backend.logEvent('store_level_up', {
        'new_level': newLevel,
        'total_xp': totalXp,
      });

  Future<void> equipmentPurchased({
    required String itemId,
    required int costKurus,
  }) =>
      _backend.logEvent('equipment_purchased', {
        'item_id': itemId,
        'cost': costKurus,
      });

  // -------------------- Errors --------------------

  Future<void> errorCaught(
    Object error,
    StackTrace? stack, {
    String? screen,
    bool fatal = false,
  }) =>
      _backend.recordError(error, stack, context: screen, fatal: fatal);

  Future<void> saveLoadFailed({
    required String box,
    required bool fallbackUsed,
  }) =>
      _backend.logEvent('save_load_failed', {
        'box': box,
        'fallback_used': fallbackUsed,
      });

  // -------------------- User properties --------------------

  Future<void> setStoreLevel(int level) =>
      _backend.setUserProperty('store_level', '$level');

  Future<void> setLocale(String locale) =>
      _backend.setUserProperty('locale', locale);
}
