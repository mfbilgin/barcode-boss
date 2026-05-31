import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import 'dart:async';

import '../../services/bcoin_formatter.dart';
import '../../services/elasticity.dart';
import '../../services/telemetry/telemetry_service.dart';
import '../../state/inventory_state.dart';
import '../../theme/app_theme.dart';

/// Fiyat sekmesi (GDD §3.5) — per-product slider, canlı elastikiyet önizlemesi.
class FiyatTab extends ConsumerWidget {
  const FiyatTab({required this.catalog, super.key});

  final Catalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final p in catalog.products)
          if (inventory[p.id] != null)
            _FiyatRow(
              key: ValueKey(p.id),
              product: p,
              item: inventory[p.id]!,
              onCommit: (kurus) {
                final old = inventory[p.id]!.currentSellPriceKurus;
                ref.read(inventoryProvider.notifier).setItem(
                  inventory[p.id]!.copyWith(currentSellPriceKurus: kurus),
                );
                if (old != kurus) {
                  unawaited(
                    TelemetryService.instance.priceChanged(
                      productId: p.id,
                      oldPriceKurus: old,
                      newPriceKurus: kurus,
                      elasticity: p.elasticity,
                    ),
                  );
                }
              },
            )
          else
            _LockedRow(product: p),
      ],
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.nameTr,
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ),
          Text(
            'Lvl ${product.unlockLevel}\'de açılır',
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _FiyatRow extends StatefulWidget {
  const _FiyatRow({
    required this.product,
    required this.item,
    required this.onCommit,
    super.key,
  });

  final Product product;
  final InventoryItem item;
  final void Function(int kurus) onCommit;

  @override
  State<_FiyatRow> createState() => _FiyatRowState();
}

class _FiyatRowState extends State<_FiyatRow> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.item.currentSellPriceKurus.toDouble();
  }

  @override
  void didUpdateWidget(covariant _FiyatRow old) {
    super.didUpdateWidget(old);
    // Dışarıdan reset edilirse (yeni oyun vs.) slider'ı senkronla.
    if (old.item.currentSellPriceKurus != widget.item.currentSellPriceKurus) {
      _value = widget.item.currentSellPriceKurus.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPrice = widget.product.defaultSellPriceKurus;
    final min = defaultPrice * 0.5;
    final max = defaultPrice * 3.0;
    final priceKurus = _value.round();
    final chance = Elasticity.purchaseChance(
      currentSellPriceKurus: priceKurus,
      defaultSellPriceKurus: defaultPrice,
      elasticity: widget.product.elasticity,
    );

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
                  widget.product.nameTr,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                BCoinFormatter.withSymbol(priceKurus),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          Slider(
            min: min,
            max: max,
            value: _value.clamp(min, max),
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _value = v),
            onChangeEnd: (v) => widget.onCommit(v.round()),
          ),
          Row(
            children: [
              Text(
                'Default: ${BCoinFormatter.withSymbol(defaultPrice)}'
                ' · Esneklik: ${_elasticityLabel(widget.product.elasticity)}',
                style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
              ),
              const Spacer(),
              Text(
                'Satış olasılığı: %${(chance * 100).round()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: chance >= 0.66
                      ? AppColors.patienceHigh
                      : chance >= 0.33
                          ? AppColors.patienceMid
                          : AppColors.patienceLow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _elasticityLabel(int e) {
    switch (e) {
      case 0:
        return 'inelastik';
      case 2:
        return 'elastik';
      default:
        return 'normal';
    }
  }
}
