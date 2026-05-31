import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/shift_record.dart';
import '../services/bcoin_formatter.dart';
import '../state/app_providers.dart';
import '../theme/app_theme.dart';

/// Vardiya Sonu Raporu (Monitör — vardiya sonrası, GDD §6.4).
class ShiftSummaryScreen extends ConsumerStatefulWidget {
  const ShiftSummaryScreen({super.key});

  @override
  ConsumerState<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends ConsumerState<ShiftSummaryScreen> {
  bool _advanceDialogShown = false;

  @override
  void initState() {
    super.initState();
    // §14.2 — acil avans tetiklendiyse rapor görüntülenir görüntülenmez popup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _advanceDialogShown) return;
      final record = ref.read(lastShiftProvider);
      if (record == null || record.emergencyAdvanceKurus <= 0) return;
      _advanceDialogShown = true;
      final l = AppLocalizations.of(context);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.emergencyAdvanceDialogTitle),
          content: Text(
            l.emergencyAdvanceDialogBody(
              BCoinFormatter.withSymbol(record.emergencyAdvanceKurus),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.emergencyAdvanceDialogClose),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(lastShiftProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: record == null
                  ? Text(l.emptyShiftRecord)
                  : _Report(record: record),
            ),
          ),
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.record});

  final ShiftRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasTutorialBonus = record.tutorialBonusKurus > 0;
    final hasRepayment = record.repaymentKurus > 0;
    final hasEmergencyAdvance = record.emergencyAdvanceKurus > 0;
    final hasLifeline =
        hasTutorialBonus || hasRepayment || hasEmergencyAdvance;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.summaryTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _row(l.labelCustomersServed, '${record.customersServed}'),
              if (record.customersLost > 0)
                _row(l.labelCustomersLost, '${record.customersLost}'),
              _row(l.labelMissedDemand, '${record.missedDemand}'),
              if (record.wrongChange > 0)
                _row(l.labelWrongChange, '${record.wrongChange}'),
              _StarsRow(stars: record.stars, label: l.labelSatisfaction),
              const Divider(height: 24),
              _row(l.labelRevenue, BCoinFormatter.withSymbol(record.revenueKurus)),
              _row(l.labelCost, '-${BCoinFormatter.withSymbol(record.costKurus)}'),
              const Divider(height: 24),
              _row(
                l.labelNet,
                BCoinFormatter.signed(record.netKurus),
                emphasize: true,
              ),
              if (hasLifeline) const Divider(height: 24),
              if (hasTutorialBonus)
                _row(
                  l.labelTutorialBonus,
                  '+${BCoinFormatter.withSymbol(record.tutorialBonusKurus)}',
                ),
              if (hasRepayment)
                _row(
                  l.labelAdvanceRepayment,
                  '-${BCoinFormatter.withSymbol(record.repaymentKurus)}',
                ),
              if (hasEmergencyAdvance)
                _row(
                  l.labelEmergencyAdvance,
                  '+${BCoinFormatter.withSymbol(record.emergencyAdvanceKurus)}',
                ),
              _row(l.labelXp, '+${record.xpEarned}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.go(Routes.prep),
            child: Text(l.buttonBackToPrep),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    final style = TextStyle(
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
      fontSize: emphasize ? 18 : 15,
      color: emphasize ? AppColors.secondary : AppColors.ink,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.inkSoft,
                fontSize: style.fontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars, required this.label});

  final int stars;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft)),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
