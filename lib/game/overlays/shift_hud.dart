import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/bcoin_formatter.dart';
import '../../theme/app_theme.dart';
import '../cashier_game.dart';

/// Kasa ekranı HUD'u (GDD §6.3) — geri sayım, vardiya net B-Coin, müşteri
/// portresi, sabır metresi, combo, TOTAL ve kuyruk silüetleri.
///
/// Tamamen pasif (IgnorePointer) — swipe/tap gesture'ları altındaki Flame
/// kasa bandına geçer.
class ShiftHud extends StatelessWidget {
  const ShiftHud({required this.game, super.key});

  final CashierGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: 8),
            _customerCard(context),
            const Spacer(),
            _queue(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: game.signals.timeLeft,
            builder: (_, s, __) {
              // Süre bitti ama aktif müşteri varsa motor 'gap'e geçene kadar
              // bekler (yarıda kesilmesin diye). Kullanıcıya bu durumu net
              // göster.
              if (s <= 0) {
                return _pill(
                  '⏱ Kapanıyor — son müşteri',
                  color: AppColors.patienceLow,
                );
              }
              return _pill(
                '⏱ ${_mmss(s)}',
                color: s <= 30 ? AppColors.patienceLow : AppColors.ink,
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: game.signals.shiftNet,
            builder: (_, net, __) =>
                _pill('Net ${BCoinFormatter.withSymbol(net)}'),
          ),
        ],
      ),
    );
  }

  Widget _customerCard(BuildContext context) {
    return ValueListenableBuilder<Customer?>(
      valueListenable: game.signals.customer,
      builder: (context, customer, __) {
        if (customer == null) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Sıradaki müşteri geliyor…',
                style: TextStyle(color: AppColors.inkSoft),
              ),
            ),
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 132,
              child: Image.asset(
                'assets/images/${customer.type.portrait}',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 96),
              ),
            ),
            Text(
              customer.type.displayTr,
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
            ),
            const SizedBox(height: 6),
            _patienceBar(),
            const SizedBox(height: 8),
            _totalAndCombo(),
          ],
        );
      },
    );
  }

  Widget _patienceBar() {
    return ValueListenableBuilder<double>(
      valueListenable: game.signals.patience,
      builder: (_, p, __) {
        final color = p > 0.66
            ? AppColors.patienceHigh
            : p > 0.33
                ? AppColors.patienceMid
                : AppColors.patienceLow;
        final face = p > 0.66 ? '😊' : (p > 0.33 ? '😐' : '😠');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Text(face, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: p,
                    minHeight: 12,
                    backgroundColor: const Color(0x22000000),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _totalAndCombo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: game.signals.total,
          builder: (_, total, __) => _pill(
            'TOPLAM ${BCoinFormatter.withSymbol(total)}',
            color: AppColors.secondary,
            strong: true,
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<int>(
          valueListenable: game.signals.combo,
          builder: (_, combo, __) => combo >= 2
              ? _pill('🔗 x$combo', color: AppColors.primary)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _queue() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text('Sırada: ', style: TextStyle(color: AppColors.inkSoft)),
          Opacity(opacity: 0.35, child: Text('👤', style: TextStyle(fontSize: 22))),
          Opacity(opacity: 0.2, child: Text('👤', style: TextStyle(fontSize: 22))),
        ],
      ),
    );
  }

  Widget _pill(String text, {Color color = AppColors.ink, bool strong = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          fontSize: strong ? 16 : 14,
        ),
      ),
    );
  }

  static String _mmss(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
