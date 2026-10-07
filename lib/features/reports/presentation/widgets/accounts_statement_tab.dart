/// Reports — Accounts Statement tab.
///
/// Lists all accounts with type and balance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import 'package:intl/intl.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/features/reports/providers/reports_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';

class AccountsStatementTab extends ConsumerWidget {
  const AccountsStatementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsReportProvider);
    final currencyFmt = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);

    return accounts.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noAccountsCreated));
        }

        final assets =
            items.where((a) => a.accountType == AccountType.asset).toList();
        final liabilities =
            items.where((a) => a.accountType == AccountType.liability).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Assets Section ────────────────────────────
              Text('Assets (Sellers / Receivables)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  )),
              const SizedBox(height: 8),
              if (assets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No asset accounts.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textTertiaryFor(context))),
                )
              else
                ...assets.map((a) => Card(
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.success, size: 18),
                        ),
                        title: Text(a.accountName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(AccountType.label(a.accountType)),
                        trailing: Text(
                          currencyFmt.format(a.balance),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    )),

              const SizedBox(height: 24),

              // ── Liabilities Section ───────────────────────
              Text('Liabilities (Buyers / Payables)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  )),
              const SizedBox(height: 8),
              if (liabilities.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No liability accounts.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textTertiaryFor(context))),
                )
              else
                ...liabilities.map((a) => Card(
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.error, size: 18),
                        ),
                        title: Text(a.accountName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(AccountType.label(a.accountType)),
                        trailing: Text(
                          currencyFmt.format(a.balance),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
