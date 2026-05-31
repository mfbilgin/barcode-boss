import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Tarayıcı zonu (GDD §6.3) — ürünün durup tarandığı koyu pad + sabit laser.
class ScannerComponent extends PositionComponent {
  ScannerComponent({super.position, super.size, super.anchor});

  final Paint _pad = Paint()..color = AppColors.scannerGlass;
  final Paint _laser = Paint()
    ..color = AppColors.scanLaser.withValues(alpha: 0.45)
    ..strokeWidth = 2;

  @override
  Future<void> onLoad() async {
    final label = TextComponent(
      text: '📷 TARAYICI',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 6),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: AppColors.inkSoft,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    await add(label);
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, _pad);
    final midY = size.y / 2;
    canvas.drawLine(Offset(8, midY), Offset(size.x - 8, midY), _laser);
  }
}
