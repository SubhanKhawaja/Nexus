/// Reports — Main screen with tabbed report views (Financial Reports).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/features/reports/providers/reports_providers.dart';
import '../widgets/stock_report_tab.dart';
import '../widgets/accounts_statement_tab.dart';
import '../widgets/sales_summary_tab.dart';
import '../widgets/income_expenses_tab.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String get _formattedRange {
    final range = ref.read(salesDateRangeProvider);
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final currentRange = ref.read(salesDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(salesDateRangeProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= kDesktopBreakpoint;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

    // Watch the range so the formatted label updates
    ref.watch(salesDateRangeProvider);

    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          title: Text(
            AppLocalizations.of(context)!.stats,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_outline_rounded,
                    color: AppColors.textSecondaryFor(context), size: 20),
              ),
              onPressed: () => context.push('/settings'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24 : 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.financialReports,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.reviewPerformanceMetrics,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryFor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker Button
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _pickDateRange,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondaryFor(context)),
                            const SizedBox(width: 8),
                            Text(
                              _formattedRange,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondaryFor(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryFor(context),
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.inventoryReports),
                Tab(text: AppLocalizations.of(context)!.salesReports),
                Tab(text: AppLocalizations.of(context)!.accounts),
                Tab(text: AppLocalizations.of(context)!.incomeExpense),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 12,
                  vertical: 12,
                ),
                child: const TabBarView(
                  children: [
                    StockReportTab(),
                    SalesSummaryTab(),
                    AccountsStatementTab(),
                    IncomeExpensesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



