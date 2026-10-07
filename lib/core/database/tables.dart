/// Nexus POS & Accounting — Drift table definitions.
///
/// Defines the 5 core relational tables for the double-entry
/// accounting and POS system.
library;

import 'package:drift/drift.dart';

// ──────────────────────────────────────────────────────────────
// Products — Product catalog with stock tracking
// ──────────────────────────────────────────────────────────────
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withDefault(const Constant('General'))();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  RealColumn get purchaseRate => real()();
  RealColumn get sellingPrice => real()();
}

// ──────────────────────────────────────────────────────────────
// Accounts — Seller (Asset) / Buyer (Liability) accounts
// ──────────────────────────────────────────────────────────────
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountName => text().withLength(min: 1, max: 255)();
  /// 'asset' for sellers (receivables), 'liability' for buyers (payables)
  TextColumn get accountType => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
}

// ──────────────────────────────────────────────────────────────
// Transactions — Sale / Purchase header records
// ──────────────────────────────────────────────────────────────
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// One of: 'sale_daily', 'sales_return', 'daily_purchase', 'purchase_return'
  TextColumn get transactionType => text()();

  DateTimeColumn get date => dateTime()();
  RealColumn get totalAmount => real()();
  IntColumn get linkedAccountId =>
      integer().nullable().references(Accounts, #id)();
}

// ──────────────────────────────────────────────────────────────
// TransactionItems — Line items per transaction
// ──────────────────────────────────────────────────────────────
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
}

// ──────────────────────────────────────────────────────────────
// CashFlows — Cash movement ledger
// ──────────────────────────────────────────────────────────────
class CashFlows extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'cash_received' or 'cash_paid'
  TextColumn get flowType => text()();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  IntColumn get linkedAccountId =>
      integer().nullable().references(Accounts, #id)();
}
