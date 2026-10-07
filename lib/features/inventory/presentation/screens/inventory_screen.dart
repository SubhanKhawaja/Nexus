/// Inventory — Main screen.
///
/// Search bar, category filter chips, product list with
/// swipe-to-delete (mobile), and FAB to add new products.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/inventory/providers/inventory_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/widgets/user_avatar.dart';
import '../widgets/product_card.dart';
import '../widgets/add_product_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(inventoryProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(inventoryCategoryFilterProvider);
    final isWide = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventory),
        actions: [
          IconButton(
            icon: const UserAvatar(radius: 16),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Search Bar ──────────────────────────────────
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products, SKU, or category...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                ref.read(inventorySearchProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 12),

            // ── Category Chips ──────────────────────────────
            SizedBox(
              height: 40,
              child: categories.when(
                data: (cats) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.allStock),
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            ref
                                .read(
                                    inventoryCategoryFilterProvider.notifier)
                                .state = null;
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selectedCategory == null
                                ? Colors.white
                                : AppColors.textPrimaryFor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          showCheckmark: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.lowStock),
                          selected: selectedCategory == '__low__',
                          onSelected: (_) {
                            ref
                                .read(
                                    inventoryCategoryFilterProvider.notifier)
                                .state = '__low__';
                          },
                          selectedColor: AppColors.warning,
                          labelStyle: TextStyle(
                            color: selectedCategory == '__low__'
                                ? Colors.white
                                : AppColors.textPrimaryFor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          showCheckmark: false,
                        ),
                      ),
                      ...cats.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selectedCategory == cat,
                            onSelected: (_) {
                              ref
                                  .read(
                                      inventoryCategoryFilterProvider.notifier)
                                  .state = cat;
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selectedCategory == cat
                                  ? Colors.white
                                  : AppColors.textPrimaryFor(context),
                              fontWeight: FontWeight.w600,
                            ),
                            showCheckmark: false,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Product List ────────────────────────────────
            Expanded(
              child: products.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: AppColors.textTertiaryFor(context)),
                          const SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textSecondaryFor(context),
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first product',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiaryFor(context),
                                    ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isWide) {
                    // Desktop: grid layout
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500,
                        childAspectRatio: 3.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: items[index],
                          onDelete: () {
                            ref.read(deleteProductProvider)(items[index].id);
                          },
                        );
                      },
                    );
                  }

                  // Mobile: list layout
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: items[index],
                        onDelete: () {
                          ref.read(deleteProductProvider)(items[index].id);
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
        ),
      ),

      // ── FAB ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        heroTag: 'inventory_fab',
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddProductDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
