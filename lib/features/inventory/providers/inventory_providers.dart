/// Inventory — Riverpod providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/database/app_database.dart';

/// Search query for inventory filtering.
final inventorySearchProvider = StateProvider<String>((ref) => '');

/// Selected category filter (null = all).
final inventoryCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// All product categories.
final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productDaoProvider).getCategories();
});

/// Filtered product list (reactive).
final inventoryProductsProvider = StreamProvider<List<Product>>((ref) {
  final query = ref.watch(inventorySearchProvider);
  final category = ref.watch(inventoryCategoryFilterProvider);
  final dao = ref.watch(productDaoProvider);

  if (query.isNotEmpty) {
    return dao.watchBySearch(query);
  }
  if (category == '__low__') {
    return dao.watchLowStock(kLowStockThreshold);
  }
  if (category != null) {
    return dao.watchByCategory(category);
  }
  return dao.watchAll();
});

/// Add a new product.
final addProductProvider =
    Provider<Future<int> Function(ProductsCompanion)>((ref) {
  return (ProductsCompanion entry) {
    return ref.read(productDaoProvider).insertProduct(entry);
  };
});

/// Delete a product.
final deleteProductProvider =
    Provider<Future<int> Function(int)>((ref) {
  return (int id) {
    return ref.read(productDaoProvider).deleteProduct(id);
  };
});
