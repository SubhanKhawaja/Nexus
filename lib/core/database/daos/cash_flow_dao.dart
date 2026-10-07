/// DAO for [CashFlows] table — cash movement recording & querying.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'cash_flow_dao.g.dart';

@DriftAccessor(tables: [CashFlows, Accounts])
class CashFlowDao extends DatabaseAccessor<AppDatabase>
    with _$CashFlowDaoMixin {
  CashFlowDao(super.db);

  // ── Reads ──────────────────────────────────────────────────

  /// Watch all cash flows, newest first.
  Stream<List<CashFlow>> watchAll() {
    return (select(cashFlows)..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Watch recent cash flows (limited).
  Stream<List<CashFlow>> watchRecent({int limit = 20}) {
    return (select(cashFlows)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  /// Watch cash flows filtered by flow type.
  Stream<List<CashFlow>> watchByType(String flowType) {
    return (select(cashFlows)
          ..where((t) => t.flowType.equals(flowType))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Watch cash flows for a specific account.
  Stream<List<CashFlow>> watchByAccount(int accountId) {
    return (select(cashFlows)
          ..where((t) => t.linkedAccountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Sum of cash received today.
  Stream<double> watchTodayCashReceived() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(cashFlows)
      ..where(cashFlows.flowType.equals('cash_received') &
          cashFlows.date.isBiggerOrEqualValue(startOfDay) &
          cashFlows.date.isSmallerThanValue(endOfDay))
      ..addColumns([cashFlows.amount.sum()]);

    return query
        .watchSingle()
        .map((row) => row.read(cashFlows.amount.sum()) ?? 0.0);
  }

  /// Sum of cash paid today.
  Stream<double> watchTodayCashPaid() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(cashFlows)
      ..where(cashFlows.flowType.equals('cash_paid') &
          cashFlows.date.isBiggerOrEqualValue(startOfDay) &
          cashFlows.date.isSmallerThanValue(endOfDay))
      ..addColumns([cashFlows.amount.sum()]);

    return query
        .watchSingle()
        .map((row) => row.read(cashFlows.amount.sum()) ?? 0.0);
  }

  /// Get cash flows in a date range.
  Future<List<CashFlow>> getByDateRange(DateTime start, DateTime end) {
    return (select(cashFlows)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // ── Writes ─────────────────────────────────────────────────

  /// Record a new cash flow entry.
  Future<int> insertCashFlow(CashFlowsCompanion entry) {
    return into(cashFlows).insert(entry);
  }

  /// Delete a cash flow entry.
  Future<int> deleteCashFlow(int id) {
    return (delete(cashFlows)..where((t) => t.id.equals(id))).go();
  }
}
