/// POS — Cart state providers.
///
/// Manages the active cart: adding/removing items, quantity
/// changes, subtotal/tax/total calculations, and checkout processing.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/database/app_database.dart';

// ── Cart Item Model ─────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.sellingPrice * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// ── Transaction Type Selector ───────────────────────────────
final posTransactionTypeProvider = StateProvider<String>((ref) {
  return TransactionType.saleDaily;
});

// ── Cart State ──────────────────────────────────────────────
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(state);
      updated[existingIndex] = updated[existingIndex]
          .copyWith(quantity: updated[existingIndex].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void clear() => state = [];
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// ── Derived Calculations ────────────────────────────────────
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.lineTotal);
});

final cartTaxProvider = Provider<double>((ref) {
  return 0.0;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider);
});

// ── Cash Received ───────────────────────────────────────────
final cashReceivedProvider = StateProvider<double>((ref) => 0.0);

final changeDueProvider = Provider<double>((ref) {
  final received = ref.watch(cashReceivedProvider);
  final total = ref.watch(cartTotalProvider);
  return (received - total).clamp(0.0, double.infinity);
});

// ── Product Search ──────────────────────────────────────────
final posSearchQueryProvider = StateProvider<String>((ref) => '');

final posProductListProvider = StreamProvider<List<Product>>((ref) {
  final query = ref.watch(posSearchQueryProvider);
  final dao = ref.watch(productDaoProvider);

  if (query.isEmpty) {
    return dao.watchAll();
  }
  return dao.watchBySearch(query);
});

// ── Checkout Action ─────────────────────────────────────────
final checkoutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final total = ref.read(cartTotalProvider);
    final txnType = ref.read(posTransactionTypeProvider);
    final txnDao = ref.read(transactionDaoProvider);
    final productDao = ref.read(productDaoProvider);

    // Create transaction header + items
    await txnDao.insertFullTransaction(
      header: TransactionsCompanion.insert(
        transactionType: txnType,
        date: DateTime.now(),
        totalAmount: total,
      ),
      items: cart
          .map((item) => TransactionItemsCompanion.insert(
                transactionId: 0, // will be replaced by DAO
                productId: item.product.id,
                quantity: item.quantity,
                unitPrice: item.product.sellingPrice,
              ))
          .toList(),
    );

    // Update stock quantities
    for (final item in cart) {
      final delta =
          txnType == TransactionType.saleDaily ||
                  txnType == TransactionType.purchaseReturn
              ? -item.quantity
              : item.quantity;
      await productDao.adjustStock(item.product.id, delta);
    }

    // Clear cart
    ref.read(cartProvider.notifier).clear();
    ref.read(cashReceivedProvider.notifier).state = 0.0;
  };
});
