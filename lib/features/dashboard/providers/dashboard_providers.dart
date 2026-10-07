/// Dashboard — Riverpod providers.
///
/// Exposes reactive streams for today's sales, cash flow,
/// low-stock alerts, and recent activity.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/database/app_database.dart';

/// Today's total sales amount (stream).
final todaySalesProvider = StreamProvider<double>((ref) {
  return ref.watch(transactionDaoProvider).watchTodaySalesTotal();
});

/// Yesterday's total sales amount (one-shot).
final yesterdaySalesProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final startOfYesterday = DateTime(now.year, now.month, now.day - 1);
  final endOfYesterday = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(seconds: 1));
  return ref.watch(transactionDaoProvider).totalByTypeAndDateRange(
        TransactionType.saleDaily,
        startOfYesterday,
        endOfYesterday,
      );
});

/// Percentage change from yesterday → today.
/// Returns null if yesterday had no sales (avoid division by zero).
final salesChangeProvider = Provider<double?>((ref) {
  final todayVal = ref.watch(todaySalesProvider).valueOrNull;
  final yesterdayVal = ref.watch(yesterdaySalesProvider).valueOrNull;
  if (todayVal == null || yesterdayVal == null) return null;
  if (yesterdayVal == 0) {
    return todayVal > 0 ? 100.0 : null;
  }
  return ((todayVal - yesterdayVal) / yesterdayVal) * 100;
});

/// Today's total cash received (stream).
final todayCashReceivedProvider = StreamProvider<double>((ref) {
  return ref.watch(cashFlowDaoProvider).watchTodayCashReceived();
});

/// Today's total cash paid (stream).
final todayCashPaidProvider = StreamProvider<double>((ref) {
  return ref.watch(cashFlowDaoProvider).watchTodayCashPaid();
});

/// Products with stock at or below the low-stock threshold (stream).
final lowStockProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productDaoProvider).watchLowStock(kLowStockThreshold);
});

/// Recent cash flows (stream, limited to 10).
final recentCashFlowsProvider = StreamProvider<List<CashFlow>>((ref) {
  return ref.watch(cashFlowDaoProvider).watchRecent(limit: 10);
});

/// Recent transactions (stream, newest first).
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(transactionDaoProvider).watchByDate(startOfDay);
});

