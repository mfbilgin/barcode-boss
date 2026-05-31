import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../models/product.dart';
import '../../services/audio_service.dart';
import '../input/scan_handler.dart';

/// Kasa bandında tarayıcı zonunda duran tek ürün (GDD §3.3 swipe-through).
///
/// Yalnızca [interactive] true iken (tarayıcıya yerleştiğinde) swipe/tap kabul
/// eder. Geçerli sola-doğru swipe veya (tap modunda) tek tap → [onScanned].
class ProductComponent extends SpriteComponent with DragCallbacks, TapCallbacks {
  ProductComponent({
    required this.product,
    required Sprite sprite,
    required this.scanHandler,
    required this.onScanned,
    required this.nowSeconds,
    super.position,
  }) : super(sprite: sprite, size: Vector2.all(112), anchor: Anchor.center);

  final Product product;
  final ScanHandler scanHandler;
  final void Function(ProductComponent self) onScanned;

  /// Oyun saatini (saniye) okur — swipe süresi/hızı hesabı için.
  final double Function() nowSeconds;

  bool interactive = false;
  bool _scanned = false;
  double _dragDx = 0;
  double _dragStart = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!interactive || _scanned) return;
    _dragDx = 0;
    _dragStart = nowSeconds();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!interactive || _scanned) return;
    _dragDx += event.localDelta.x;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!interactive || _scanned) return;
    final leftwardPx = -_dragDx; // sağdan sola = pozitif
    final duration = nowSeconds() - _dragStart;
    if (scanHandler.isValidSwipe(leftwardPx, duration)) {
      _success();
    } else {
      _buzz();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!interactive || _scanned) return;
    if (scanHandler.tapModeEnabled) _success();
  }

  void _success() {
    _scanned = true;
    interactive = false;
    onScanned(this);
  }

  /// Yetersiz/yanlış swipe — "buzz", ürün titrer, yerinde kalır (GDD §3.3).
  void _buzz() {
    AudioService.instance.playSfx(SfxId.buzz);
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(7, 0), EffectController(duration: 0.04)),
        MoveEffect.by(Vector2(-14, 0), EffectController(duration: 0.06)),
        MoveEffect.by(Vector2(7, 0), EffectController(duration: 0.04)),
      ]),
    );
  }
}
