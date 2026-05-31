import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/bcoin_formatter.dart';
import '../../services/change_options.dart';
import '../../theme/app_theme.dart';
import '../cashier_game.dart';
import '../game_signals.dart';

/// Ödeme widget'ı (GDD §3.4). Üç yol:
///   • exactCash → "Tam para" + Tamam
///   • card      → "Kart Cihazı" + Onayla
///   • bigBill   → 3-option çoktan seçmeli para üstü
class PaymentOverlay extends StatelessWidget {
  const PaymentOverlay({required this.game, super.key});

  final CashierGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentPrompt?>(
      valueListenable: game.signals.payment,
      builder: (context, prompt, __) {
        if (prompt == null) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Toplam: ${BCoinFormatter.withSymbol(prompt.totalKurus)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 12),
                _body(prompt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(PaymentPrompt prompt) {
    if (prompt.method == PaymentMethod.card) {
      return _CardPrompt(onConfirm: game.confirmPayment);
    }
    if (prompt.scenario == ChangeScenario.bigBill &&
        prompt.changeOptions != null) {
      return _BigBillPrompt(
        givenKurus: prompt.givenAmountKurus ?? 0,
        changeKurus: prompt.changeKurus ?? 0,
        options: prompt.changeOptions!,
        onSelect: game.submitChange,
      );
    }
    return _ExactCashPrompt(
      totalKurus: prompt.totalKurus,
      onConfirm: game.confirmPayment,
    );
  }
}

class _ExactCashPrompt extends StatelessWidget {
  const _ExactCashPrompt({required this.totalKurus, required this.onConfirm});

  final int totalKurus;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Tam para: ${BCoinFormatter.withSymbol(totalKurus)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Tamam'),
          ),
        ),
      ],
    );
  }
}

class _CardPrompt extends StatelessWidget {
  const _CardPrompt({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.scannerGlass,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card, color: Colors.white, size: 36),
              SizedBox(height: 8),
              Text(
                'Kart Cihazı',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Onayla'),
          ),
        ),
      ],
    );
  }
}

class _BigBillPrompt extends StatelessWidget {
  const _BigBillPrompt({
    required this.givenKurus,
    required this.changeKurus,
    required this.options,
    required this.onSelect,
  });

  final int givenKurus;
  final int changeKurus;
  final ChangeOptions options;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Verilen: ${BCoinFormatter.withSymbol(givenKurus)}'
          '   →   Para üstü: ${BCoinFormatter.withSymbol(changeKurus)}',
          style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < options.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onSelect(i),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _formatOption(options.options[i]),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatOption(ChangeOption opt) {
    if (opt.denominationsKurus.isEmpty) return '— (boş)';
    return opt.denominationsKurus
        .map((k) => BCoinFormatter.withSymbol(k))
        .join('  +  ');
  }
}
