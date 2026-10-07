/// POS — Main checkout screen.
///
/// Desktop: split-screen (products left, cart + checkout right).
/// Mobile: vertical scroll with type tabs, products, cart, checkout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/pos/providers/cart_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/widgets/user_avatar.dart';
import '../widgets/product_search.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/checkout_summary.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pointOfSale),
        actions: [
          IconButton(
            icon: const UserAvatar(radius: 16),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Transaction Type Tabs ─────────────────────────
          const _TransactionTypeTabs(),
          const Divider(height: 1),

          // ── Main Content ──────────────────────────────────
          Expanded(
            child: isWide
                ? const _DesktopPosLayout()
                : const _MobilePosLayout(),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Type Tabs ────────────────────────────────────
class _TransactionTypeTabs extends ConsumerWidget {
  const _TransactionTypeTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(posTransactionTypeProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: TransactionType.all.map((type) {
          final isSelected = type == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(TransactionType.label(type)),
              selected: isSelected,
              onSelected: (_) {
                ref.read(posTransactionTypeProvider.notifier).state = type;
                ref.read(cartProvider.notifier).clear();
              },
              selectedColor: AppColors.primary,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w600,
              ),
              side: isSelected
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.cardBorder),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Desktop Layout ───────────────────────────────────────────
class _DesktopPosLayout extends ConsumerWidget {
  const _DesktopPosLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Product Search (left) ───────────────────────────
        const Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ProductSearch(),
          ),
        ),

        const VerticalDivider(width: 1),

        // ── Cart + Checkout (right) ─────────────────────────
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CartHeader(),
                const Divider(),
                const Expanded(child: _CartList()),
                const SizedBox(height: 12),
                const CheckoutSummary(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile Layout ────────────────────────────────────────────
class _MobilePosLayout extends ConsumerWidget {
  const _MobilePosLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Search (constrained height) ───────────
          SizedBox(
            height: 300,
            child: ProductSearch(),
          ),

          if (cart.isNotEmpty) ...[
            const SizedBox(height: 16),

            // ── Current Sale Header ─────────────────────────
            _CartHeader(),
            const Divider(),

            // ── Cart Items ──────────────────────────────────
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return CartItemTile(
                  item: item,
                  onQuantityChanged: (qty) {
                    ref
                        .read(cartProvider.notifier)
                        .updateQuantity(item.product.id, qty);
                  },
                  onRemove: () {
                    ref
                        .read(cartProvider.notifier)
                        .removeProduct(item.product.id);
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // ── Checkout Summary ────────────────────────────
            const CheckoutSummary(),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Cart Header ──────────────────────────────────────────────
class _CartHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnType = ref.watch(posTransactionTypeProvider);
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Current ${TransactionType.label(txnType)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (cart.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.error,
            onPressed: () => ref.read(cartProvider.notifier).clear(),
            tooltip: 'Clear cart',
          ),
      ],
    );
  }
}

// ── Cart List ────────────────────────────────────────────────
class _CartList extends ConsumerWidget {
  const _CartList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 48, color: AppColors.textTertiaryFor(context)),
            const SizedBox(height: 8),
            Text(
              'Cart is empty',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiaryFor(context),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a product to add it',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryFor(context),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cart.length,
      itemBuilder: (context, index) {
        final item = cart[index];
        return CartItemTile(
          item: item,
          onQuantityChanged: (qty) {
            ref
                .read(cartProvider.notifier)
                .updateQuantity(item.product.id, qty);
          },
          onRemove: () {
            ref.read(cartProvider.notifier).removeProduct(item.product.id);
          },
        );
      },
    );
  }
}
