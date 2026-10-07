/// POS — Checkout summary panel.
///
/// Shows subtotal, tax, total, cash received input, and change due.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/pos/providers/cart_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';

class CheckoutSummary extends ConsumerWidget {
  const CheckoutSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final total = ref.watch(cartTotalProvider);
    final changeDue = ref.watch(changeDueProvider);
    final cart = ref.watch(cartProvider);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Summary rows ──────────────────────────────────
          _SummaryRow(label: 'Subtotal', value: currencyFmt.format(subtotal)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          // ── Total ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                currencyFmt.format(total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Cash Received ─────────────────────────────────
          Text(
            'CASH RECEIVED',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiaryFor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '${currencyFmt.currencySymbol} ',
              prefixStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              hintText: '0.00',
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            onChanged: (value) {
              ref.read(cashReceivedProvider.notifier).state =
                  double.tryParse(value) ?? 0.0;
            },
          ),
          const SizedBox(height: 12),

          // ── Change Due ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change Due:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                currencyFmt.format(changeDue),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Checkout Button ───────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: cart.isEmpty
                  ? null
                  : () async {
                      final checkout = ref.read(checkoutProvider);
                      await checkout();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.transactionCompleted),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(AppLocalizations.of(context)!.completeSale),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondaryFor(context))),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
