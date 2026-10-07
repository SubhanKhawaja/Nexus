/// Reports — Sales Summary tab (Financial Reports UI).
///
/// Features grid cards, a revenue trend line chart, and a daily sales summary.
/// All data is sourced from the database via Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/features/reports/providers/reports_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';

class SalesSummaryTab extends ConsumerWidget {
  const SalesSummaryTab({super.key});

  /// Format large numbers in a compact way (e.g. 124500 → "124.5k").
  String _compactValue(double value, NumberFormat currencyFmt) {
    if (value.abs() >= 1000000) {
      return '${currencyFmt.currencySymbol}${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${currencyFmt.currencySymbol}${(value / 1000).toStringAsFixed(1)}k';
    }
    return currencyFmt.format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final l10n = AppLocalizations.of(context)!;

    final grossSales = ref.watch(grossSalesProvider);
    final netProfit = ref.watch(netProfitProvider);
    final avgOrderValue = ref.watch(avgOrderValueProvider);
    final transactionCount = ref.watch(transactionCountProvider);
    final dailySummaries = ref.watch(dailySalesSummaryProvider);
    final chartData = ref.watch(dailyChartDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Stats Grid ─────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  title: 'GROSS SALES',
                  asyncValue: grossSales.whenData(
                    (v) => _compactValue(v, currencyFmt),
                  ),
                  isPositive: true,
                ),
                _StatCard(
                  title: 'NET PROFIT',
                  asyncValue: netProfit.whenData(
                    (v) => _compactValue(v, currencyFmt),
                  ),
                  isPositive: netProfit.valueOrNull != null
                      ? netProfit.valueOrNull! >= 0
                      : true,
                ),
                _StatCard(
                  title: 'AVG ORDER VAL',
                  asyncValue: avgOrderValue.whenData(
                    (v) => currencyFmt.format(v),
                  ),
                  isPositive: true,
                ),
                _StatCard(
                  title: 'TRANSACTIONS',
                  asyncValue: transactionCount.whenData(
                    (v) => v.toString(),
                  ),
                  isPositive: true,
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // ── 2. Revenue Trend Chart ────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Revenue Trend',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(l10n.export),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: chartData.when(
                      data: (totals) {
                        if (totals.isEmpty || totals.every((v) => v == 0)) {
                          return Center(
                            child: Text(
                              'No sales data for this period',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryFor(context),
                              ),
                            ),
                          );
                        }

                        final maxY = totals.reduce((a, b) => a > b ? a : b);
                        final spots = <FlSpot>[];
                        for (int i = 0; i < totals.length; i++) {
                          spots.add(FlSpot(i.toDouble(), totals[i]));
                        }

                        return LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: (totals.length - 1).toDouble(),
                            minY: 0,
                            maxY: maxY * 1.1,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withAlpha(20),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Error loading chart data'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 3. Daily Sales Summary ────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Daily Sales Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Date', style: theme.textTheme.labelMedium),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Orders', style: theme.textTheme.labelMedium),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Gross Sales',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelMedium),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                dailySummaries.when(
                  data: (summaries) {
                    if (summaries.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No sales recorded in this period',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summaries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = summaries[index];
                        return _DailySaleRow(
                          date: DateFormat('MMM d, yyyy').format(s.date),
                          orders: s.orderCount,
                          sales: s.grossSales,
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Error loading data')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  final String title;
  final AsyncValue<String> asyncValue;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.asyncValue,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiaryFor(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            asyncValue.when(
              data: (value) => Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryFor(context),
                ),
              ),
              loading: () => SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              error: (_, __) => Text(
                '--',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryFor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySaleRow extends ConsumerWidget {
  final String date;
  final int orders;
  final double sales;

  const _DailySaleRow({
    required this.date,
    required this.orders,
    required this.sales,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              orders.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFmt.format(sales),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
