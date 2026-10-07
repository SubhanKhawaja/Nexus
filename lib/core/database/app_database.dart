/// Nexus — Main Drift database class.
///
/// Central database definition that registers all tables and DAOs.
/// Uses [driftDatabase] from `drift_flutter` for cross-platform
/// SQLite opening (Android, iOS, Windows, macOS, Linux).
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
import 'daos/product_dao.dart';
import 'daos/account_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/cash_flow_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Accounts,
    Transactions,
    TransactionItems,
    CashFlows,
  ],
  daos: [
    ProductDao,
    AccountDao,
    TransactionDao,
    CashFlowDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'nexus_db'));

  /// Exposed for testing — inject a custom [QueryExecutor].
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
