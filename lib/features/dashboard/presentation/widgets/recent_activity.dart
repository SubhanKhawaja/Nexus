/// Dashboard — Recent Activity widget.
///
/// Displays a scrollable list of recent cash flow entries
/// with type badges and formatted amounts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/dashboard/providers/dashboard_providers.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFlows = ref.watch(recentCashFlowsProvider);
    final theme = Theme.of(context);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final timeFmt = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Activity list ───────────────────────────────────
        recentFlows.when(
          data: (flows) {
            if (flows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 48, color: AppColors.textTertiaryFor(context)),
                      const SizedBox(height: 8),
                      Text(
                        'No recent activity',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: flows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final flow = flows[index];
                final isReceived = flow.flowType == CashFlowType.received;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isReceived
                          ? AppColors.cashReceivedBgFor(context)
                          : AppColors.cashPaidBgFor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isReceived
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isReceived
                          ? AppColors.cashReceived
                          : AppColors.cashPaid,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    flow.description ?? CashFlowType.label(flow.flowType),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isReceived
                              ? AppColors.cashReceivedBg
                              : AppColors.cashPaidBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          CashFlowType.label(flow.flowType),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isReceived
                                ? AppColors.cashReceived
                                : AppColors.cashPaid,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isReceived ? '+' : '-'}${currencyFmt.format(flow.amount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isReceived
                              ? AppColors.cashReceived
                              : AppColors.cashPaid,
                        ),
                      ),
                      Text(
                        timeFmt.format(flow.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryFor(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $e'),
          ),
        ),
      ],
    );
  }
}
