import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/catalog.dart';

/// Master ürün katalogunu `assets/data/products.json`'dan yükler (GDD §9.4).
///
/// Faz 0–1'de doğrudan JSON'dan okunur. Faz 2'de `catalog_v1` Hive box'ına
/// seed edilip runtime'da Hive'dan okunacak (GDD §9.4 hibrit model).
class CatalogLoader {
  CatalogLoader._();

  static const String assetPath = 'assets/data/products.json';

  static Future<Catalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Catalog.fromJson(json);
  }
}
