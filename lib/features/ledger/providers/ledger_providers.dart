/// Ledger — Riverpod providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/database/app_database.dart';

/// Total assets (receivables) balance.
final totalAssetsProvider = FutureProvider<double>((ref) {
  return ref.watch(accountDaoProvider).totalBalanceByType(AccountType.asset);
});

/// Total liabilities (payables) balance.
final totalLiabilitiesProvider = FutureProvider<double>((ref) {
  return ref
      .watch(accountDaoProvider)
      .totalBalanceByType(AccountType.liability);
});

/// All asset accounts.
final assetAccountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountDaoProvider).watchByType(AccountType.asset);
});

/// All liability accounts.
final liabilityAccountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountDaoProvider).watchByType(AccountType.liability);
});

/// Recent cash flows for ledger view.
final ledgerRecentCashFlowsProvider = StreamProvider<List<CashFlow>>((ref) {
  return ref.watch(cashFlowDaoProvider).watchRecent(limit: 20);
});
