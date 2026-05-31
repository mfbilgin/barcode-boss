import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/bcoin_formatter.dart';
import '../services/tutorial_service.dart';
import '../state/app_providers.dart';
import '../state/economy_state.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/tutorial_banner.dart';
import 'prep/fiyat_tab.dart';
import 'prep/rapor_tab.dart';
import 'prep/siparis_tab.dart';
import 'prep/stok_tab.dart';

/// Hazırlık Ekranı (GDD §6.2). Faz 2: dört sekme + auto-reorder + öneriler.
/// Faz 5: §14.4 stok=0 lifeline (vardiya başlatma blokajı + 200 BC avans).
///
/// Provider state mutasyonları event handler'larda yapılır (build sırasında
/// değil — Riverpod buna izin vermez).
class PrepScreen extends ConsumerStatefulWidget {
  const PrepScreen({super.key});

  @override
  ConsumerState<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends ConsumerState<PrepScreen>
    with SingleTickerProviderStateMixin {
  static const int _tabOrders = 1;

  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    // Katalog yüklenip ekran ilk frame'i çizildikten sonra eksik ürünleri seed et.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final catalog = await ref.read(catalogProvider.future);
      if (!mounted) return;
      final level = ref.read(economyProvider).storeLevel;
      ref.read(inventoryProvider.notifier).ensureSeeded(catalog, level);

      // §6.4 — RaporTab için son vardiyayı Hive'dan restore et.
      // (Provider state ShiftSummaryScreen unmount'unda kaybolabiliyor;
      // Hive tek doğru kaynak.)
      if (ref.read(lastShiftProvider) == null) {
        final last = ref.read(saveServiceProvider).lastShiftRecord;
        if (last != null) {
          ref.read(lastShiftProvider.notifier).state = last;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _startShift() async {
    // §14.4 — stok=0 ise vardiya başlamaz; Sipariş sekmesine yönlendir,
    // bakiye yetersizse 200 BC tek-seferlik avans.
    final inv = ref.read(inventoryProvider);
    final allZero =
        inv.isNotEmpty && inv.values.every((it) => it.totalQty == 0);
    if (allZero) {
      final lifeline = ref.read(lifelineServiceProvider);
      final result = lifeline.checkStockZero(inventoryAllZero: true);
      if (result.advanceKurus > 0) {
        ref.read(economyProvider.notifier).syncFromSave();
      }
      if (!mounted) return;
      _tabs.animateTo(_tabOrders);
      await _showStockZeroDialog(result.advanceKurus);
      return;
    }

    // Sipariş teslimi + depodan rafa taşıma — vardiya başlamadan önce.
    final shiftNumber = ref.read(economyProvider).shiftNumber;
    ref.read(inventoryProvider.notifier).processShiftStart(shiftNumber);
    if (!mounted) return;
    context.go(Routes.game);
  }

  Future<void> _showStockZeroDialog(int advanceKurus) async {
    final l = AppLocalizations.of(context);
    final body = advanceKurus > 0
        ? l.stockZeroDialogBodyWithAdvance(
            BCoinFormatter.withSymbol(advanceKurus),
          )
        : l.stockZeroDialogBody;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.stockZeroDialogTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.stockZeroDialogClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final economy = ref.watch(economyProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l.prepTitle(economy.shiftNumber)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                BCoinFormatter.withSymbol(economy.coinsKurus),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(Routes.settings),
            tooltip: l.tooltipSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.inkSoft,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l.tabStock),
            Tab(text: l.tabOrders),
            Tab(text: l.tabPricing),
            Tab(text: l.tabReport),
          ],
        ),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Katalog yüklenemedi: $e')),
        data: (catalog) => Column(
          children: [
            const TutorialBanner(
              step: TutorialStep.prepTabs,
              title: 'Hazırlık ekranı',
              body:
                  'Stok / Sipariş / Fiyat sekmeleriyle dükkânı yönet. Sipariş günün başında ("Güne Başla" anında) teslim edilir.',
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  StokTab(catalog: catalog),
                  SiparisTab(catalog: catalog),
                  FiyatTab(catalog: catalog),
                  const RaporTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startShift,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l.buttonStartShiftUpper),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

