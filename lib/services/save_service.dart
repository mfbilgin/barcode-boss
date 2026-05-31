import 'package:hive/hive.dart';

import '../models/shift_record.dart';
import 'balance.dart';

/// Hive tabanlı kalıcı kayıt sarmalayıcısı (GDD §9.4).
///
/// Faz 1'de yalnızca `economy_v1` box'ı kullanılır (B-Coin, XP, vardiya no).
/// Stok/sipariş (`inventory_v1`), vardiya geçmişi (`shifts_v1`) ve şema
/// migration (`meta_v1`) Faz 2'de eklenir. `@HiveType` codegen yerine şimdilik
/// primitive depolama — adapter'lar model olgunlaşınca eklenecek.
class SaveService {
  SaveService._(this._economy);

  static const String _economyBox = 'economy_v1';

  static const String _kCoins = 'coins_kurus';
  static const String _kXp = 'total_xp';
  static const String _kShift = 'shift_number';
  // §14 lifeline sayaçları (GDD §14.2, §14.4).
  static const String _kEmergencyAdvanceCount = 'emergency_advance_count';
  static const String _kAdvanceRepayRemaining = 'advance_repay_remaining';
  static const String _kStockZeroAdvanceCount = 'stock_zero_advance_count';

  // §6.4 son tamamlanan vardiya raporu — RaporTab burayı okur.
  // Riverpod StateProvider yerine kalıcı kayıt (uygulama yeniden başlasa
  // bile rapor sekmesi son vardiyayı gösterir).
  static const String _kLastShiftRecord = 'last_shift_record';

  final Box<dynamic> _economy;

  static Future<SaveService> open() async {
    final box = await Hive.openBox<dynamic>(_economyBox);
    return SaveService._(box);
  }

  int get coinsKurus =>
      _economy.get(_kCoins, defaultValue: Balance.startingCapitalKurus) as int;
  set coinsKurus(int value) => _economy.put(_kCoins, value);

  int get totalXp => _economy.get(_kXp, defaultValue: 0) as int;
  set totalXp(int value) => _economy.put(_kXp, value);

  int get shiftNumber => _economy.get(_kShift, defaultValue: 1) as int;
  set shiftNumber(int value) => _economy.put(_kShift, value);

  /// §14.2 — şimdiye kadar tetiklenen acil avans sayısı (lifetime max 3).
  int get emergencyAdvanceCount =>
      _economy.get(_kEmergencyAdvanceCount, defaultValue: 0) as int;
  set emergencyAdvanceCount(int value) =>
      _economy.put(_kEmergencyAdvanceCount, value);

  /// §14.2 — sonraki net gelirden %20 kesilecek vardiya sayısı (0..3).
  int get advanceRepayShiftsRemaining =>
      _economy.get(_kAdvanceRepayRemaining, defaultValue: 0) as int;
  set advanceRepayShiftsRemaining(int value) =>
      _economy.put(_kAdvanceRepayRemaining, value);

  /// §14.4 — stok=0 lifeline'ı (200 BC avans) lifetime kullanım sayısı.
  int get stockZeroAdvanceCount =>
      _economy.get(_kStockZeroAdvanceCount, defaultValue: 0) as int;
  set stockZeroAdvanceCount(int value) =>
      _economy.put(_kStockZeroAdvanceCount, value);

  /// Son tamamlanan vardiya raporu. `null` = henüz vardiya yok (yeni oyun).
  ShiftRecord? get lastShiftRecord {
    final raw = _economy.get(_kLastShiftRecord);
    if (raw is! Map) return null;
    return ShiftRecord.fromJson(raw);
  }

  set lastShiftRecord(ShiftRecord? value) {
    if (value == null) {
      _economy.delete(_kLastShiftRecord);
    } else {
      _economy.put(_kLastShiftRecord, value.toJson());
    }
  }

  int get storeLevel => Balance.levelForXp(totalXp);

  /// Tüm ekonomi state'ini sıfırlar (yeni oyun).
  Future<void> reset() async {
    await _economy.clear();
  }
}
