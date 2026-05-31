import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import 'dart:async';

import '../../services/bcoin_formatter.dart';
import '../../services/telemetry/telemetry_service.dart';
import '../../state/economy_state.dart';
import '../../state/inventory_state.dart';
import '../../theme/app_theme.dart';

/// Sipariş sekmesi (GDD §3.5). Quick-order butonları + per-product
/// auto-reorder eşiği + vardiya başı önerileri uygula.
class SiparisTab extends ConsumerWidget {
  const SiparisTab({required this.catalog, super.key});

  final Catalog catalog;

  /// Auto-reorder threshold preset cycle (0 = kapalı).
  static const List<int> _thresholdCycle = [0, 5, 10, 15, 20];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final economy = ref.watch(economyProvider);
    final invNotifier = ref.read(inventoryProvider.notifier);
    final econNotifier = ref.read(economyProvider.notifier);
    final suggestions = invNotifier.autoReorderSuggestions();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SuggestionsBanner(
          suggestions: suggestions,
          catalog: catalog,
          coinsKurus: economy.coinsKurus,
          shiftNumber: economy.shiftNumber,
          onApply: () => _applySuggestions(
            suggestions: suggestions,
            catalog: catalog,
            invNotifier: invNotifier,
            econNotifier: econNotifier,
            shiftNumber: economy.shiftNumber,
          ),
        ),
        const SizedBox(height: 8),
        for (final p in catalog.products)
          _SiparisRow(
            product: p,
            item: inventory[p.id],
            coinsKurus: economy.coinsKurus,
            onOrder: (qty) => _placeOrder(
              product: p,
              quantity: qty,
              invNotifier: invNotifier,
              econNotifier: econNotifier,
              shiftNumber: economy.shiftNumber,
            ),
            onCycleThreshold: () {
              final item = inventory[p.id];
              if (item == null) return;
              final current = item.autoReorderThreshold;
              final next = _thresholdCycle[
                  (_thresholdCycle.indexOf(current).clamp(0, 99) + 1) %
                      _thresholdCycle.length];
              invNotifier.setItem(
                item.copyWith(
                  autoReorderThreshold: next,
                  autoReorderEnabled: next > 0,
                ),
              );
            },
          ),
      ],
    );
  }

  void _placeOrder({
    required Product product,
    required int quantity,
    required InventoryNotifier invNotifier,
    required EconomyNotifier econNotifier,
    required int shiftNumber,
  }) {
    final cost = product.costPriceKurus * quantity;
    if (!econNotifier.deductCoins(cost)) return;
    invNotifier.placeOrder(
      productId: product.id,
      quantity: quantity,
      costPaidKurus: cost,
      currentShiftNumber: shiftNumber,
    );
    unawaited(
      TelemetryService.instance.orderPlaced(
        productIds: List.filled(quantity, product.id),
        totalCostKurus: cost,
      ),
    );
  }

  void _applySuggestions({
    required List<({String productId, int quantity})> suggestions,
    required Catalog catalog,
    required InventoryNotifier invNotifier,
    required EconomyNotifier econNotifier,
    required int shiftNumber,
  }) {
    for (final s in suggestions) {
      final product = catalog.byId(s.productId);
      _placeOrder(
        product: product,
        quantity: s.quantity,
        invNotifier: invNotifier,
        econNotifier: econNotifier,
        shiftNumber: shiftNumber,
      );
    }
  }
}

class _SuggestionsBanner extends StatelessWidget {
  const _SuggestionsBanner({
    required this.suggestions,
    required this.catalog,
    required this.coinsKurus,
    required this.shiftNumber,
    required this.onApply,
  });

  final List<({String productId, int quantity})> suggestions;
  final Catalog catalog;
  final int coinsKurus;
  final int shiftNumber;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Auto-reorder önerisi yok. (Eşik = 0 ile devre dışı)',
          style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
        ),
      );
    }
    final totalCost = suggestions.fold<int>(
      0,
      (sum, s) => sum + catalog.byId(s.productId).costPriceKurus * s.quantity,
    );
    final canAfford = coinsKurus >= totalCost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto-reorder önerisi: ${suggestions.length} ürün',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam: ${BCoinFormatter.withSymbol(totalCost)}',
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canAfford ? onApply : null,
              child: Text(canAfford ? 'Tümünü onayla' : 'Yetersiz bakiye'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiparisRow extends StatelessWidget {
  const _SiparisRow({
    required this.product,
    required this.item,
    required this.coinsKurus,
    required this.onOrder,
    required this.onCycleThreshold,
  });

  final Product product;
  final InventoryItem? item;
  final int coinsKurus;
  final void Function(int quantity) onOrder;
  final VoidCallback onCycleThreshold;

  @override
  Widget build(BuildContext context) {
    final locked = item == null;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.nameTr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: locked ? AppColors.inkSoft : AppColors.ink,
                  ),
                ),
              ),
              Text(
                'Maliyet: ${BCoinFormatter.withSymbol(product.costPriceKurus)} /adet',
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
              ),
            ],
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Lvl ${product.unlockLevel}\'de açılır',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkSoft,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  for (final qty in const [5, 10, 20])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: OutlinedButton(
                        onPressed: coinsKurus >= product.costPriceKurus * qty
                            ? () => onOrder(qty)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('+$qty'),
                      ),
                    ),
                  const Spacer(),
                  InkWell(
                    onTap: onCycleThreshold,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item!.autoReorderEnabled
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        item!.autoReorderEnabled
                            ? 'Auto: ${item!.autoReorderThreshold}'
                            : 'Auto: kapalı',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
