import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/bcoin_formatter.dart';
import '../../state/app_providers.dart';
import '../../theme/app_theme.dart';

/// Önceki Rapor sekmesi (GDD §6.4 mini-versiyon, en son tamamlanan vardiya).
class RaporTab extends ConsumerWidget {
  const RaporTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(lastShiftProvider);
    if (record == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Henüz tamamlanmış gün yok.\nİlk günü başlatıp burada raporu gör.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSoft),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                'Gün ${record.shiftNumber} özeti',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _row('İşlenen müşteri', '${record.customersServed}'),
              _row('Kaybedilen müşteri', '${record.customersLost}'),
              _row('Kaçırılan talep', '${record.missedDemand}'),
              _row('Yanlış para üstü', '${record.wrongChange}'),
              const Divider(height: 24),
              _row('Ciro', BCoinFormatter.withSymbol(record.revenueKurus)),
              _row(
                'Maliyet',
                '-${BCoinFormatter.withSymbol(record.costKurus)}',
              ),
              _row(
                'Net kâr',
                BCoinFormatter.signed(record.netKurus),
                emphasize: true,
              ),
              _row('XP', '+${record.xpEarned}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft)),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              color: emphasize ? AppColors.secondary : AppColors.ink,
              fontSize: emphasize ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
