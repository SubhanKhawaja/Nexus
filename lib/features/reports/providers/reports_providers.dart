/// Reports — Riverpod providers for report data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/database/app_database.dart';
import 'package:nexus/core/database/daos/transaction_dao.dart';

/// All products for stock report.
final stockReportProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productDaoProvider).watchAll();
});

/// All accounts for accounts statement.
final accountsReportProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountDaoProvider).watchAll();
});

/// Selected date range for sales summary.
/// Defaults to current month if not set.
final salesDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: now,
  );
});

/// Today's sales total.
final salesTodayTotalProvider = StreamProvider<double>((ref) {
  return ref.watch(transactionDaoProvider).watchTodaySalesTotal();
});

// ── Sales Summary Providers (driven by date range) ─────────

/// Gross sales total for the selected range.
final grossSalesProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.saleDaily,
        range.start,
        range.end,
      );
});

/// Sales returns total for the selected range.
final salesReturnsProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.salesReturn,
        range.start,
        range.end,
      );
});

/// Purchase total for the selected range (cost of goods).
final purchaseTotalByRangeProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.dailyPurchase,
        range.start,
        range.end,
      );
});

/// Transaction count for the selected range.
final transactionCountProvider = FutureProvider<int>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).countByTypeAndDateRange(
        TransactionType.saleDaily,
        range.start,
        range.end,
      );
});

/// Net profit = gross sales - sales returns - purchases.
final netProfitProvider = FutureProvider<double>((ref) async {
  final gross = await ref.watch(grossSalesProvider.future);
  final returns = await ref.watch(salesReturnsProvider.future);
  final purchases = await ref.watch(purchaseTotalByRangeProvider.future);
  return gross - returns - purchases;
});

/// Average order value = gross sales / transaction count.
final avgOrderValueProvider = FutureProvider<double>((ref) async {
  final gross = await ref.watch(grossSalesProvider.future);
  final count = await ref.watch(transactionCountProvider.future);
  if (count == 0) return 0.0;
  return gross / count;
});

/// Daily sales summary rows for the table.
final dailySalesSummaryProvider =
    FutureProvider<List<DailySalesSummary>>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).dailySalesSummary(
        range.start,
        range.end,
      );
});

/// Daily totals for the revenue trend chart.
final dailyChartDataProvider = FutureProvider<List<double>>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).dailyTotalsForChart(
        range.start,
        range.end,
      );
});

/// Sales by date range (legacy — used by other parts).
final salesByRangeProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.saleDaily,
        range.start,
        range.end,
      );
});

/// Purchase total by date range (for income/expense).
final purchaseTotalProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.dailyPurchase,
        range.start,
        range.end,
      );
});

/// Sales total for income statement.
final salesTotalForIncomeProvider = FutureProvider<double>((ref) async {
  final range = ref.watch(salesDateRangeProvider);
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.saleDaily,
        range.start,
        range.end,
      );
});
