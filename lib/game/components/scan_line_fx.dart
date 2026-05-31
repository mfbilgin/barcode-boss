import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Başarılı taramada tarayıcı üzerinden geçen laser flash (GDD §3.3, §7.8).
class ScanLineFx extends RectangleComponent {
  ScanLineFx({required Vector2 center, required double width})
    : super(
        position: center,
        size: Vector2(width, 4),
        anchor: Anchor.center,
        paint: Paint()..color = AppColors.scanLaser,
      );

  @override
  Future<void> onLoad() async {
    add(OpacityEffect.fadeOut(EffectController(duration: 0.22)));
    add(ScaleEffect.by(Vector2(1, 3), EffectController(duration: 0.22)));
    add(RemoveEffect(delay: 0.24));
  }
}

/// "BEEP!" pop yazısı — tarama feedback'i (ses + flash + yazı redundancy, §18.4).
class BeepText extends TextComponent {
  BeepText({required Vector2 position})
    : super(
        text: 'BEEP!',
        anchor: Anchor.center,
        position: position,
        scale: Vector2.all(0.6),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: AppColors.scanLaser,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  @override
  Future<void> onLoad() async {
    add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.18)));
    add(
      MoveEffect.by(Vector2(0, -28), EffectController(duration: 0.4)),
    );
    add(RemoveEffect(delay: 0.42));
  }
}
