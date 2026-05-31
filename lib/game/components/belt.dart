import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Kasa bandı (GDD §6.3) — diyagonal çizgili metal bant görseli.
class BeltComponent extends PositionComponent {
  BeltComponent({super.position, super.size});

  final Paint _body = Paint()..color = AppColors.belt;
  final Paint _stripe = Paint()..color = AppColors.beltStripe;

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, _body);

    canvas.save();
    canvas.clipRRect(rrect);
    const stripeW = 16.0;
    const gap = 46.0;
    for (double x = -size.y; x < size.x; x += gap) {
      final path = Path()
        ..moveTo(x, size.y)
        ..lineTo(x + size.y, 0)
        ..lineTo(x + size.y + stripeW, 0)
        ..lineTo(x + stripeW, size.y)
        ..close();
      canvas.drawPath(path, _stripe);
    }
    canvas.restore();
  }
}
