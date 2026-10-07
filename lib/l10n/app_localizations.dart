import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// App title / workspace name
  ///
  /// In en, this message translates to:
  /// **'ERP Workspace'**
  String get erpWorkspace;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'DATA MANAGEMENT'**
  String get dataManagement;

  /// No description provided for @cloudSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Status'**
  String get cloudSyncStatus;

  /// No description provided for @syncedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncedJustNow;

  /// No description provided for @forceSync.
  ///
  /// In en, this message translates to:
  /// **'Force Sync'**
  String get forceSync;

  /// No description provided for @exportLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Local Backup'**
  String get exportLocalBackup;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @welcomeToNexus.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nexus'**
  String get welcomeToNexus;

  /// No description provided for @signInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your ERP Workspace'**
  String get signInToAccess;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your business overview for today.'**
  String get businessOverview;

  /// No description provided for @todaysSales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaysSales;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @ledgerAndAccounts.
  ///
  /// In en, this message translates to:
  /// **'Ledger & Accounts'**
  String get ledgerAndAccounts;

  /// No description provided for @overviewOfCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Overview of your cash flow and balances.'**
  String get overviewOfCashFlow;

  /// No description provided for @assetsReceivables.
  ///
  /// In en, this message translates to:
  /// **'Assets (Receivables)'**
  String get assetsReceivables;

  /// No description provided for @totalUncollectedFunds.
  ///
  /// In en, this message translates to:
  /// **'Total uncollected funds'**
  String get totalUncollectedFunds;

  /// No description provided for @liabilitiesPayables.
  ///
  /// In en, this message translates to:
  /// **'Liabilities (Payables)'**
  String get liabilitiesPayables;

  /// No description provided for @totalUpcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'Total upcoming payments'**
  String get totalUpcomingPayments;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noCashFlowEntries.
  ///
  /// In en, this message translates to:
  /// **'No cash flow entries yet'**
  String get noCashFlowEntries;

  /// No description provided for @cashReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash Received'**
  String get cashReceived;

  /// No description provided for @cashPaid.
  ///
  /// In en, this message translates to:
  /// **'Cash Paid'**
  String get cashPaid;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @recordCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Record Cash Flow'**
  String get recordCashFlow;

  /// No description provided for @financialReports.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReports;

  /// No description provided for @reviewPerformanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'Review your latest performance metrics.'**
  String get reviewPerformanceMetrics;

  /// No description provided for @inventoryReports.
  ///
  /// In en, this message translates to:
  /// **'Inventory Reports'**
  String get inventoryReports;

  /// No description provided for @salesReports.
  ///
  /// In en, this message translates to:
  /// **'Sales Reports'**
  String get salesReports;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @incomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Income/Expense'**
  String get incomeExpense;

  /// No description provided for @noProductsInInventory.
  ///
  /// In en, this message translates to:
  /// **'No products in inventory.'**
  String get noProductsInInventory;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @stockQty.
  ///
  /// In en, this message translates to:
  /// **'Stock Qty'**
  String get stockQty;

  /// No description provided for @purchaseRate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Rate'**
  String get purchaseRate;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @noAccountsCreated.
  ///
  /// In en, this message translates to:
  /// **'No accounts created yet.'**
  String get noAccountsCreated;

  /// No description provided for @pointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get pointOfSale;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @transactionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction completed!'**
  String get transactionCompleted;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @allStock.
  ///
  /// In en, this message translates to:
  /// **'All Stock'**
  String get allStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
