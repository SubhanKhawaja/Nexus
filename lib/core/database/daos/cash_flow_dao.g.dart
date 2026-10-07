// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_flow_dao.dart';

// ignore_for_file: type=lint
mixin _$CashFlowDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CashFlowsTable get cashFlows => attachedDatabase.cashFlows;
  CashFlowDaoManager get managers => CashFlowDaoManager(this);
}

class CashFlowDaoManager {
  final _$CashFlowDaoMixin _db;
  CashFlowDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CashFlowsTableTableManager get cashFlows =>
      $$CashFlowsTableTableManager(_db.attachedDatabase, _db.cashFlows);
}
