/// Ledger — Cash flow tile widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/database/app_database.dart';

class CashFlowTile extends ConsumerWidget {
  final CashFlow flow;

  const CashFlowTile({super.key, required this.flow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final dateFmt = DateFormat('MMM dd, hh:mm a');
    final isReceived = flow.flowType == CashFlowType.received;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ──────────────────────────────────────────
          Container(
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
              color: isReceived ? AppColors.cashReceived : AppColors.cashPaid,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // ── Details ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flow.description ?? CashFlowType.label(flow.flowType),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryFor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateFmt.format(flow.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryFor(context),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isReceived
                        ? AppColors.cashReceivedBgFor(context)
                        : AppColors.cashPaidBgFor(context),
                    borderRadius: BorderRadius.circular(6),
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
          ),

          // ── Amount ────────────────────────────────────────
          Text(
            '${isReceived ? '+' : '-'}${currencyFmt.format(flow.amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isReceived ? AppColors.cashReceived : AppColors.cashPaid,
            ),
          ),
        ],
      ),
    );
  }
}
