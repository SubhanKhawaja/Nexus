/// Nexus — Riverpod providers for the database layer.
///
/// Exposes [AppDatabase] as a singleton and each DAO as
/// a derived provider for dependency injection throughout the app.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/product_dao.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/cash_flow_dao.dart';

// ── Database Singleton ───────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ── DAO Providers ────────────────────────────────────────────
final productDaoProvider = Provider<ProductDao>((ref) {
  return ref.watch(databaseProvider).productDao;
});

final accountDaoProvider = Provider<AccountDao>((ref) {
  return ref.watch(databaseProvider).accountDao;
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return ref.watch(databaseProvider).transactionDao;
});

final cashFlowDaoProvider = Provider<CashFlowDao>((ref) {
  return ref.watch(databaseProvider).cashFlowDao;
});
