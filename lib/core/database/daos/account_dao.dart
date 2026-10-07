/// DAO for [Accounts] table — CRUD, balance updates, type filtering.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase>
    with _$AccountDaoMixin {
  AccountDao(super.db);

  // ── Reads ──────────────────────────────────────────────────

  /// Watch all accounts ordered by name.
  Stream<List<Account>> watchAll() {
    return (select(accounts)
          ..orderBy([(t) => OrderingTerm.asc(t.accountName)]))
        .watch();
  }

  /// Get all accounts once.
  Future<List<Account>> getAll() {
    return (select(accounts)
          ..orderBy([(t) => OrderingTerm.asc(t.accountName)]))
        .get();
  }

  /// Watch accounts filtered by type ('asset' or 'liability').
  Stream<List<Account>> watchByType(String accountType) {
    return (select(accounts)
          ..where((t) => t.accountType.equals(accountType))
          ..orderBy([(t) => OrderingTerm.asc(t.accountName)]))
        .watch();
  }

  /// Get accounts filtered by type once.
  Future<List<Account>> getByType(String accountType) {
    return (select(accounts)
          ..where((t) => t.accountType.equals(accountType))
          ..orderBy([(t) => OrderingTerm.asc(t.accountName)]))
        .get();
  }

  /// Get a single account by id.
  Future<Account> getById(int id) {
    return (select(accounts)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Sum of balances by account type.
  Future<double> totalBalanceByType(String accountType) async {
    final query = selectOnly(accounts)
      ..where(accounts.accountType.equals(accountType))
      ..addColumns([accounts.balance.sum()]);
    final row = await query.getSingle();
    return row.read(accounts.balance.sum()) ?? 0.0;
  }

  // ── Writes ─────────────────────────────────────────────────

  /// Insert a new account and return the generated id.
  Future<int> insertAccount(AccountsCompanion entry) {
    return into(accounts).insert(entry);
  }

  /// Update an existing account.
  Future<bool> updateAccount(Account entry) {
    return update(accounts).replace(entry);
  }

  /// Delete an account by id.
  Future<int> deleteAccount(int id) {
    return (delete(accounts)..where((t) => t.id.equals(id))).go();
  }

  /// Adjust account balance by [delta].
  Future<void> adjustBalance(int accountId, double delta) async {
    final account = await getById(accountId);
    await (update(accounts)..where((t) => t.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(account.balance + delta),
      ),
    );
  }
}
