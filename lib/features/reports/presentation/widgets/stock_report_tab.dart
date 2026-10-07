/// Reports — Stock Report tab.
///
/// Shows stock quantity list with purchase rate valuation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/features/reports/providers/reports_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';

class StockReportTab extends ConsumerWidget {
  const StockReportTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(stockReportProvider);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    return products.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noProductsInInventory));
        }

        final totalStockValue = items.fold<double>(
          0.0,
          (sum, p) => sum + (p.purchaseRate * p.stockQuantity),
        );

        return Column(
          children: [
            // ── Summary ─────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Stock Value (at Purchase Rate)',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryFor(context))),
                        const SizedBox(height: 4),
                        Text(
                          currencyFmt.format(totalStockValue),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${items.length} Products',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Table ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                  ),
                  dataTextStyle: theme.textTheme.bodyMedium,
                  columns: [
                    const DataColumn(label: Text('#')),
                    DataColumn(label: Text(AppLocalizations.of(context)!.product)),
                    DataColumn(label: Text(AppLocalizations.of(context)!.category)),
                    DataColumn(label: Text(AppLocalizations.of(context)!.stockQty), numeric: true),
                    DataColumn(label: Text(AppLocalizations.of(context)!.purchaseRate), numeric: true),
                    DataColumn(label: Text(AppLocalizations.of(context)!.stockValue), numeric: true),
                  ],
                  rows: items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final value = p.purchaseRate * p.stockQuantity;

                    return DataRow(cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(p.category)),
                      DataCell(Text('${p.stockQuantity}',
                          style: TextStyle(
                            color: p.stockQuantity <= 5
                                ? AppColors.error
                                : AppColors.textPrimaryFor(context),
                            fontWeight: p.stockQuantity <= 5
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ))),
                      DataCell(Text(currencyFmt.format(p.purchaseRate))),
                      DataCell(Text(currencyFmt.format(value))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
