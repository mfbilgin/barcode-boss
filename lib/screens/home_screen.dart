import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/bcoin_formatter.dart';
import '../services/tutorial_service.dart';
import '../state/app_providers.dart';
import '../state/economy_state.dart';
import '../theme/app_theme.dart';
import '../widgets/tutorial_banner.dart';

/// Splash / Ana Menü (GDD §6.1).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final economy = ref.watch(economyProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go(Routes.settings),
                tooltip: l.tooltipSettings,
              ),
            ),
            const Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: TutorialBanner(
                step: TutorialStep.welcome,
                title: 'Hoş geldin!',
                body:
                    'Gün başlayınca müşteriler sırayla gelecek. Ürünün üstünde sola doğru kaydır (Tap modu Ayarlar\'da).',
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.appTitle,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.appTagline,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/images/props/character_employee.png',
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, size: 160),
                      ),
                      const SizedBox(height: 24),
                      _StatChip(
                        label: l.labelBalance,
                        value: BCoinFormatter.withSymbol(economy.coinsKurus),
                      ),
                      const SizedBox(height: 8),
                      _StatChip(
                        label: l.labelLevel,
                        value: l.levelAndShift(
                          economy.storeLevel,
                          economy.shiftNumber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _XpCard(
                        economy: economy,
                        lastShiftXp: ref.watch(lastShiftProvider)?.xpEarned,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go(Routes.prep),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(l.buttonStartShift),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.inkSoft),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// XP açıklayıcı kart: progress bar + mevcut/sonraki eşik + geçen gün +XP.
/// Tester feedback: "kullanıcı bir sonraki levelin kaç XP gerektirdiğini,
/// şu an kaç XP'de olduğunu, bir gün sonunda kaç XP kazandığını görmeli".
class _XpCard extends StatelessWidget {
  const _XpCard({required this.economy, required this.lastShiftXp});

  final EconomyState economy;

  /// En son tamamlanan günün kazandırdığı XP. `null` ise henüz gün oynanmadı.
  final int? lastShiftXp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isMax = economy.storeLevel >= 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${l.labelXpProgress}: ',
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              Text(
                isMax
                    ? '${economy.totalXp}'
                    : l.xpProgressValue(
                        economy.totalXp,
                        economy.nextLevelXpThreshold,
                      ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: economy.levelProgress,
              minHeight: 8,
              backgroundColor: const Color(0x22000000),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMax ? l.xpMaxLevel : l.xpRemaining(economy.xpToNextLevel),
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 2),
          Text(
            lastShiftXp == null
                ? l.xpNoLastDay
                : l.xpLastDay(lastShiftXp!),
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
