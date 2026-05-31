import 'package:hive/hive.dart';

/// Tutorial drip-feed adımları (GDD §4.1). Faz 3'te 2 checkpoint, ileri
/// adımlar (vardiya-içi ipuçları, kart ödeme tanıtımı vb.) bu enum'a eklenip
/// uygun olaylarda işaretlenir.
enum TutorialStep {
  /// Ana menü ilk açılışında — temel akış tanıtımı.
  welcome,

  /// Hazırlık ekranı ilk açılışında — sekme/sipariş/fiyat tanıtımı.
  prepTabs,
}

/// Hive `tutorial_v1` box sarmalayıcısı. "Seen" durumu kalıcı.
class TutorialService {
  TutorialService._(this._box);

  static const String _boxName = 'tutorial_v1';
  static const String _kPrefix = 'seen:';

  final Box<dynamic> _box;

  static Future<TutorialService> open() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    return TutorialService._(box);
  }

  bool seen(TutorialStep step) =>
      (_box.get('$_kPrefix${step.name}', defaultValue: false) as bool);

  void markSeen(TutorialStep step) => _box.put('$_kPrefix${step.name}', true);

  Future<void> reset() async => _box.clear();
}
