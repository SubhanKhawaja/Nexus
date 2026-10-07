/// DAO for [Transactions] and [TransactionItems] tables.
///
/// Handles sale/purchase recording, item management, and
/// date-range queries for reporting.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, TransactionItems, Products, Accounts])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // ── Reads ──────────────────────────────────────────────────

  /// Watch all transactions, newest first.
  Stream<List<Transaction>> watchAll() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Watch transactions filtered by type.
  Stream<List<Transaction>> watchByType(String transactionType) {
    return (select(transactions)
          ..where((t) => t.transactionType.equals(transactionType))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Get transactions within a date range.
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Watch transactions for a specific date (daily summary).
  Stream<List<Transaction>> watchByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startOfDay) &
              t.date.isSmallerThanValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Get line items for a given transaction.
  Future<List<TransactionItem>> getItemsForTransaction(int transactionId) {
    return (select(transactionItems)
          ..where((t) => t.transactionId.equals(transactionId)))
        .get();
  }

  /// Watch today's total sales amount.
  Stream<double> watchTodaySalesTotal() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(transactions)
      ..where(transactions.transactionType.equals('sale_daily') &
          transactions.date.isBiggerOrEqualValue(startOfDay) &
          transactions.date.isSmallerThanValue(endOfDay))
      ..addColumns([transactions.totalAmount.sum()]);

    return query.watchSingle().map(
        (row) => row.read(transactions.totalAmount.sum()) ?? 0.0);
  }

  /// Sum total by type within date range.
  Future<double> totalByTypeAndDateRange(
      String type, DateTime start, DateTime end) async {
    final query = selectOnly(transactions)
      ..where(transactions.transactionType.equals(type) &
          transactions.date.isBiggerOrEqualValue(start) &
          transactions.date.isSmallerOrEqualValue(end))
      ..addColumns([transactions.totalAmount.sum()]);
    final row = await query.getSingle();
    return row.read(transactions.totalAmount.sum()) ?? 0.0;
  }

  /// Count transactions by type within date range.
  Future<int> countByTypeAndDateRange(
      String type, DateTime start, DateTime end) async {
    final count = transactions.id.count();
    final query = selectOnly(transactions)
      ..where(transactions.transactionType.equals(type) &
          transactions.date.isBiggerOrEqualValue(start) &
          transactions.date.isSmallerOrEqualValue(end))
      ..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Daily sales summary: returns (date, orderCount, grossSales) grouped by day.
  Future<List<DailySalesSummary>> dailySalesSummary(
      DateTime start, DateTime end) async {
    final txns = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('sale_daily') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    // Group by calendar date
    final Map<DateTime, DailySalesSummary> grouped = {};
    for (final txn in txns) {
      final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
      final existing = grouped[day];
      if (existing != null) {
        grouped[day] = DailySalesSummary(
          date: day,
          orderCount: existing.orderCount + 1,
          grossSales: existing.grossSales + txn.totalAmount,
        );
      } else {
        grouped[day] = DailySalesSummary(
          date: day,
          orderCount: 1,
          grossSales: txn.totalAmount,
        );
      }
    }

    final result = grouped.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Daily totals for chart: returns list of (dayIndex, totalAmount).
  Future<List<double>> dailyTotalsForChart(
      DateTime start, DateTime end) async {
    final days = end.difference(start).inDays + 1;
    final totals = List<double>.filled(days, 0.0);

    final txns = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('sale_daily') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get();

    for (final txn in txns) {
      final dayIndex = txn.date.difference(start).inDays;
      if (dayIndex >= 0 && dayIndex < days) {
        totals[dayIndex] += txn.totalAmount;
      }
    }

    return totals;
  }

  // ── Writes ─────────────────────────────────────────────────

  /// Insert a full transaction with its line items in a batch.
  ///
  /// Returns the generated transaction id.
  Future<int> insertFullTransaction({
    required TransactionsCompanion header,
    required List<TransactionItemsCompanion> items,
  }) async {
    return transaction(() async {
      final txnId = await into(transactions).insert(header);

      for (final item in items) {
        await into(transactionItems).insert(
          item.copyWith(transactionId: Value(txnId)),
        );
      }

      return txnId;
    });
  }

  /// Delete a transaction and all its line items.
  Future<void> deleteTransaction(int id) async {
    await transaction(() async {
      await (delete(transactionItems)
            ..where((t) => t.transactionId.equals(id)))
          .go();
      await (delete(transactions)..where((t) => t.id.equals(id))).go();
    });
  }
}

/// Simple data class for daily sales summary.
class DailySalesSummary {
  final DateTime date;
  final int orderCount;
  final double grossSales;

  const DailySalesSummary({
    required this.date,
    required this.orderCount,
    required this.grossSales,
  });
}
