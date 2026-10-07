/// Ledger — Main screen.
///
/// Shows Assets (Receivables) and Liabilities (Payables) summary
/// cards, plus recent cash flow entries.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/constants/app_constants.dart';
import 'package:nexus/core/providers/database_provider.dart';
import 'package:nexus/core/database/app_database.dart';
import 'package:nexus/features/ledger/providers/ledger_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/widgets/user_avatar.dart';
import 'package:nexus/core/providers/currency_provider.dart';
import '../widgets/account_summary_card.dart';
import '../widgets/cash_flow_tile.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAssets = ref.watch(totalAssetsProvider);
    final totalLiabilities = ref.watch(totalLiabilitiesProvider);
    final recentFlows = ref.watch(ledgerRecentCashFlowsProvider);
    final isWide = MediaQuery.of(context).size.width >= kDesktopBreakpoint;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.ledgerAndAccounts),
        actions: [
          IconButton(
            icon: const UserAvatar(radius: 16),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 32 : 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Subtitle ──────────────────────────────────────
            Text(
              AppLocalizations.of(context)!.overviewOfCashFlow,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary Cards ─────────────────────────────────
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: totalAssets.when(
                      data: (v) => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.assetsReceivables,
                        subtitle: AppLocalizations.of(context)!.totalUncollectedFunds,
                        totalBalance: v,
                        accentColor: AppColors.success,
                        icon: Icons.account_balance_rounded,
                      ),
                      loading: () => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.assetsReceivables,
                        subtitle: '...',
                        totalBalance: 0,
                        accentColor: AppColors.success,
                        icon: Icons.account_balance_rounded,
                      ),
                      error: (_, __) => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.assetsReceivables,
                        subtitle: 'Error',
                        totalBalance: 0,
                        accentColor: AppColors.success,
                        icon: Icons.account_balance_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: totalLiabilities.when(
                      data: (v) => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.liabilitiesPayables,
                        subtitle: AppLocalizations.of(context)!.totalUpcomingPayments,
                        totalBalance: v,
                        accentColor: AppColors.error,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      loading: () => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.liabilitiesPayables,
                        subtitle: '...',
                        totalBalance: 0,
                        accentColor: AppColors.error,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      error: (_, __) => AccountSummaryCard(
                        title: AppLocalizations.of(context)!.liabilitiesPayables,
                        subtitle: 'Error',
                        totalBalance: 0,
                        accentColor: AppColors.error,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              totalAssets.when(
                data: (v) => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.assetsReceivables,
                  subtitle: AppLocalizations.of(context)!.totalUncollectedFunds,
                  totalBalance: v,
                  accentColor: AppColors.success,
                  icon: Icons.account_balance_rounded,
                ),
                loading: () => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.assetsReceivables,
                  subtitle: '...',
                  totalBalance: 0,
                  accentColor: AppColors.success,
                  icon: Icons.account_balance_rounded,
                ),
                error: (_, __) => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.assetsReceivables,
                  subtitle: 'Error',
                  totalBalance: 0,
                  accentColor: AppColors.success,
                  icon: Icons.account_balance_rounded,
                ),
              ),
              totalLiabilities.when(
                data: (v) => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.liabilitiesPayables,
                  subtitle: AppLocalizations.of(context)!.totalUpcomingPayments,
                  totalBalance: v,
                  accentColor: AppColors.error,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                loading: () => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.liabilitiesPayables,
                  subtitle: '...',
                  totalBalance: 0,
                  accentColor: AppColors.error,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                error: (_, __) => AccountSummaryCard(
                  title: AppLocalizations.of(context)!.liabilitiesPayables,
                  subtitle: 'Error',
                  totalBalance: 0,
                  accentColor: AppColors.error,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Recent Cash Flow ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.recentActivity,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            recentFlows.when(
              data: (flows) {
                if (flows.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 48, color: AppColors.textTertiaryFor(context)),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.noCashFlowEntries,
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
                  itemBuilder: (context, index) =>
                      CashFlowTile(flow: flows[index]),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── FAB to add cash flow ─────────────────────────────
      floatingActionButton: FloatingActionButton(
        heroTag: 'ledger_fab',
        onPressed: () => _showAddCashFlowDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCashFlowDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddCashFlowDialog(),
    );
  }
}

// ── Add Cash Flow Dialog ────────────────────────────────────
class _AddCashFlowDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddCashFlowDialog> createState() =>
      _AddCashFlowDialogState();
}

class _AddCashFlowDialogState extends ConsumerState<_AddCashFlowDialog> {
  String _flowType = CashFlowType.received;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    await ref.read(cashFlowDaoProvider).insertCashFlow(
          CashFlowsCompanion.insert(
            flowType: _flowType,
            amount: amount,
            date: DateTime.now(),
            description: Value(_descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim()),
          ),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final String currencySymbol = switch (currency) {
      'PKR' => 'Rs. ',
      'EUR' => '€ ',
      'GBP' => '£ ',
      _ => '\$ ',
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.recordCashFlow,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppLocalizations.of(context)!.cashReceived),
                      ),
                      selected: _flowType == CashFlowType.received,
                      onSelected: (_) =>
                          setState(() => _flowType = CashFlowType.received),
                      selectedColor: AppColors.success,
                      labelStyle: TextStyle(
                        color: _flowType == CashFlowType.received
                            ? Colors.white
                            : AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      showCheckmark: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppLocalizations.of(context)!.cashPaid),
                      ),
                      selected: _flowType == CashFlowType.paid,
                      onSelected: (_) =>
                          setState(() => _flowType = CashFlowType.paid),
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(
                        color: _flowType == CashFlowType.paid
                            ? Colors.white
                            : AppColors.textPrimaryFor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      showCheckmark: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  prefixText: currencySymbol,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.descriptionOptional,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(AppLocalizations.of(context)!.record),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
