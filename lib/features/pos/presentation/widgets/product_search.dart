/// POS — Product search bar and grid.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/database/app_database.dart';
import 'package:nexus/features/pos/providers/cart_providers.dart';

class ProductSearch extends ConsumerWidget {
  const ProductSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(posProductListProvider);
    final currencyFmt = ref.watch(currencyFormatterProvider);

    return Column(
      children: [
        // ── Search Bar ──────────────────────────────────────
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search products, SKU, or category...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) {
            ref.read(posSearchQueryProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 12),

        // ── Product Grid ────────────────────────────────────
        Expanded(
          child: products.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 56, color: AppColors.textTertiaryFor(context)),
                      const SizedBox(height: 12),
                      Text(
                        'No products found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add products in the Inventory tab',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryFor(context),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = items[index];
                  return _ProductTile(
                    product: product,
                    currencyFmt: currencyFmt,
                    onTap: () {
                      ref.read(cartProvider.notifier).addProduct(product);
                    },
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final Product product;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.currencyFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLowStock = product.stockQuantity <= 5;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.inventory_2_rounded,
            color: AppColors.textSecondaryFor(context), size: 22),
      ),
      title: Text(
        product.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryFor(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            product.category,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryFor(context),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isLowStock ? AppColors.errorLight : AppColors.successLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isLowStock ? 'Low Stock' : 'In Stock',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isLowStock ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${product.stockQuantity} Units',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryFor(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
      trailing: Text(
        currencyFmt.format(product.sellingPrice),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryFor(context),
        ),
      ),
    );
  }
}
