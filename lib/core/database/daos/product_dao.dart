/// DAO for [Products] table — CRUD, search, stock management.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  // ── Reads ──────────────────────────────────────────────────

  /// Watch all products ordered by name.
  Stream<List<Product>> watchAll() {
    return (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Get all products once.
  Future<List<Product>> getAll() {
    return (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Search products by name (case-insensitive).
  Stream<List<Product>> watchBySearch(String query) {
    return (select(products)
          ..where((t) => t.name.lower().like('%${query.toLowerCase()}%'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Get products filtered by category.
  Stream<List<Product>> watchByCategory(String category) {
    return (select(products)..where((t) => t.category.equals(category)))
        .watch();
  }

  /// Get products with stock at or below the low-stock threshold.
  Stream<List<Product>> watchLowStock(int threshold) {
    return (select(products)
          ..where(
              (t) => t.stockQuantity.isSmallerOrEqualValue(threshold))
          ..orderBy([(t) => OrderingTerm.asc(t.stockQuantity)]))
        .watch();
  }

  /// Get a single product by id.
  Future<Product> getById(int id) {
    return (select(products)..where((t) => t.id.equals(id))).getSingle();
  }

  // ── Writes ─────────────────────────────────────────────────

  /// Insert a new product and return the generated id.
  Future<int> insertProduct(ProductsCompanion entry) {
    return into(products).insert(entry);
  }

  /// Update an existing product. Returns true if the row was updated.
  Future<bool> updateProduct(Product entry) {
    return update(products).replace(entry);
  }

  /// Delete a product by id.
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((t) => t.id.equals(id))).go();
  }

  /// Adjust stock quantity by [delta] (positive = add, negative = remove).
  Future<void> adjustStock(int productId, int delta) async {
    final product = await getById(productId);
    await (update(products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion(
        stockQuantity: Value(product.stockQuantity + delta),
      ),
    );
  }

  /// Get distinct categories.
  Future<List<String>> getCategories() async {
    final query = selectOnly(products, distinct: true)
      ..addColumns([products.category]);
    final rows = await query.get();
    return rows.map((row) => row.read(products.category)!).toList();
  }
}
