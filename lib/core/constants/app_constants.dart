/// App-wide constants for Nexus POS & Accounting.
library;

/// Breakpoint at which the layout switches from mobile → desktop.
const double kDesktopBreakpoint = 900.0;

/// Default tax rate applied to POS transactions (8%).
const double kDefaultTaxRate = 0.08;

/// Application name.
const String kAppName = 'Nexus';

/// Low-stock threshold — products at or below this quantity trigger alerts.
const int kLowStockThreshold = 5;

// ── Transaction type identifiers ────────────────────────────
abstract final class TransactionType {
  static const String saleDaily = 'sale_daily';
  static const String salesReturn = 'sales_return';
  static const String dailyPurchase = 'daily_purchase';
  static const String purchaseReturn = 'purchase_return';

  static const List<String> all = [
    saleDaily,
    salesReturn,
    dailyPurchase,
    purchaseReturn,
  ];

  static String label(String type) => switch (type) {
        saleDaily => 'Sale Daily',
        salesReturn => 'Sales Return',
        dailyPurchase => 'Daily Purchase',
        purchaseReturn => 'Purchase Return',
        _ => type,
      };
}

// ── Account type identifiers ────────────────────────────────
abstract final class AccountType {
  static const String asset = 'asset';
  static const String liability = 'liability';

  static String label(String type) => switch (type) {
        asset => 'Asset (Seller)',
        liability => 'Liability (Buyer)',
        _ => type,
      };
}

// ── Cash flow type identifiers ──────────────────────────────
abstract final class CashFlowType {
  static const String received = 'cash_received';
  static const String paid = 'cash_paid';

  static String label(String type) => switch (type) {
        received => 'Cash Received',
        paid => 'Cash Paid',
        _ => type,
      };
}
