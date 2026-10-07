/// Dashboard — Main screen.
///
/// Shows today's sales, cash flow summary, low stock alerts,
/// quick actions, and recent activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/dashboard/providers/dashboard_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/widgets/user_avatar.dart';

import '../widgets/summary_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final todaySales = ref.watch(todaySalesProvider);
    final cashIn = ref.watch(todayCashReceivedProvider);
    final cashOut = ref.watch(todayCashPaidProvider);
    final lowStock = ref.watch(lowStockProductsProvider);
    final salesChange = ref.watch(salesChangeProvider);
    final isWide = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        actions: [
          IconButton(
            icon: const UserAvatar(radius: 16),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaySalesProvider);
          ref.invalidate(todayCashReceivedProvider);
          ref.invalidate(todayCashPaidProvider);
          ref.invalidate(lowStockProductsProvider);
          ref.invalidate(recentCashFlowsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 16,
          ),
          child: isWide
              ? _DesktopDashboard(
                  currencyFmt: currencyFmt,
                  todaySales: todaySales,
                  cashIn: cashIn,
                  cashOut: cashOut,
                  lowStock: lowStock,
                  salesChange: salesChange,
                )
              : _MobileDashboard(
                  currencyFmt: currencyFmt,
                  todaySales: todaySales,
                  cashIn: cashIn,
                  cashOut: cashOut,
                  lowStock: lowStock,
                  salesChange: salesChange,
                ),
        ),
      ),
    );
  }
}

// ── Mobile Dashboard ─────────────────────────────────────────
class _MobileDashboard extends ConsumerWidget {
  final NumberFormat currencyFmt;
  final AsyncValue<double> todaySales;
  final AsyncValue<double> cashIn;
  final AsyncValue<double> cashOut;
  final AsyncValue<List<dynamic>> lowStock;
  final double? salesChange;

  const _MobileDashboard({
    required this.currencyFmt,
    required this.todaySales,
    required this.cashIn,
    required this.cashOut,
    required this.lowStock,
    this.salesChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Greeting ─────────────────────────────────────────
        Text(
          '$greeting!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.businessOverview,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        const SizedBox(height: 20),

        // ── Today's Sales ────────────────────────────────────
        SummaryCard(
          title: AppLocalizations.of(context)!.todaysSales,
          value: todaySales.when(
            data: (v) => currencyFmt.format(v),
            loading: () => '...',
            error: (_, __) => '--',
          ),
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
          badge: salesChange != null
              ? '${salesChange! >= 0 ? '+' : ''}${salesChange!.toStringAsFixed(1)}%'
              : null,
          badgeColor: salesChange != null && salesChange! < 0
              ? AppColors.error
              : AppColors.success,
          subtitle: 'vs yesterday',
        ),

        // ── Cash Flow ────────────────────────────────────────
        _CashFlowCard(
          cashIn: cashIn,
          cashOut: cashOut,
          currencyFmt: currencyFmt,
        ),

        // ── Low Stock Alert ──────────────────────────────────
        lowStock.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Card(
              color: AppColors.warningLightFor(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Low Stock Alerts',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.warning_amber_rounded,
                                  color: AppColors.warning, size: 18),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${items.length} Items',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryFor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Require immediate reorder',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/inventory'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                      ),
                      child: const Text('View List'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 20),

        // ── Quick Actions ────────────────────────────────────
        const QuickActions(),
        const SizedBox(height: 24),

        // ── Recent Activity ──────────────────────────────────
        const RecentActivity(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Desktop Dashboard ────────────────────────────────────────
class _DesktopDashboard extends ConsumerWidget {
  final NumberFormat currencyFmt;
  final AsyncValue<double> todaySales;
  final AsyncValue<double> cashIn;
  final AsyncValue<double> cashOut;
  final AsyncValue<List<dynamic>> lowStock;
  final double? salesChange;

  const _DesktopDashboard({
    required this.currencyFmt,
    required this.todaySales,
    required this.cashIn,
    required this.cashOut,
    required this.lowStock,
    this.salesChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's your business overview for today.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        const SizedBox(height: 24),

        // ── Top cards row ────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SummaryCard(
                title: "Today's Sales",
                value: todaySales.when(
                  data: (v) => currencyFmt.format(v),
                  loading: () => '...',
                  error: (_, __) => '--',
                ),
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                badge: salesChange != null
                    ? '${salesChange! >= 0 ? '+' : ''}${salesChange!.toStringAsFixed(1)}%'
                    : null,
                badgeColor: salesChange != null && salesChange! < 0
                    ? AppColors.error
                    : AppColors.success,
                subtitle: 'vs yesterday',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CashFlowCard(
                cashIn: cashIn,
                cashOut: cashOut,
                currencyFmt: currencyFmt,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: lowStock.when(
                data: (items) => SummaryCard(
                  title: 'Low Stock',
                  value: '${items.length} Items',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warning,
                  subtitle: 'Require reorder',
                  onTap: () => context.go('/inventory'),
                ),
                loading: () => const SummaryCard(
                    title: 'Low Stock', value: '...'),
                error: (_, __) => const SummaryCard(
                    title: 'Low Stock', value: '--'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Bottom section ───────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            const Expanded(flex: 1, child: QuickActions()),
            const SizedBox(width: 24),
            // Recent Activity
            const Expanded(flex: 2, child: RecentActivity()),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Cash Flow Card ───────────────────────────────────────────
class _CashFlowCard extends ConsumerWidget {
  final AsyncValue<double> cashIn;
  final AsyncValue<double> cashOut;
  final NumberFormat currencyFmt;

  const _CashFlowCard({
    required this.cashIn,
    required this.cashOut,
    required this.currencyFmt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cash Flow (Net)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryFor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('In',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textTertiaryFor(context))),
                    const SizedBox(height: 2),
                    Text(
                      cashIn.when(
                        data: (v) => currencyFmt.format(v),
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Out',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textTertiaryFor(context))),
                    const SizedBox(height: 2),
                    Text(
                      cashOut.when(
                        data: (v) => currencyFmt.format(v),
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper ───────────────────────────────────────────────────
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
