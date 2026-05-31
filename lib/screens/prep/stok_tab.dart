import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../state/inventory_state.dart';
import '../../theme/app_theme.dart';

/// Stok sekmesi (GDD §3.5) — kategorilere göre raf+depo, durum etiketleri.
class StokTab extends ConsumerWidget {
  const StokTab({required this.catalog, super.key});

  final Catalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final byCategory = _groupByCategory(catalog);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final entry in byCategory.entries) ...[
          _CategoryHeader(
            title: catalog.categories[entry.key]?.heading ?? entry.key,
          ),
          for (final p in entry.value)
            _StokRow(product: p, item: inventory[p.id]),
        ],
      ],
    );
  }

  Map<String, List<Product>> _groupByCategory(Catalog c) {
    final out = <String, List<Product>>{};
    for (final p in c.products) {
      out.putIfAbsent(p.category, () => []).add(p);
    }
    return out;
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _StokRow extends StatelessWidget {
  const _StokRow({required this.product, required this.item});

  final Product product;
  final InventoryItem? item;

  @override
  Widget build(BuildContext context) {
    final total = item?.totalQty ?? 0;
    final shelf = item?.shelfQty ?? 0;
    final warehouse = item?.warehouseQty ?? 0;
    final (label, color) = _status(total);
    final locked = item == null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameTr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: locked ? AppColors.inkSoft : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  locked
                      ? 'Lvl ${product.unlockLevel}\'de açılır'
                      : 'Raf: $shelf · Depo: $warehouse',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          if (!locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  (String, Color) _status(int total) {
    if (total == 0) return ('Tükendi', AppColors.patienceLow);
    if (total <= 5) return ('Azalıyor', AppColors.patienceMid);
    return ('Yeterli', AppColors.patienceHigh);
  }
}
