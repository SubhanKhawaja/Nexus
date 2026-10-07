/// Reports — Income & Expenses Summary tab.
///
/// Shows revenue vs cost breakdown for the current period.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/features/reports/providers/reports_providers.dart';

class IncomeExpensesTab extends ConsumerWidget {
  const IncomeExpensesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesTotal = ref.watch(salesTotalForIncomeProvider);
    final purchaseTotal = ref.watch(purchaseTotalProvider);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Month Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // ── Revenue Card ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: AppColors.success, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue (Sales)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            )),
                        const SizedBox(height: 4),
                        salesTotal.when(
                          data: (v) => Text(
                            currencyFmt.format(v),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          loading: () => const Text('...'),
                          error: (_, __) => const Text('--'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expenses Card ─────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_down_rounded,
                        color: AppColors.error, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expenses (Purchases)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            )),
                        const SizedBox(height: 4),
                        purchaseTotal.when(
                          data: (v) => Text(
                            currencyFmt.format(v),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                          loading: () => const Text('...'),
                          error: (_, __) => const Text('--'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Net Income Card ───────────────────────────────
          Builder(builder: (context) {
            final salesVal = salesTotal.valueOrNull ?? 0.0;
            final purchaseVal = purchaseTotal.valueOrNull ?? 0.0;
            final net = salesVal - purchaseVal;
            final isPositive = net >= 0;

            return Card(
              color: isPositive
                  ? AppColors.successLight
                  : AppColors.errorLight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Income',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          'Revenue - Expenses',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryFor(context),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${currencyFmt.format(net)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
